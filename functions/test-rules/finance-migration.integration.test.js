"use strict";

const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {randomUUID} = require("node:crypto");
const fs = require("node:fs");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {collection, doc, getDoc, getDocs, updateDoc, setDoc} = require("firebase/firestore");
const {createMigrationHandlers} = require("../finance/migration-actions");
const {createBatchMigrationHandlers} = require("../finance/migration-batch-actions");

let app; let db; let env; let migration; let batchMigration;
const owner = "migration-owner"; const other = "migration-other";
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-finance-migration"}, "finance-migration-test");
  db = getFirestore(app);
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-finance-migration",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
  for (const uid of [owner, other]) await db.doc(`users/${uid}`).set({uid});
  migration = createMigrationHandlers(db);
  batchMigration = createBatchMigrationHandlers(db);
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});
async function fixture({embedded = [{name: "Meal", amount: 12.5}], nested = true,
  top = true} = {}) {
  const id = randomUUID();
  await db.doc(`trips/${id}`).set({id, createdBy: owner, tripStatus: "upcoming",
    isShared: false, joinedUsers: [other], expenses: embedded});
  if (nested) await db.doc(`trips/${id}/expenses/nested`).set({tripId: id,
    createdBy: owner, name: "Train", amount: 20, paidByUsers: [owner]});
  if (top) await db.doc(`expense/${id}`).set({tripId: id, createdBy: owner,
    name: "Bad record", amount: "unknown"});
  return id;
}
const call = (tripId, uid = owner) => ({auth: {uid}, data: {tripId}});
const code = (name) => (error) => error.code === name;
function approval(id, preview, overrides = {}) {
  return {auth: {uid: owner}, data: {
    tripId: id, requestId: randomUUID().replaceAll("-", ""),
    expectedRevision: preview.revision, currencyCode: "USD",
    decisions: preview.sources.map((source, index) => index === 0 ? {
      sourceId: source.sourceId, rawDigest: source.rawDigest,
      action: "migrate", name: "Reviewed meal", date: "2027-04-10",
      amount: "12.50", payerAmountsMinor: {[owner]: 1250},
      sharesMinor: {[owner]: 625, [other]: 625},
    } : {
      sourceId: source.sourceId, rawDigest: source.rawDigest,
      action: "exclude", reason: index === 1 ? "duplicate" : "invalid",
    }), ...overrides}};
}

test("owner starts review once, sees every raw source separately, and legacy writes freeze", async () => {
  const id = await fixture();
  await assert.rejects(migration.preview(call(id)), code("failed-precondition"));
  await assert.rejects(migration.begin(call(id, other)), code("permission-denied"));
  assert.deepEqual(await migration.begin(call(id)), {status: "reviewing", revision: 1});
  assert.deepEqual(await migration.begin(call(id)), {status: "reviewing", revision: 1});
  const preview = await migration.preview(call(id));
  assert.equal(preview.sourceCount, 3);
  assert.deepEqual(preview.sources.map((source) => source.source),
      ["embedded", "nested", "top"]);
  assert.equal(new Set(preview.sources.map((source) => source.sourceId)).size, 3);
  assert.ok(preview.sources.every((source) => source.currencyUnknown &&
    /^[a-f0-9]{64}$/.test(source.rawDigest)));
  assert.deepEqual(preview.sources[1].unverifiedTravelerHints, [owner]);
  await assert.rejects(migration.preview(call(id, other)), code("permission-denied"));
  const client = env.authenticatedContext(owner).firestore();
  await assertSucceeds(getDoc(doc(client, `trips/${id}/expenses/nested`)));
  await assertSucceeds(getDoc(doc(client, `expense/${id}`)));
  await assertFails(updateDoc(doc(client, `trips/${id}/expenses/nested`), {amount: 21}));
  await assertFails(setDoc(doc(client, `expense/${randomUUID()}`),
    {tripId: id, createdBy: owner, amount: 5}));
  await assertFails(updateDoc(doc(client, `trips/${id}`), {expenses: []}));
  await assertFails(updateDoc(doc(client, `trips/${id}`), {financeMigrationStatus: null}));
  await assertSucceeds(updateDoc(doc(client, `trips/${id}`), {title: "Planning continues"}));
});

