const {before, beforeEach, after, test} = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, setDoc, getDoc, updateDoc, deleteDoc, writeBatch} = require("firebase/firestore");
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-transportation",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
});
after(async () => { if (env) await env.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "users/member"), {displayName: "Member"});
    await setDoc(doc(db, "users/owner"), {displayName: "Owner"});
    await setDoc(doc(db, "trips/trip"), {id: "trip", createdBy: "owner", isShared: false,
      joinedUsers: ["member", "departed"], tripStatus: "upcoming"});
    await setDoc(doc(db, "trips/trip/members/member"), {userId: "member", status: "active"});
    await setDoc(doc(db, "trips/trip/members/departed"), {userId: "departed", status: "left"});
  });
});
const dbFor = (uid) => env.authenticatedContext(uid).firestore();
const entry = (patch = {}) => ({id: "ride", tripId: "trip", userId: "member",
  displayName: "Member", mode: "rideshare", departure: null, arrival: null,
  notes: "", revision: 1, isDeleted: false, ...patch});

test("all supported modes use one canonical collection, including assistant flights", async () => {
  const modes = ["flight", "driving", "rideshare", "taxi", "train", "bus",
    "scooter", "bicycle", "walking", "ferry", "boat", "other"];
  for (const mode of modes) {
    const path = `trips/trip/transportation/${mode}`;
    await assertSucceeds(setDoc(doc(dbFor("member"), path), entry({id: mode, mode,
      departure: "2027-04-10T23:00:00", arrival: "2027-04-11T08:00:00",
      notes: "Service and route details"})));
    const saved = await assertSucceeds(getDoc(doc(dbFor("member"), path)));
    assert.equal(saved.data().mode, mode);
    await assertSucceeds(updateDoc(doc(dbFor("member"), path), {notes: "Updated", revision: 2}));
  }
  await assertSucceeds(setDoc(doc(dbFor("member"), "trips/trip/transportation/leap"),
    entry({id: "leap", departure: "2028-02-29"})));
});

test("author and owner can edit or delete; strangers and departed members cannot", async () => {
  const path = "trips/trip/transportation/ride";
  await assertSucceeds(setDoc(doc(dbFor("member"), path), entry()));
  await assertFails(updateDoc(doc(dbFor("owner"), path), {userId: "owner", revision: 2}));
  await assertFails(updateDoc(doc(dbFor("owner"), path), {displayName: "Owner", revision: 2}));
  await assertSucceeds(updateDoc(doc(dbFor("owner"), path), {mode: "train", revision: 2}));
  await assertFails(updateDoc(doc(dbFor("member"), path), {notes: "stale", revision: 2}));
  await assertFails(updateDoc(doc(dbFor("stranger"), path), {notes: "forged", revision: 3}));
  await assertFails(updateDoc(doc(dbFor("departed"), path), {notes: "forged", revision: 3}));
  await assertFails(deleteDoc(doc(dbFor("departed"), path)));
  await assertFails(updateDoc(doc(dbFor("departed"), path), {isDeleted: true, revision: 3}));
  await assertFails(getDoc(doc(dbFor("departed"), path)));
  await assertFails(deleteDoc(doc(dbFor("owner"), path)));
  await assertSucceeds(updateDoc(doc(dbFor("owner"), path), {isDeleted: true, revision: 3}));
  await assertFails(updateDoc(doc(dbFor("member"), path), {notes: "resurrect", isDeleted: false, revision: 4}));
});

test("forged identity, unknown fields, bad dates, oversize and invalid revision are denied", async () => {
  const path = "trips/trip/transportation/ride";
  const invalid = [
    {userId: "owner"}, {displayName: "Owner"}, {tripId: "other"}, {id: "other"}, {mode: "spaceship"},
    {notes: "x".repeat(4001)}, {title: "Deprecated"}, {provider: "Uber"},
    {travelerNames: ["Member"]}, {revision: 2}, {revision: 0},
    {departure: "2027-14-10"}, {departure: "2027-02-30"},
    {departure: "2027-02-29"}, {arrival: "2027-04-10T25:00:00"},
    {departure: "yesterday"}, {departure: "2027-04-10T10:00:00Z"},
    {arrival: "2027-04-10T04:00:00-07:00"},
    {displayName: "x".repeat(201)},
    {moderationRemoved: false},
  ];
  for (const patch of invalid) {
    await assertFails(setDoc(doc(dbFor("member"), path), entry(patch)));
  }
  await assertFails(setDoc(doc(dbFor("stranger"), path), entry({userId: "stranger"})));
  await assertFails(setDoc(doc(dbFor("departed"), path), entry({userId: "departed"})));
  await env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), "safetyAccounts/member"), {restricted: true}));
  await assertFails(setDoc(doc(dbFor("member"), path), entry()));
});

test("sharing is read-only and moderated or deleted entries cannot be changed", async () => {
  const path = "trips/trip/transportation/ride";
  await assertSucceeds(setDoc(doc(dbFor("member"), path), entry()));
  await env.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), "trips/trip"), {isShared: true});
    await updateDoc(doc(context.firestore(), path), {moderationRemoved: true});
  });
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), path)));
  await assertFails(updateDoc(doc(dbFor("member"), path), {notes: "Restore", revision: 2}));
  await env.withSecurityRulesDisabled((context) => updateDoc(doc(context.firestore(), "trips/trip"), {tripStatus: "deleted"}));
  await assertFails(setDoc(doc(dbFor("member"), "trips/trip/transportation/new"), entry({id: "new"})));
});

test("trip creation atomically includes canonical transportation", async () => {
  const db = dbFor("owner");
  const batch = writeBatch(db);
  batch.set(doc(db, "trips/new"), {id: "new", createdBy: "owner", isShared: false,
    joinedUsers: [], tripStatus: "upcoming"});
  batch.set(doc(db, "trips/new/members/owner"), {userId: "owner", status: "active", role: "creator"});
  batch.set(doc(db, "trips/new/transportation/flight"), entry({id: "flight", tripId: "new", userId: "owner", displayName: "Owner", mode: "flight"}));
  await assertSucceeds(batch.commit());
  await assertSucceeds(getDoc(doc(db, "trips/new/transportation/flight")));
});

test("simultaneous edits with the same revision cannot silently overwrite", async () => {
  const path = "trips/trip/transportation/ride";
  await assertSucceeds(setDoc(doc(dbFor("member"), path), entry()));
  const results = await Promise.allSettled([
    updateDoc(doc(dbFor("member"), path), {notes: "First", revision: 2}),
    updateDoc(doc(dbFor("owner"), path), {notes: "Second", revision: 2}),
  ]);
  assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
  assert.equal((await getDoc(doc(dbFor("member"), path))).data().revision, 2);
});
