const {before, beforeEach, after, test} = require("node:test");
const fs = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, setDoc, getDoc, updateDoc, deleteDoc, writeBatch, arrayUnion} = require("firebase/firestore");
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-safety", firestore: {
    rules: fs.readFileSync("../firestore.rules", "utf8"),
  }});
});
after(async () => { if (env) await env.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const data = {
      "publicProfile/alice": {uid: "alice", displayName: "Alice", following: [], followers: []},
      "publicProfile/bob": {uid: "bob", displayName: "Bob", following: [], followers: []},
      "users/alice/blockedUsers/bob": {schemaVersion: 1},
      "reports/report": {reporterId: "alice", status: "open"},
      "trips/trip": {id: "trip", createdBy: "bob", joinedUsers: ["alice", "carol"], isShared: true},
      "trips/trip/members/alice": {userId: "alice", status: "active", role: "member"},
      "trips/trip/members/carol": {userId: "carol", status: "active", role: "member"},
      "chat/trip": {roomId: "trip", usersIds: ["alice", "bob", "carol"]},
      "chat/trip/messages/message": {createdBy: "bob", data: "", moderationRemoved: true},
    };
    for (const [key, value] of Object.entries(data)) await setDoc(doc(db, key), value);
  });
});
const dbFor = (uid) => env.authenticatedContext(uid).firestore();

test("reports and block relationships stay private and cannot be forged directly", async () => {
  const alice = dbFor("alice"); const bob = dbFor("bob");
  await assertSucceeds(getDoc(doc(alice, "users/alice/blockedUsers/bob")));
  await assertFails(getDoc(doc(bob, "users/alice/blockedUsers/bob")));
  await assertFails(setDoc(doc(alice, "users/alice/blockedUsers/carol"), {}));
  await assertFails(deleteDoc(doc(alice, "users/alice/blockedUsers/bob")));
  await assertFails(setDoc(doc(alice, "reports/forged"), {reporterId: "bob", status: "resolved"}));
  await assertFails(getDoc(doc(alice, "reports/report")));
  await assertFails(getDoc(doc(bob, "reports/report")));
  const moderator = env.authenticatedContext("moderator", {admin: true}).firestore();
  await assertSucceeds(getDoc(doc(moderator, "reports/report")));
  await assertFails(updateDoc(doc(moderator, "reports/report"), {status: "resolved"}));
  await assertFails(setDoc(doc(moderator, "reports/report/audit/forged"), {action: "remove"}));
});
test("blocked users cannot add follows or send join requests in either direction", async () => {
  const alice = dbFor("alice"); const bob = dbFor("bob");
  await assertFails(updateDoc(doc(alice, "publicProfile/alice"), {following: ["bob"]}));
  await assertFails(updateDoc(doc(bob, "publicProfile/alice"), {followers: ["bob"]}));
  await assertFails(setDoc(doc(alice, "trips/trip/joinRequests/alice"), {tripId: "trip", userId: "alice", status: "pending"}));
  await env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), "trips/other"), {createdBy: "alice", joinedUsers: [], isShared: true}));
  await assertFails(setDoc(doc(bob, "trips/other/joinRequests/bob"), {tripId: "other", userId: "bob", status: "pending"}));
  await assertSucceeds(setDoc(doc(dbFor("dave"), "trips/trip/joinRequests/dave"), {tripId: "trip", userId: "dave", status: "pending"}));
});
test("legacy, member, trip-array and chat paths cannot bypass server admission", async () => {
  const bob = dbFor("bob"); const dave = dbFor("dave");
  await assertFails(updateDoc(doc(bob, "trips/trip"), {joinedUsers: arrayUnion("dave")}));
  await assertFails(setDoc(doc(bob, "trips/trip/members/dave"), {userId: "dave", role: "member", status: "active"}));
  await assertFails(setDoc(doc(dave, "trips/trip/members/dave"), {userId: "dave", role: "creator", status: "active"}));
  await assertFails(setDoc(doc(dave, "trips/trip/Members/dave"), {userId: "dave"}));
  await assertFails(updateDoc(doc(bob, "chat/trip"), {usersIds: ["alice", "bob", "dave"]}));
});
test("existing shared trips, group messages and expense settlement remain available", async () => {
  const alice = dbFor("alice"); const carol = dbFor("carol");
  await assertSucceeds(getDoc(doc(alice, "trips/trip")));
  for (const [db, uid] of [[alice, "alice"], [carol, "carol"]]) {
    await assertSucceeds(setDoc(doc(db, `chat/trip/messages/${uid}`), {createdBy: uid, data: "Group update"}));
  }
  await assertSucceeds(setDoc(doc(alice, "trips/trip/expenses/expense"), {createdBy: "alice", tripId: "trip", amount: 10}));
  await assertSucceeds(updateDoc(doc(alice, "trips/trip/expenses/expense"), {amount: 0}));
  await assertSucceeds(updateDoc(doc(alice, "trips/trip/members/alice"), {status: "left", removedAt: new Date()}));
});
test("removed content cannot be restored and restrictions affect existing sessions", async () => {
  const bob = dbFor("bob");
  await assertFails(updateDoc(doc(bob, "chat/trip/messages/message"), {data: "restore"}));
  await assertFails(deleteDoc(doc(bob, "chat/trip/messages/message")));
  await env.withSecurityRulesDisabled((context) => setDoc(doc(context.firestore(), "safetyAccounts/bob"), {restricted: true}));
  await assertFails(setDoc(doc(bob, "chat/trip/messages/new"), {createdBy: "bob", data: "new"}));
  await assertFails(updateDoc(doc(bob, "publicProfile/bob"), {displayName: "new"}));
  await assertFails(setDoc(doc(bob, "safetyAccounts/bob"), {restricted: false}));
});
test("new trip creation still supports the creator membership batch", async () => {
  const alice = dbFor("alice"); const batch = writeBatch(alice);
  batch.set(doc(alice, "trips/new"), {id: "new", createdBy: "alice", joinedUsers: null, isShared: false});
  batch.set(doc(alice, "trips/new/members/alice"), {userId: "alice", role: "creator", status: "active"});
  batch.set(doc(alice, "users/alice/tripMemberships/new"), {role: "creator", status: "active"});
  await assertSucceeds(batch.commit());
});