test("provisional v2 ledger documents stay private until review completes", async () => {
  const id = await fixture();
  await migration.begin(call(id));
  const expense = db.doc(`trips/${id}/financeExpenses/provisional`);
  const transfer = db.doc(`trips/${id}/financeTransfers/provisional`);
  await expense.set({amountMinor: 1250});
  await transfer.set({amountMinor: 500});
  for (const uid of [owner, other]) {
    const client = env.authenticatedContext(uid).firestore();
    await assertFails(getDoc(doc(client, expense.path)));
    await assertFails(getDoc(doc(client, transfer.path)));
    await assertFails(getDocs(collection(client, `trips/${id}/financeExpenses`)));
    await assertFails(getDocs(collection(client, `trips/${id}/financeTransfers`)));
  }
  await db.doc(`trips/${id}`).update({financeMigrationStatus: "completed",
    financeSchemaVersion: 2});
  const member = env.authenticatedContext(other).firestore();
  await assertSucceeds(getDoc(doc(member, expense.path)));
  await assertSucceeds(getDoc(doc(member, transfer.path)));
});

test("review cannot start without sources or on a mixed v2 ledger", async () => {
  const empty = await fixture({embedded: [], nested: false, top: false});
  await assert.rejects(migration.begin(call(empty)), code("failed-precondition"));
  const mixed = await fixture();
  await db.doc(`trips/${mixed}/financeExpenses/existing`).set({amountMinor: 100});
  await assert.rejects(migration.begin(call(mixed)), code("failed-precondition"));
  assert.equal((await db.doc(`trips/${mixed}`).get()).data().financeMigrationStatus, undefined);
});

test("review fails explicitly above its source bound and on account restriction", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  let batch = db.batch();
  for (let index = 0; index < 1001; index++) {
    batch.set(db.doc(`trips/${id}/expenses/entry-${String(index).padStart(4, "0")}`),
        {tripId: id, name: `Entry ${index}`, amount: 1});
    if (index % 400 === 399) {
      await batch.commit();
      batch = db.batch();
    }
  }
  await batch.commit();
  await assert.rejects(migration.begin(call(id)), code("resource-exhausted"));
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeMigrationStatus, undefined);
  await db.doc(`safetyAccounts/${owner}`).set({restricted: true});
  await assert.rejects(migration.begin(call(id)), code("permission-denied"));
  await db.doc(`safetyAccounts/${owner}`).delete();
});

test("the 200-source boundary can complete without partial writes", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  const batch = db.batch();
  for (let index = 0; index < 200; index++) {
    batch.set(db.doc(`trips/${id}/expenses/entry-${String(index).padStart(3, "0")}`),
        {tripId: id, name: `Entry ${index}`, amount: 1});
  }
  await batch.commit();
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  assert.equal(preview.sourceCount, 200);
  const decisions = preview.sources.map((item) => ({sourceId: item.sourceId,
    rawDigest: item.rawDigest, action: "migrate", name: item.name,
    date: "2027-04-10", amount: "1.00",
    payerAmountsMinor: {[owner]: 100}, sharesMinor: {[owner]: 100}}));
  const result = await migration.commit(approval(id, preview, {decisions}));
  assert.equal(result.migratedCount, 200);
  assert.equal((await db.collection(`trips/${id}/financeMigrationSources`).get()).size, 200);
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 200);
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeMigrationStatus, "completed");
});

