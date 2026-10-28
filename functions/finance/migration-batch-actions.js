"use strict";

const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {z} = require("zod");
const {validId} = require("../validation");
const {currencyPrecision} = require("./money");
const {readSources, source, canonical, migrateDecision, excludeDecision,
  digest, assertOwner, reviewedExpense} = require("./migration-actions");

const MAX_BATCH_SOURCES = 1000;
const STAGE_SIZE = 100;
const requestId = z.string().regex(/^[A-Za-z0-9_-]{16,128}$/);
const location = {
  source: z.enum(["embedded", "nested", "top"]),
  sourceRecordId: z.string().min(1).max(500),
};
const stageSchema = z.object({
  tripId: z.string(), requestId, expectedRevision: z.number().int().positive(),
  currencyCode: z.string().regex(/^[A-Z]{3}$/),
  sourceCount: z.number().int().min(201).max(MAX_BATCH_SOURCES),
  decisions: z.array(z.discriminatedUnion("action", [
    migrateDecision.extend(location), excludeDecision.extend(location),
  ])).min(1).max(STAGE_SIZE),
}).strict();
const finishSchema = z.object({
  tripId: z.string(), requestId, expectedRevision: z.number().int().positive(),
}).strict();

function parse(schema, request) {
  const uid = request.auth?.uid;
  if (!validId(uid)) throw new HttpsError("unauthenticated", "Sign in required.");
  const parsed = schema.safeParse(request.data);
  if (!parsed.success || !validId(parsed.data.tripId)) {
    throw new HttpsError("invalid-argument", "Invalid migration batch.");
  }
  return {uid, data: parsed.data};
}

function expenseFingerprint(expense) {
  const stable = Object.fromEntries(Object.entries(expense)
      .filter(([key]) => key !== "createdAt" && key !== "updatedAt"));
  return digest(JSON.stringify(canonical(stable)));
}

async function originalFor(tx, db, tripRef, trip, decision) {
  const id = decision.sourceRecordId;
  let raw;
  if (decision.source === "embedded") {
    if (!/^(0|[1-9][0-9]*)$/.test(id)) {
      throw new HttpsError("invalid-argument", "Invalid embedded source index.");
    }
    const embedded = Array.isArray(trip.expenses) ? trip.expenses :
      trip.expenses == null ? [] : [trip.expenses];
    raw = embedded[Number(id)];
    if (raw === undefined) {
      throw new HttpsError("failed-precondition", "A source record changed. Reload review.");
    }
  } else {
    if (!validId(id)) throw new HttpsError("invalid-argument", "Invalid source ID.");
    const ref = decision.source === "nested" ?
      tripRef.collection("expenses").doc(id) : db.collection("expense").doc(id);
    const snapshot = await tx.get(ref);
    if (!snapshot.exists || (decision.source === "top" &&
        snapshot.data().tripId !== tripRef.id)) {
      throw new HttpsError("failed-precondition", "A source record changed. Reload review.");
    }
    raw = snapshot.data();
  }
  const original = source(decision.source, id, raw);
  if (original.sourceId !== decision.sourceId ||
      original.rawDigest !== decision.rawDigest) {
    throw new HttpsError("failed-precondition", "A source record changed. Reload review.");
  }
  return original;
}

