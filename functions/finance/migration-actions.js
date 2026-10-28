"use strict";

const {createHash} = require("node:crypto");
const {FieldPath, FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {z} = require("zod");
const {validId} = require("../validation");
const {currencyPrecision, toMinorUnits, validateAllocation} = require("./money");

const MAX_SOURCES = 200;
const MAX_REVIEW_SOURCES = 1000;
const digest = (value) => createHash("sha256").update(value).digest("hex");
const hex = z.string().regex(/^[a-f0-9]{64}$/);
const allocation = z.record(z.string(), z.number().int().nonnegative());
const date = z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine((value) => {
  const parsed = new Date(`${value}T00:00:00Z`);
  return Number.isFinite(+parsed) && parsed.toISOString().slice(0, 10) === value;
});
const migrateDecision = z.object({
  sourceId: hex, rawDigest: hex, action: z.literal("migrate"),
  name: z.string().trim().min(1).max(200), date,
  amount: z.string().regex(/^(0|[1-9][0-9]*)(?:\.[0-9]+)?$/),
  payerAmountsMinor: allocation, sharesMinor: allocation,
}).strict();
const excludeDecision = z.object({
  sourceId: hex, rawDigest: hex, action: z.literal("exclude"),
  reason: z.enum(["duplicate", "invalid", "not_trip_expense", "other"]),
  note: z.string().trim().max(500).optional(),
}).strict();
const commitSchema = z.object({
  tripId: z.string(), requestId: z.string().regex(/^[A-Za-z0-9_-]{16,128}$/),
  expectedRevision: z.number().int().positive(),
  currencyCode: z.string().regex(/^[A-Z]{3}$/),
  decisions: z.array(z.discriminatedUnion("action", [migrateDecision, excludeDecision]))
      .min(1).max(MAX_SOURCES),
}).strict();

function requestTripId(request) {
  const uid = request.auth?.uid;
  if (!validId(uid)) throw new HttpsError("unauthenticated", "Sign in required.");
  const data = request.data;
  if (!data || Object.keys(data).length !== 1 || !validId(data.tripId)) {
    throw new HttpsError("invalid-argument", "Supply a trip ID.");
  }
  return {uid, tripId: data.tripId};
}

async function assertOwner(db, trip, uid, get) {
  if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved ||
      trip.createdBy !== uid) {
    throw new HttpsError("permission-denied", "Current trip owner required.");
  }
  const [account, safety] = await Promise.all([
    get(db.doc(`users/${uid}`)), get(db.doc(`safetyAccounts/${uid}`)),
  ]);
  if (!account.exists || account.data()?.isDeleted || safety.data()?.restricted) {
    throw new HttpsError("permission-denied", "Active trip owner required.");
  }
}

function canonical(value) {
  if (value === null) return ["null"];
  if (typeof value === "string") return ["string", value];
  if (typeof value === "number") return ["number", String(value)];
  if (typeof value === "boolean") return ["boolean", value];
  if (Array.isArray(value)) return ["array", value.map(canonical)];
  if (value && typeof value === "object") {
    if (typeof value.toDate === "function" &&
        Number.isInteger(value.seconds) && Number.isInteger(value.nanoseconds)) {
      return ["timestamp", value.seconds, value.nanoseconds];
    }
    if (value instanceof Date) return ["date", value.toISOString()];
    if (Buffer.isBuffer(value)) return ["bytes", value.toString("base64")];
    return ["map", Object.keys(value).sort().map((key) => [key, canonical(value[key])])];
  }
  return [typeof value, String(value)];
}

