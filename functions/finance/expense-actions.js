"use strict";

const {createHash} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {z} = require("zod");
const {validId} = require("../validation");
const {currencyPrecision, toMinorUnits, equalShares, validateAllocation} = require("./money");

const requestIdSchema = z.string().regex(/^[A-Za-z0-9_-]{16,128}$/);
const dateSchema = z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine((value) => {
  const parsed = new Date(`${value}T00:00:00Z`);
  return Number.isFinite(+parsed) && parsed.toISOString().slice(0, 10) === value;
});
const localDateTimeSchema = z.string().regex(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/)
    .refine((value) => {
      const parsed = new Date(`${value}Z`);
      return Number.isFinite(+parsed) && parsed.toISOString().slice(0, 19) === value;
    });
const minorMap = z.record(z.string(), z.number().int().nonnegative());
const saveSchema = z.object({
  tripId: z.string().min(1).max(500),
  requestId: requestIdSchema,
  expenseId: z.string().min(1).max(128).optional(),
  expectedRevision: z.number().int().positive().optional(),
  name: z.string().trim().min(1).max(200),
  date: dateSchema,
  localDateTime: localDateTimeSchema.nullable().optional(),
  amount: z.union([z.string(), z.number().finite()]),
  currencyCode: z.string().regex(/^[A-Z]{3}$/),
  splitType: z.enum(["equally", "custom"]),
  participants: z.array(z.string()).min(1).max(100).optional(),
  payerAmountsMinor: minorMap.optional(),
  sharesMinor: minorMap.optional(),
}).strict().superRefine((value, context) => {
  if (!!value.expenseId !== !!value.expectedRevision ||
      (value.localDateTime && value.localDateTime.slice(0, 10) !== value.date) ||
      (value.splitType === "equally" && (!value.participants || value.sharesMinor)) ||
      (value.splitType === "custom" && (!value.sharesMinor || value.participants))) {
    context.addIssue({code: "custom", message: "Choose a complete expense split."});
  }
});
const deleteSchema = z.object({
  tripId: z.string().min(1).max(500), requestId: requestIdSchema,
  expenseId: z.string().min(1).max(128), expectedRevision: z.number().int().positive(),
}).strict();

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, canonical(value[key])]));
  }
  return value;
}
const digest = (value) => createHash("sha256").update(value).digest("hex");
function parse(schema, data) {
  const parsed = schema.safeParse(data);
  if (!parsed.success || !validId(parsed.data.tripId) ||
      (parsed.data.expenseId && !validId(parsed.data.expenseId))) {
    throw new HttpsError("invalid-argument", "Invalid expense request.");
  }
  return parsed.data;
}
function caller(request) {
  const uid = request.auth?.uid;
  if (!uid || !validId(uid)) throw new HttpsError("unauthenticated", "Sign in required.");
  return uid;
}
function makeExpense(data, uid, id, tripId) {
  let amountMinor;
  let precision;
  try {
    precision = currencyPrecision(data.currencyCode);
    amountMinor = toMinorUnits(data.amount, data.currencyCode);
  } catch {
    throw new HttpsError("invalid-argument", "Enter a supported currency and exact positive amount.");
  }
  const payerAmountsMinor = data.payerAmountsMinor || {[uid]: amountMinor};
  let sharesMinor;
  try {
    sharesMinor = data.splitType === "equally" ?
      equalShares(amountMinor, data.participants) : data.sharesMinor;
    validateAllocation({amountMinor, payerAmountsMinor, sharesMinor});
  } catch {
    throw new HttpsError("invalid-argument", "Payer amounts and participant shares must each equal the total.");
  }
  return {
    id, tripId, createdBy: uid, currencyCode: data.currencyCode,
    name: data.name, date: data.date,
    localDateTime: data.localDateTime || null,
    amountMinor, payerAmountsMinor,
    sharesMinor, splitType: data.splitType, financeSchemaVersion: 2,
    revision: 1, isDeleted: false, currencyPrecision: precision,
  };
}
function available(trip) {
  if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved) {
    throw new HttpsError("failed-precondition", "Trip unavailable.");
  }
  if (trip.financeMigrationStatus != null && trip.financeMigrationStatus !== "completed") {
    throw new HttpsError("failed-precondition", "Historical expenses are under review.");
  }
}
const currentlyActive = (trip, uid, member) =>
  trip.createdBy === uid || member?.status === "active";