function createBatchMigrationHandlers(db, log = () => {}) {
  return {
    async stage(request) {
      const {uid, data} = parse(stageSchema, request);
      let precision;
      try { precision = currencyPrecision(data.currencyCode); } catch {
        throw new HttpsError("invalid-argument", "Choose a supported currency.");
      }
      if (new Set(data.decisions.map((item) => item.sourceId)).size !==
          data.decisions.length) {
        throw new HttpsError("invalid-argument", "Duplicate source decision.");
      }
      const tripRef = db.doc(`trips/${data.tripId}`);
      const planRef = tripRef.collection("financeMigrationPlans").doc("current");
      const result = await db.runTransaction(async (tx) => {
        const [tripDoc, planDoc] = await Promise.all([tx.get(tripRef), tx.get(planRef)]);
        const trip = tripDoc.data();
        await assertOwner(db, trip, uid, (ref) => tx.get(ref));
        if (trip.financeMigrationStatus !== "reviewing" ||
            trip.financeMigrationRevision !== data.expectedRevision ||
            trip.financeSchemaVersion === 2 || trip.financeCurrency != null) {
          throw new HttpsError("failed-precondition", "Review changed. Reload before approval.");
        }
        const plan = planDoc.data();
        if (plan && (plan.status !== "staging" ||
            plan.requestId !== data.requestId ||
            plan.currencyCode !== data.currencyCode ||
            plan.sourceCount !== data.sourceCount ||
            trip.financeMigrationPlanId !== data.requestId)) {
          throw new HttpsError("failed-precondition", "Another review plan is active.");
        }
        if (!plan && trip.financeMigrationPlanId != null) {
          throw new HttpsError("failed-precondition", "Review plan needs support recovery.");
        }

        let allowed;
        if (plan) {
          allowed = new Set(plan.allowedTravelerIds);
        } else {
          const [sources, members, v2, transfers, provenance] = await Promise.all([
            readSources(db, data.tripId, trip, (query) => tx.get(query), MAX_BATCH_SOURCES),
            tx.get(tripRef.collection("members").limit(501)),
            tx.get(tripRef.collection("financeExpenses").limit(1)),
            tx.get(tripRef.collection("financeTransfers").limit(1)),
            tx.get(tripRef.collection("financeMigrationSources").limit(1)),
          ]);
          if (sources.length !== data.sourceCount || members.size > 500 ||
              !v2.empty || !transfers.empty || !provenance.empty) {
            throw new HttpsError("failed-precondition", "Finance sources changed. Reload review.");
          }
          allowed = new Set([uid,
            ...(Array.isArray(trip.joinedUsers) ? trip.joinedUsers : []),
            ...members.docs.map((doc) => doc.data().userId || doc.id),
            ...sources.flatMap((item) => item.unverifiedTravelerHints)]);
          if (allowed.size > 500 || [...allowed].some((id) => !validId(id))) {
            throw new HttpsError("resource-exhausted", "Too many historical travelers for review.");
          }
        }

        const originals = await Promise.all(data.decisions.map((item) =>
          originalFor(tx, db, tripRef, trip, item)));
        const refs = data.decisions.map((item) => ({
          provenance: tripRef.collection("financeMigrationSources").doc(item.sourceId),
          expense: tripRef.collection("financeExpenses")
              .doc(`migrated_${item.sourceId.slice(0, 40)}`),
        }));
        const existing = await Promise.all(refs.map(async (ref) => ({
          provenance: await tx.get(ref.provenance),
          expense: await tx.get(ref.expense),
        })));
        let added = 0;
        let migrated = 0;
        const writes = [];
        for (const [index, decision] of data.decisions.entries()) {
          const fingerprint = digest(JSON.stringify(canonical(decision)));
          const prior = existing[index].provenance.data();
          if (prior) {
            if (prior.migrationPlanId !== data.requestId ||
                prior.decisionFingerprint !== fingerprint ||
                (decision.action === "migrate") !== existing[index].expense.exists) {
              throw new HttpsError("failed-precondition", "A staged decision changed. Restart review.");
            }
            continue;
          }
          if (existing[index].expense.exists) {
            throw new HttpsError("failed-precondition", "An expense already uses this source.");
          }
          const original = originals[index];
          const expense = decision.action === "migrate" ? reviewedExpense(
              data, decision, original, uid, precision, allowed) : null;
          const stagedExpense = expense ? {...expense,
            migrationPlanId: data.requestId} : null;
          const record = {sourceId: original.sourceId,
            source: original.source, sourceRecordId: original.sourceRecordId,
            rawDigest: original.rawDigest, action: decision.action,
            migrationPlanId: data.requestId, decisionFingerprint: fingerprint,
            reviewedBy: uid, reviewedAt: FieldValue.serverTimestamp(),
            ...(stagedExpense ? {expenseId: stagedExpense.id,
              expenseFingerprint: expenseFingerprint(stagedExpense)} :
              {reason: decision.reason, note: decision.note || ""})};
          writes.push({ref: refs[index], record, expense: stagedExpense});
          added++;
          if (expense) migrated++;
        }
        if (!plan) {
          tx.create(planRef, {requestId: data.requestId, status: "staging",
            currencyCode: data.currencyCode, precision, sourceCount: data.sourceCount,
            allowedTravelerIds: [...allowed].sort(), stagedCount: added,
            migratedCount: migrated, startedBy: uid,
            startedAt: FieldValue.serverTimestamp()});
          tx.update(tripRef, {financeMigrationPlanId: data.requestId});
        }
        for (const item of writes) {
          tx.create(item.ref.provenance, item.record);
          if (item.expense) {
            tx.create(item.ref.expense, item.expense);
          }
        }
        if (plan && added) {
          tx.update(planRef, {stagedCount: (plan?.stagedCount || 0) + added,
            migratedCount: (plan?.migratedCount || 0) + migrated,
            updatedAt: FieldValue.serverTimestamp()});
        }
        return {status: "staging", stagedCount: (plan?.stagedCount || 0) + added,
          sourceCount: data.sourceCount, replayed: added === 0};
      });
      log("finance_migration_batch_staged", {tripId: data.tripId,
        stagedCount: result.stagedCount, replayed: result.replayed});
      return result;
    },

    async finish(request) {
      const {uid, data} = parse(finishSchema, request);
      const tripRef = db.doc(`trips/${data.tripId}`);
      const planRef = tripRef.collection("financeMigrationPlans").doc("current");
      const result = await db.runTransaction(async (tx) => {
        const [tripDoc, planDoc] = await Promise.all([tx.get(tripRef), tx.get(planRef)]);
        const trip = tripDoc.data();
        await assertOwner(db, trip, uid, (ref) => tx.get(ref));
        if (trip.financeMigrationStatus === "completed" &&
            trip.financeMigrationCommitId === data.requestId) {
          return {status: "completed", migratedCount: trip.financeMigrationMigratedCount,
            revision: trip.financeMigrationRevision, replayed: true};
        }
        const plan = planDoc.data();
        if (trip.financeMigrationStatus !== "reviewing" ||
            trip.financeMigrationRevision !== data.expectedRevision ||
            trip.financeMigrationPlanId !== data.requestId ||
            !plan || plan.status !== "staging" ||
            plan.requestId !== data.requestId ||
            plan.stagedCount !== plan.sourceCount) {
          throw new HttpsError("failed-precondition", "Review is incomplete or changed.");
        }
        const [sources, provenance, expenses] = await Promise.all([
          readSources(db, data.tripId, trip, (query) => tx.get(query), MAX_BATCH_SOURCES),
          tx.get(tripRef.collection("financeMigrationSources").limit(MAX_BATCH_SOURCES + 1)),
          tx.get(tripRef.collection("financeExpenses").limit(MAX_BATCH_SOURCES + 1)),
        ]);
        if (sources.length !== plan.sourceCount ||
            provenance.size !== sources.length ||
            expenses.size !== plan.migratedCount) {
          throw new HttpsError("failed-precondition", "Staged ledger is incomplete.");
        }
        const bySource = new Map(sources.map((item) => [item.sourceId, item]));
        const expenseBySource = new Map(expenses.docs.map((doc) =>
          [doc.data().migrationSourceId, doc]));
        if (bySource.size !== sources.length ||
            expenseBySource.size !== expenses.size) {
          throw new HttpsError("failed-precondition", "Staged ledger has duplicate sources.");
        }
        for (const doc of provenance.docs) {
          const record = doc.data();
          const original = bySource.get(doc.id);
          const expense = expenseBySource.get(doc.id);
          if (!original || record.sourceId !== doc.id ||
              record.rawDigest !== original.rawDigest ||
              record.migrationPlanId !== data.requestId ||
              !["migrate", "exclude"].includes(record.action) ||
              (record.action === "migrate") !== !!expense ||
              (expense && (expense.id !== record.expenseId ||
                expense.data().migrationPlanId !== data.requestId ||
                expense.data().migrationRawDigest !== original.rawDigest ||
                expenseFingerprint(expense.data()) !== record.expenseFingerprint))) {
            throw new HttpsError("failed-precondition", "A staged source changed.");
          }
        }
        const fingerprint = digest(JSON.stringify(provenance.docs
            .map((doc) => [doc.id, doc.data().decisionFingerprint]).sort()));
        tx.update(tripRef, {financeMigrationStatus: "completed",
          financeMigrationRevision: data.expectedRevision + 1,
          financeMigrationCompletedBy: uid,
          financeMigrationCompletedAt: FieldValue.serverTimestamp(),
          financeMigrationCommitId: data.requestId,
          financeMigrationCommitFingerprint: fingerprint,
          financeMigrationMigratedCount: plan.migratedCount,
          financeCurrency: plan.currencyCode, financePrecision: plan.precision,
          financeSchemaVersion: 2});
        tx.update(planRef, {status: "completed",
          completedAt: FieldValue.serverTimestamp()});
        return {status: "completed", migratedCount: plan.migratedCount,
          revision: data.expectedRevision + 1, replayed: false};
      });
      log("finance_migration_batch_completed", {tripId: data.tripId,
        migratedCount: result.migratedCount, replayed: result.replayed});
      return result;
    },

    async abort(request) {
      const {uid, data} = parse(finishSchema, request);
      const tripRef = db.doc(`trips/${data.tripId}`);
      const planRef = tripRef.collection("financeMigrationPlans").doc("current");
      const result = await db.runTransaction(async (tx) => {
        const [tripDoc, planDoc] = await Promise.all([tx.get(tripRef), tx.get(planRef)]);
        const trip = tripDoc.data();
        await assertOwner(db, trip, uid, (ref) => tx.get(ref));
        if (trip.financeMigrationStatus !== "reviewing" ||
            trip.financeMigrationRevision !== data.expectedRevision) {
          throw new HttpsError("failed-precondition", "Review can no longer be restarted.");
        }
        const plan = planDoc.data();
        if (!plan && trip.financeMigrationPlanId == null) {
          return {status: "reviewing", cleared: true, removedCount: 0};
        }
        if (!plan || plan.requestId !== data.requestId ||
            trip.financeMigrationPlanId !== data.requestId ||
            !["staging", "aborting"].includes(plan.status)) {
          throw new HttpsError("failed-precondition", "Another review plan is active.");
        }
        const staged = await tx.get(tripRef.collection("financeMigrationSources")
            .limit(STAGE_SIZE));
        if (staged.empty) {
          const remaining = await tx.get(tripRef.collection("financeExpenses").limit(1));
          if (!remaining.empty) {
            throw new HttpsError("failed-precondition", "Staged expenses need support recovery.");
          }
          tx.delete(planRef);
          tx.update(tripRef, {financeMigrationPlanId: FieldValue.delete()});
          return {status: "reviewing", cleared: true, removedCount: 0};
        }
        for (const doc of staged.docs) {
          const record = doc.data();
          if (record.migrationPlanId !== data.requestId ||
              (record.expenseId && !validId(record.expenseId))) {
            throw new HttpsError("failed-precondition", "Staged source needs support recovery.");
          }
        }
        tx.update(planRef, {status: "aborting",
          updatedAt: FieldValue.serverTimestamp()});
        for (const doc of staged.docs) {
          const expenseId = doc.data().expenseId;
          if (expenseId) {
            tx.delete(tripRef.collection("financeExpenses").doc(expenseId));
          }
          tx.delete(doc.ref);
        }
        return {status: "reviewing", cleared: false, removedCount: staged.size};
      });
      log("finance_migration_batch_aborted", {tripId: data.tripId,
        cleared: result.cleared, removedCount: result.removedCount});
      return result;
    },
  };
}

module.exports = {createBatchMigrationHandlers, MAX_BATCH_SOURCES, STAGE_SIZE};
