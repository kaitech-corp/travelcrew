const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {randomUUID} = require("node:crypto");
const fs = require("node:fs");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, setDoc, getDoc, updateDoc, deleteDoc} = require("firebase/firestore");
const {createExpenseHandlers} = require("../finance/expense-actions");

let app; let db; let env; let finance;
const owner = "finance-owner"; const member = "finance-member";
const other = "finance-other"; const stranger = "finance-stranger";
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-finance"}, "finance-integration");
  db = getFirestore(app);
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-finance",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
  finance = createExpenseHandlers(db);
  for (const uid of [owner, member, other, stranger]) {
    await db.doc(`users/${uid}`).set({uid, displayName: uid});
  }
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});
async function trip({legacy = false} = {}) {
  const id = randomUUID();
  await db.doc(`trips/${id}`).set({id, createdBy: owner,
    joinedUsers: [member, other], tripStatus: "upcoming"});
  for (const uid of [member, other]) {
    await db.doc(`trips/${id}/members/${uid}`).set({userId: uid, status: "active"});
  }
  if (legacy) await db.doc(`trips/${id}/expenses/old`).set({amount: 2.5, paidByUsers: [owner]});
  return id;
}
const request = (uid, data) => ({auth: uid ? {uid} : null, data});
const input = (tripId, overrides = {}) => ({tripId, requestId: randomUUID(),
  name: "Train tickets", date: "2027-04-10", amount: "10.01",
  currencyCode: "USD", splitType: "equally", participants: [owner, member, other],
  ...overrides});
async function rejectsCode(promise, code) {
  await assert.rejects(promise, (error) => error.code === code);
}

test("first expense selects trip currency and exact allocations; replay is idempotent", async () => {
  const id = await trip();
  const data = input(id);
  const saved = await finance.save(request(owner, data));
  assert.equal(saved.revision, 1);
  assert.equal(saved.currencyCode, "USD");
  assert.equal((await finance.save(request(owner, data))).replayed, true);
  const expense = (await db.doc(`trips/${id}/financeExpenses/${saved.expenseId}`).get()).data();
  assert.equal(expense.amountMinor, 1001);
  assert.deepEqual(expense.payerAmountsMinor, {[owner]: 1001});
  assert.deepEqual(expense.sharesMinor, {[member]: 334, [other]: 334, [owner]: 333});
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeCurrency, "USD");
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 1);
  await rejectsCode(finance.save(request(owner, {...data, amount: "20"})), "already-exists");
});

test("currency, legacy inventory, membership and malformed allocation gates fail before writes", async () => {
  const id = await trip();
  await rejectsCode(finance.save(request(null, input(id))), "unauthenticated");
  await rejectsCode(finance.save(request(stranger, input(id))), "permission-denied");
  await rejectsCode(finance.save(request(owner, input(id, {date: "2027-02-30"}))), "invalid-argument");
  await rejectsCode(finance.save(request(owner, input(id, {amount: "10.001"}))), "invalid-argument");
  await rejectsCode(finance.save(request(owner, input(id, {payerAmountsMinor: {[owner]: 1}}))), "invalid-argument");
  await rejectsCode(finance.save(request(owner, input(id, {localDateTime: "2027-04-10T10:00:00Z"}))), "invalid-argument");
  await rejectsCode(finance.save(request(owner, input(id, {localDateTime: "2027-04-11T10:00:00"}))), "invalid-argument");
  await finance.save(request(owner, input(id)));
  await rejectsCode(finance.save(request(member, input(id, {currencyCode: "JPY", amount: "100"}))), "failed-precondition");
  const oldTrip = await trip({legacy: true});
  await rejectsCode(finance.save(request(owner, input(oldTrip))), "failed-precondition");
  assert.equal((await db.collection(`trips/${oldTrip}/financeExpenses`).get()).empty, true);
  const topTrip = await trip();
  await db.doc(`expense/${randomUUID()}`).set({tripId: topTrip, amount: 4});
  await rejectsCode(finance.save(request(owner, input(topTrip))), "failed-precondition");
  const embeddedTrip = await trip();
  await db.doc(`trips/${embeddedTrip}`).update({expenses: [{amount: 5}]});
  await rejectsCode(finance.save(request(owner, input(embeddedTrip))), "failed-precondition");
});

