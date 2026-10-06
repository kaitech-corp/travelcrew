const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {createTripInvitations, invitationNoteId} = require("../trip-invitations");
const {createTripActions} = require("../trip-actions");
const {sendInboxPush} = require("../notification-delivery");
let app; let db; let auth; let invitations; let sequence = 0;
before(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) throw new Error("Auth and Firestore emulators required");
  app = initializeApp({projectId: "demo-travelcrew-safety"}, "invitation-integration");
  db = getFirestore(app, "travel-crew-db-2"); auth = getAuth(app); invitations = createTripInvitations(db, auth);
});
after(async () => { if (app) { await db.terminate(); await deleteApp(app); } });
async function fixture() {
  const base = `invite-${Date.now()}-${++sequence}`;
  const owner = `${base}-owner`; const recipient = `${base}-recipient`; const stranger = `${base}-stranger`; const tripId = `${base}-trip`;
  for (const uid of [owner, recipient, stranger]) {
    await auth.createUser({uid});
    await db.doc(`users/${uid}`).set({isDeleted: false, email: "private@example.com"});
    await db.doc(`publicProfile/${uid}`).set({uid, displayName: `${base} ${uid === owner ? "Owner" : "Traveler"}`, hometown: "Tokyo", email: "private@example.com"});
  }
  await db.doc(`trips/${tripId}`).set({id: tripId, title: "Private getaway", createdBy: owner, joinedUsers: [], isPrivate: true, isShared: false, destination: "Tokyo", tripStatus: "upcoming", secret: "private itinerary"});
  await db.doc(`tripDiscovery/${tripId}`).set({isDiscoverable: false, memberCount: 1});
  await db.doc(`chat/${tripId}`).set({usersIds: [owner]});
  const request = (data, actor = owner) => ({auth: {uid: actor}, data: {tripId, ...data}});
  const send = (requestId = "first") => invitations.send(request({userId: recipient, requestId}));
  const respond = (accept, invitationId = "first", actor = recipient) => invitations.respond(request({accept, invitationId}, actor));
  return {base, owner, recipient, stranger, tripId, request, send, respond};
}
test("search returns active profiles with membership/pending states but no private account fields", async () => {
  const f = await fixture();
  const users = (await invitations.search(f.request({query: f.base}))).users;
  assert.equal(users.length, 2); assert.ok(users.every((u) => u.uid !== f.owner));
  assert.ok(users.every((u) => !Object.hasOwn(u, "email")));
  await f.send();
  await db.doc(`trips/${f.tripId}/members/${f.stranger}`).set({status: "active"});
  const states = (await invitations.search(f.request({query: f.base}))).users;
  assert.equal(states.find((u) => u.uid === f.recipient).status, "invited");
  assert.equal(states.find((u) => u.uid === f.stranger).status, "member");
  await assert.rejects(invitations.search(f.request({query: f.base}, f.recipient)), {code: "permission-denied"});
  await assert.rejects(invitations.search(f.request({query: "a"})), {code: "invalid-argument"});
});
test("search hides blocked, disabled, deleted, restricted, and removed accounts", async () => {
  const f = await fixture();
  for (const reason of ["blocked", "reverse-block", "disabled", "deleted", "restricted", "removed"]) {
    const path = reason === "blocked" ? `users/${f.owner}/blockedUsers/${f.recipient}` : `users/${f.recipient}/blockedUsers/${f.owner}`;
    if (reason.includes("block")) await db.doc(path).set({});
    if (reason === "disabled") await auth.updateUser(f.recipient, {disabled: true});
    if (reason === "deleted") await db.doc(`users/${f.recipient}`).update({isDeleted: true});
    if (reason === "restricted") await db.doc(`safetyAccounts/${f.recipient}`).set({restricted: true});
    if (reason === "removed") await db.doc(`publicProfile/${f.recipient}`).update({moderationRemoved: true});
    const users = (await invitations.search(f.request({query: f.base}))).users;
    assert.ok(!users.some((u) => u.uid === f.recipient), reason);
    await assert.rejects(f.send(reason), {code: "permission-denied"});
    if (reason.includes("block")) await db.doc(path).delete();
    if (reason === "disabled") await auth.updateUser(f.recipient, {disabled: false});
    if (reason === "deleted") await db.doc(`users/${f.recipient}`).update({isDeleted: false});
    if (reason === "restricted") await db.doc(`safetyAccounts/${f.recipient}`).delete();
    if (reason === "removed") await db.doc(`publicProfile/${f.recipient}`).update({moderationRemoved: false});
  }
});
test("private invitations produce one inbox event and limited preview without sharing the trip", async () => {
  const f = await fixture();
  const results = await Promise.all([f.send(), f.send(), f.send("concurrent")]);
  assert.equal(new Set(results.map((r) => r.invitationId)).size, 1);
  const invitationId = results[0].invitationId;
  const notes = await db.collection(`notifications/${f.recipient}/notification`).get();
  assert.equal(notes.size, 1); assert.equal(notes.docs[0].data().notificationType, "Invitation");
  const preview = await invitations.preview(f.request({invitationId}, f.recipient));
  assert.equal(preview.title, "Private getaway"); assert.equal(preview.secret, undefined);
  assert.equal((await db.doc(`trips/${f.tripId}`).get()).data().isShared, false);
  assert.equal((await db.doc(`trips/${f.tripId}/members/${f.recipient}`).get()).exists, false);
  await assert.rejects(invitations.preview(f.request({invitationId}, f.stranger)), {code: "not-found"});
  await assert.rejects(f.respond(true, invitationId, f.stranger), {code: "not-found"});
});
test("accept/decline race commits one result; acceptance creates membership/chat exactly once", async () => {
  const f = await fixture(); await f.send();
  const results = await Promise.allSettled([f.respond(true), f.respond(false)]);
  assert.equal(results.filter((r) => r.status === "fulfilled").length, 1);
  let status = (await db.doc(`trips/${f.tripId}/invitations/${f.recipient}`).get()).data().status;
  if (status === "declined") { await f.send("second"); await f.respond(true, "second"); status = "accepted"; }
  const invitationId = (await db.doc(`trips/${f.tripId}/invitations/${f.recipient}`).get()).data().invitationId;
  await f.respond(true, invitationId);
  assert.equal(status, "accepted");
  assert.deepEqual((await db.doc(`trips/${f.tripId}`).get()).data().joinedUsers, [f.recipient]);
  assert.equal((await db.doc(`trips/${f.tripId}/members/${f.recipient}`).get()).data().attemptId, `invite_${invitationId}`);
  assert.equal((await db.doc(`users/${f.recipient}/tripMemberships/${f.tripId}`).get()).data().status, "active");
  assert.deepEqual((await db.doc(`chat/${f.tripId}`).get()).data().usersIds, [f.owner, f.recipient]);
  assert.equal((await db.doc(`tripDiscovery/${f.tripId}`).get()).data().memberCount, 2);
  assert.equal((await db.collection(`notifications/${f.owner}/notification`).get()).size, 1);
  await assert.rejects(f.send("member"), {code: "already-exists"});
  await createTripActions(db).leave(f.request({membershipAttemptId: `invite_${invitationId}`}, f.recipient));
  await f.respond(true, invitationId);
  assert.equal((await db.doc(`trips/${f.tripId}/members/${f.recipient}`).get()).data().status, "left", "stale accept must not rejoin after leaving");
});
test("decline, retries, and new invites do not resurrect or answer old invitations", async () => {
  const f = await fixture(); await f.send(); await f.respond(false); await f.respond(false);
  await f.send();
  assert.equal((await db.doc(`trips/${f.tripId}/invitations/${f.recipient}`).get()).data().status, "declined");
  assert.equal((await db.doc(`trips/${f.tripId}/members/${f.recipient}`).get()).exists, false);
  await f.send("new");
  await assert.rejects(f.respond(true), {code: "not-found"});
  await f.respond(true, "new");
});
test("authorization and changes after sending prevent admission", async () => {
  const f = await fixture();
  await assert.rejects(invitations.send({data: {tripId: f.tripId}}), {code: "unauthenticated"});
  await assert.rejects(invitations.send(f.request({userId: f.recipient, requestId: "fake"}, f.stranger)), {code: "permission-denied"});
  await assert.rejects(invitations.send(f.request({userId: f.owner, requestId: "self"})), {code: "invalid-argument"});
  await f.send();
  await db.doc(`users/${f.owner}/blockedUsers/${f.recipient}`).set({});
  await assert.rejects(f.respond(true), {code: "permission-denied"});
  await db.doc(`users/${f.owner}/blockedUsers/${f.recipient}`).delete();
  await db.doc(`trips/${f.tripId}`).update({tripStatus: "deleted"});
  await assert.rejects(f.respond(true), {code: "failed-precondition"});
  assert.equal((await db.doc(`trips/${f.tripId}/members/${f.recipient}`).get()).exists, false);
});
test("acceptance resolves an existing join request and preserves its member count", async () => {
  const f = await fixture();
  await db.doc(`trips/${f.tripId}`).update({isShared: true});
  await createTripActions(db).requestJoin(f.request({attemptId: "join"}, f.recipient));
  await f.send(); await f.respond(true);
  assert.equal((await db.doc(`trips/${f.tripId}/joinRequests/${f.recipient}`).get()).data().status, "accepted");
  await createTripActions(db).transition(f.request({attemptId: "join", userId: f.recipient}), "accepted");
  assert.equal((await db.doc(`tripDiscovery/${f.tripId}`).get()).data().memberCount, 2);
});
test("pending invitations can push before membership; answered invitations suppress delayed pushes", async () => {
  const f = await fixture(); await f.send();
  const notificationId = invitationNoteId(f.tripId, f.recipient, "first");
  await db.doc(`tokens/${f.recipient}/tokens/device`).set({});
  const sends = [];
  const messaging = {sendEachForMulticast: async (payload) => { sends.push(payload); return {responses: [{success: true}]}; }};
  const event = {params: {userId: f.recipient, notificationId}};
  await sendInboxPush(db, messaging, event);
  assert.equal(sends.length, 1); assert.equal(sends[0].data.type, "Invitation");
  await f.respond(false); await db.doc(`tokens/${f.recipient}/tokens/later-device`).set({});
  await sendInboxPush(db, messaging, event);
  assert.equal(sends.length, 1);
});