test("201 reviewed sources stage privately and become visible in one final transaction", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  const writes = db.batch();
  for (let index = 0; index < 201; index++) {
    writes.set(db.doc(`trips/${id}/expenses/entry-${String(index).padStart(3, "0")}`),
        {tripId: id, name: `Entry ${index}`, amount: 1});
  }
  await writes.commit();
  await migration.begin(call(id));
  const sources = (await migration.preview(call(id))).sources;
  const decisions = sources.map((item) => ({sourceId: item.sourceId,
    source: item.source, sourceRecordId: item.sourceRecordId,
    rawDigest: item.rawDigest, action: "migrate", name: item.name,
    date: "2027-04-10", amount: "1.00",
    payerAmountsMinor: {[owner]: 100}, sharesMinor: {[owner]: 100}}));
  const planId = randomUUID().replaceAll("-", "");
  const request = (items) => ({auth: {uid: owner}, data: {tripId: id,
    requestId: planId, expectedRevision: 1, currencyCode: "USD",
    sourceCount: sources.length, decisions: items}});
  for (let index = 0; index < decisions.length; index += 100) {
    await batchMigration.stage(request(decisions.slice(index, index + 100)));
  }
  assert.equal((await batchMigration.stage(request(decisions.slice(0, 100)))).replayed, true);
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeMigrationStatus, "reviewing");
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 201);
  const member = env.authenticatedContext(other).firestore();
  await assertFails(getDocs(collection(member, `trips/${id}/financeExpenses`)));
  await assertFails(getDoc(doc(member, `trips/${id}/financeMigrationPlans/current`)));
  await assertFails(updateDoc(doc(env.authenticatedContext(owner).firestore(), `trips/${id}`),
      {financeMigrationPlanId: "forged"}));
  const finish = {auth: {uid: owner}, data: {tripId: id, requestId: planId,
    expectedRevision: 1}};
  await assert.rejects(batchMigration.finish({auth: {uid: other}, data: finish.data}),
      code("permission-denied"));
  const firstExpense = db.doc(`trips/${id}/financeExpenses/migrated_${sources[0].sourceId.slice(0, 40)}`);
  await firstExpense.update({amountMinor: 999});
  await assert.rejects(batchMigration.finish(finish), code("failed-precondition"));
  await firstExpense.update({amountMinor: 100});
  const firstSource = db.doc(`trips/${id}/expenses/${sources[0].sourceRecordId}`);
  await firstSource.update({amount: 2});
  await assert.rejects(batchMigration.finish(finish), code("failed-precondition"));
  await firstSource.update({amount: 1});
  assert.equal((await batchMigration.finish(finish)).migratedCount, 201);
  assert.equal((await batchMigration.finish(finish)).replayed, true);
  assert.equal((await getDocs(collection(member, `trips/${id}/financeExpenses`))).size, 201);
});

test("1000 reviewed expenses finish at the supported batch boundary", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  let writes = db.batch();
  for (let index = 0; index < 1000; index++) {
    writes.set(db.doc(`trips/${id}/expenses/entry-${String(index).padStart(4, "0")}`),
        {tripId: id, name: `Entry ${index}`, amount: 1});
    if (index % 400 === 399) {
      await writes.commit();
      writes = db.batch();
    }
  }
  await writes.commit();
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  assert.equal(preview.sourceCount, 1000);
  const planId = randomUUID().replaceAll("-", "");
  const decisions = preview.sources.map((item) => ({sourceId: item.sourceId,
    source: item.source, sourceRecordId: item.sourceRecordId,
    rawDigest: item.rawDigest, action: "migrate", name: item.name,
    date: "2027-04-10", amount: "1.00",
    payerAmountsMinor: {[owner]: 100}, sharesMinor: {[owner]: 100}}));
  for (let index = 0; index < decisions.length; index += 100) {
    await batchMigration.stage({auth: {uid: owner}, data: {tripId: id,
      requestId: planId, expectedRevision: 1, currencyCode: "USD",
      sourceCount: 1000, decisions: decisions.slice(index, index + 100)}});
  }
  const result = await batchMigration.finish({auth: {uid: owner}, data: {
    tripId: id, requestId: planId, expectedRevision: 1}});
  assert.equal(result.migratedCount, 1000);
  assert.equal((await db.collection(`trips/${id}/financeMigrationSources`).get()).size, 1000);
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 1000);
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeMigrationStatus, "completed");
});

