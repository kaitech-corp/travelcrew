const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {randomUUID, createHash} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {createPhotoService} = require("../trip-photos");
const {createTripService} = require("../assistant-trip");
let app; let db;
const url = "https://upload.wikimedia.org/wikipedia/commons/a/ab/Tokyo.jpg";
const trip = {destination: "Tokyo", country: "Japan", start_date: "2027-04-10", end_date: "2027-04-12"};
const digest = (s) => createHash("sha256").update(s).digest("hex");
before(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-safety"}, "trip-photos");
  db = getFirestore(app, "trip-photos");
});
after(async () => { if (db) await db.terminate(); if (app) await deleteApp(app); });
async function account() { const uid = randomUUID(); await db.doc(`users/${uid}`).set({uid}); return uid; }
function service(overrides = {}) {
  const calls = {load: 0, scan: 0, save: 0, delete: 0};
  const prepare = createPhotoService({db, bucket: () => ({name: "test-bucket", file: () => ({
    save: async () => { calls.save++; }, delete: async () => { calls.delete++; },
  })}), load: async () => { calls.load++; return {bytes: Buffer.from("photo"), credit: {license: "CC0"}}; },
  normalize: async (data) => data, scan: async () => { calls.scan++; return false; }, ...overrides});
  return {prepare, calls};
}
test("prepared photos are owner-scoped, cached, quota-limited and blocked for restricted/deleted accounts", async () => {
  const owner = await account(); const other = await account(); const {prepare, calls} = service();
  const first = await prepare(owner, url); assert.equal(first.status, "ready");
  assert.deepEqual(await prepare(owner, url), first); assert.equal(calls.load, 1);
  assert.notEqual((await prepare(other, url)).url, first.url); assert.equal(calls.load, 2);
  await db.doc(`safetyAccounts/${owner}`).set({restricted: true});
  await assert.rejects(prepare(owner, url), (e) => e.code === "permission-denied");
  await db.doc(`users/${other}`).update({isDeleted: true});
  await assert.rejects(prepare(other, url));
  const limited = await account();
  await db.doc(`tripPhotoQuotas/${digest(`${limited}:${Math.floor(Date.now() / 86400000)}`)}`).set({count: 20});
  assert.equal((await prepare(limited, url)).status, "unavailable"); assert.equal(calls.load, 2);
});
test("concurrent duplicate preparation performs one download and never changes trips", async () => {
  const uid = await account(); const {prepare, calls} = service();
  await Promise.all(Array.from({length: 4}, () => prepare(uid, url)));
  assert.equal(calls.load, 1); assert.equal(calls.save, 1);
  assert.equal((await db.collection("trips").where("createdBy", "==", uid).get()).size, 0);
});
test("moderation rejection and scanner/network failure store no image, remain retry-bounded", async () => {
  for (const scan of [async () => true, async () => { throw new Error("scan unavailable"); }]) {
    const uid = await account(); const {prepare, calls} = service({scan});
    assert.equal((await prepare(uid, url)).status, "unavailable"); assert.equal(calls.save, 0);
    await prepare(uid, url); assert.equal(calls.load, 1);
  }
  const uid = await account(); const {prepare, calls} = service({load: async () => { throw new Error("network unavailable"); }});
  assert.equal((await prepare(uid, url)).status, "unavailable"); assert.equal(calls.save, 0);
});
test("account restriction during processing discards the uploaded object", async () => {
  const uid = await account(); const {prepare, calls} = service({scan: async () => {
    await db.doc(`safetyAccounts/${uid}`).set({restricted: true}); return false;
  }});
  assert.equal((await prepare(uid, url)).status, "unavailable"); assert.equal(calls.delete, 1);
});
test("MCP creation stores only prepared photos, preserves optional fields, and retries never overwrite manual covers", async () => {
  const uid = await account(); const {prepare, calls} = service();
  const create = createTripService(db, "https://travelcrew.app/assistant", undefined, prepare);
  const key = randomUUID(); const input = {...trip, image_url: url};
  const first = await create(uid, input, key);
  assert.equal(first.cover_status, "ready");
  const ref = db.doc(`trips/${first.trip_id}`); const saved = (await ref.get()).data();
  assert.equal(saved.images.length, 1); assert.ok(saved.images[0].startsWith("https://firebasestorage.googleapis.com/"));
  assert.equal(saved.imageCredits[saved.images[0]].license, "CC0"); assert.equal(saved.expensePerNight, null);
  await ref.update({images: ["manual-cover"]});
  const retry = await create(uid, input, key); assert.equal(retry.trip_id, first.trip_id); assert.equal(calls.load, 1);
  assert.deepEqual((await ref.get()).data().images, ["manual-cover"]);
  await assert.rejects(create(uid, {...input, title: "changed"}, key), (e) => e.status === 409);
});
test("unsupported HTTPS and processing failures still create one private editable trip without a cover", async () => {
  const uid = await account(); const {prepare, calls} = service();
  const create = createTripService(db, "https://travelcrew.app/assistant", undefined, prepare);
  const result = await create(uid, {...trip, image_url: "https://169.254.169.254/private.jpg"}, randomUUID());
  const saved = (await db.doc(`trips/${result.trip_id}`).get()).data();
  assert.equal(result.cover_status, "unavailable"); assert.deepEqual(saved.images, []); assert.equal(saved.isPrivate, true); assert.equal(calls.load, 0);
  const fail = createTripService(db, "https://travelcrew.app/assistant", undefined, async () => { throw new Error("offline"); });
  assert.equal((await fail(uid, {...trip, image_url: url}, randomUUID())).cover_status, "unavailable");
  const legacy = await create(uid, trip, randomUUID()); assert.equal(legacy.cover_status, undefined);
});
