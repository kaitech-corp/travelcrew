const {before, after, beforeEach, test} = require("node:test");
const fs = require("node:fs");
const assert = require("node:assert/strict");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, collection, getDocs, getDoc, setDoc, updateDoc, deleteDoc, serverTimestamp} = require("firebase/firestore");

let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-activity-contract",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
});
after(async () => { if (env) await env.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "trips/trip"), {id: "trip", createdBy: "owner",
      joinedUsers: ["author", "member"], tripStatus: "upcoming", isShared: false});
    for (const uid of ["author", "member"]) {
      await setDoc(doc(db, `trips/trip/members/${uid}`), {userId: uid, status: "active"});
    }
    await setDoc(doc(db, "trips/trip/activities/existing"), {id: "existing", tripId: "trip",
      createdBy: "author", title: "Museum", description: "Visit", likedBy: [], likesCount: 0});
    await setDoc(doc(db, "trips/trip/activities/legacy"), {id: "legacy", tripId: "trip",
      title: "Old", description: "Visit", likedBy: [], likesCount: 0});
    await setDoc(doc(db, "activity/top-old"), {id: "top-old", tripId: "trip",
      title: "Older", description: "Visit", likedBy: [], likesCount: 0});
  });
});
const dbFor = (uid) => env.authenticatedContext(uid).firestore();
const entry = (id, author = "author") => ({id, tripId: "trip", createdBy: author,
  title: "Park", description: "A walk", location: "Tokyo",
  startDateTime: "2027-04-10T10:00:00+09:00", endDateTime: null,
  likedBy: [], likesCount: 0, contentRevision: 1});
const tombstone = (actor, contentRevision = 1) => ({isDeleted: true, deletedBy: actor, deletedAt: serverTimestamp(),
  title: "", description: "", location: null, startDateTime: null,
  endDateTime: null, likedBy: [], likesCount: 0, contentRevision});

test("active travelers create only valid self-authored activities", async () => {
  const author = dbFor("author");
  await assertFails(getDocs(collection(author, "trips/trip/activities")));
  await assertSucceeds(setDoc(doc(author, "trips/trip/activities/new"), entry("new")));
  for (const forged of [
    {...entry("forged"), createdBy: "owner"},
    {...entry("forged"), id: "other"},
    {...entry("forged"), tripId: "other"},
    {...entry("forged"), moderationRemoved: false},
    {...entry("forged"), likedBy: ["author"], likesCount: 1},
    {...entry("forged"), startDateTime: "not a date"},
    {...entry("forged"), title: ""},
    {...entry("forged"), contentRevision: 0},
  ]) await assertFails(setDoc(doc(author, "trips/trip/activities/forged"), forged));
  await assertFails(setDoc(doc(dbFor("stranger"), "trips/trip/activities/outsider"), entry("outsider", "stranger")));
  const owner = dbFor("owner");
  const oldShape = entry("owner-old", "owner"); delete oldShape.createdBy;
  await assertSucceeds(setDoc(doc(owner, "trips/trip/activities/owner-old"), oldShape));
  await assertFails(setDoc(doc(author, "trips/trip/activities/member-old"),
      {...oldShape, id: "member-old"}));
});

test("content edits preserve identity and votes; legacy records remain owner-managed", async () => {
  const author = dbFor("author"); const member = dbFor("member"); const owner = dbFor("owner");
  const ref = doc(author, "trips/trip/activities/existing");
  await assertSucceeds(updateDoc(ref, {title: "Gallery", location: null, contentRevision: 1}));
  await assertSucceeds(updateDoc(doc(owner, "trips/trip/activities/existing"), {description: "Updated", contentRevision: 2}));
  await assertFails(updateDoc(doc(member, "trips/trip/activities/existing"), {title: "Hijacked"}));
  for (const patch of [{createdBy: "member"}, {tripId: "other"}, {id: "other"},
    {likesCount: 99}, {title: "Edited", likedBy: ["member"]},
    {moderationRemoved: false}, {startDateTime: "nonsense"}]) {
    await assertFails(updateDoc(ref, patch));
  }
  await assertFails(updateDoc(doc(author, "trips/trip/activities/legacy"), {title: "Stolen"}));
  await assertSucceeds(updateDoc(doc(owner, "trips/trip/activities/legacy"), {title: "Owner edited", contentRevision: 1}));
  await assertFails(updateDoc(doc(member, "activity/top-old"), {title: "Stolen"}));
  await assertFails(updateDoc(doc(owner, "activity/top-old"), {startDateTime: "invalid"}));
  await assertSucceeds(updateDoc(doc(owner, "activity/top-old"), {title: "Owner edited", contentRevision: 1}));
  await assertFails(updateDoc(doc(author, "trips/trip/activities/missing"), {title: "Resurrected"}));
  assert.equal((await getDoc(doc(owner, "trips/trip/activities/missing"))).exists(), false);
});

