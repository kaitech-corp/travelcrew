const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {randomUUID} = require("node:crypto");
const {readFileSync} = require("node:fs");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {initializeTestEnvironment, assertFails} = require("@firebase/rules-unit-testing");
const {doc, updateDoc, deleteDoc} = require("firebase/firestore");
const {createFavoriteHandler} = require("../favorite-actions");
const {cleanDeletedUserFavorites} = require("../favorite-cleanup");
const {repairTripFavoriteCount} = require("../favorite-repair");
const {auditTripFavoriteCount, auditFavoriteTripPage,
  auditFavoriteCardPage, auditFavoriteUserPage} = require("../favorite-audit");

let app; let db; let env; let favorite;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-favorites"}, "favorites-test");
  db = getFirestore(app);
  env = await initializeTestEnvironment({
    projectId: "demo-travelcrew-favorites",
    firestore: {rules: readFileSync("../firestore.rules", "utf8")},
  });
  favorite = createFavoriteHandler(db);
  for (const uid of ["owner", "viewer", "stranger"]) {
    await db.doc(`users/${uid}`).set({uid, isDeleted: false, favouriteTrips: []});
  }
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});
const req = (uid, tripId, state) => ({auth: uid ? {uid} : null, data: {tripId, favorite: state}});
const code = (name) => (error) => error.code === name;
async function setup() {
  const id = randomUUID();
  await db.doc("users/viewer").update({favouriteTrips: []});
  await db.doc(`trips/${id}`).set({id, createdBy: "owner", isPrivate: false,
    tripStatus: "upcoming", favouriteCount: 0});
  await db.doc(`tripDiscovery/${id}`).set({id, createdBy: "owner", isDiscoverable: true,
    favouriteCount: 0});
  return id;
}
async function state(id) {
  const [user, trip, card] = await Promise.all([
    db.doc("users/viewer").get(), db.doc(`trips/${id}`).get(), db.doc(`tripDiscovery/${id}`).get(),
  ]);
  return {favorites: user.data().favouriteTrips, tripCount: trip.data().favouriteCount,
    cardCount: card.data()?.favouriteCount};
}

test("desired favorite state is idempotent and both counts commit together", async () => {
  const id = await setup();
  assert.equal((await favorite(req("viewer", id, true))).changed, true);
  assert.equal((await favorite(req("viewer", id, true))).changed, false);
  assert.deepEqual(await state(id), {favorites: [id], tripCount: 1, cardCount: 1});
  assert.equal((await favorite(req("viewer", id, false))).changed, true);
  assert.equal((await favorite(req("viewer", id, false))).changed, false);
  assert.deepEqual(await state(id), {favorites: [], tripCount: 0, cardCount: 0});
});

test("concurrent duplicate requests cannot inflate popularity", async () => {
  const id = await setup();
  const results = await Promise.all([
    favorite(req("viewer", id, true)), favorite(req("viewer", id, true)),
  ]);
  assert.equal(results.filter((result) => result.changed).length, 1);
  assert.deepEqual(await state(id), {favorites: [id], tripCount: 1, cardCount: 1});
});

test("favorite transitions stop while maintenance pause is active", async () => {
  const id = await setup();
  const pauseRef = db.doc("favoriteMaintenance/current");
  await pauseRef.set({paused: true});
  try {
    await assert.rejects(favorite(req("viewer", id, true)), code("unavailable"));
    assert.deepEqual(await state(id), {favorites: [], tripCount: 0, cardCount: 0});
  } finally {
    await pauseRef.delete();
  }
  assert.equal((await favorite(req("viewer", id, true))).changed, true);
  assert.deepEqual(await state(id), {favorites: [id], tripCount: 1, cardCount: 1});
  await favorite(req("viewer", id, false));
});

test("a pause and favorite request commit in a safe order", async () => {
  const id = await setup();
  const pauseRef = db.doc("favoriteMaintenance/current");
  const tripRef = db.doc(`trips/${id}`);
  try {
    const [request, pause] = await Promise.allSettled([
      favorite(req("viewer", id, true)), pauseRef.set({paused: true}),
    ]);
    assert.equal(pause.status, "fulfilled");
    if (request.status === "fulfilled") {
      assert.deepEqual(await state(id), {favorites: [id], tripCount: 1, cardCount: 1});
      const [tripDoc, pauseDoc] = await Promise.all([tripRef.get(), pauseRef.get()]);
      assert.ok(tripDoc.updateTime.toMillis() <= pauseDoc.updateTime.toMillis());
    } else {
      assert.equal(request.reason.code, "unavailable");
      assert.deepEqual(await state(id), {favorites: [], tripCount: 0, cardCount: 0});
    }
  } finally {
    await pauseRef.delete();
  }
});

