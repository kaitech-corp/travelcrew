"use strict";

const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {getStorage} = require("firebase-admin/storage");
const {createPrivatePhotoHandler} = require("../private-photos");

const projectId = "demo-travelcrew-safety";
const bucketName = `${projectId}.appspot.com`;
const tripId = "private-photo-integration-trip";
const owner = "private-photo-owner";
const member = "private-photo-member";
const outsider = "private-photo-outsider";
const path = `private_uploads/${owner}/trip_images/${tripId}/cover.jpg`;
const source = `gs://${bucketName}/${path}`;
let app; let db; let auth; let bucket; let handler; let tokens;

async function signIn(uid) {
  const response = await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key`, {
    method: "POST", headers: {"Content-Type": "application/json"},
    body: JSON.stringify({email: `${uid}@example.test`, password: "test-password-123", returnSecureToken: true}),
  });
  const result = await response.json();
  assert.ok(result.idToken, result.error?.message);
  return result.idToken;
}

async function request(token, ref = source) {
  const response = {statusCode: 0, headers: {}, body: null,
    set(name, value) { this.headers[name] = value; return this; },
    status(code) { this.statusCode = code; return this; },
    send(body) { this.body = body; return this; }};
  await handler({method: "GET", headers: token ? {authorization: `Bearer ${token}`} : {},
    query: {ref}}, response);
  return response;
}

before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST ||
      !process.env.STORAGE_EMULATOR_HOST || process.env.GCLOUD_PROJECT !== projectId) {
    throw new Error("Demo Auth, named Firestore, and Storage emulators required");
  }
  app = initializeApp({projectId, storageBucket: bucketName}, "private-photo-integration");
  db = getFirestore(app, "travel-crew-db-2");
  auth = getAuth(app);
  bucket = getStorage(app).bucket();
  for (const uid of [owner, member, outsider]) {
    await auth.createUser({uid, email: `${uid}@example.test`, password: "test-password-123"});
    await db.doc(`users/${uid}`).set({isDeleted: false});
  }
  await db.doc(`trips/${tripId}`).set({createdBy: owner, joinedUsers: [member],
    tripStatus: "upcoming", isShared: false, isPrivate: true, images: [source]});
  await db.doc(`trips/${tripId}/members/${member}`).set({status: "active"});
  await bucket.file(path).save(Buffer.from("image"), {resumable: false,
    metadata: {contentType: "image/jpeg"}});
  handler = createPrivatePhotoHandler({db, auth, bucket});
  tokens = {owner: await signIn(owner), member: await signIn(member),
    outsider: await signIn(outsider)};
});

after(async () => {
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});

test("real emulator ID tokens and named trip membership gate private image bytes", async () => {
  assert.equal((await request(null)).statusCode, 401);
  assert.equal((await request(tokens.outsider)).statusCode, 404);
  const image = await request(tokens.member);
  assert.equal(image.statusCode, 200);
  assert.equal(image.headers["Content-Type"], "image/jpeg");
  assert.equal(image.body.toString(), "image");
  await db.doc(`trips/${tripId}/members/${member}`).update({status: "left"});
  assert.equal((await request(tokens.member)).statusCode, 404);
  await db.doc(`trips/${tripId}`).update({isShared: true});
  assert.equal((await request(tokens.outsider)).statusCode, 200);
  await db.doc(`trips/${tripId}`).update({isShared: false});
  assert.equal((await request(tokens.outsider)).statusCode, 404);
});

test("Functions HTTP transport serves the same authorized image", {
  skip: !process.env.FIREBASE_FUNCTIONS_EMULATOR_HOST,
}, async () => {
  await db.doc(`trips/${tripId}/members/${member}`).update({status: "active"});
  const url = new URL(`http://${process.env.FIREBASE_FUNCTIONS_EMULATOR_HOST}/${projectId}/us-central1/privatePhotoV3`);
  url.searchParams.set("ref", source);
  const ok = await fetch(url, {headers: {Authorization: `Bearer ${tokens.member}`}});
  assert.equal(ok.status, 200);
  assert.equal(ok.headers.get("cache-control"), "private, no-store");
  assert.equal(await ok.text(), "image");
  await db.doc(`trips/${tripId}/members/${member}`).update({status: "left"});
  const denied = await fetch(url, {headers: {Authorization: `Bearer ${tokens.member}`}});
  assert.equal(denied.status, 404);
});