function source(kind, id, data) {
  const sourceKey = `${kind}:${id}`;
  const raw = canonical(data);
  const value = data && typeof data === "object" && !Array.isArray(data) ? data : {};
  const text = (input, maximum) => typeof input === "string" ? input.slice(0, maximum) : null;
  const amount = typeof value.amount === "number" && Number.isFinite(value.amount) ?
    String(value.amount) : text(value.amount, 40);
  const date = value.date && typeof value.date.toDate === "function" ?
    value.date.toDate().toISOString() : text(value.date, 40);
  const hintIds = [...new Set([
    ...(Array.isArray(value.paidByUsers) ? value.paidByUsers : []),
    ...Object.keys(value.owners && typeof value.owners === "object" ? value.owners : {}),
    ...Object.keys(value.owedTo && typeof value.owedTo === "object" ? value.owedTo : {}),
  ].filter(validId))].slice(0, 100);
  return {
    sourceId: digest(sourceKey), source: kind, sourceRecordId: id,
    rawDigest: digest(JSON.stringify(raw)),
    name: text(value.name, 200), date, amount,
    currencyUnknown: true, unverifiedTravelerHints: hintIds,
  };
}

function reviewedExpense(data, decision, original, uid, precision, allowed) {
  let amountMinor;
  try {
    amountMinor = toMinorUnits(decision.amount, data.currencyCode);
    validateAllocation({amountMinor,
      payerAmountsMinor: decision.payerAmountsMinor,
      sharesMinor: decision.sharesMinor});
  } catch {
    throw new HttpsError("invalid-argument", "Enter exact payer and participant amounts.");
  }
  const allocations = [...Object.keys(decision.payerAmountsMinor),
    ...Object.keys(decision.sharesMinor)];
  if (allocations.some((traveler) => !allowed.has(traveler))) {
    throw new HttpsError("invalid-argument", "Use verified current or historical travelers.");
  }
  const expenseId = `migrated_${decision.sourceId.slice(0, 40)}`;
  return {id: expenseId, tripId: data.tripId, createdBy: uid,
    name: decision.name, date: decision.date, localDateTime: null,
    amountMinor, payerAmountsMinor: decision.payerAmountsMinor,
    sharesMinor: decision.sharesMinor, splitType: "custom",
    currencyCode: data.currencyCode, currencyPrecision: precision,
    financeSchemaVersion: 2, revision: 1, isDeleted: false,
    migrationSourceId: original.sourceId,
    migrationRawDigest: original.rawDigest,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp()};
}

async function readSources(db, tripId, trip, get = (query) => query.get(),
    maxSources = MAX_REVIEW_SOURCES) {
  const tripRef = db.doc(`trips/${tripId}`);
  const [nested, top] = await Promise.all([
    get(tripRef.collection("expenses").orderBy(FieldPath.documentId()).limit(maxSources + 1)),
    get(db.collection("expense").where("tripId", "==", tripId)
        .orderBy(FieldPath.documentId()).limit(maxSources + 1)),
  ]);
  const embedded = Array.isArray(trip.expenses) ? trip.expenses :
    trip.expenses == null ? [] : [trip.expenses];
  if (embedded.length + nested.size + top.size > maxSources) {
    throw new HttpsError("resource-exhausted", "Trip has too many historical expenses for review.");
  }
  return [
    ...embedded.map((entry, index) => source("embedded", String(index), entry)),
    ...nested.docs.map((doc) => source("nested", doc.id, doc.data())),
    ...top.docs.map((doc) => source("top", doc.id, doc.data())),
  ];
}