test("stale roster and restricted accounts cannot receive new expense shares", async () => {
  const id = await trip();
  await db.doc(`trips/${id}/members/${other}`).update({status: "left"});
  await rejectsCode(finance.save(request(owner, input(id))), "failed-precondition");
  await db.doc(`trips/${id}/members/${other}`).update({status: "active"});
  await db.doc(`safetyAccounts/${other}`).set({restricted: true});
  await rejectsCode(finance.save(request(owner, input(id))), "failed-precondition");
  await db.doc(`safetyAccounts/${other}`).delete();
  await db.doc(`trips/${id}/members/${member}`).update({status: "left"});
  await rejectsCode(finance.save(request(member, input(id, {participants: [owner, other]}))),
      "permission-denied");
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).empty, true);
});

test("author or owner edits with revision; tombstone blocks stale writes and resurrection", async () => {
  const id = await trip();
  const saved = await finance.save(request(member, input(id)));
  const edit = input(id, {expenseId: saved.expenseId, expectedRevision: 1,
    amount: "12.00", payerAmountsMinor: {[member]: 1200}, requestId: randomUUID()});
  await rejectsCode(finance.save(request(other, edit)), "permission-denied");
  const changed = await finance.save(request(owner, edit));
  assert.equal(changed.revision, 2);
  const updated = (await db.doc(`trips/${id}/financeExpenses/${saved.expenseId}`).get()).data();
  assert.equal(updated.createdBy, member);
  assert.deepEqual(updated.payerAmountsMinor, {[member]: 1200});
  await rejectsCode(finance.save(request(member, {...edit, requestId: randomUUID()})), "failed-precondition");
  const remove = {tripId: id, expenseId: saved.expenseId, expectedRevision: 2,
    requestId: randomUUID()};
  await rejectsCode(finance.remove(request(other, remove)), "permission-denied");
  assert.equal((await finance.remove(request(member, remove))).revision, 3);
  assert.equal((await finance.remove(request(member, remove))).replayed, true);
  await rejectsCode(finance.remove(request(owner, {...remove, requestId: randomUUID()})), "failed-precondition");
  await rejectsCode(finance.save(request(owner, {...edit, expectedRevision: 3,
    requestId: randomUUID()})), "failed-precondition");
});

test("owner text edits preserve original payer; concurrent revision writes have one winner", async () => {
  const id = await trip();
  const saved = await finance.save(request(member, input(id, {localDateTime: "2027-04-10T10:00:00"})));
  const base = input(id, {expenseId: saved.expenseId, expectedRevision: 1,
    name: "Renamed tickets"});
  const renamed = await finance.save(request(owner, base));
  assert.equal(renamed.revision, 2);
  const ref = db.doc(`trips/${id}/financeExpenses/${saved.expenseId}`);
  assert.deepEqual((await ref.get()).data().payerAmountsMinor, {[member]: 1001});
  assert.equal((await ref.get()).data().localDateTime, "2027-04-10T10:00:00");
  const redated = await finance.save(request(owner, input(id, {
    expenseId: saved.expenseId, expectedRevision: 2, date: "2027-04-11",
    payerAmountsMinor: {[member]: 1001}, requestId: randomUUID(),
  })));
  assert.equal(redated.revision, 3);
  assert.equal((await ref.get()).data().localDateTime, null);
  const version = input(id, {expenseId: saved.expenseId, expectedRevision: 3,
    payerAmountsMinor: {[member]: 1001}});
  const results = await Promise.allSettled([
    finance.save(request(owner, {...version, name: "Version A", requestId: randomUUID()})),
    finance.save(request(member, {...version, name: "Version B", requestId: randomUUID()})),
  ]);
  assert.equal(results.filter((result) => result.status === "fulfilled").length, 1);
  assert.equal((await ref.get()).data().revision, 4);
});

