const {before, beforeEach, after, test} = require("node:test");
const fs = require("node:fs");
const assert = require("node:assert/strict");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, collection, query, where, getDocs, setDoc, getDoc, updateDoc, deleteDoc,
  limit, startAfter, orderBy, writeBatch, Timestamp} = require("firebase/firestore");

let env;
before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-travelcrew-membership",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")},
  });
});
after(async () => { if (env) await env.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "trips/private"), {id: "private", createdBy: "owner", joinedUsers: ["member", "left", "legacy"], isShared: false, tripStatus: "upcoming"});
    await setDoc(doc(db, "trips/private/members/member"), {userId: "member", status: "active"});
    await setDoc(doc(db, "trips/private/members/left"), {userId: "left", status: "left"});
    await setDoc(doc(db, "trips/private/activities/activity"), {tripId: "private", createdBy: "left", title: "Private"});
    await setDoc(doc(db, "trips/private/expenses/expense"), {tripId: "private", createdBy: "left", amount: 10});
    await setDoc(doc(db, "trips/private/lodgings/lodging"), {createdBy: "left", hotelName: "Private"});
    await setDoc(doc(db, "chat/private"), {roomId: "private", usersIds: ["owner", "member", "left"]});
    await setDoc(doc(db, "chat/private/messages/message"), {createdBy: "left", data: "Private"});
  });
});
const dbFor = (uid) => env.authenticatedContext(uid).firestore();

test("active members and the creator retain access; legacy arrays without member records still read", async () => {
  for (const uid of ["owner", "member", "legacy"]) {
    await assertSucceeds(getDoc(doc(dbFor(uid), "trips/private")));
    await assertSucceeds(getDoc(doc(dbFor(uid), "trips/private/activities/activity")));
  }
});

test("a left member record overrides stale joinedUsers and chat roster", async () => {
  const db = dbFor("left");
  for (const path of ["trips/private", "trips/private/activities/activity", "trips/private/expenses/expense", "trips/private/lodgings/lodging", "chat/private", "chat/private/messages/message"]) {
    await assertFails(getDoc(doc(db, path)));
  }
  await assertFails(setDoc(doc(db, "trips/private/activities/new"), {tripId: "private", title: "Forged"}));
  await assertFails(updateDoc(doc(db, "trips/private/expenses/expense"), {amount: 20}));
  await assertFails(setDoc(doc(db, "chat/private/messages/new"), {createdBy: "left", data: "Forged"}));
  await assertFails(updateDoc(doc(db, "chat/private/messages/message"), {data: "Edited"}));
  await assertFails(deleteDoc(doc(db, "chat/private/messages/message")));
  await assertFails(deleteDoc(doc(db, "trips/private/members/left")));
});

test("owner can distinguish no active members from a removed-member roster", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "trips/removed-roster"), {id: "removed-roster",
      createdBy: "owner", joinedUsers: ["left"], isShared: false,
      tripStatus: "upcoming"});
    await setDoc(doc(db, "trips/removed-roster/members/left"),
      {userId: "left", status: "left"});
  });
  const members = collection(dbFor("owner"), "trips/removed-roster/members");
  const active = await assertSucceeds(getDocs(query(members,
    where("status", "==", "active"))));
  const any = await assertSucceeds(getDocs(query(members, limit(1))));
  assert.equal(active.size, 0);
  assert.equal(any.size, 1);
});

test("a member cannot delete their membership to reactivate a stale array entry", async () => {
  const db = dbFor("member");
  await assertFails(deleteDoc(doc(db, "trips/private/members/member")));
  await assertSucceeds(updateDoc(doc(db, "trips/private/members/member"), {status: "left", removedAt: new Date()}));
  await assertFails(getDoc(doc(db, "trips/private")));
});