test("a stale batch cannot complete and abort can be resumed", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  const writes = db.batch();
  for (let index = 0; index < 201; index++) {
    writes.set(db.doc(`trips/${id}/expenses/entry-${String(index).padStart(3, "0")}`),
        {tripId: id, name: `Entry ${index}`, amount: 1});
  }
  await writes.commit();
  await migration.begin(call(id));
  const sources = (await migration.preview(call(id))).sources;
  const planId = randomUUID().replaceAll("-", "");
  const decisions = sources.slice(0, 2).map((item) => ({sourceId: item.sourceId,
    source: item.source, sourceRecordId: item.sourceRecordId,
    rawDigest: item.rawDigest, action: "migrate", name: item.name,
    date: "2027-04-10", amount: "1.00",
    payerAmountsMinor: {[owner]: 100}, sharesMinor: {[owner]: 100}}));
  await assert.rejects(batchMigration.stage({auth: {uid: other}, data: {tripId: id,
    requestId: planId, expectedRevision: 1, currencyCode: "USD",
    sourceCount: sources.length, decisions}}), code("permission-denied"));
  await batchMigration.stage({auth: {uid: owner}, data: {tripId: id,
    requestId: planId, expectedRevision: 1, currencyCode: "USD",
    sourceCount: sources.length, decisions}});
  const control = {auth: {uid: owner}, data: {tripId: id,
    requestId: planId, expectedRevision: 1}};
  await assert.rejects(batchMigration.abort({auth: {uid: other}, data: control.data}),
      code("permission-denied"));
  await assert.rejects(batchMigration.finish(control), code("failed-precondition"));
  await db.doc(`trips/${id}/expenses/${sources[0].sourceRecordId}`).update({amount: 2});
  await assert.rejects(batchMigration.stage({auth: {uid: owner},
    data: {tripId: id, requestId: planId, expectedRevision: 1,
      currencyCode: "USD", sourceCount: sources.length, decisions}}),
  code("failed-precondition"));
  assert.equal((await batchMigration.abort(control)).cleared, false);
  assert.equal((await batchMigration.abort(control)).cleared, true);
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 0);
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeMigrationPlanId, undefined);
});

test("competing batch plans cannot stage two ledgers", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  const writes = db.batch();
  for (let index = 0; index < 201; index++) {
    writes.set(db.doc(`trips/${id}/expenses/entry-${String(index).padStart(3, "0")}`),
        {tripId: id, name: `Entry ${index}`, amount: 1});
  }
  await writes.commit();
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  const item = preview.sources[0];
  const decision = {sourceId: item.sourceId, source: item.source,
    sourceRecordId: item.sourceRecordId, rawDigest: item.rawDigest,
    action: "exclude", reason: "duplicate"};
  const request = (idempotencyKey) => ({auth: {uid: owner}, data: {tripId: id,
    requestId: idempotencyKey, expectedRevision: 1, currencyCode: "USD",
    sourceCount: 201, decisions: [decision]}});
  const first = randomUUID().replaceAll("-", "");
  const second = randomUUID().replaceAll("-", "");
  const results = await Promise.allSettled([
    batchMigration.stage(request(first)), batchMigration.stage(request(second)),
  ]);
  assert.equal(results.filter((item) => item.status === "fulfilled").length, 1);
  assert.equal((await db.collection(`trips/${id}/financeMigrationSources`).get()).size, 1);
  const active = (await db.doc(`trips/${id}`).get()).data().financeMigrationPlanId;
  assert.ok(active === first || active === second);
  const control = {auth: {uid: owner}, data: {tripId: id,
    requestId: active, expectedRevision: 1}};
  assert.equal((await batchMigration.abort(control)).cleared, false);
  assert.equal((await batchMigration.abort(control)).cleared, true);
});

test("owner approval atomically records every decision and exact v2 balance without altering originals", async () => {
  const id = await fixture();
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  const request = approval(id, preview);
  const result = await migration.commit(request);
  assert.deepEqual(result, {status: "completed", revision: 2,
    migratedCount: 1, replayed: false});
  assert.equal((await migration.commit(request)).replayed, true);
  await assert.rejects(migration.commit(approval(id, preview)), code("failed-precondition"));
  const trip = (await db.doc(`trips/${id}`).get()).data();
  assert.equal(trip.financeMigrationStatus, "completed");
  assert.equal(trip.financeSchemaVersion, 2);
  assert.equal(trip.financeCurrency, "USD");
  const migrated = await db.collection(`trips/${id}/financeExpenses`).get();
  assert.equal(migrated.size, 1);
  assert.equal(migrated.docs[0].data().amountMinor, 1250);
  assert.deepEqual(migrated.docs[0].data().payerAmountsMinor, {[owner]: 1250});
  assert.deepEqual(migrated.docs[0].data().sharesMinor, {[owner]: 625, [other]: 625});
  assert.equal((await db.collection(`trips/${id}/financeMigrationSources`).get()).size, 3);
  assert.equal((await db.doc(`trips/${id}/expenses/nested`).get()).exists, true);
  assert.equal((await db.doc(`expense/${id}`).get()).exists, true);
  const member = env.authenticatedContext(other).firestore();
  await assertSucceeds(getDoc(doc(member, migrated.docs[0].ref.path)));
  await assertFails(getDoc(doc(member,
    `trips/${id}/financeMigrationSources/${preview.sources[0].sourceId}`)));
});

