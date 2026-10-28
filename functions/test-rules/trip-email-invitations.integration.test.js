const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {createTripEmailInvitationHandler} = require("../trip-email-invitations");

let app; let db; let auth; let send; let sequence = 0;
before(() => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    throw new Error("Auth and Firestore emulators required");
  }
  app = initializeApp({projectId: "demo-travelcrew-safety"}, "trip-email-integration");
  db = getFirestore(app, "travel-crew-db-2");
  auth = getAuth(app);
  send = createTripEmailInvitationHandler(db, auth);
});
after(async () => { if (app) { await db.terminate(); await deleteApp(app); } });

async function fixture() {
  const base = `email-invite-${Date.now()}-${++sequence}`;
  const tripId = `${base}-trip`;
  const owner = `${base}-owner`;
  const recipient = `${base}-recipient`;
  const address = `${recipient}@example.com`;
  await auth.createUser({uid: owner});
  await auth.createUser({uid: recipient, email: address});
  await db.doc(`trips/${tripId}`).set({id: tripId, createdBy: owner,
    title: "Stored title", destination: "Tokyo", tripStatus: "upcoming", invitedUsers: []});
  const request = (data, uid = owner) => ({auth: {uid}, data: {tripId, ...data}});
  return {tripId, owner, recipient, address, request};
}

test("concurrent retries queue one mail document and retain the original result", async () => {
  const f = await fixture();
  const payload = {requestId: "initial_attempt", tripTitle: "Forged title",
    emails: [` ${f.address.toUpperCase()} `, f.address]};
  const results = await Promise.all(Array.from({length: 4}, () => send(f.request(payload))));
  assert.ok(results.every((result) => result.queued === 1));
  const mails = await db.collection("mail").where("tripId", "==", f.tripId).get();
  assert.equal(mails.size, 1);
  assert.deepEqual(mails.docs[0].data().to, [f.address]);
  assert.match(mails.docs[0].data().message.text, /Stored title/);
  const receipt = await db.doc(`trips/${f.tripId}/emailInviteAttempts/initial_attempt`).get();
  assert.equal(receipt.data().createdBy, f.owner);
  await assert.rejects(send(f.request({requestId: "initial_attempt", emails: ["other@example.com"]})),
      {code: "invalid-argument"});
  assert.equal((await db.collection("mail").where("tripId", "==", f.tripId).get()).size, 1);
});

test("owner, account and trip checks apply before queueing mail", async () => {
  const f = await fixture();
  const payload = {requestId: "first_attempt", emails: [f.address]};
  await assert.rejects(send({data: {tripId: f.tripId, ...payload}}), {code: "unauthenticated"});
  await assert.rejects(send(f.request(payload, f.recipient)), {code: "permission-denied"});
  await db.doc(`safetyAccounts/${f.owner}`).set({restricted: true});
  await assert.rejects(send(f.request(payload)), {code: "permission-denied"});
  await db.doc(`safetyAccounts/${f.owner}`).delete();
  await db.doc(`trips/${f.tripId}`).update({tripStatus: "deleted"});
  await assert.rejects(send(f.request(payload)), {code: "failed-precondition"});
  assert.equal((await db.collection("mail").where("tripId", "==", f.tripId).get()).size, 0);
});

test("blocked or disabled recipients receive no queued mail", async () => {
  const f = await fixture();
  await db.doc(`users/${f.owner}/blockedUsers/${f.recipient}`).set({});
  await send(f.request({requestId: "blocked_attempt", emails: [f.address]}));
  assert.equal((await db.collection("mail").where("tripId", "==", f.tripId).get()).size, 0);
  await db.doc(`users/${f.owner}/blockedUsers/${f.recipient}`).delete();
  await auth.updateUser(f.recipient, {disabled: true});
  await send(f.request({requestId: "disabled_attempt", emails: [f.address]}));
  assert.equal((await db.collection("mail").where("tripId", "==", f.tripId).get()).size, 0);
});
