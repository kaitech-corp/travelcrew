"use strict";

const {createHash} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {z} = require("zod");
const {validId} = require("../validation");
const {currencyPrecision, toMinorUnits} = require("./money");

const requestId = z.string().regex(/^[A-Za-z0-9_-]{16,128}$/);
const recordSchema = z.object({
  tripId: z.string().min(1).max(500), requestId,
  toUserId: z.string().min(1).max(128),
  amount: z.union([z.string(), z.number().finite()]),
}).strict();
const answerSchema = z.object({
  tripId: z.string().min(1).max(500), requestId,
  transferId: z.string().min(1).max(128),
  expectedRevision: z.number().int().positive(),
  action: z.enum(["confirm", "reject", "cancel"]),
}).strict();
const hash = (value) => createHash("sha256").update(value).digest("hex");
function parse(schema, data) {
  const result = schema.safeParse(data);
  if (!result.success) {
    throw new HttpsError("invalid-argument", "Invalid transfer request.");
  }
  if (!validId(result.data.tripId) ||
      (result.data.toUserId && !validId(result.data.toUserId)) ||
      (result.data.transferId && !validId(result.data.transferId))) {
    throw new HttpsError("invalid-argument", "Invalid transfer request.");
  }
  return result.data;
}
function identity(request) {
  const uid = request.auth?.uid;
  if (!validId(uid)) throw new HttpsError("unauthenticated", "Sign in required.");
  return uid;
}
async function active(db, tx, trip, tripRef, uid) {
  const [account, safety, member] = await Promise.all([
    tx.get(db.doc(`users/${uid}`)), tx.get(db.doc(`safetyAccounts/${uid}`)),
    tx.get(tripRef.collection("members").doc(uid)),
  ]);
  return account.exists && !account.data()?.isDeleted && !safety.data()?.restricted &&
    (trip.createdBy === uid || member.data()?.status === "active");
}
function available(trip) {
  let validCurrency = false;
  try {
    validCurrency = trip?.financePrecision === currencyPrecision(trip?.financeCurrency);
  } catch {
    // A corrupt or unsupported trip currency cannot accept transfers.
  }
  if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved ||
      trip.financeSchemaVersion !== 2 || !validCurrency ||
      (trip.financeMigrationStatus != null && trip.financeMigrationStatus !== "completed")) {
    throw new HttpsError("failed-precondition", "Trip finance ledger unavailable.");
  }
}
function createTransferHandlers(db, log = () => {}) {
  async function transact(uid, data, operation) {
    const fingerprint = hash(JSON.stringify({operation, ...data}));
    const receiptRef = db.doc(`financeTransferRequests/${hash(`${uid}:${data.requestId}`)}`);
    const tripRef = db.doc(`trips/${data.tripId}`);
    const transferId = operation === "record" ? data.requestId : data.transferId;
    const transferRef = tripRef.collection("financeTransfers").doc(transferId);
    const result = await db.runTransaction(async (tx) => {
      const [receiptDoc, tripDoc, transferDoc] = await Promise.all([
        tx.get(receiptRef), tx.get(tripRef), tx.get(transferRef),
      ]);
      if (receiptDoc.exists) {
        if (receiptDoc.data().fingerprint !== fingerprint) {
          throw new HttpsError("already-exists", "Request ID was used for another transfer action.");
        }
        return {...receiptDoc.data().result, replayed: true};
      }
      const trip = tripDoc.data(); available(trip);
      if (!await active(db, tx, trip, tripRef, uid)) {
        throw new HttpsError("permission-denied", "Current trip membership required.");
      }
      let response;
      if (operation === "record") {
        if (transferDoc.exists) throw new HttpsError("already-exists", "Transfer ID already exists.");
        if (data.toUserId === uid || !await active(db, tx, trip, tripRef, data.toUserId)) {
          throw new HttpsError("failed-precondition", "Choose another active traveler.");
        }
        let amountMinor;
        try {
          amountMinor = toMinorUnits(data.amount, trip.financeCurrency);
        } catch {
          throw new HttpsError("invalid-argument", "Enter an exact positive transfer amount.");
        }
        tx.create(transferRef, {
          id: transferId, tripId: data.tripId, fromUserId: uid,
          toUserId: data.toUserId, amountMinor,
          currencyCode: trip.financeCurrency, currencyPrecision: trip.financePrecision,
          status: "pending", revision: 1, transferSchemaVersion: 1,
          createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
        });
        response = {transferId, revision: 1, status: "pending"};
      } else {
        const transfer = transferDoc.data();
        if (!transfer || transfer.tripId !== data.tripId ||
            transfer.transferSchemaVersion !== 1 ||
            transfer.currencyCode !== trip.financeCurrency ||
            transfer.status !== "pending" ||
            transfer.revision !== data.expectedRevision) {
          throw new HttpsError("failed-precondition", "Transfer changed. Refresh before responding.");
        }
        if (data.action === "cancel" ? transfer.fromUserId !== uid : transfer.toUserId !== uid) {
          throw new HttpsError("permission-denied", "Only the payer or recipient may answer this transfer.");
        }
        const status = data.action === "confirm" ? "confirmed" :
          data.action === "reject" ? "rejected" : "cancelled";
        tx.update(transferRef, {status, revision: transfer.revision + 1,
          respondedBy: uid, respondedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp()});
        response = {transferId, revision: transfer.revision + 1, status};
      }
      tx.create(receiptRef, {uid, tripId: data.tripId, transferId, fingerprint,
        result: response, createdAt: FieldValue.serverTimestamp()});
      return {...response, replayed: false};
    });
    log("finance_transfer_action", {tripId: data.tripId, transferId,
      operation, status: result.status, replayed: result.replayed});
    return result;
  }
  return {
    record: async (request) => transact(identity(request), parse(recordSchema, request.data), "record"),
    answer: async (request) => transact(identity(request), parse(answerSchema, request.data), "answer"),
  };
}

module.exports = {createTransferHandlers};