test("repair previews by default and includes deleted refs until cleanup", async () => {
  const id = await setup();
  await favorite(req("viewer", id, true));
  await db.doc("users/stranger").update({isDeleted: true, favouriteTrips: [id]});
  const pauseRef = db.doc("favoriteMaintenance/current");
  const preview = await repairTripFavoriteCount(db, id);
  assert.equal(preview.status, "preview");
  assert.equal(preview.expectedCount, 2);
  assert.equal(preview.consistent, false);
  await assert.rejects(repairTripFavoriteCount(db, id, {apply: true}), /must be paused/);
  await pauseRef.set({paused: true});
  try {
    const repaired = await repairTripFavoriteCount(db, id, {apply: true});
    assert.equal(repaired.status, "repaired");
    assert.equal(repaired.expectedCount, 2);
    assert.deepEqual(await state(id), {favorites: [id], tripCount: 2, cardCount: 2});
    assert.equal((await repairTripFavoriteCount(db, id, {apply: true})).status, "unchanged");
  } finally {
    await pauseRef.delete();
  }
  await cleanDeletedUserFavorites(db, "stranger", [id]);
  assert.deepEqual(await state(id), {favorites: [id], tripCount: 1, cardCount: 1});
  await favorite(req("viewer", id, false));
});

test("clients cannot forge favorite lists or popularity counts", async () => {
  const id = await setup();
  const viewer = env.authenticatedContext("viewer").firestore();
  const owner = env.authenticatedContext("owner").firestore();
  await assertFails(updateDoc(doc(viewer, "users/viewer"), {favouriteTrips: [id]}));
  await assertFails(deleteDoc(doc(viewer, "users/viewer")));
  await assertFails(updateDoc(doc(viewer, `trips/${id}`), {favouriteCount: 5000}));
  await assertFails(updateDoc(doc(viewer, `tripDiscovery/${id}`), {favouriteCount: 5000}));
  await assertFails(updateDoc(doc(owner, `trips/${id}`), {favouriteCount: 5000}));
  await assertFails(updateDoc(doc(owner, `tripDiscovery/${id}`), {favouriteCount: 5000}));
});

test("favorite creation checks identity and current trip availability", async () => {
  const id = await setup();
  await assert.rejects(favorite(req(null, id, true)), code("unauthenticated"));
  await assert.rejects(favorite(req("viewer", id, "yes")), code("invalid-argument"));
  await assert.rejects(favorite(req("owner", id, true)), code("failed-precondition"));
  await db.doc(`trips/${id}`).update({isPrivate: true});
  await assert.rejects(favorite(req("viewer", id, true)), code("failed-precondition"));
  await db.doc(`trips/${id}`).update({isPrivate: false});
  await db.doc(`tripDiscovery/${id}`).update({createdBy: "stranger"});
  await assert.rejects(favorite(req("viewer", id, true)), code("failed-precondition"));
  await db.doc(`tripDiscovery/${id}`).update({createdBy: "owner"});
  await db.doc("users/viewer/blockedUsers/owner").set({createdAt: Date.now()});
  await assert.rejects(favorite(req("viewer", id, true)), code("permission-denied"));
  await db.doc("users/viewer/blockedUsers/owner").delete();
});

test("a stale favorite can be removed after trip visibility is revoked", async () => {
  const id = await setup();
  await favorite(req("viewer", id, true));
  await db.doc(`trips/${id}`).update({isPrivate: true});
  await db.doc(`tripDiscovery/${id}`).delete();
  assert.equal((await favorite(req("viewer", id, false))).favorite, false);
  const [user, trip] = await Promise.all([
    db.doc("users/viewer").get(), db.doc(`trips/${id}`).get(),
  ]);
  assert.deepEqual(user.data().favouriteTrips, []);
  assert.equal(trip.data().favouriteCount, 0);
});

test("read-only audit reports drift and marks capped counts incomplete", async () => {
  const id = await setup();
  await favorite(req("viewer", id, true));
  await db.doc(`tripDiscovery/${id}`).update({favouriteCount: 9});
  await db.doc("users/stranger").update({isDeleted: true, favouriteTrips: [id]});

  const result = await auditTripFavoriteCount(db, id, {userPageSize: 2});
  assert.equal(result.complete, true);
  assert.equal(result.activeFavorites, 1);
  assert.equal(result.deletedUserRefs, 1);
  assert.equal(result.tripMismatch, false);
  assert.equal(result.cardMismatch, true);
  assert.equal(result.tripCardDivergent, true);

  const capped = await auditTripFavoriteCount(db, id, {userPageSize: 1, maxUserPages: 1});
  assert.equal(capped.complete, false);
  assert.equal(capped.tripMismatch, false);
  assert.equal(capped.cardMismatch, false);

  const page = await auditFavoriteTripPage(db, {limit: 50, userPageSize: 2});
  assert.ok(page.totals.tripsScanned >= 1);
  assert.ok(page.totals.cardMismatch >= 1);
  assert.equal(page.totals.countScanCapped, 0);
});

