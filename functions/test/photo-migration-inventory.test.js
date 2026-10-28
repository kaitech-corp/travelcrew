"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {tokenizedStoragePhoto, photoReferences,
  inventoryPhotoReferences} = require("../photo-migration-inventory");
const {main} = require("../photo-migration-inventory-cli");

const bucketName = "app.appspot.com";
const path = "uploads/owner/trip_images/old.jpg";
const token = "PRIVATE_DOWNLOAD_TOKEN";
const source = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
const privateSource = `gs://${bucketName}/private_uploads/owner/trip_images/trip-1/new.jpg`;

function fakeDb(data) {
  const documentRef = (name, id) => ({id, path: `${name}/${id}`,
    listCollections: async () => Object.keys(data).filter((key) =>
      key.startsWith(`${name}/${id}/`) &&
      key.split("/").length === name.split("/").length + 2)
      .map((key) => db.collection(key))});
  const db = {collection(name) {
    let cursor = ""; let limit = 50;
    const query = {
      orderBy: () => query,
      limit: (value) => { limit = value; return query; },
      startAfter: (last) => { cursor = last.id; return query; },
      get: async () => {
        const docs = (data[name] || []).filter((entry) => entry.id > cursor)
          .sort((a, b) => a.id.localeCompare(b.id)).slice(0, limit)
          .map((entry) => ({id: entry.id, data: () => entry.data,
            ref: documentRef(name, entry.id),
          }));
        return {docs, size: docs.length};
      },
      listDocuments: async () => [...new Set([
        ...(data[name] || []).map((entry) => entry.id),
        ...Object.keys(data).filter((key) => key.startsWith(`${name}/`) &&
          key.split("/").length >= name.split("/").length + 2)
          .map((key) => key.split("/")[name.split("/").length]),
      ])].map((id) => documentRef(name, id)),
      path: name,
    };
    return query;
  }};
  return db;
}

test("download-token parser is bucket-scoped and rejects malformed paths", () => {
  assert.deepEqual(tokenizedStoragePhoto(source, bucketName), {path, token});
  for (const invalid of [source.replace(bucketName, "other.appspot.com"),
    source.replace("firebasestorage.googleapis.com", "evil.example"),
    source.replace("old.jpg", "..%2Fsecret.jpg"),
    source.replace("token=", "access="),
  ]) assert.equal(tokenizedStoragePhoto(invalid, bucketName), null);
});

test("inventory finds document values and map keys without retaining token text", () => {
  const result = photoReferences({images: [source, privateSource], imageCredits: {[source]: {author: "A"}},
    users: [{profileImage: source}]}, bucketName);
  assert.equal(result.capped, false);
  assert.deepEqual(result.found.map((item) => item.fieldPath), [
    "images[]", "images[]", "imageCredits{key}", "users[].profileImage",
  ]);
  assert.equal(result.found.filter((item) => item.kind === "tokenized").length, 3);
  assert.equal(result.found.filter((item) => item.kind === "private").length, 1);
  assert.equal(JSON.stringify(result.found.map((entry) => ({sourceHash: entry.sourceHash,
    fieldPath: entry.fieldPath, kind: entry.kind, path: entry.path}))).includes(token), false);
  assert.equal(photoReferences({huge: Array(10).fill("x")}, bucketName, 3).capped, true);
});

test("paged read-only inventory checks metadata and flags incomplete coverage", async () => {
  const db = fakeDb({trips: [{id: "a", data: {images: [source]}},
    {id: "b", data: {images: [source]}}], publicProfile: [{id: "owner", data: {profileImage: privateSource}}]});
  let metadataReads = 0;
  const bucket = {name: bucketName, file: (objectPath) => {
    assert.equal(objectPath, path);
    return {getMetadata: async () => {
      metadataReads++;
      return [{size: "5", contentType: "image/jpeg", metadata: {firebaseStorageDownloadTokens: token}}];
    }};
  }};
  const result = await inventoryPhotoReferences(db, bucket, {collections: ["trips", "publicProfile"], pageSize: 1,
    maxPages: 3});
  assert.equal(result.coverageComplete, true);
  assert.equal(result.totals.tokenizedReferences, 2);
  assert.equal(result.totals.privateReferences, 1);
  assert.equal(result.totals.uniqueTokenizedSources, 1);
  assert.equal(metadataReads, 1);
  const capped = await inventoryPhotoReferences(db, bucket, {collections: ["trips"], pageSize: 1,
    maxPages: 1});
  assert.equal(capped.coverageComplete, false);
  assert.equal(capped.coverage.trips.nextAfter, "a");
});

test("descendant scan finds nested image copies and enforces traversal caps", async () => {
  const db = fakeDb({trips: [{id: "a", data: {images: []}}],
    "trips/a/activities": [{id: "activity", data: {attachment: source}}]});
  const bucket = {name: bucketName, file: () => ({getMetadata: async () => [
    {size: "5", contentType: "image/jpeg", metadata: {firebaseStorageDownloadTokens: token}},
  ]})};
  const result = await inventoryPhotoReferences(db, bucket, {collections: ["trips"],
    includeDescendants: true, checkOrphans: true});
  assert.equal(result.coverageComplete, true);
  assert.equal(result.totals.nestedDocuments, 1);
  assert.equal(result.totals.tokenizedReferences, 1);
  assert.equal(result.manifest[0].document, "trips/a/activities/activity");
  const capped = await inventoryPhotoReferences(db, bucket, {collections: ["trips"],
    includeDescendants: true, checkOrphans: true, maxDocuments: 1});
  assert.equal(capped.coverageComplete, false);
  assert.ok(capped.totals.traversalCapped > 0);
  const orphanDb = fakeDb({trips: [{id: "a", data: {images: []}}],
    "trips/orphan/activities": [{id: "nested", data: {attachment: source}}]});
  const orphan = await inventoryPhotoReferences(orphanDb, bucket, {collections: ["trips"],
    includeDescendants: true, checkOrphans: true});
  assert.equal(orphan.coverageComplete, true);
  assert.equal(orphan.totals.orphanParents, 1);
  assert.equal(orphan.totals.tokenizedReferences, 1);
});

test("CLI requires explicit targets and never prints bearer tokens", async () => {
  await assert.rejects(main([]), /explicit --project/);
  const db = fakeDb({trips: [{id: "trip-1", data: {images: [source]}}]});
  const bucket = {name: bucketName, file: () => ({getMetadata: async () => [
    {size: "5", contentType: "image/jpeg", metadata: {firebaseStorageDownloadTokens: token}},
  ]})};
  let printed = "";
  const output = await main(["--project", "demo-travelcrew-safety", "--database", "travel-crew-db-2",
    "--bucket", bucketName, "--collections", "trips"],
  {db, bucket, app: {}, print: (value) => { printed = value; }});
  assert.equal(output.coverageComplete, true);
  assert.equal(printed.includes(token), false);
  assert.equal(printed.includes("trip-1"), false);
  db.listCollections = async () => [{id: "trips"}];
  const all = await main(["--project", "demo-travelcrew-safety", "--database", "travel-crew-db-2",
    "--bucket", bucketName, "--all-top-level"],
  {db, bucket, app: {}, print: () => {}});
  assert.equal(all.coverageComplete, true);
  assert.deepEqual(Object.keys(all.coverage), ["trips"]);
});