function createMigrationHandlers(db, log = () => {}) {
  return {
    async begin(request) {
      const {uid, tripId} = requestTripId(request);
      const tripRef = db.doc(`trips/${tripId}`);
      const result = await db.runTransaction(async (tx) => {
        const tripDoc = await tx.get(tripRef);
        const trip = tripDoc.data();
        await assertOwner(db, trip, uid, (ref) => tx.get(ref));
        if (trip.financeMigrationStatus === "reviewing") {
          return {status: "reviewing", revision: trip.financeMigrationRevision};
        }
        if (trip.financeMigrationStatus != null || trip.financeSchemaVersion === 2) {
          throw new HttpsError("failed-precondition", "Finance ledger already changed.");
        }
        const [nested, top, v2, transfers, members] = await Promise.all([
          tx.get(tripRef.collection("expenses").limit(MAX_REVIEW_SOURCES + 1)),
          tx.get(db.collection("expense").where("tripId", "==", tripId)
              .limit(MAX_REVIEW_SOURCES + 1)),
          tx.get(tripRef.collection("financeExpenses").limit(1)),
          tx.get(tripRef.collection("financeTransfers").limit(1)),
          tx.get(tripRef.collection("members").limit(501)),
        ]);
        if (!v2.empty || !transfers.empty) {
          throw new HttpsError("failed-precondition", "Mixed finance data needs support review.");
        }
        const embeddedCount = Array.isArray(trip.expenses) ? trip.expenses.length :
          trip.expenses == null ? 0 : 1;
        if (embeddedCount + nested.size + top.size > MAX_REVIEW_SOURCES) {
          throw new HttpsError("resource-exhausted",
              "Trip has too many historical expenses for review.");
        }
        const embedded = Array.isArray(trip.expenses) ? trip.expenses :
          trip.expenses == null ? [] : [trip.expenses];
        const hints = [
          ...embedded.map((entry, index) => source("embedded", String(index), entry)),
          ...nested.docs.map((doc) => source("nested", doc.id, doc.data())),
          ...top.docs.map((doc) => source("top", doc.id, doc.data())),
        ];
        const allowed = new Set([uid,
          ...(Array.isArray(trip.joinedUsers) ? trip.joinedUsers : []),
          ...members.docs.map((doc) => doc.data().userId || doc.id),
          ...hints.flatMap((item) => item.unverifiedTravelerHints)]);
        if (members.size > 500 || allowed.size > 500 ||
            [...allowed].some((id) => !validId(id))) {
          throw new HttpsError("resource-exhausted",
              "Too many historical travelers for review.");
        }
        if (embeddedCount === 0 && nested.empty && top.empty) {
          throw new HttpsError("failed-precondition", "No historical expenses to review.");
        }
        tx.update(tripRef, {financeMigrationStatus: "reviewing",
          financeMigrationRevision: 1, financeMigrationStartedBy: uid,
          financeMigrationStartedAt: FieldValue.serverTimestamp()});
        return {status: "reviewing", revision: 1};
      });
      log("finance_migration_review_started", {tripId});
      return result;
    },
    async preview(request) {
      const {uid, tripId} = requestTripId(request);
      const tripDoc = await db.doc(`trips/${tripId}`).get();
      const trip = tripDoc.data();
      await assertOwner(db, trip, uid, (ref) => ref.get());
      if (trip.financeMigrationStatus !== "reviewing") {
        throw new HttpsError("failed-precondition", "Start historical expense review first.");
      }
      const sources = await readSources(db, tripId, trip);
      const [currentTrip, planDoc] = await Promise.all([
        db.doc(`trips/${tripId}`).get(),
        db.doc(`trips/${tripId}/financeMigrationPlans/current`).get(),
      ]);
      await assertOwner(db, currentTrip.data(), uid, (ref) => ref.get());
      if (currentTrip.data()?.financeMigrationStatus !== "reviewing" ||
          currentTrip.data()?.financeMigrationRevision !== trip.financeMigrationRevision) {
        throw new HttpsError("aborted", "Review changed. Reload the trip.");
      }
      return {status: "reviewing", revision: trip.financeMigrationRevision,
        sourceCount: sources.length, sources,
        batchPlan: planDoc.exists ? {
          requestId: planDoc.data().requestId,
          status: planDoc.data().status,
          stagedCount: planDoc.data().stagedCount,
        } : null};
    },
    async commit(request) {
      const uid = request.auth?.uid;
      if (!validId(uid)) throw new HttpsError("unauthenticated", "Sign in required.");
      const parsed = commitSchema.safeParse(request.data);
      if (!parsed.success || !validId(parsed.data.tripId)) {
        throw new HttpsError("invalid-argument", "Review every historical expense.");
      }
      const data = parsed.data;
      let precision;
      try { precision = currencyPrecision(data.currencyCode); } catch {
        throw new HttpsError("invalid-argument", "Choose a supported currency.");
      }
      const decisions = [...data.decisions].sort((a, b) => a.sourceId.localeCompare(b.sourceId));
      const fingerprint = digest(JSON.stringify(canonical({...data, decisions})));
      const tripRef = db.doc(`trips/${data.tripId}`);
      const result = await db.runTransaction(async (tx) => {
        const tripDoc = await tx.get(tripRef);
        const trip = tripDoc.data();
        await assertOwner(db, trip, uid, (ref) => tx.get(ref));
        if (trip.financeMigrationStatus === "completed") {
          if (trip.financeMigrationCommitId === data.requestId &&
              trip.financeMigrationCommitFingerprint === fingerprint) {
            return {status: "completed", revision: trip.financeMigrationRevision,
              migratedCount: trip.financeMigrationMigratedCount, replayed: true};
          }
          throw new HttpsError("failed-precondition", "Migration already completed.");
        }
        if (trip.financeMigrationStatus !== "reviewing" ||
            trip.financeMigrationRevision !== data.expectedRevision ||
            trip.financeSchemaVersion === 2 || trip.financeCurrency != null ||
            trip.financeMigrationPlanId != null) {
          throw new HttpsError("failed-precondition", "Review changed. Reload before approval.");
        }
        const [sources, members, v2, transfers] = await Promise.all([
          readSources(db, data.tripId, trip, (query) => tx.get(query)),
          tx.get(tripRef.collection("members").limit(501)),
          tx.get(tripRef.collection("financeExpenses").limit(1)),
          tx.get(tripRef.collection("financeTransfers").limit(1)),
        ]);
        if (members.size > 500 || !v2.empty || !transfers.empty) {
          throw new HttpsError("failed-precondition", "Finance sources changed. Contact support.");
        }
        const expected = new Map(sources.map((source) => [source.sourceId, source]));
        if (expected.size !== sources.length || decisions.length !== sources.length ||
            new Set(decisions.map((decision) => decision.sourceId)).size !== decisions.length) {
          throw new HttpsError("invalid-argument", "Review every source record exactly once.");
        }
        const allowed = new Set([uid,
          ...(Array.isArray(trip.joinedUsers) ? trip.joinedUsers : []),
          ...members.docs.map((doc) => doc.data().userId || doc.id),
          ...sources.flatMap((source) => source.unverifiedTravelerHints)]);
        const migrated = [];
        for (const decision of decisions) {
          const original = expected.get(decision.sourceId);
          if (!original || original.rawDigest !== decision.rawDigest) {
            throw new HttpsError("failed-precondition", "A source record changed. Reload review.");
          }
          let expense = null;
          if (decision.action === "migrate") {
            expense = reviewedExpense(data, decision, original, uid,
                precision, allowed);
            migrated.push(expense);
          }
          const record = {sourceId: original.sourceId,
            source: original.source, sourceRecordId: original.sourceRecordId,
            rawDigest: original.rawDigest, action: decision.action,
            reviewedBy: uid, reviewedAt: FieldValue.serverTimestamp(),
            ...(expense ? {expenseId: expense.id} :
              {reason: decision.reason, note: decision.note || ""})};
          tx.create(tripRef.collection("financeMigrationSources").doc(original.sourceId), record);
          if (expense) tx.create(tripRef.collection("financeExpenses").doc(expense.id), expense);
        }
        tx.update(tripRef, {financeMigrationStatus: "completed",
          financeMigrationRevision: data.expectedRevision + 1,
          financeMigrationCompletedBy: uid,
          financeMigrationCompletedAt: FieldValue.serverTimestamp(),
          financeMigrationCommitId: data.requestId,
          financeMigrationCommitFingerprint: fingerprint,
          financeMigrationMigratedCount: migrated.length,
          financeCurrency: data.currencyCode, financePrecision: precision,
          financeSchemaVersion: 2});
        return {status: "completed", revision: data.expectedRevision + 1,
          migratedCount: migrated.length, replayed: false};
      });
      log("finance_migration_review_completed", {tripId: data.tripId,
        migratedCount: result.migratedCount, replayed: result.replayed});
      return result;
    },
  };
}

module.exports = {createMigrationHandlers, readSources, source, canonical,
  migrateDecision, excludeDecision, digest, assertOwner, date, allocation,
  reviewedExpense};