async function assertActiveCaller(db, tx, trip, tripRef, uid) {
  const [account, safety, member] = await Promise.all([
    tx.get(db.doc(`users/${uid}`)), tx.get(db.doc(`safetyAccounts/${uid}`)),
    tx.get(tripRef.collection("members").doc(uid)),
  ]);
  if (!account.exists || account.data()?.isDeleted || safety.data()?.restricted ||
      !currentlyActive(trip, uid, member.data())) {
    throw new HttpsError("permission-denied", "Current trip membership required.");
  }
}
async function assertAllocationMembers(db, tx, trip, tripRef, proposed, previous) {
  const uids = [...new Set([...Object.keys(proposed.payerAmountsMinor),
    ...Object.keys(proposed.sharesMinor)])];
  const docs = await Promise.all(uids.map((uid) =>
    tx.get(tripRef.collection("members").doc(uid))));
  const needsAccountCheck = [];
  for (let index = 0; index < uids.length; index++) {
    const uid = uids[index];
    if (currentlyActive(trip, uid, docs[index].data())) {
      needsAccountCheck.push(uid);
      continue;
    }
    // Editing text or the amount of other travelers must not erase a former
    // member's already-recorded share. A new allocation needs current members.
    if (previous &&
        proposed.payerAmountsMinor[uid] === previous.payerAmountsMinor?.[uid] &&
        proposed.sharesMinor[uid] === previous.sharesMinor?.[uid]) continue;
    throw new HttpsError("failed-precondition", "Refresh the trip's current participants.");
  }
  const accountStates = await Promise.all(needsAccountCheck.map(async (uid) => {
    const [account, safety] = await Promise.all([
      tx.get(db.doc(`users/${uid}`)), tx.get(db.doc(`safetyAccounts/${uid}`)),
    ]);
    return account.exists && !account.data()?.isDeleted && !safety.data()?.restricted;
  }));
  if (accountStates.some((active) => !active)) {
    throw new HttpsError("failed-precondition", "Only active travelers can be allocated a new share.");
  }
}
function createExpenseHandlers(db, log = () => {}) {
  return {
    async save(request) {
      const uid = caller(request);
      const data = parse(saveSchema, request.data);
      const isNew = !data.expenseId;
      const expenseId = data.expenseId || data.requestId;
      const fingerprint = digest(JSON.stringify(canonical(data)));
      const receipt = db.doc(`financeRequests/${digest(`${uid}:${data.requestId}`)}`);
      const tripRef = db.doc(`trips/${data.tripId}`);
      const expenseRef = tripRef.collection("financeExpenses").doc(expenseId);
      const result = await db.runTransaction(async (tx) => {
        const [receiptDoc, tripDoc, existing, legacy, legacyTop] = await Promise.all([
          tx.get(receipt), tx.get(tripRef), tx.get(expenseRef),
          isNew ? tx.get(tripRef.collection("expenses").limit(1)) : Promise.resolve(null),
          isNew ? tx.get(db.collection("expense").where("tripId", "==", data.tripId).limit(1)) : Promise.resolve(null),
        ]);
        if (receiptDoc.exists) {
          if (receiptDoc.data().fingerprint !== fingerprint) {
            throw new HttpsError("already-exists", "Request ID was used for a different expense action.");
          }
          return {...receiptDoc.data().result, replayed: true};
        }
        const trip = tripDoc.data(); available(trip);
        await assertActiveCaller(db, tx, trip, tripRef, uid);
        const old = existing.data();
        if (isNew) {
          if (existing.exists) throw new HttpsError("already-exists", "Expense ID already exists.");
          if (!trip.financeCurrency && (!legacy.empty || !legacyTop.empty ||
              (Array.isArray(trip.expenses) && trip.expenses.length > 0))) {
            throw new HttpsError("failed-precondition", "Existing expenses need review before a currency can be selected.");
          }
        } else if (!old || old.isDeleted || old.financeSchemaVersion !== 2 ||
            old.revision !== data.expectedRevision) {
          throw new HttpsError("failed-precondition", "Expense changed. Refresh before editing.");
        } else if (old.createdBy !== uid && trip.createdBy !== uid) {
          throw new HttpsError("permission-denied", "Only the author or trip owner may edit this expense.");
        }
        const proposed = makeExpense({
          ...data,
          payerAmountsMinor: data.payerAmountsMinor || old?.payerAmountsMinor,
          localDateTime: data.localDateTime === undefined && old?.date === data.date ?
            old.localDateTime : data.localDateTime,
        }, uid, expenseId, data.tripId);
        if (trip.financeCurrency && (trip.financeCurrency !== data.currencyCode ||
            trip.financePrecision !== proposed.currencyPrecision || trip.financeSchemaVersion !== 2)) {
          throw new HttpsError("failed-precondition", "Use the trip's selected currency.");
        }
        if (!isNew && old.currencyCode !== data.currencyCode) {
          throw new HttpsError("failed-precondition", "An expense's currency cannot change.");
        }
        await assertAllocationMembers(db, tx, trip, tripRef, proposed, old);
        if (isNew) {
          tx.create(expenseRef, {...proposed, createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp()});
          if (!trip.financeCurrency) {
            tx.update(tripRef, {financeCurrency: data.currencyCode,
              financePrecision: proposed.currencyPrecision, financeSchemaVersion: 2});
          }
        } else {
          tx.update(expenseRef, {...proposed, createdBy: old.createdBy,
            revision: old.revision + 1, updatedAt: FieldValue.serverTimestamp()});
        }
        const response = {expenseId, revision: isNew ? 1 : old.revision + 1,
          currencyCode: data.currencyCode};
        tx.create(receipt, {uid, tripId: data.tripId, expenseId, fingerprint,
          result: response, createdAt: FieldValue.serverTimestamp()});
        return {...response, replayed: false};
      });
      log("finance_expense_saved", {tripId: data.tripId, expenseId,
        operation: isNew ? "create" : "edit", replayed: result.replayed});
      return result;
    },
    async remove(request) {
      const uid = caller(request);
      const data = parse(deleteSchema, request.data);
      const fingerprint = digest(JSON.stringify(canonical(data)));
      const receipt = db.doc(`financeRequests/${digest(`${uid}:${data.requestId}`)}`);
      const tripRef = db.doc(`trips/${data.tripId}`);
      const expenseRef = tripRef.collection("financeExpenses").doc(data.expenseId);
      const result = await db.runTransaction(async (tx) => {
        const [receiptDoc, tripDoc, expenseDoc] = await Promise.all([
          tx.get(receipt), tx.get(tripRef), tx.get(expenseRef),
        ]);
        if (receiptDoc.exists) {
          if (receiptDoc.data().fingerprint !== fingerprint) {
            throw new HttpsError("already-exists", "Request ID was used for a different expense action.");
          }
          return {...receiptDoc.data().result, replayed: true};
        }
        const trip = tripDoc.data(); available(trip);
        await assertActiveCaller(db, tx, trip, tripRef, uid);
        const expense = expenseDoc.data();
        if (!expense || expense.isDeleted || expense.financeSchemaVersion !== 2 ||
            expense.revision !== data.expectedRevision) {
          throw new HttpsError("failed-precondition", "Expense changed. Refresh before deleting.");
        }
        if (expense.createdBy !== uid && trip.createdBy !== uid) {
          throw new HttpsError("permission-denied", "Only the author or trip owner may delete this expense.");
        }
        tx.update(expenseRef, {isDeleted: true, revision: expense.revision + 1,
          updatedAt: FieldValue.serverTimestamp()});
        const response = {expenseId: data.expenseId, revision: expense.revision + 1};
        tx.create(receipt, {uid, tripId: data.tripId, expenseId: data.expenseId,
          fingerprint, result: response, createdAt: FieldValue.serverTimestamp()});
        return {...response, replayed: false};
      });
      log("finance_expense_deleted", {tripId: data.tripId, expenseId: data.expenseId,
        replayed: result.replayed});
      return result;
    },
  };
}

module.exports = {createExpenseHandlers};