test("deleted account favorite cleanup resumes safely after retries", async () => {
  const [first, second] = await Promise.all([setup(), setup()]);
  await favorite(req("viewer", first, true));
  await favorite(req("viewer", second, true));
  await db.doc("users/viewer").update({isDeleted: true});
  const staleImage = [first, second];
  assert.deepEqual(await cleanDeletedUserFavorites(db, "viewer", staleImage),
      {examined: 2, removed: 2, invalidRemoved: 0});
  assert.deepEqual(await cleanDeletedUserFavorites(db, "viewer", staleImage),
      {examined: 2, removed: 0, invalidRemoved: 0});
  assert.deepEqual(await state(first), {favorites: [], tripCount: 0, cardCount: 0});
  assert.deepEqual(await state(second), {favorites: [], tripCount: 0, cardCount: 0});
  await db.doc("users/viewer").update({isDeleted: false});
});

test("deleted account cleanup clears malformed leftover favorite entries", async () => {
  const id = await setup();
  await db.doc("users/malformed-deleted").set({isDeleted: true,
    favouriteTrips: [id, "..", 42]});
  await db.doc(`trips/${id}`).update({favouriteCount: 1});
  await db.doc(`tripDiscovery/${id}`).update({favouriteCount: 1});
  const result = await cleanDeletedUserFavorites(db, "malformed-deleted", [id, "..", 42]);
  assert.deepEqual(result, {examined: 1, removed: 1, invalidRemoved: 2});
  assert.deepEqual((await db.doc("users/malformed-deleted").get()).data().favouriteTrips, []);
  assert.equal((await db.doc(`trips/${id}`).get()).data().favouriteCount, 0);
});

test("hard-deleted account cleanup uses an event receipt for replay safety", async () => {
  const id = await setup();
  await db.doc("users/departed").set({uid: "departed", favouriteTrips: []});
  await favorite(req("departed", id, true));
  const previous = (await db.doc("users/departed").get()).data().favouriteTrips;
  await db.doc("users/departed").delete();
  assert.deepEqual(await cleanDeletedUserFavorites(db, "departed", previous, "delete-event-1"),
      {examined: 1, removed: 1, invalidRemoved: 0});
  assert.deepEqual(await cleanDeletedUserFavorites(db, "departed", previous, "delete-event-1"),
      {examined: 1, removed: 0, invalidRemoved: 0});
  assert.equal((await db.doc(`trips/${id}`).get()).data().favouriteCount, 0);
  assert.equal((await db.doc(`tripDiscovery/${id}`).get()).data().favouriteCount, 0);
});

test("card inventory identifies orphaned and inconsistent discovery records", async () => {
  const orphan = randomUUID();
  const mismatch = await setup();
  await db.doc(`tripDiscovery/${orphan}`).set({id: orphan, createdBy: "owner", favouriteCount: 3});
  await db.doc(`tripDiscovery/${mismatch}`).update({createdBy: "stranger", favouriteCount: -1});
  await db.doc(`trips/${mismatch}`).update({isPrivate: true, tripStatus: "deleted"});
  const result = await auditFavoriteCardPage(db, {limit: 50});
  assert.ok(result.totals.cardsScanned >= 2);
  assert.ok(result.totals.orphanCards >= 1);
  assert.ok(result.totals.creatorMismatchCards >= 1);
  assert.ok(result.totals.privateSourceCards >= 1);
  assert.ok(result.totals.removedSourceCards >= 1);
  assert.ok(result.totals.invalidCardCount >= 1);
});

test("user inventory counts stale links and reports capped inspection", async () => {
  const privateTrip = await setup();
  const missing = randomUUID();
  await db.doc(`trips/${privateTrip}`).update({isPrivate: true});
  await db.doc("users/viewer").update({favouriteTrips: [privateTrip, privateTrip, missing, ".."]});
  await db.doc("users/owner").update({favouriteTrips: [privateTrip]});
  await db.doc("users/stranger").update({isDeleted: true, favouriteTrips: [missing]});
  await db.doc("users/malformed").set({favouriteTrips: "bad"});
  const result = await auditFavoriteUserPage(db, {limit: 50, maxLinksPerUser: 2});
  assert.ok(result.totals.usersScanned >= 3);
  assert.ok(result.totals.malformedLists >= 1);
  assert.ok(result.totals.duplicateLinks >= 1);
  assert.ok(result.totals.invalidLinks >= 1);
  assert.ok(result.totals.deletedUserLinks >= 1);
  assert.ok(result.totals.missingTripLinks >= 1);
  assert.ok(result.totals.unavailableTripLinks >= 1);
  assert.ok(result.totals.selfFavoriteLinks >= 1);
  const capped = await auditFavoriteUserPage(db, {limit: 50, maxLinksPerUser: 1});
  assert.ok(capped.totals.linkScanCappedUsers >= 1);
  await db.doc("users/viewer").update({favouriteTrips: []});
  await db.doc("users/owner").update({favouriteTrips: []});
});