test("concurrent first expenses cannot select different currencies", async () => {
  const id = await trip();
  const results = await Promise.allSettled([
    finance.save(request(owner, input(id, {currencyCode: "USD"}))),
    finance.save(request(member, input(id, {currencyCode: "JPY", amount: "100"}))),
  ]);
  assert.equal(results.filter((result) => result.status === "fulfilled").length, 1);
  const currency = (await db.doc(`trips/${id}`).get()).data().financeCurrency;
  const docs = await db.collection(`trips/${id}/financeExpenses`).get();
  assert.equal(docs.size, 1);
  assert.equal(docs.docs[0].data().currencyCode, currency);
});

test("finance documents are readable by active travelers but never writable by clients", async () => {
  const id = await trip();
  const saved = await finance.save(request(owner, input(id)));
  const path = `trips/${id}/financeExpenses/${saved.expenseId}`;
  const active = env.authenticatedContext(member).firestore();
  const outsider = env.authenticatedContext(stranger).firestore();
  await assertSucceeds(getDoc(doc(active, path)));
  await assertFails(getDoc(doc(outsider, path)));
  await assertFails(setDoc(doc(active, `trips/${id}/financeExpenses/forged`), {amountMinor: 1}));
  await assertFails(updateDoc(doc(active, path), {amountMinor: 1}));
  await db.doc(`trips/${id}/members/${member}`).update({status: "left"});
  await assertFails(getDoc(doc(active, path)));
});

test("clients cannot forge trip currency or add legacy expenses after finance v2 starts", async () => {
  const id = await trip();
  const client = env.authenticatedContext(owner).firestore();
  const forgedId = randomUUID();
  await assertFails(setDoc(doc(client, `trips/${forgedId}`), {
    id: forgedId, createdBy: owner, joinedUsers: [], tripStatus: "upcoming",
    financeCurrency: "USD", financePrecision: 2, financeSchemaVersion: 2,
  }));
  await assertFails(updateDoc(doc(client, `trips/${id}`), {
    financeCurrency: "JPY", financePrecision: 0, financeSchemaVersion: 2,
  }));
  await finance.save(request(owner, input(id)));
  await assertFails(updateDoc(doc(client, `trips/${id}`), {financeCurrency: "JPY"}));
  await assertSucceeds(updateDoc(doc(client, `trips/${id}`), {title: "Updated title"}));
  await assertFails(setDoc(doc(client, `trips/${id}/expenses/old`), {
    tripId: id, createdBy: owner, amount: 10,
  }));
  await assertFails(setDoc(doc(client, `expense/${randomUUID()}`), {
    tripId: id, createdBy: owner, amount: 10,
  }));
});

test("server-owned review state freezes every legacy write while preserving source reads", async () => {
  const id = await trip({legacy: true});
  const nested = `trips/${id}/expenses/old`;
  const top = `expense/${randomUUID()}`;
  await db.doc(top).set({tripId: id, createdBy: owner, amount: 7});
  await db.doc(`trips/${id}`).update({expenses: [{name: "Old meal", amount: 7}],
    financeMigrationStatus: "reviewing"});
  const client = env.authenticatedContext(owner).firestore();
  await assertSucceeds(getDoc(doc(client, nested)));
  await assertSucceeds(getDoc(doc(client, top)));
  await assertFails(setDoc(doc(client, `trips/${id}/expenses/new`),
    {tripId: id, createdBy: owner, amount: 5}));
  await assertFails(updateDoc(doc(client, nested), {amount: 8}));
  await assertFails(deleteDoc(doc(client, nested)));
  await assertFails(setDoc(doc(client, `expense/${randomUUID()}`),
    {tripId: id, createdBy: owner, amount: 5}));
  await assertFails(updateDoc(doc(client, top), {amount: 8}));
  await assertFails(deleteDoc(doc(client, top)));
  await assertFails(updateDoc(doc(client, `trips/${id}`), {expenses: []}));
  await assertFails(updateDoc(doc(client, `trips/${id}`), {financeMigrationStatus: null}));
  await assertSucceeds(updateDoc(doc(client, `trips/${id}`), {title: "Still editable"}));
  await rejectsCode(finance.save(request(owner, input(id))), "failed-precondition");
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).empty, true);
});
