"use strict";

const {createHash} = require("node:crypto");
const {parsePrivatePhoto} = require("./private-photos");

const ID = /^[A-Za-z0-9_-]{1,128}$/;
const TYPE_EXTENSION = new Map([
  ["image/jpeg", "jpg"], ["image/png", "png"], ["image/webp", "webp"],
  ["image/gif", "gif"], ["image/heic", "heic"], ["image/heif", "heif"],
]);
const hash = (value) => createHash("sha256").update(value).digest("hex");

function anchorFor(reference) {
  const parts = reference.document.split("/");
  if (parts.length !== 2) return null;
  if (parts[0] === "trips" && reference.field === "images[]" && ID.test(parts[1])) {
    return {kind: "trip", id: parts[1]};
  }
  if (parts[0] === "publicProfile" && reference.field === "profileImage" && ID.test(parts[1])) {
    return {kind: "profile", id: parts[1]};
  }
  return null;
}

function referenceAllowed(reference, anchor) {
  const parts = reference.document.split("/");
  if (parts.length !== 2) return false;
  const [collection, id] = parts;
  if (anchor.kind === "trip") {
    return id === anchor.id &&
      ((collection === "trips" && ["images[]", "imageCredits{key}"].includes(reference.field)) ||
        (collection === "tripDiscovery" && reference.field === "images[]"));
  }
  return (collection === "publicProfile" && id === anchor.id && reference.field === "profileImage") ||
    (collection === "users" && id === anchor.id && reference.field === "profileImage") ||
    (collection === "userPublicProfile" && id === anchor.id && reference.field === "profileImage") ||
    (collection === "tripDiscovery" && reference.field === "creatorProfileImage") ||
    (collection === "chat" && reference.field === "users[].profileImage");
}

async function buildPhotoMigrationPlan({inventory, db, bucket, project, database}) {
  if (!inventory.coverageComplete || inventory.totals.cappedDocuments ||
      inventory.totals.missingObjects || inventory.totals.tokenMismatch ||
      inventory.totals.invalidMetadata || inventory.totals.metadataErrors ||
      !ID.test(project) || !ID.test(database)) {
    throw new Error("A complete and clean photo inventory is required.");
  }
  const groups = new Map();
  for (const reference of inventory.manifest) {
    if (reference.kind !== "tokenized") continue;
    const group = groups.get(reference.sourceHash) || [];
    group.push(reference);
    groups.set(reference.sourceHash, group);
  }
  if (groups.size !== inventory.totals.uniqueTokenizedSources ||
      groups.size !== inventory.sources.size) {
    throw new Error("Photo source inventory changed.");
  }
  const sources = [];
  const paths = new Set();
  for (const sourceHash of [...groups.keys()].sort()) {
    const references = groups.get(sourceHash);
    const anchors = references.map(anchorFor).filter(Boolean);
    if (anchors.length !== 1 || references.some((reference) => !referenceAllowed(reference, anchors[0]))) {
      throw new Error("A photo source has ambiguous or unsupported references.");
    }
    const anchor = anchors[0];
    const source = inventory.sources.get(sourceHash);
    if (!source || !source.source || hash(source.source) !== sourceHash ||
        paths.has(source.path)) throw new Error("A photo source is missing or shares an old object.");
    paths.add(source.path);
    const anchorRef = anchor.kind === "trip" ? db.doc(`trips/${anchor.id}`) :
      db.doc(`publicProfile/${anchor.id}`);
    const anchorDoc = await anchorRef.get();
    const anchorData = anchorDoc.data();
    if (!anchorDoc.exists || (anchor.kind === "trip" &&
        (!ID.test(anchorData?.createdBy) || !anchorData.images?.includes(source.source))) ||
        (anchor.kind === "profile" && anchorData?.profileImage !== source.source)) {
      throw new Error("A photo anchor changed during planning.");
    }
    const ownerId = anchor.kind === "trip" ? anchorData.createdBy : anchor.id;
    for (const reference of references) {
      if (reference.document.startsWith("tripDiscovery/")) {
        const card = await db.doc(reference.document).get();
        if (card.data()?.createdBy !== ownerId) {
          throw new Error("A discovery photo has a different creator.");
        }
      }
      if (reference.document.startsWith("chat/")) {
        const room = await db.doc(reference.document).get();
        if (!room.data()?.users?.some((user) =>
          user.id === ownerId && user.profileImage === source.source)) {
          throw new Error("A chat avatar does not match its owner.");
        }
      }
    }
    const [metadata] = await bucket.file(source.path).getMetadata();
    const type = metadata.contentType?.split(";")[0].trim().toLowerCase();
    const size = Number(metadata.size);
    const generation = String(metadata.generation || "");
    if (!TYPE_EXTENSION.has(type) || !Number.isSafeInteger(size) ||
        size <= 0 || size > 20 * 1024 * 1024 || !/^\d+$/.test(generation) ||
        !(metadata.metadata?.firebaseStorageDownloadTokens || "").split(",").includes(source.token)) {
      throw new Error("A photo object changed during planning.");
    }
    const targetPath = anchor.kind === "trip" ?
      `private_uploads/${ownerId}/trip_images/${anchor.id}/${sourceHash}.${TYPE_EXTENSION.get(type)}` :
      `private_uploads/${ownerId}/users_profile/${sourceHash}.${TYPE_EXTENSION.get(type)}`;
    const target = `gs://${bucket.name}/${targetPath}`;
    const parsed = parsePrivatePhoto(target, bucket.name);
    if (!parsed || parsed.ownerId !== ownerId ||
        (anchor.kind === "trip" && parsed.tripId !== anchor.id)) {
      throw new Error("Private destination validation failed.");
    }
    sources.push({sourceHash, oldPath: source.path, sourceGeneration: generation,
      contentType: type, size, ownerId, anchor, targetPath, target,
      documents: [...new Set(references.map((reference) => reference.document))].sort()});
  }
  const identity = {version: 1, project, database, bucket: bucket.name, sources};
  return {...identity, planId: hash(JSON.stringify(identity))};
}

function replacePhotoReferences(data, substitutions) {
  let changed = false;
  function replace(value) {
    if (typeof value === "string") {
      const replacement = substitutions.get(hash(value));
      if (replacement && value !== replacement) { changed = true; return replacement; }
      return value;
    }
    if (Array.isArray(value)) return value.map(replace);
    if (!value || Object.getPrototypeOf(value) !== Object.prototype) return value;
    const updated = {};
    for (const [key, item] of Object.entries(value)) {
      const replacement = substitutions.get(hash(key));
      const nextKey = replacement || key;
      if (nextKey !== key) changed = true;
      if (Object.hasOwn(updated, nextKey)) {
        throw new Error("Image credit keys would collide during migration.");
      }
      updated[nextKey] = replace(item);
    }
    return updated;
  }
  const updated = replace(data);
  return {updated, changed};
}

module.exports = {buildPhotoMigrationPlan, replacePhotoReferences, anchorFor, referenceAllowed};
