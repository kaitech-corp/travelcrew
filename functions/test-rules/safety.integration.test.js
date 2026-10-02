const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {createSafetyHandlers} = require("../safety");
const {queueReportAlert, cleanBlockedPair} = require("../safety-triggers");
let app; let db; let handlers;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Emulator required.");
  app = initializeApp({projectId: "demo-travelcrew-safety"}, "safety-integration");
  db = getFirestore(app, "travel-crew-db-2"); handlers = createSafetyHandlers(db);
  for (const [path, data] of Object.entries({
    "publicProfile/amy": {displayName: "Amy", followers: ["ben"], following: ["ben"]},
    "publicProfile/ben": {displayName: "Ben", followers: ["amy"], following: ["amy"]},
    "trips/journey": {createdBy: "ben", joinedUsers: ["amy"], title: "Trip", isShared: true},
    "trips/journey/joinRequests/amy": {status: "pending"},
    "chat/journey": {usersIds: ["amy", "ben"]},
    "chat/journey/messages/msg": {createdBy: "ben", messageType: "Text", data: "Reported content"},
    "notifications/amy/notification/old": {createdBy: "ben"},
  })) await db.doc(path).set(data);
});
after(async () => { if (app) { await db.terminate(); await deleteApp(app); } });
const req = (data, uid = "amy", admin = false) => ({auth: {uid, token: {admin}}, data});

test("named database: durable receipt, private block, retryable cleanup, alert and moderation action", async () => {
  const request = req({targetType: "message", targetId: "msg", roomId: "journey", requestId: "integration-report", reason: "harassment", details: "Please investigate"});
  const first = await handlers.submitReport(request);
  assert.equal((await handlers.submitReport(request)).reportId, first.reportId);
  await handlers.blockUser(req({targetUserId: "ben"}));
  assert.equal((await db.doc("users/amy/blockedUsers/ben").get()).exists, true);
  assert.deepEqual((await db.doc("publicProfile/ben").get()).data().followers, []);
  await assert.rejects(handlers.followUser(req({targetUserId: "amy", following: true}, "ben")), (e) => e.code === "permission-denied");
  await cleanBlockedPair(db, "amy", "ben");
  await cleanBlockedPair(db, "amy", "ben");
  assert.equal((await db.doc("notifications/amy/notification/old").get()).exists, false);
  assert.equal((await db.doc("trips/journey/joinRequests/amy").get()).data().status, "cancelled");
  assert.deepEqual((await db.doc("trips/journey").get()).data().joinedUsers, ["amy"]);
  process.env.MODERATION_ALERT_EMAIL = "moderation@example.invalid";
  await queueReportAlert(db, first.reportId); await queueReportAlert(db, first.reportId);
  assert.equal((await db.collection("mail").get()).size, 1);
  await handlers.reviewReport(req({reportId: first.reportId, action: "remove", rationale: "Harassment"}, "moderator", true));
  assert.equal((await db.doc("chat/journey/messages/msg").get()).data().moderationRemoved, true);
  assert.equal((await db.collection(`reports/${first.reportId}/audit`).get()).size, 1);
  await handlers.unblockUser(req({targetUserId: "ben"}));
  await handlers.followUser(req({targetUserId: "ben", following: true}));
  assert.deepEqual((await db.doc("publicProfile/amy").get()).data().following, ["ben"]);
});
