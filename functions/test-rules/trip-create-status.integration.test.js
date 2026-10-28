const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const {randomUUID} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {initializeTestEnvironment} = require("@firebase/rules-unit-testing");
const {createTripStatusHandler} = require("../trip-create-status");

let app; let db; let env;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-trip-create"}, "trip-create-status");
  db = getFirestore(app);
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-trip-create",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});

test("status callable distinguishes a missing trip, the owner, and another user", async () => {
  const id = randomUUID();
  const check = createTripStatusHandler(db);
  const request = (uid) => ({auth: {uid}, data: {tripId: id}});
  assert.deepEqual(await check(request("owner")), {exists: false});
  await db.doc(`trips/${id}`).set({id, createdBy: "owner", tripStatus: "upcoming"});
  assert.deepEqual(await check(request("owner")), {exists: true});
  assert.deepEqual(await check(request("stranger")), {exists: false});
});
