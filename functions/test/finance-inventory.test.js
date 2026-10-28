"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {auditFinancePage, auditTopLevelExpensePage, legacyShape} = require("../finance/inventory");
const {main} = require("../finance/inventory-cli");

function fixture() {
  const tripA = {financeCurrency: "USD",
    expenses: [{name: "Hotel", amount: 42, paidByUsers: ["u"]}]};
  const trips = [{id: "a", data: () => tripA},
  {id: "b", data: () => ({financeCurrency: "USD", expenses: []})}];
  const nested = {a: [{id: "n", data: () => ({name: "Taxi", amount: 10})}], b: []};
  const top = {a: [], b: [{id: "t", data: () => ({name: "Old", amount: "5"})}]};
  const topDocs = [
    {id: "missing", data: () => ({name: "No trip", amount: 4})},
    {id: "orphan", data: () => ({tripId: "gone", name: "Orphan", amount: 5})},
    {id: "linked", data: () => ({tripId: "a", name: "Linked", amount: 6})},
  ].sort((a, b) => a.id.localeCompare(b.id));
  const v2 = {a: [{id: "e", data: () => ({id: "e", tripId: "a",
    financeSchemaVersion: 2, currencyCode: "USD", amountMinor: 4200,
    currencyPrecision: 2, payerAmountsMinor: {u: 4200}, sharesMinor: {u: 4200},
    revision: 1, isDeleted: false})}], b: []};
  const transfers = {a: [{id: "p"}], b: []};
  let reads = 0;
  function snapshot(items, limit) {
    reads++;
    const docs = items.slice(0, limit);
    return {docs, size: docs.length};
  }
  function source(items) {
    return {limit: (limit) => ({get: async () => snapshot(items, limit)})};
  }
  const db = {collection(name) {
    if (name === "trips") return {
      doc: (id) => ({id, collection: (child) => source(({expenses: nested,
        financeExpenses: v2, financeTransfers: transfers})[child][id])}),
      orderBy: () => ({limit: (limit) => ({
        get: async () => snapshot(trips, limit),
        startAfter: (after) => ({get: async () => snapshot(trips.filter((t) => t.id > after), limit)}),
      })}),
    };
    if (name === "expense") return {
      where: (_field, _op, id) => source(top[id]),
      orderBy: () => ({limit: (limit) => ({
        get: async () => snapshot(topDocs, limit),
        startAfter: (after) => ({get: async () => snapshot(topDocs.filter((d) => d.id > after), limit)}),
      })}),
    };
    throw Error(`Unexpected collection: ${name}`);
  }, getAll: async (...refs) => {
    reads++;
    return refs.map((ref) => ({exists: trips.some((t) => t.id === ref.id)}));
  }};
  return {db, nested, tripA, get reads() { return reads; }};
}

test("inventory distinguishes ambiguous and missing legacy payer data", () => {
  assert.equal(legacyShape({name: "Old", amount: 1, paidByUsers: ["u"]}), "ambiguousPayer");
  assert.equal(legacyShape({name: "Old", amount: 1}), "missingPayer");
  assert.equal(legacyShape({name: "Old", amount: "1"}), "malformed");
});

test("read-only finance inventory counts all legacy locations and mixed schemas", async () => {
  const state = fixture();
  const first = await auditFinancePage(state.db, {limit: 1});
  assert.equal(first.nextAfter, "a");
  assert.equal(first.totals.embeddedRecords, 1);
  assert.equal(first.totals.nestedRecords, 1);
  assert.equal(first.totals.v2Records, 1);
  assert.equal(first.totals.transferRecords, 1);
  assert.equal(first.totals.mixedTrips, 1);
  assert.equal(first.totals.ambiguousPayer, 1);
  assert.equal(first.totals.malformedV2, 0);
  assert.equal(first.totals.legacyMissingIds, 1);
  const second = await auditFinancePage(state.db, {after: "a", limit: 1});
  assert.equal(second.totals.malformed, 1);
  assert.equal(second.totals.topLevelRecords, 1);
  assert.equal(second.totals.currencyWithoutV2, 1);
  assert.equal(state.reads, 10);
});

test("CLI requires an explicit target before touching Firestore", async () => {
  const state = fixture();
  await assert.rejects(main([], {db: state.db}), /--project PROJECT --database DATABASE/);
  assert.equal(state.reads, 0);
  let output;
  await main(["--project", "demo-travel", "--database", "travel-crew-db-2",
    "--limit", "1", "--pages", "1"],
  {db: state.db, app: {}, print: (value) => { output = JSON.parse(value); }});
  assert.equal(output.scanComplete, false);
  assert.equal(output.coverageComplete, false);
  assert.equal(output.nextAfter, "a");
  assert.equal(output.totals.legacyRecords, 2);
});

test("top-level scan finds missing and orphan trip references across pages", async () => {
  const state = fixture();
  const first = await auditTopLevelExpensePage(state.db, {limit: 2});
  assert.equal(first.nextAfter, "missing");
  assert.equal(first.totals.missingTripId, 1);
  assert.equal(first.totals.linkedToTrip, 1);
  const second = await auditTopLevelExpensePage(state.db, {after: first.nextAfter, limit: 2});
  assert.equal(second.totals.orphanTripId, 1);
  let output;
  await main(["--project", "demo-travel", "--database", "travel-crew-db-2",
    "--scan", "top-level", "--limit", "2", "--pages", "2"],
  {db: state.db, app: {}, print: (value) => { output = JSON.parse(value); }});
  assert.equal(output.scanComplete, true);
  assert.equal(output.coverageComplete, true);
  assert.equal(output.totals.recordsScanned, 3);
  assert.equal(output.totals.orphanTripId, 1);
});

test("capped source is reported as incomplete with its trip ID", async () => {
  const state = fixture();
  state.nested.a.push({id: "n2", data: () => ({name: "More", amount: 12})});
  const page = await auditFinancePage(state.db, {limit: 1, maxDocsPerSource: 1});
  assert.deepEqual(page.cappedTripIds, ["a"]);
  assert.equal(page.totals.sourceCappedTrips, 1);
  assert.equal(page.totals.nestedRecords, 1);
});

test("inventory flags duplicate IDs across embedded and nested legacy sources", async () => {
  const state = fixture();
  state.tripA.expenses[0].id = "n";
  const page = await auditFinancePage(state.db, {limit: 1});
  assert.equal(page.totals.legacyIdCollisions, 1);
  assert.equal(page.totals.legacyMissingIds, 0);
});
