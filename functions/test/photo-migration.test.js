"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {createHash} = require("node:crypto");
const {Readable} = require("node:stream");
const {buildPhotoMigrationPlan, replacePhotoReferences} = require("../photo-migration");
const {stagePhotoCopies, verifyStagedCopies,
  rewritePhotoReferences} = require("../photo-migration-apply");

const bucketName = "app.appspot.com";
const oldPath = "uploads/owner/trip_images/old.jpg";
const token = "PRIVATE_TOKEN";
const source = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(oldPath)}?alt=media&token=${token}`;
const sourceHash = createHash("sha256").update(source).digest("hex");
const reference = (document, field) => ({document, field, kind: "tokenized", sourceHash, storagePath: oldPath});

function fixture() {
  const records = new Map([
    ["trips/trip-1", {createdBy: "owner", images: [source]}],
    ["tripDiscovery/trip-1", {createdBy: "owner", images: [source]}],
  ]);
  const db = {doc: (path) => ({path,
    get: async () => ({exists: records.has(path), data: () => records.get(path)})}),
  runTransaction: async (fn) => fn({
    get: async (ref) => ref.get(),
    update: (ref, patch) => records.set(ref.path, {...records.get(ref.path), ...patch}),
  })};
  const objects = new Map([[oldPath, {bytes: Buffer.from("image"), metadata: {
    generation: "42", size: "5", contentType: "image/jpeg",
    metadata: {firebaseStorageDownloadTokens: token},
  }}]]);
  const bucket = {name: bucketName, file: (path) => ({
    getMetadata: async () => {
      if (!objects.has(path)) throw Object.assign(Error("missing"), {code: 404});
      return [objects.get(path).metadata];
    },
    createReadStream: () => Readable.from([objects.get(path).bytes]),
    save: async (bytes, options) => {
      assert.equal(options.preconditionOpts.ifGenerationMatch, 0);
      if (objects.has(path)) throw Object.assign(Error("exists"), {code: 412});
      objects.set(path, {bytes: Buffer.from(bytes), metadata: {generation: "43",
        size: String(bytes.length), ...options.metadata}});
    },
    delete: async (options) => {
      if (!objects.has(path)) throw Object.assign(Error("missing"), {code: 404});
      if (objects.get(path).metadata.generation !== options.ifGenerationMatch) {
        throw Object.assign(Error("changed"), {code: 412});
      }
      objects.delete(path);
    },
  })};
  const inventory = {coverageComplete: true, totals: {cappedDocuments: 0, missingObjects: 0,
    tokenMismatch: 0, invalidMetadata: 0, metadataErrors: 0, uniqueTokenizedSources: 1},
  manifest: [reference("trips/trip-1", "images[]"), reference("tripDiscovery/trip-1", "images[]")],
  sources: new Map([[sourceHash, {source, path: oldPath, token}]])};
  const plan = () => buildPhotoMigrationPlan({inventory, db, bucket,
    project: "demo-travelcrew-safety", database: "travel-crew-db-2"});
  return {records, objects, db, bucket, inventory, plan};
}

test("plan binds each source to its owner, trip and immutable object generation", async () => {
  const f = fixture();
  const plan = await f.plan();
  assert.match(plan.planId, /^[a-f0-9]{64}$/);
  assert.equal(plan.sources.length, 1);
  assert.equal(plan.sources[0].sourceGeneration, "42");
  assert.equal(plan.sources[0].target,
    `gs://${bucketName}/private_uploads/owner/trip_images/trip-1/${sourceHash}.jpg`);
  assert.deepEqual(plan.sources[0].documents, ["tripDiscovery/trip-1", "trips/trip-1"]);
  assert.equal(JSON.stringify(plan).includes(token), false);
});

test("plan rejects ambiguous references and changed ownership", async () => {
  const f = fixture();
  f.inventory.manifest.push(reference("trips/another", "images[]"));
  await assert.rejects(f.plan(), /ambiguous/);
  f.inventory.manifest.pop();
  f.inventory.manifest.push(reference("reports/evidence", "evidence.images[]"));
  await assert.rejects(f.plan(), /unsupported/);
  f.inventory.manifest.pop();
  f.records.get("trips/trip-1").createdBy = "different";
  await assert.rejects(f.plan(), /different creator/);
  f.records.get("trips/trip-1").images = [];
  await assert.rejects(f.plan(), /anchor changed/);
});

test("replacement preserves unrelated values and renames image-credit keys", () => {
  const target = `gs://${bucketName}/private_uploads/owner/trip_images/trip-1/${sourceHash}.jpg`;
  const original = {images: [source, "https://example.test/other"],
    imageCredits: {[source]: {author: "Owner"}}, title: "Trip"};
  const changed = replacePhotoReferences(original, new Map([[sourceHash, target]]));
  assert.equal(changed.changed, true);
  assert.deepEqual(changed.updated.images, [target, "https://example.test/other"]);
  assert.deepEqual(changed.updated.imageCredits[target], {author: "Owner"});
  assert.equal(changed.updated.title, "Trip");
  assert.equal(original.images[0], source);
  assert.throws(() => replacePhotoReferences({imageCredits: {[source]: {}, [target]: {}}},
      new Map([[sourceHash, target]])), /collide/);
});

test("private copies are create-only, checked and idempotent", async () => {
  const f = fixture(); const plan = await f.plan();
  const first = await stagePhotoCopies(f.bucket, plan);
  assert.equal(first.staged[0].created, true);
  assert.equal(f.objects.get(plan.sources[0].targetPath).metadata.metadata?.firebaseStorageDownloadTokens, undefined);
  await verifyStagedCopies(f.bucket, plan, first);
  const retry = await stagePhotoCopies(f.bucket, plan);
  assert.equal(retry.staged[0].created, false);
  f.objects.get(plan.sources[0].targetPath).bytes = Buffer.from("other");
  await assert.rejects(verifyStagedCopies(f.bucket, plan, first), /changed/);
});

test("reference rewrites preserve other fields and retry without duplicate writes", async () => {
  const f = fixture(); const plan = await f.plan();
  const stage = await stagePhotoCopies(f.bucket, plan);
  f.records.get("trips/trip-1").title = "Concurrent edit";
  f.records.get("trips/trip-1").imageCredits = {[source]: {author: "Owner"}};
  const result = await rewritePhotoReferences(f.db, f.bucket, plan, stage);
  assert.equal(result.updated, 2);
  assert.equal(f.records.get("trips/trip-1").title, "Concurrent edit");
  assert.deepEqual(f.records.get("trips/trip-1").images, [plan.sources[0].target]);
  assert.deepEqual(f.records.get("trips/trip-1").imageCredits[plan.sources[0].target], {author: "Owner"});
  const retry = await rewritePhotoReferences(f.db, f.bucket, plan, stage);
  assert.equal(retry.unchanged, 2);
});
