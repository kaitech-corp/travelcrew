"use strict";

const {createHash} = require("node:crypto");
const {FieldPath} = require("firebase-admin/firestore");
const {parsePrivatePhoto} = require("./private-photos");

const COLLECTIONS = [
  "trips", "tripDiscovery", "users", "publicProfile",
  "userPublicProfile", "chat", "reports",
];
const MAX_FIELDS_PER_DOC = 5000;
const PHOTO_TYPES = new Set([
  "image/jpeg", "image/png", "image/webp", "image/gif", "image/heic", "image/heif",
]);

function tokenizedStoragePhoto(value, bucketName) {
  if (typeof value !== "string" || value.length > 4096) return null;
  try {
    const url = new URL(value);
    if (url.protocol !== "https:" || url.hostname !== "firebasestorage.googleapis.com" ||
        url.port || url.username || url.password || url.hash ||
        url.searchParams.get("alt") !== "media") return null;
    const match = /^\/v0\/b\/([^/]+)\/o\/(.+)$/.exec(url.pathname);
    if (!match || decodeURIComponent(match[1]) !== bucketName) return null;
    const path = decodeURIComponent(match[2]);
    const token = url.searchParams.get("token");
    if (!path || path.length > 1024 || path.includes("\\") || path.includes("\0") ||
        path.split("/").some((part) => !part || part === "." || part === "..") ||
        !token || !/^[A-Za-z0-9._-]{1,256}$/.test(token)) return null;
    return {path, token};
  } catch {
    return null;
  }
}

function photoReferences(data, bucketName, maxFields = MAX_FIELDS_PER_DOC) {
  const found = [];
  let visited = 0;
  let capped = false;
  function capture(value, fieldPath) {
    const tokenized = tokenizedStoragePhoto(value, bucketName);
    const privatePhoto = parsePrivatePhoto(value, bucketName);
    if (tokenized || privatePhoto) {
      found.push({fieldPath, sourceHash: createHash("sha256").update(value).digest("hex"),
        kind: tokenized ? "tokenized" : "private", path: (tokenized || privatePhoto).path,
        token: tokenized?.token, source: value});
    }
  }
  function walk(value, fieldPath, depth) {
    if (++visited > maxFields || depth > 8) { capped = true; return; }
    if (typeof value === "string") {
      capture(value, fieldPath);
      return;
    }
    if (Array.isArray(value)) {
      for (const item of value) walk(item, `${fieldPath}[]`, depth + 1);
      return;
    }
    if (value && Object.getPrototypeOf(value) === Object.prototype) {
      for (const [key, item] of Object.entries(value)) {
        capture(key, `${fieldPath}{key}`);
        walk(item, fieldPath ? `${fieldPath}.${key}` : key, depth + 1);
      }
    }
  }
  walk(data, "", 0);
  return {found, capped};
}

