const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {randomUUID} = require("node:crypto");
const fs = require("node:fs");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, getDoc, setDoc, updateDoc} = require("firebase/firestore");
const {createTransferHandlers} = require("../finance/transfer-actions");
const {balancesFor} = require("../finance/money");

let app; let db; let env; let transfers;
const owner = "owner"; const member = "member";
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-finance-transfers"}, "finance-transfers-test");
  db = getFirestore(app);
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-finance-transfers",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
  transfers = createTransferHandlers(db);
  for (const uid of [owner, member, "stranger"]) await db.doc(`users/${uid}`).set({uid});
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});
const req = (uid, data) => ({auth: uid ? {uid} : null, data});
const code = (name) => (error) => error.code === name;
const entry = (tripId, overrides = {}) => ({tripId, requestId: randomUUID(),
  toUserId: owner, amount: "2.50", ...overrides});
async function setup() {
  const id = randomUUID();
  await db.doc(`trips/${id}`).set({id, createdBy: owner, joinedUsers: [member],
    tripStatus: "upcoming", financeCurrency: "USD", financePrecision: 2, financeSchemaVersion: 2});
  await db.doc(`trips/${id}/members/${member}`).set({userId: member, status: "active"});
  const expense = {amountMinor: 1000, payerAmountsMinor: {[owner]: 1000},
    sharesMinor: {[owner]: 500, [member]: 500}};
  return {id, expense};
}

test("specific pending transfer changes balances only after recipient confirmation", async () => {
  const {id, expense} = await setup();
  const data = entry(id);
  const saved = await transfers.record(req(member, data));
  assert.equal(saved.status, "pending");
  assert.equal((await transfers.record(req(member, data))).replayed, true);
  const path = `trips/${id}/financeTransfers/${saved.transferId}`;
  const pending = (await db.doc(path).get()).data();
  assert.equal(pending.amountMinor, 250);
  assert.equal(pending.currencyCode, "USD");
  assert.deepEqual(balancesFor([expense], [pending]), {[member]: -500, [owner]: 500});
  const answer = {tripId: id, transferId: saved.transferId, requestId: randomUUID(),
    expectedRevision: 1, action: "confirm"};
  await assert.rejects(transfers.answer(req(member, answer)), code("permission-denied"));
  const confirmed = await transfers.answer(req(owner, answer));
  assert.equal(confirmed.status, "confirmed");
  assert.equal((await transfers.answer(req(owner, answer))).replayed, true);
  assert.deepEqual(balancesFor([expense], [(await db.doc(path).get()).data()]),
      {[member]: -250, [owner]: 250});
  await assert.rejects(transfers.answer(req(owner, {...answer, requestId: randomUUID()})), code("failed-precondition"));
  const client = env.authenticatedContext(member).firestore();
  await assertSucceeds(getDoc(doc(client, path)));
  await assertFails(updateDoc(doc(client, path), {status: "confirmed"}));
  await assertFails(setDoc(doc(client, `trips/${id}/financeTransfers/forged`), {status: "confirmed"}));
});

test("record validation, membership and currency gates prevent false transfers", async () => {
  const {id} = await setup();
  await assert.rejects(transfers.record(req(null, entry(id))), code("unauthenticated"));
  await assert.rejects(transfers.record(req("stranger", entry(id))), code("permission-denied"));
  await assert.rejects(transfers.record(req(member, entry(id, {toUserId: member}))), code("failed-precondition"));
  await assert.rejects(transfers.record(req(member, entry(id, {amount: "2.501"}))), code("invalid-argument"));
  await assert.rejects(transfers.record(req(member, entry(id, {amount: "0"}))), code("invalid-argument"));
  await assert.rejects(transfers.record(req(member, entry(id, {currencyCode: "JPY"}))), code("invalid-argument"));
  await assert.rejects(transfers.record(req(member, {tripId: id})), code("invalid-argument"));
  const request = entry(id);
  await transfers.record(req(member, request));
  await assert.rejects(transfers.record(req(member, {...request, amount: "3.00"})), code("already-exists"));
  await db.doc(`trips/${id}/members/${member}`).update({status: "left"});
  await assert.rejects(transfers.record(req(member, entry(id))), code("permission-denied"));
  const client = env.authenticatedContext(member).firestore();
  await assertFails(getDoc(doc(client, `trips/${id}/financeTransfers/${request.requestId}`)));
  await db.doc(`trips/${id}`).update({financeCurrency: "NOT_A_CURRENCY"});
  await assert.rejects(transfers.record(req(owner, entry(id, {toUserId: member}))),
      code("failed-precondition"));
});

test("reviewing a mixed historical ledger pauses transfers", async () => {
  const {id} = await setup();
  await db.doc(`trips/${id}`).update({financeMigrationStatus: "reviewing"});
  await assert.rejects(transfers.record(req(member, entry(id))), code("failed-precondition"));
  assert.equal((await db.collection(`trips/${id}/financeTransfers`).get()).empty, true);
});

test("recipient decision and payer cancellation have one winner under races", async () => {
  const {id} = await setup();
  const saved = await transfers.record(req(member, entry(id)));
  const base = {tripId: id, transferId: saved.transferId, expectedRevision: 1};
  const race = await Promise.allSettled([
    transfers.answer(req(owner, {...base, requestId: randomUUID(), action: "confirm"})),
    transfers.answer(req(owner, {...base, requestId: randomUUID(), action: "reject"})),
  ]);
  assert.equal(race.filter((result) => result.status === "fulfilled").length, 1);
  assert.equal((await db.doc(`trips/${id}/financeTransfers/${saved.transferId}`).get()).data().revision, 2);
  const second = await transfers.record(req(member, entry(id)));
  const cancel = {tripId: id, transferId: second.transferId, expectedRevision: 1,
    requestId: randomUUID(), action: "cancel"};
  await assert.rejects(transfers.answer(req(owner, cancel)), code("permission-denied"));
  assert.equal((await transfers.answer(req(member, cancel))).status, "cancelled");
  assert.equal((await transfers.answer(req(member, cancel))).replayed, true);
});
