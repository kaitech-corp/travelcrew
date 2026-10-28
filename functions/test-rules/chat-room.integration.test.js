const {before, after, beforeEach, test} = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {doc, getDoc, getDocs, collection, query, where, setDoc, updateDoc, serverTimestamp} = require("firebase/firestore");
const {createChatRoomHandler, createChatRoomListHandler, removeInactiveChatUser} = require("../chat-rooms");

let app; let db; let env; let ensure; let list;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-chat-room"}, "chat-room-test");
  db = getFirestore(app);
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-chat-room",
    firestore: {rules: fs.readFileSync("../firestore.rules", "utf8")}});
  ensure = createChatRoomHandler(db);
  list = createChatRoomListHandler(db);
});
after(async () => {
  if (env) await env.cleanup();
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});
beforeEach(async () => {
  await env.clearFirestore();
  await db.doc("trips/trip").set({id: "trip", createdBy: "owner", joinedUsers: ["member", "legacy"], tripStatus: "upcoming"});
  await db.doc("trips/trip/members/member").set({userId: "member", status: "active"});
  await db.doc("trips/trip/members/legacy").set({userId: "legacy", status: "left"});
  await db.doc("users/owner").set({uid: "owner"});
  await db.doc("users/member").set({uid: "member"});
  await db.doc("publicProfile/owner").set({displayName: "Owner", profileImage: "owner.jpg"});
  await db.doc("publicProfile/member").set({displayName: "Member", profileImage: "member.jpg"});
});
const request = (uid, data = {tripId: "trip"}) => ({auth: uid ? {uid} : null, data});
const listRequest = (uid, data = {}) => ({auth: uid ? {uid} : null, data});
const code = (name) => (error) => error.code === name;

test("concurrent opens create one trusted roster and clients cannot forge profiles", async () => {
  await Promise.all([ensure(request("owner")), ensure(request("member"))]);
  const room = (await db.doc("chat/trip").get()).data();
  assert.deepEqual(room.usersIds, ["member", "owner"]);
  assert.deepEqual(room.users.map((user) => user.name), ["Member", "Owner"]);
  assert.equal(room.users[0].profileImage, "member.jpg");
  assert.equal(room.updatedAt.toMillis() > 0, true);
  const client = env.authenticatedContext("member").firestore();
  await assertSucceeds(getDoc(doc(client, "chat/trip")));
  await assertFails(getDocs(query(collection(client, "chat"), where("usersIds", "array-contains", "member"))));
  assert.deepEqual((await list(listRequest("member"))).roomIds, ["trip"]);
  await assertFails(updateDoc(doc(client, "chat/trip"), {users: [{id: "owner", name: "Forged"}]}));
  await assertFails(updateDoc(doc(client, "chat/trip"), {usersIds: ["member"]}));
  await assertFails(updateDoc(doc(client, "chat/trip"), {updatedAt: serverTimestamp()}));
  assert.deepEqual(await ensure(request("owner")), {ok: true});
  assert.equal((await db.doc("chat/trip").get()).data().updatedAt.toMillis(), room.updatedAt.toMillis());
});

test("membership and safety changes block refresh and remove departed users", async () => {
  await ensure(request("owner"));
  await db.doc("trips/trip/members/member").update({status: "left"});
  await assert.rejects(ensure(request("member")), code("permission-denied"));
  await ensure(request("owner"));
  assert.deepEqual((await db.doc("chat/trip").get()).data().usersIds, ["owner"]);
  await db.doc("safetyAccounts/owner").set({restricted: true});
  await assert.rejects(ensure(request("owner")), code("permission-denied"));
  await assert.rejects(ensure(request("legacy")), code("permission-denied"));
  await assert.rejects(ensure(request("stranger")), code("permission-denied"));
  await assert.rejects(ensure(request(null)), code("unauthenticated"));
  await assert.rejects(ensure(request("member", {tripId: "trip", usersIds: ["member"]})), code("invalid-argument"));
});

test("legacy joined users without member documents can open chat", async () => {
  await db.doc("trips/trip").update({joinedUsers: ["member", "legacy", "old"]});
  await db.doc("users/old").set({uid: "old"});
  await ensure(request("old"));
  assert.deepEqual((await db.doc("chat/trip").get()).data().usersIds, ["member", "old", "owner"]);
});

test("deleted or missing user document cannot read or create chat activity", async () => {
  await ensure(request("owner"));
  const owner = env.authenticatedContext("owner").firestore();
  const member = env.authenticatedContext("member").firestore();
  await assertSucceeds(getDoc(doc(owner, "chat/trip")));
  await assertSucceeds(getDoc(doc(member, "chat/trip")));
  const message = (id) => ({chateId: id, createdBy: "owner", sentTo: "trip",
    messageType: "Text", messageStatus: "Sent", data: "Hello",
    createdAt: serverTimestamp()});
  await assertSucceeds(setDoc(doc(owner, "chat/trip/messages/before"), message("before")));
  await db.doc("users/owner").update({isDeleted: true});
  await assertFails(getDoc(doc(owner, "chat/trip")));
  await assertFails(getDocs(collection(owner, "chat/trip/messages")));
  await assertFails(setDoc(doc(owner, "chat/trip/messages/after"), message("after")));
  await assertFails(setDoc(doc(owner, "users/owner/chatActivity/trip"),
      {readAt: serverTimestamp()}));
  await assert.rejects(ensure(request("owner")), code("permission-denied"));
  await assert.rejects(list(listRequest("owner")), code("permission-denied"));
  await assertFails(getDoc(doc(member, "chat/trip")));
  await db.doc("users/owner").delete();
  await assertFails(getDoc(doc(owner, "chat/trip")));
  await assert.rejects(ensure(request("owner")), code("permission-denied"));
});

