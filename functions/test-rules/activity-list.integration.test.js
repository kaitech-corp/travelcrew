const {before, after, beforeEach, test} = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, getDoc, getDocs, collection} = require("firebase/firestore");
const {createActivityListHandler} = require("../trip-activities");

let app; let db; let env; let list;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-activity-list"}, "activity-list-test");
  db = getFirestore(app);
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-activity-list",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
  list = createActivityListHandler(db);
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});
beforeEach(async () => {
  await env.clearFirestore();
  await db.doc("trips/trip").set({id: "trip", createdBy: "owner", joinedUsers: ["member"], tripStatus: "upcoming"});
  await db.doc("trips/trip/members/member").set({userId: "member", status: "active"});
});
const request = (uid, data = {tripId: "trip"}) => ({auth: uid ? {uid} : null, data});
const code = (name) => (error) => error.code === name;

test("server filters moderation, deletion and private metadata while client lists are closed", async () => {
  await db.doc("trips/trip/activities/visible").set({id: "visible", tripId: "trip", title: "Museum",
    description: "Visit", createdBy: "owner", likedBy: [], likesCount: 0, contentRevision: 1,
    privateModerationNote: "not for clients"});
  await db.doc("trips/trip/activities/removed").set({id: "removed", tripId: "trip", title: "Secret",
    description: "Hidden", moderationRemoved: true});
  await db.doc("trips/trip/activities/deleted").set({id: "deleted", tripId: "trip", title: "",
    description: "", isDeleted: true});
  const result = await list(request("member"));
  assert.equal(result.source, "canonical");
  assert.deepEqual(result.activities.map((activity) => activity.id), ["visible"]);
  assert.equal(result.activities[0].title, "Museum");
  assert.equal(result.activities[0].privateModerationNote, undefined);
  assert.equal(result.nextCursor, null);
  assert.equal(result.nextSource, "legacy");
  const client = env.authenticatedContext("member").firestore();
  await assertFails(getDocs(collection(client, "trips/trip/activities")));
  await assertSucceeds(getDoc(doc(client, "trips/trip/activities/visible")));
  await assertFails(getDoc(doc(client, "trips/trip/activities/removed")));
  await assert.rejects(list(request(null)), code("unauthenticated"));
  await assert.rejects(list(request("stranger")), code("permission-denied"));
  await assert.rejects(list(request("member", {tripId: "trip", extra: true})), code("invalid-argument"));
  await db.doc("trips/trip/members/member").update({status: "left"});
  await assert.rejects(list(request("member")), code("permission-denied"));
});

test("legacy fallback pages by ID without leaking removed records", async () => {
  const batch = db.batch();
  for (let i = 0; i < 103; i++) {
    const id = `old-${String(i).padStart(3, "0")}`;
    batch.set(db.doc(`activity/${id}`), {id, tripId: "trip", title: id,
      description: "", moderationRemoved: i === 50, isDeleted: i === 51});
  }
  batch.set(db.doc("activity/other-trip"), {id: "other-trip", tripId: "other", title: "Other"});
  await batch.commit();
  const first = await list(request("owner"));
  assert.equal(first.source, "legacy");
  assert.equal(first.source, "legacy");
  assert.equal(first.activities.length, 98);
  assert.equal(first.activities.every((item) => item.isLegacy === true), true);
  assert.equal(first.nextCursor, "old-099");
  const second = await list(request("owner", {tripId: "trip", source: first.source, cursor: first.nextCursor}));
  assert.deepEqual(second.activities.map((item) => item.id), ["old-100", "old-101", "old-102"]);
  assert.equal(second.nextCursor, null);
  await db.doc("trips/trip/activities/old-102").set({id: "old-102", tripId: "trip", title: "New"});
  const changed = await list(request("owner", {tripId: "trip", source: "legacy", cursor: "old-099"}));
  assert.deepEqual(changed.activities.map((item) => item.id), ["old-100", "old-101"]);
});

test("canonical tombstones mask matching legacy IDs while distinct old activities remain", async () => {
  await db.doc("trips/trip/activities/shared").set({id: "shared", tripId: "trip", title: "Canonical"});
  await db.doc("trips/trip/activities/deleted").set({id: "deleted", tripId: "trip", isDeleted: true});
  await db.doc("activity/shared").set({id: "shared", tripId: "trip", title: "Old duplicate"});
  await db.doc("activity/deleted").set({id: "deleted", tripId: "trip", title: "Must stay deleted"});
  await db.doc("activity/old-only").set({id: "old-only", tripId: "trip", title: "Old distinct"});
  const current = await list(request("member"));
  assert.deepEqual(current.activities.map((item) => item.id), ["shared"]);
  assert.equal(current.nextSource, "legacy");
  const old = await list(request("member", {tripId: "trip", source: current.nextSource}));
  assert.deepEqual(old.activities.map((item) => item.id), ["old-only"]);
});
