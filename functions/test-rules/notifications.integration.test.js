const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {createTripActions} = require("../trip-actions");
const {sendInboxPush, sendChatPush} = require("../notification-delivery");
const {eventKey} = require("../notification-data");
let app; let db; let actions;
const uid = "notification-member"; const owner = "notification-owner"; const tripId = "notification-trip";
const request = (data, actor = uid) => ({auth: {uid: actor}, data: {tripId, ...data}});
const note = (actor, id) => db.doc(`notifications/${actor}/notification/${id}`);
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulator required");
  app = initializeApp({projectId: "demo-travelcrew-safety"}, "notifications-integration");
  db = getFirestore(app, "travel-crew-db-2"); actions = createTripActions(db);
  await db.doc(`trips/${tripId}`).set({createdBy: owner, joinedUsers: [], title: "Trip", isShared: true});
  await db.doc(`tripDiscovery/${tripId}`).set({isDiscoverable: true, memberCount: 1});
  await db.doc(`publicProfile/${uid}`).set({displayName: "Member"});
  await db.doc(`chat/${tripId}`).set({usersIds: [owner]});
});
after(async () => { if (app) { await db.terminate(); await deleteApp(app); } });

test("real transactions resolve accept/cancel race and allow a new attempt", async () => {
  await actions.requestJoin(request({attemptId: "race"}));
  const results = await Promise.allSettled([
    actions.transition(request({attemptId: "race"}), "cancelled"),
    actions.transition(request({attemptId: "race", userId: uid}, owner), "accepted"),
  ]);
  assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
  const status = (await db.doc(`trips/${tripId}/joinRequests/${uid}`).get()).data().status;
  const member = (await db.doc(`trips/${tripId}/members/${uid}`).get()).data();
  assert.equal(member?.status === "active", status === "accepted");
  if (status === "accepted") await actions.leave(request({membershipAttemptId: "race"}));
  await actions.requestJoin(request({attemptId: "after-race"}));
  await actions.requestJoin(request({attemptId: "after-race"}));
  assert.equal((await db.doc(`trips/${tripId}/joinRequests/${uid}`).get()).data().attemptId, "after-race");
  await assert.rejects(actions.transition(request({attemptId: "race"}), "cancelled"));
});
test("cancelled request suppresses delayed push; transient token failure retries only failed delivery", async () => {
  const id = eventKey("join_request", tripId, uid, "after-race");
  await db.doc(`tokens/${owner}/tokens/good`).set({});
  await db.doc(`tokens/${owner}/tokens/transient`).set({});
  let fail = true; const delivered = [];
  const messaging = {sendEachForMulticast: async (payload) => {
    const token = payload.tokens[0];
    if (token === "transient" && fail) return {responses: [{error: {code: "messaging/internal-error"}}]};
    delivered.push(token); return {responses: [{success: true}]};
  }};
  const event = {params: {userId: owner, notificationId: id}};
  await assert.rejects(sendInboxPush(db, messaging, event)); fail = false;
  await sendInboxPush(db, messaging, event); await sendInboxPush(db, messaging, event);
  assert.deepEqual(delivered.sort(), ["good", "transient"]);
  await actions.transition(request({attemptId: "after-race"}), "cancelled");
  await db.doc(`tokens/${owner}/tokens/late`).set({});
  await sendInboxPush(db, messaging, event);
  assert.equal(delivered.length, 2);
  assert.equal((await note(owner, id).get()).data().requestStatus, "cancelled");
});
test("chat uses private activity and push, skips sender/blocked/read recipients, and keeps inbox clean", async () => {
  await actions.requestJoin(request({attemptId: "chat"}));
  await actions.transition(request({attemptId: "chat", userId: uid}, owner), "accepted");
  const before = (await db.collection(`notifications/${owner}/notification`).get()).size;
  let pushes = 0;
  const messaging = {sendEachForMulticast: async () => { pushes++; return {responses: [{success: true}]}; }};
  async function message(id) {
    const ref = db.doc(`chat/${tripId}/messages/${id}`);
    await ref.set({createdBy: uid, createdAt: Timestamp.now(), data: "Private chat text", messageType: "Text"});
    await sendChatPush(db, messaging, {params: {roomId: tripId, messageId: id}, data: await ref.get()});
  }
  await message("one"); const sent = pushes; assert.ok(sent > 0);
  assert.equal((await db.doc(`users/${owner}/chatActivity/${tripId}`).get()).data().lastSenderId, uid);
  assert.equal((await db.collection(`notifications/${owner}/notification`).get()).size, before);
  await db.doc(`users/${owner}/chatActivity/${tripId}`).set({readAt: Timestamp.fromMillis(Date.now() + 60000)}, {merge: true});
  await message("two"); assert.equal(pushes, sent);
  await db.doc(`users/${owner}/blockedUsers/${uid}`).set({});
  await message("three"); assert.equal(pushes, sent);
  await db.doc(`users/${owner}/blockedUsers/${uid}`).delete();
});