test("room refresh excludes deleted and restricted travelers from the roster", async () => {
  await ensure(request("owner"));
  await db.doc("users/member").update({isDeleted: true});
  await ensure(request("owner"));
  assert.deepEqual((await db.doc("chat/trip").get()).data().usersIds, ["owner"]);
  await db.doc("users/member").update({isDeleted: false});
  await db.doc("safetyAccounts/member").set({restricted: true});
  await ensure(request("owner"));
  assert.deepEqual((await db.doc("chat/trip").get()).data().usersIds, ["owner"]);
  await db.doc("safetyAccounts/member").delete();
  await ensure(request("owner"));
  assert.deepEqual((await db.doc("chat/trip").get()).data().usersIds, ["member", "owner"]);
  await db.doc("users/owner").update({isDeleted: true});
  await assert.rejects(ensure(request("member")), code("permission-denied"));
  const member = env.authenticatedContext("member").firestore();
  await assertFails(getDoc(doc(member, "chat/trip")));
  assert.deepEqual((await list(listRequest("member"))).roomIds, []);
  await db.doc("users/owner").update({isDeleted: false});
  await db.doc("safetyAccounts/owner").set({restricted: true});
  await assertFails(getDoc(doc(member, "chat/trip")));
  assert.deepEqual((await list(listRequest("member"))).roomIds, []);
});

test("account cleanup removes an inactive member without deleting messages", async () => {
  await ensure(request("owner"));
  await db.doc("chat/trip/messages/keep").set({data: "Keep history"});
  await db.doc("users/member").update({isDeleted: true});
  assert.deepEqual(await removeInactiveChatUser(db, "member"), {examined: 1, changed: 1});
  const room = (await db.doc("chat/trip").get()).data();
  assert.deepEqual(room.usersIds, ["owner"]);
  assert.deepEqual(room.users.map((user) => user.id), ["owner"]);
  assert.equal((await db.doc("chat/trip/messages/keep").get()).exists, true);
  assert.deepEqual(await removeInactiveChatUser(db, "member"), {examined: 0, changed: 0});
  await db.doc("users/member").update({isDeleted: false});
  await ensure(request("owner"));
  assert.deepEqual(await removeInactiveChatUser(db, "member"), {examined: 1, changed: 0});
  await db.doc("safetyAccounts/member").set({restricted: true});
  assert.deepEqual(await removeInactiveChatUser(db, "member"), {examined: 1, changed: 1});
});

test("owner account cleanup clears access roster while preserving room history", async () => {
  await ensure(request("owner"));
  const before = (await db.doc("chat/trip").get()).data();
  await db.doc("users/owner").update({isDeleted: true});
  assert.deepEqual(await removeInactiveChatUser(db, "owner"), {examined: 1, changed: 1});
  const after = (await db.doc("chat/trip").get()).data();
  assert.deepEqual(after.usersIds, []);
  assert.deepEqual(after.users, []);
  assert.equal(after.updatedAt.toMillis(), before.updatedAt.toMillis());
  await db.doc("users/owner").update({isDeleted: false});
  await ensure(request("owner"));
  assert.deepEqual((await db.doc("chat/trip").get()).data().usersIds, ["member", "owner"]);
});

test("inactive chat cleanup pages through more than 100 rooms", async () => {
  const batch = db.batch();
  for (let i = 0; i < 101; i++) {
    const id = `clean-${String(i).padStart(3, "0")}`;
    batch.set(db.doc(`trips/${id}`), {createdBy: "owner", tripStatus: "upcoming"});
    batch.set(db.doc(`chat/${id}`), {roomId: id, usersIds: ["member", "owner"],
      users: [{id: "member"}, {id: "owner"}], updatedAt: Timestamp.now()});
  }
  await batch.commit();
  await db.doc("users/member").update({isDeleted: true});
  assert.deepEqual(await removeInactiveChatUser(db, "member"), {examined: 101, changed: 101});
  assert.deepEqual((await db.doc("chat/clean-100").get()).data().usersIds, ["owner"]);
});

test("chat list pages current memberships and skips deleted trips", async () => {
  const batch = db.batch();
  for (let i = 0; i < 52; i++) {
    const id = `trip-${String(i).padStart(3, "0")}`;
    batch.set(db.doc(`trips/${id}`), {id, createdBy: "owner",
      tripStatus: i === 51 ? "deleted" : "upcoming"});
    batch.set(db.doc(`chat/${id}`), {roomId: id, usersIds: ["owner"], users: [],
      updatedAt: Timestamp.fromMillis(1_800_000_000_000 + i * 1000)});
  }
  await batch.commit();
  const first = await list(listRequest("owner"));
  assert.equal(first.roomIds.length, 49);
  assert.equal(first.roomIds.includes("trip-051"), false);
  assert.ok(first.nextCursor);
  const second = await list(listRequest("owner", {cursor: first.nextCursor}));
  assert.deepEqual(second.roomIds, ["trip-001", "trip-000"]);
  assert.equal(second.nextCursor, null);
  await assert.rejects(list(listRequest(null)), code("unauthenticated"));
  await assert.rejects(list(listRequest("owner", {cursor: {id: "bad"}})), code("invalid-argument"));
});
