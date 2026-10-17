const {before, beforeEach, after, test} = require("node:test");
const fs = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, setDoc, getDoc, updateDoc, deleteDoc, writeBatch} = require("firebase/firestore");
let env;
before(async () => { env = await initializeTestEnvironment({projectId: "demo-travelcrew-transportation", firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}}); });
after(async () => { if (env) await env.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "trips/trip"), {id: "trip", createdBy: "owner", isShared: false, joinedUsers: ["member", "departed"], tripStatus: "upcoming"});
    await setDoc(doc(db, "trips/trip/members/member"), {userId: "member", status: "active"});
    await setDoc(doc(db, "trips/trip/members/departed"), {userId: "departed", status: "left"});
  });
});
const dbFor = (uid) => env.authenticatedContext(uid).firestore();
const entry = (patch = {}) => ({id: "ride", tripId: "trip", userId: "member", displayName: "Member", mode: "rideshare", title: "Airport transfer",
  origin: "Airport", destination: "Hotel", departure: null, arrival: null, provider: "Uber", serviceNumber: "", driver: "", travelerNames: ["Member"], notes: "", ...patch});
const flight = (patch = {}) => ({id: "flight", tripId: "trip", userId: "member", flightNumber: "AB123", ...patch});

test("members create and edit their entries; owner manages crew entries; other viewers cannot", async () => {
  const path = "trips/trip/transportation/ride";
  await assertSucceeds(setDoc(doc(dbFor("member"), path), entry()));
  await assertSucceeds(updateDoc(doc(dbFor("member"), path), {notes: "Pickup at arrivals"}));
  await assertSucceeds(updateDoc(doc(dbFor("owner"), path), {notes: "Updated by owner"}));
  await assertFails(updateDoc(doc(dbFor("stranger"), path), {notes: "Forged"}));
  await assertFails(updateDoc(doc(dbFor("member"), path), {userId: "owner"}));
  await assertFails(updateDoc(doc(dbFor("member"), path), {tripId: "other"}));
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), path)));
  await assertFails(getDoc(doc(dbFor("departed"), path)));
  await assertSucceeds(deleteDoc(doc(dbFor("owner"), path)));
});

test("transportation rejects forged identity, invalid modes, oversized payloads, and departed members", async () => {
  const path = "trips/trip/transportation/ride";
  for (const patch of [{userId: "owner"}, {tripId: "other"}, {id: "other"}, {mode: "flight"}, {mode: "spaceship"}, {notes: "x".repeat(4001)}, {travelerNames: Array(51).fill("Name")}, {moderationRemoved: false}]) {
    await assertFails(setDoc(doc(dbFor("member"), path), entry(patch)));
  }
  await assertFails(setDoc(doc(dbFor("stranger"), path), entry({userId: "stranger"})));
  await assertFails(setDoc(doc(dbFor("departed"), path), entry({userId: "departed"})));
  await env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), "safetyAccounts/member"), {restricted: true}));
  await assertFails(setDoc(doc(dbFor("member"), path), entry()));
});

test("transportation follows sharing and prevents edits to moderated entries", async () => {
  const path = "trips/trip/transportation/ride";
  await assertSucceeds(setDoc(doc(dbFor("member"), path), entry()));
  await env.withSecurityRulesDisabled(async (context) => {
    await updateDoc(doc(context.firestore(), "trips/trip"), {isShared: true});
    await updateDoc(doc(context.firestore(), path), {moderationRemoved: true});
  });
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), path)));
  await assertFails(updateDoc(doc(dbFor("member"), path), {notes: "Restore"}));
});

test("trip creation atomically includes transportation and old-client-compatible flights", async () => {
  const db = dbFor("owner");
  const batch = writeBatch(db);
  batch.set(doc(db, "trips/new"), {id: "new", createdBy: "owner", isShared: false, joinedUsers: [], tripStatus: "upcoming"});
  batch.set(doc(db, "trips/new/members/owner"), {userId: "owner", status: "active", role: "creator"});
  batch.set(doc(db, "trips/new/transportation/ride"), entry({tripId: "new", userId: "owner"}));
  batch.set(doc(db, "trips/new/flights/flight"), flight({tripId: "new", userId: "owner"}));
  await assertSucceeds(batch.commit());
  await assertSucceeds(getDoc(doc(db, "trips/new/flights/flight")));
});

test("legacy and nested flight updates retain ownership and trip identity", async () => {
  for (const path of ["flights/flight", "trips/trip/flights/flight"]) {
    await assertSucceeds(setDoc(doc(dbFor("member"), path), flight()));
    await assertSucceeds(updateDoc(doc(dbFor("member"), path), {flightNumber: "AB456"}));
    await assertFails(updateDoc(doc(dbFor("member"), path), {userId: "stranger"}));
    await assertFails(updateDoc(doc(dbFor("member"), path), {tripId: "other"}));
    await assertFails(deleteDoc(doc(dbFor("stranger"), path)));
    await assertSucceeds(deleteDoc(doc(dbFor("owner"), path)));
  }
});
