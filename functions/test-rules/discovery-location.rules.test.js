const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {readFileSync} = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, getDoc, setDoc, writeBatch} = require("firebase/firestore");

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-travelcrew-discovery-location",
    firestore: {rules: readFileSync("../firestore.rules", "utf8")},
  });
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    for (const [id, patch] of Object.entries({
      public: {},
      private: {isPrivate: true},
      deleted: {tripStatus: "deleted"},
      other: {},
    })) {
      await setDoc(doc(db, `trips/${id}`), {
        id, createdBy: "owner", isPrivate: false, tripStatus: "upcoming",
        latitude: 35.6, longitude: 139.7, ...patch,
      });
    }
  });
});
after(async () => { if (env) await env.cleanup(); });

const card = (id, patch = {}) => ({
  id, createdBy: "owner", isDiscoverable: true,
  latitude: 35.6, longitude: 139.7, ...patch,
});

test("owner may publish coordinates matching an eligible trip", async () => {
  const db = env.authenticatedContext("owner").firestore();
  await assertSucceeds(setDoc(doc(db, "tripDiscovery/public"), card("public")));
  assert.equal((await getDoc(doc(db, "tripDiscovery/public"))).data().latitude, 35.6);
});

test("trip and matching discovery card can be created atomically", async () => {
  const db = env.authenticatedContext("owner").firestore();
  const batch = writeBatch(db);
  batch.set(doc(db, "trips/new"), {
    id: "new", createdBy: "owner", tripStatus: "upcoming",
    latitude: 48.8, longitude: 2.3,
  });
  batch.set(doc(db, "tripDiscovery/new"), card("new", {latitude: 48.8, longitude: 2.3}));
  await assertSucceeds(batch.commit());
});

test("trip and discovery coordinates can change together", async () => {
  const db = env.authenticatedContext("owner").firestore();
  const batch = writeBatch(db);
  batch.update(doc(db, "trips/public"), {latitude: 34.0, longitude: -118.2});
  batch.set(doc(db, "tripDiscovery/public"), card("public", {latitude: 34.0, longitude: -118.2}));
  await assertSucceeds(batch.commit());
});

test("forged coordinates and visibility cannot be published", async () => {
  const db = env.authenticatedContext("owner").firestore();
  await assertFails(setDoc(doc(db, "tripDiscovery/public"), card("public", {latitude: 40})));
  await assertFails(setDoc(doc(db, "tripDiscovery/public"), card("public", {longitude: 200})));
  await assertFails(setDoc(doc(db, "tripDiscovery/public"), card("public", {isDiscoverable: false})));
});

test("another account cannot publish a card for the owner's trip", async () => {
  const db = env.authenticatedContext("stranger").firestore();
  await assertFails(setDoc(doc(db, "tripDiscovery/other"), card("other", {createdBy: "stranger"})));
});

test("private or deleted trips cannot be put into discovery", async () => {
  const db = env.authenticatedContext("owner").firestore();
  await assertFails(setDoc(doc(db, "tripDiscovery/private"), card("private")));
  await assertFails(setDoc(doc(db, "tripDiscovery/deleted"), card("deleted")));
});
