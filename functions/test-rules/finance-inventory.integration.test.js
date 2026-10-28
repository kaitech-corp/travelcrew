"use strict";

const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {auditFinancePage, auditTopLevelExpensePage} = require("../finance/inventory");

let app; let db;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-finance-inventory"}, "finance-inventory");
  db = getFirestore(app);
  await db.doc("trips/a").set({financeCurrency: "USD",
    expenses: [{name: "Old", amount: 10, paidByUsers: ["owner"]}]});
  await db.doc("trips/a/expenses/one").set({name: "Nested", amount: 5});
  await db.doc("expense/top").set({tripId: "a", name: "Top", amount: 3});
  await db.doc("expense/missing").set({name: "Missing", amount: 2});
  await db.doc("expense/orphan").set({tripId: "gone", name: "Orphan", amount: 4});
  await db.doc("trips/a/financeExpenses/new").set({id: "new", tripId: "a",
    financeSchemaVersion: 2, currencyCode: "USD", amountMinor: 1000,
    currencyPrecision: 2, payerAmountsMinor: {owner: 1000},
    sharesMinor: {owner: 1000},
    revision: 1, isDeleted: false});
  await db.doc("trips/a/financeTransfers/payment").set({status: "pending"});
  await db.doc("trips/b").set({financeCurrency: "USD"});
});

test("top-level scan finds orphan and missing trip references through Firestore", async () => {
  const first = await auditTopLevelExpensePage(db, {limit: 2});
  assert.equal(first.nextAfter, "orphan");
  assert.equal(first.totals.missingTripId, 1);
  assert.equal(first.totals.orphanTripId, 1);
  const second = await auditTopLevelExpensePage(db, {after: first.nextAfter, limit: 2});
  assert.equal(second.totals.linkedToTrip, 1);
  assert.equal(second.nextAfter, null);
  assert.equal((await db.doc("expense/orphan").get()).exists, true);
});
after(async () => {
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});

test("Admin inventory pages real Firestore queries without changing records", async () => {
  const first = await auditFinancePage(db, {limit: 1});
  assert.equal(first.nextAfter, "a");
  assert.equal(first.totals.legacyRecords, 3);
  assert.equal(first.totals.v2Records, 1);
  assert.equal(first.totals.transferRecords, 1);
  assert.equal(first.totals.mixedTrips, 1);
  assert.equal(first.totals.malformedV2, 0);
  const second = await auditFinancePage(db, {limit: 1, after: first.nextAfter});
  assert.equal(second.totals.currencyWithoutV2, 1);
  assert.equal((await db.doc("trips/a/financeExpenses/new").get()).data().amountMinor, 1000);
  assert.equal((await db.doc("expense/top").get()).data().amount, 3);
});
