const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {readFileSync} = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {collection, doc, documentId, getDoc, getDocs, limit, query, setDoc, where} = require("firebase/firestore");

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-travelcrew-recommendations",
    firestore: {rules: readFileSync("../firestore.rules", "utf8")},
  });
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const records = {
      "tripDiscovery/public": {isDiscoverable: true, continent: "Asia", createdBy: "owner"},
      "tripDiscovery/hidden": {isDiscoverable: false, continent: "Europe", createdBy: "owner"},
      "trips/joined": {createdBy: "owner", joinedUsers: ["viewer"], isShared: false, continent: "Asia"},
      "trips/revoked": {createdBy: "owner", joinedUsers: [], isShared: false, continent: "Europe"},
      "users/viewer/tripMemberships/joined": {tripId: "joined", status: "active"},
      "users/viewer/tripMemberships/revoked": {tripId: "revoked", status: "active"},
      "users/viewer/tripMemberships/left": {tripId: "left", status: "left"},
      "users/viewer/recommendationPreferences/current": {destinations: ["paris"]},
      "users/viewer/recommendationProfile/current": {history: []},
      "users/viewer/recommendationDismissals/public": {dismissed: true},
      "recommendationSessions/session": {uid: "viewer", ranked: []},
      "recommendationEvents/event": {uid: "viewer", type: "impression"},
      "recommendationAttributions/attempt": {uid: "viewer"},
      "recommendationTripFeatures/public": {destinationKey: "paris"},
    };
    for (const [path, data] of Object.entries(records)) await setDoc(doc(db, path), data);
  });
});
after(async () => { if (env) await env.cleanup(); });

test("unavailable favorites cannot poison individually authorized recommendation history", async () => {
  const db = env.authenticatedContext("viewer").firestore();
  const favorites = where(documentId(), "in", ["public", "hidden", "deleted"]);
  // Reproduce the old batch denial, including the insufficient filter-only fix.
  await assertFails(getDocs(query(collection(db, "tripDiscovery"), favorites)));
  await assertFails(getDocs(query(
    collection(db, "tripDiscovery"), where("isDiscoverable", "==", true), favorites,
  )));
  const visible = await assertSucceeds(getDoc(doc(db, "tripDiscovery/public")));
  assert.equal(visible.data().continent, "Asia");
  await assertFails(getDoc(doc(db, "tripDiscovery/hidden")));
  await assertFails(getDoc(doc(db, "tripDiscovery/deleted")));
  const recommendations = await assertSucceeds(getDocs(query(
    collection(db, "tripDiscovery"), where("isDiscoverable", "==", true), where("continent", "in", [visible.data().continent]), limit(50),
  )));
  assert.deepEqual(recommendations.docs.map((item) => item.id), ["public"]);
  const popularFallback = await assertSucceeds(getDocs(query(
    collection(db, "tripDiscovery"), where("isDiscoverable", "==", true), limit(50),
  )));
  assert.deepEqual(popularFallback.docs.map((item) => item.id), ["public"]);
});

test("active history can contain revoked access without granting private trip reads", async () => {
  const db = env.authenticatedContext("viewer").firestore();
  const memberships = await assertSucceeds(getDocs(query(
    collection(db, "users/viewer/tripMemberships"), where("status", "==", "active"), limit(50),
  )));
  assert.deepEqual(memberships.docs.map((item) => item.id).sort(), ["joined", "revoked"]);
  await assertSucceeds(getDoc(doc(db, "trips/joined")));
  await assertFails(getDoc(doc(db, "trips/revoked")));
  await assertFails(getDoc(doc(db, "trips/deleted")));
  await assertFails(getDocs(collection(env.authenticatedContext("stranger").firestore(), "users/viewer/tripMemberships")));
});

test("recommendation preferences and dismissals are private; server data and writes stay protected", async () => {
  const owner = env.authenticatedContext("viewer").firestore();
  const stranger = env.authenticatedContext("stranger").firestore();
  for (const path of ["users/viewer/recommendationPreferences/current", "users/viewer/recommendationDismissals/public"]) {
    await assertSucceeds(getDoc(doc(owner, path)));
    await assertFails(getDoc(doc(stranger, path)));
    await assertFails(setDoc(doc(owner, path), {destinations: ["forged"], dismissed: false}));
  }
  for (const path of ["users/viewer/recommendationProfile/current", "recommendationSessions/session", "recommendationEvents/event",
    "recommendationAttributions/attempt", "recommendationTripFeatures/public", "recommendationConfig/current", "recommendationQuotas/quota"]) {
    await assertFails(getDoc(doc(owner, path)));
    await assertFails(setDoc(doc(owner, path), {uid: "viewer", type: "join_accepted"}));
  }
});
