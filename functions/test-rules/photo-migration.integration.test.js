"use strict";

const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getStorage} = require("firebase-admin/storage");
const {inventoryPhotoReferences} = require("../photo-migration-inventory");
const {buildPhotoMigrationPlan} = require("../photo-migration");
const {stagePhotoCopies, rewritePhotoReferences, verifyPhotoMigration,
  deleteOldPhotoObjects} = require("../photo-migration-apply");

const project = "demo-travelcrew-safety";
const bucketName = `${project}.appspot.com`;
let app; let db; let bucket;

before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.STORAGE_EMULATOR_HOST ||
      process.env.GCLOUD_PROJECT !== project) {
    throw new Error("Demo Firestore and Storage emulators are required.");
  }
  app = initializeApp({projectId: project, storageBucket: bucketName}, "photo-migration-integration");
  db = getFirestore(app, "photo-migration");
  bucket = getStorage(app).bucket();
});
after(async () => {
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});

test("migration copies, rewrites and revokes trip/profile tokens with retries", async () => {
  const source = (path, token) =>
    `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
  const tripPath = "trip_images/migration-cover.jpg";
  const profilePath = "users_profile/migration-avatar.jpg";
  const tripUrl = source(tripPath, "TRIP_SECRET");
  const profileUrl = source(profilePath, "PROFILE_SECRET");
  for (const [path, token] of [[tripPath, "TRIP_SECRET"], [profilePath, "PROFILE_SECRET"]]) {
    await bucket.file(path).save(Buffer.from("image"), {resumable: false,
      metadata: {contentType: "image/jpeg", metadata: {firebaseStorageDownloadTokens: token}}});
  }
  await db.doc("trips/trip-1").set({id: "trip-1", createdBy: "owner", images: [tripUrl],
    imageCredits: {[tripUrl]: {author: "Owner"}}, title: "Before"});
  await db.doc("tripDiscovery/trip-1").set({createdBy: "owner", isDiscoverable: true,
    images: [tripUrl], creatorProfileImage: profileUrl});
  await db.doc("users/owner").set({profileImage: profileUrl});
  await db.doc("publicProfile/owner").set({profileImage: profileUrl});
  await db.doc("chat/trip-1").set({users: [{id: "owner", profileImage: profileUrl}]});
  const options = async () => ({collections: (await db.listCollections()).map((ref) => ref.id).sort(),
    includeDescendants: true, checkOrphans: true});
  const beforeInventory = await inventoryPhotoReferences(db, bucket, await options());
  assert.equal(beforeInventory.coverageComplete, true);
  assert.equal(beforeInventory.totals.tokenizedReferences, 7);
  const plan = await buildPhotoMigrationPlan({inventory: beforeInventory, db, bucket,
    project, database: "photo-migration"});
  assert.equal(plan.sources.length, 2);
  const stage = await stagePhotoCopies(bucket, plan);
  assert.equal(stage.staged.filter((item) => item.created).length, 2);
  assert.equal((await stagePhotoCopies(bucket, plan)).staged.filter((item) => item.created).length, 0);
  await db.doc("trips/trip-1").update({title: "Concurrent title"});
  const rewrite = await rewritePhotoReferences(db, bucket, plan, stage);
  assert.equal(rewrite.updated, 5);
  assert.equal((await rewritePhotoReferences(db, bucket, plan, stage)).unchanged, 5);
  const trip = (await db.doc("trips/trip-1").get()).data();
  assert.equal(trip.title, "Concurrent title");
  assert.ok(trip.images[0].startsWith(`gs://${bucketName}/private_uploads/owner/trip_images/trip-1/`));
  assert.deepEqual(trip.imageCredits[trip.images[0]], {author: "Owner"});
  const verified = await verifyPhotoMigration({db, bucket, plan, stage});
  assert.equal(verified.verified, true);
  assert.equal(verified.privateReferences, 7);
  await db.doc("tripDiscovery/trip-1").update({staleImage: tripUrl});
  await assert.rejects(deleteOldPhotoObjects({db, bucket, plan, stage}),
      /Old photo references remain/);
  await db.doc("tripDiscovery/trip-1").update({staleImage: ""});
  await bucket.file(tripPath).delete();
  const purge = await deleteOldPhotoObjects({db, bucket, plan, stage});
  assert.equal(purge.deleted, 1);
  assert.equal((await deleteOldPhotoObjects({db, bucket, plan, stage})).deleted, 0);
  assert.equal((await verifyPhotoMigration({db, bucket, plan, stage,
    allowMissingOld: true})).verified, true);
  for (const path of [tripPath, profilePath]) {
    await assert.rejects(bucket.file(path).getMetadata(), (error) => error.code === 404);
  }
});