test("changed sources, wrong allocations and unverified travelers prevent partial migration", async () => {
  const id = await fixture();
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  const badAmount = approval(id, preview);
  badAmount.data.decisions[0].sharesMinor = {[owner]: 500, [other]: 500};
  await assert.rejects(migration.commit(badAmount), code("invalid-argument"));
  const badTraveler = approval(id, preview);
  badTraveler.data.decisions[0].sharesMinor = {[owner]: 625, "migration-stranger": 625};
  await assert.rejects(migration.commit(badTraveler), code("invalid-argument"));
  await db.doc(`trips/${id}/expenses/nested`).update({amount: 22});
  await assert.rejects(migration.commit(approval(id, preview)), code("failed-precondition"));
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 0);
  assert.equal((await db.collection(`trips/${id}/financeMigrationSources`).get()).size, 0);
  assert.equal((await db.doc(`trips/${id}`).get()).data().financeMigrationStatus, "reviewing");
});

test("review detects a stored timestamp changed to an equal-looking string", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  const when = new Date("2027-04-10T12:00:00.000Z");
  await db.doc(`trips/${id}/expenses/dated`).set({tripId: id, name: "Meal",
    amount: 12.5, date: when});
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  await db.doc(`trips/${id}/expenses/dated`).update({date: when.toISOString()});
  const request = approval(id, preview);
  await assert.rejects(migration.commit(request), code("failed-precondition"));
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 0);
});

test("review detects a timestamp change below millisecond precision", async () => {
  const id = await fixture({embedded: [], nested: false, top: false});
  await db.doc(`trips/${id}/expenses/dated`).set({tripId: id, name: "Meal",
    amount: 12.5, date: new Timestamp(1800000000, 1000)});
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  await db.doc(`trips/${id}/expenses/dated`).update({date: new Timestamp(1800000000, 2000)});
  await assert.rejects(migration.commit(approval(id, preview)), code("failed-precondition"));
});

test("competing owner approvals commit at most one reviewed ledger", async () => {
  const id = await fixture();
  await migration.begin(call(id));
  const preview = await migration.preview(call(id));
  const results = await Promise.allSettled([
    migration.commit(approval(id, preview)), migration.commit(approval(id, preview)),
  ]);
  assert.equal(results.filter((item) => item.status === "fulfilled").length, 1);
  assert.equal((await db.collection(`trips/${id}/financeMigrationSources`).get()).size, 3);
  assert.equal((await db.collection(`trips/${id}/financeExpenses`).get()).size, 1);
});

test("review uses exact zero- and three-decimal currency precision", async () => {
  for (const [codeName, amount, minor] of [["JPY", "42", 42], ["KWD", "1.234", 1234]]) {
    const id = await fixture({embedded: [{name: "Taxi", amount: 42}], nested: false,
      top: false});
    await migration.begin(call(id));
    const preview = await migration.preview(call(id));
    const request = approval(id, preview, {currencyCode: codeName});
    request.data.decisions[0].amount = codeName === "JPY" ? "42.1" : "1.2345";
    request.data.decisions[0].payerAmountsMinor = {[owner]: minor};
    request.data.decisions[0].sharesMinor = {[owner]: minor};
    await assert.rejects(migration.commit(request), code("invalid-argument"));
    request.data.decisions[0].amount = amount;
    const saved = await migration.commit(request);
    assert.equal(saved.migratedCount, 1);
    const docs = await db.collection(`trips/${id}/financeExpenses`).get();
    assert.equal(docs.docs[0].data().amountMinor, minor);
    assert.equal(docs.docs[0].data().currencyCode, codeName);
  }
});