test("stale content revisions cannot overwrite edits or delete; votes stay independent", async () => {
  const author = dbFor("author");
  const member = dbFor("member");
  const ref = doc(author, "trips/trip/activities/existing");
  await assertSucceeds(updateDoc(ref, {title: "Gallery", contentRevision: 1}));
  await assertFails(updateDoc(ref, {title: "Stale", contentRevision: 1}));
  await assertFails(updateDoc(ref, tombstone("author", 1)));
  await assertSucceeds(updateDoc(doc(member, "trips/trip/activities/existing"),
      {likedBy: ["member"], likesCount: 1}));
  assert.equal((await getDoc(ref)).data().contentRevision, 1);
  await assertSucceeds(updateDoc(ref, {description: "New", contentRevision: 2}));
  assert.deepEqual((await getDoc(ref)).data().likedBy, ["member"]);
  await assertSucceeds(updateDoc(ref, tombstone("author", 3)));
  await assertFails(updateDoc(ref, {title: "Revived", contentRevision: 4}));
  const old = doc(dbFor("owner"), "activity/top-old");
  await assertSucceeds(updateDoc(old, {title: "Edited", contentRevision: 1}));
  await assertFails(updateDoc(old, {title: "Stale", contentRevision: 1}));
});

test("client collection queries cannot expose moderated records", async () => {
  await env.withSecurityRulesDisabled((context) => setDoc(
      doc(context.firestore(), "trips/trip/activities/removed"),
      {...entry("removed"), moderationRemoved: true}));
  await assertFails(getDoc(doc(dbFor("author"), "trips/trip/activities/removed")));
  await assertFails(getDocs(collection(dbFor("author"), "trips/trip/activities")));
  await assertFails(getDocs(collection(dbFor("author"), "activity")));
  await env.withSecurityRulesDisabled((context) => setDoc(
      doc(context.firestore(), "activity/top-removed"),
      {...entry("top-removed"), moderationRemoved: true}));
  await assertFails(getDoc(doc(dbFor("author"), "activity/top-removed")));
});

test("a traveler can change only their own vote and the count must match", async () => {
  const author = dbFor("author"); const member = dbFor("member");
  await assertSucceeds(updateDoc(doc(member, "trips/trip/activities/existing"),
      {likedBy: ["member"], likesCount: 1}));
  await assertFails(updateDoc(doc(author, "trips/trip/activities/existing"),
      {likedBy: [], likesCount: 0}));
  await assertFails(updateDoc(doc(author, "trips/trip/activities/existing"),
      {likedBy: ["member", "author"], likesCount: 9}));
  await assertSucceeds(updateDoc(doc(author, "trips/trip/activities/existing"),
      {likedBy: ["member", "author"], likesCount: 2}));
  await assertSucceeds(updateDoc(doc(member, "trips/trip/activities/existing"),
      {likedBy: ["author"], likesCount: 1}));
  await assertFails(updateDoc(doc(member, "trips/trip/activities/existing"),
      {likedBy: ["author", "author"], likesCount: 2}));
});

test("author or owner tombstones content; old IDs cannot be revived", async () => {
  await assertFails(deleteDoc(doc(dbFor("member"), "trips/trip/activities/existing")));
  await assertFails(updateDoc(doc(dbFor("member"), "trips/trip/activities/existing"), tombstone("member")));
  await assertSucceeds(updateDoc(doc(dbFor("author"), "trips/trip/activities/existing"), tombstone("author")));
  const deleted = (await getDoc(doc(dbFor("owner"), "trips/trip/activities/existing"))).data();
  assert.equal(deleted.isDeleted, true);
  assert.equal(deleted.title, ""); assert.equal(deleted.description, "");
  await assertFails(setDoc(doc(dbFor("author"), "trips/trip/activities/existing"), entry("existing")));
  await assertFails(updateDoc(doc(dbFor("author"), "trips/trip/activities/existing"), {title: "Restored"}));
  await assertFails(deleteDoc(doc(dbFor("author"), "trips/trip/activities/existing")));
  await assertFails(updateDoc(doc(dbFor("author"), "trips/trip/activities/legacy"), tombstone("author")));
  await assertSucceeds(updateDoc(doc(dbFor("owner"), "trips/trip/activities/legacy"), tombstone("owner")));
  await assertFails(setDoc(doc(dbFor("owner"), "trips/trip/activities/legacy"), entry("legacy", "owner")));
  await assertFails(setDoc(doc(dbFor("owner"), "activity/new-old"), entry("new-old", "owner")));
  await assertFails(updateDoc(doc(dbFor("author"), "activity/top-old"), tombstone("author")));
  await assertSucceeds(updateDoc(doc(dbFor("owner"), "activity/top-old"), tombstone("owner")));
  await assertFails(setDoc(doc(dbFor("owner"), "activity/top-old"), entry("top-old", "owner")));
  await env.withSecurityRulesDisabled((context) => setDoc(
      doc(context.firestore(), "trips/trip/activities/removed"),
      {...entry("removed"), moderationRemoved: true}));
  await assertFails(getDoc(doc(dbFor("author"), "trips/trip/activities/removed")));
  await assertFails(updateDoc(doc(dbFor("author"), "trips/trip/activities/removed"), {title: "Restore"}));
  await assertFails(deleteDoc(doc(dbFor("owner"), "trips/trip/activities/removed")));
  await env.withSecurityRulesDisabled((context) => updateDoc(doc(context.firestore(), "trips/trip"), {tripStatus: "deleted"}));
  await assertFails(setDoc(doc(dbFor("author"), "trips/trip/activities/new"), entry("new")));
});