test("deleted and moderated trips revoke member reads and writes", async () => {
  for (const patch of [{tripStatus: "deleted"}, {moderationRemoved: true}]) {
    await env.withSecurityRulesDisabled((context) => updateDoc(doc(context.firestore(), "trips/private"), patch));
    const db = dbFor("member");
    for (const path of ["trips/private", "trips/private/activities/activity", "trips/private/expenses/expense", "chat/private/messages/message"]) {
      await assertFails(getDoc(doc(db, path)));
    }
    await assertFails(setDoc(doc(db, "trips/private/activities/new"), {tripId: "private", title: "New"}));
    await assertFails(updateDoc(doc(dbFor("owner"), "trips/private"), {title: "Stale edit"}));
    await env.withSecurityRulesDisabled((context) => updateDoc(doc(context.firestore(), "trips/private"), {tripStatus: "upcoming", moderationRemoved: false}));
  }
});

test("creator and active traveler trip queries remain authorized", async () => {
  const owner = dbFor("owner");
  const created = query(collection(owner, "trips"), where("createdBy", "==", "owner"), where("tripStatus", "==", "upcoming"));
  const result = await assertSucceeds(getDocs(created));
  assert.deepEqual(result.docs.map((item) => item.id), ["private"]);
  await assertSucceeds(getDoc(doc(dbFor("member"), "trips/private")));
});

test("owned trips and membership index queries advance past 50 records", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const batch = writeBatch(db);
    for (let index = 0; index < 55; index++) {
      const id = `extra-${String(index).padStart(3, "0")}`;
      batch.set(doc(db, `trips/${id}`), {id, createdBy: "owner",
        tripStatus: "upcoming", isShared: false});
      batch.set(doc(db, `users/owner/tripMemberships/${id}`),
        {tripId: id, status: "active", joinedAt: Timestamp.fromMillis(index + 1)});
    }
    await batch.commit();
  });
  const owner = dbFor("owner");
  const owned = query(collection(owner, "trips"), where("createdBy", "==", "owner"),
    where("tripStatus", "in", ["upcoming", "completed", "cancelled"]));
  const firstOwned = await assertSucceeds(getDocs(query(owned, limit(50))));
  const secondOwned = await assertSucceeds(getDocs(query(owned,
    startAfter(firstOwned.docs.at(-1)), limit(50))));
  assert.equal(firstOwned.size, 50);
  assert.equal(secondOwned.size, 6);
  const memberships = query(collection(owner, "users/owner/tripMemberships"),
    where("status", "==", "active"), orderBy("joinedAt", "desc"));
  const firstMemberships = await assertSucceeds(getDocs(query(memberships, limit(50))));
  const secondMemberships = await assertSucceeds(getDocs(query(memberships,
    startAfter(firstMemberships.docs.at(-1)), limit(50))));
  assert.equal(firstMemberships.size, 50);
  assert.equal(secondMemberships.size, 5);
});

test("a signed-in nonmember can read only their own membership and join-request records on a discoverable trip", async () => {
  // The native detail screen checks members/{self} before offering Request to join.
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "trips/public"), {id: "public", createdBy: "owner", joinedUsers: [], isPrivate: false, isShared: false, tripStatus: "upcoming"});
    await setDoc(doc(db, "trips/public/members/owner"), {userId: "owner", role: "creator", status: "active"});
    await setDoc(doc(db, "trips/public/joinRequests/visitor"), {userId: "visitor", status: "pending"});
  });
  await assertSucceeds(getDoc(doc(dbFor("visitor"), "trips/public/members/visitor")));
  await assertSucceeds(getDoc(doc(dbFor("visitor"), "trips/public/joinRequests/visitor")));
  await assertSucceeds(getDoc(doc(dbFor("visitor"), "trips/private/members/visitor")));
  await assertFails(getDoc(doc(dbFor("visitor"), "trips/public/members/owner")));
  await assertFails(getDocs(collection(dbFor("visitor"), "trips/public/members")));
  await assertFails(getDoc(doc(dbFor("visitor"), "trips/public/joinRequests/other")));
  await assertFails(getDoc(doc(dbFor("visitor"), "trips/public")));
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), "trips/public/members/visitor")));
});