async function inventoryPhotoReferences(db, bucket, {pageSize = 50, maxPages = 100,
  collections = COLLECTIONS, includeDescendants = false, maxDocuments = 10000,
  maxNestedCollections = 2000, maxDepth = 6, checkOrphans = false} = {}) {
  if (!Number.isInteger(pageSize) || pageSize < 1 || pageSize > 100 ||
      !Number.isInteger(maxPages) || maxPages < 1 || maxPages > 1000 ||
      !Array.isArray(collections) || collections.length < 1 || collections.length > 200 ||
      collections.some((name) => typeof name !== "string" ||
        !/^[A-Za-z0-9_-]{1,128}$/.test(name)) ||
      new Set(collections).size !== collections.length ||
      !Number.isInteger(maxDocuments) || maxDocuments < 1 || maxDocuments > 100000 ||
      !Number.isInteger(maxNestedCollections) || maxNestedCollections < 1 ||
        maxNestedCollections > 10000 ||
      !Number.isInteger(maxDepth) || maxDepth < 1 || maxDepth > 10) {
    throw new Error("Use bounded page and collection options.");
  }
  const manifest = [];
  const coverage = {};
  const totals = {documents: 0, tokenizedReferences: 0, privateReferences: 0,
    cappedDocuments: 0, uniqueTokenizedSources: 0, storageChecked: 0,
    missingObjects: 0, tokenMismatch: 0, invalidMetadata: 0, metadataErrors: 0,
    nestedCollections: 0, nestedDocuments: 0, orphanParents: 0,
    traversalCapped: 0};
  const sources = new Map();
  async function scanChildren(parent, depth) {
    const children = await parent.listCollections();
    for (const child of children) {
      if (depth >= maxDepth || totals.nestedCollections >= maxNestedCollections) {
        totals.traversalCapped++;
        continue;
      }
      totals.nestedCollections++;
      const nested = await scan(child, child.path, depth + 1);
      if (!nested.complete) totals.traversalCapped++;
    }
  }
  async function scan(ref, collection, depth) {
    let cursor;
    let complete = false;
    let pages = 0;
    let documents = 0;
    const seen = new Set();
    for (; pages < maxPages; pages++) {
      let query = ref.orderBy(FieldPath.documentId()).limit(pageSize);
      if (cursor) query = query.startAfter(cursor);
      const snapshot = await query.get();
      for (const doc of snapshot.docs) {
        if (totals.documents >= maxDocuments) {
          totals.traversalCapped++;
          return {documents, pages: pages + 1, complete: false, nextAfter: cursor?.id || null};
        }
        documents++;
        totals.documents++;
        seen.add(doc.id);
        if (depth > 0) totals.nestedDocuments++;
        const result = photoReferences(doc.data(), bucket.name);
        if (result.capped) totals.cappedDocuments++;
        for (const photo of result.found) {
          totals[photo.kind === "tokenized" ? "tokenizedReferences" : "privateReferences"]++;
          manifest.push({document: doc.ref?.path || `${collection}/${doc.id}`, field: photo.fieldPath,
            sourceHash: photo.sourceHash, kind: photo.kind, storagePath: photo.path});
          if (photo.kind === "tokenized" && !sources.has(photo.sourceHash)) {
            sources.set(photo.sourceHash, photo);
          }
        }
        if (includeDescendants) await scanChildren(doc.ref, depth);
      }
      if (snapshot.size < pageSize) { complete = true; break; }
      cursor = snapshot.docs.at(-1);
    }
    if (includeDescendants && checkOrphans && complete) {
      // listDocuments(showMissing=true) includes document references whose
      // parent document was deleted while subcollections survived.
      const refs = await ref.listDocuments();
      if (refs.length > maxDocuments) totals.traversalCapped++;
      else for (const parent of refs) {
        if (seen.has(parent.id)) continue;
        totals.orphanParents++;
        await scanChildren(parent, depth);
      }
    }
    return {documents, pages: pages + (complete ? 1 : 0),
      complete, nextAfter: complete ? null : cursor?.id || null};
  }
  for (const collection of collections) {
    coverage[collection] = await scan(db.collection(collection), collection, 0);
  }
  totals.uniqueTokenizedSources = sources.size;
  for (const photo of sources.values()) {
    try {
      const [metadata] = await bucket.file(photo.path).getMetadata();
      totals.storageChecked++;
      const tokens = metadata.metadata?.firebaseStorageDownloadTokens?.split(",") || [];
      if (!tokens.includes(photo.token)) totals.tokenMismatch++;
      const size = Number(metadata.size);
      const type = metadata.contentType?.split(";")[0].trim().toLowerCase();
      if (!PHOTO_TYPES.has(type) || !Number.isFinite(size) || size <= 0 ||
          size > 20 * 1024 * 1024) totals.invalidMetadata++;
    } catch (error) {
      if (error.code === 404) totals.missingObjects++;
      else totals.metadataErrors++;
    }
  }
  return {coverage, totals, manifest, sources,
    coverageComplete: Object.values(coverage).every((entry) => entry.complete) &&
      totals.cappedDocuments === 0 && totals.metadataErrors === 0 &&
      totals.traversalCapped === 0 && (!includeDescendants || checkOrphans)};
}

module.exports = {COLLECTIONS, tokenizedStoragePhoto, photoReferences, inventoryPhotoReferences};
