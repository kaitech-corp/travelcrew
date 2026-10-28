"use strict";

const {createHash} = require("node:crypto");
const {boundedBytes, parsePrivatePhoto} = require("./private-photos");
const {photoReferences, inventoryPhotoReferences} = require("./photo-migration-inventory");
const {replacePhotoReferences, referenceAllowed} = require("./photo-migration");

const hash = (value) => createHash("sha256").update(value).digest("hex");
const missing = (error) => error.code === 404 || error.code === "404";

function validatePlan(plan, bucketName) {
  if (plan?.version !== 1 || plan.bucket !== bucketName ||
      !Array.isArray(plan.sources) || !/^[a-f0-9]{64}$/.test(plan.planId)) {
    throw new Error("Invalid photo migration plan.");
  }
  const {planId, ...identity} = plan;
  if (hash(JSON.stringify(identity)) !== planId) {
    throw new Error("Photo migration plan fingerprint mismatch.");
  }
  const oldPaths = new Set(); const targets = new Set();
  for (const source of plan.sources) {
    const target = parsePrivatePhoto(source.target, bucketName);
    if (!/^[a-f0-9]{64}$/.test(source.sourceHash) ||
        !/^\d+$/.test(source.sourceGeneration) ||
        !Number.isSafeInteger(source.size) || source.size < 1 ||
        source.size > 20 * 1024 * 1024 ||
        !Array.isArray(source.documents) || !source.documents.length ||
        oldPaths.has(source.oldPath) || targets.has(source.targetPath) ||
        source.target !== `gs://${bucketName}/${source.targetPath}` ||
        !target || target.ownerId !== source.ownerId ||
        target.kind !== source.anchor?.kind ||
        (target.kind === "trip" && target.tripId !== source.anchor.id) ||
        (target.kind === "profile" && source.anchor.id !== source.ownerId) ||
        source.oldPath === source.targetPath ||
        source.oldPath.split("/").some((part) => !part || part === "." || part === "..")) {
      throw new Error("Photo migration plan has duplicate or invalid paths.");
    }
    oldPaths.add(source.oldPath); targets.add(source.targetPath);
  }
}

function sameSource(metadata, source) {
  return String(metadata.generation) === source.sourceGeneration &&
    Number(metadata.size) === source.size &&
    metadata.contentType?.split(";")[0].trim().toLowerCase() === source.contentType;
}

async function readBounded(file, size) {
  const bytes = await boundedBytes(file.createReadStream());
  if (bytes.length !== size) throw new Error("Photo bytes changed during migration.");
  return bytes;
}

async function stagePhotoCopies(bucket, plan) {
  validatePlan(plan, bucket.name);
  const staged = [];
  for (const source of plan.sources) {
    const old = bucket.file(source.oldPath);
    const [before] = await old.getMetadata();
    if (!sameSource(before, source)) throw new Error("Old photo generation changed.");
    const bytes = await readBounded(old, source.size);
    const [after] = await old.getMetadata();
    if (!sameSource(after, source)) throw new Error("Old photo changed during copy.");
    const digest = hash(bytes);
    const target = bucket.file(source.targetPath);
    let created = false;
    let exists = false;
    try {
      await target.getMetadata();
      exists = true;
    } catch (error) {
      if (!missing(error)) throw error;
    }
    if (!exists) {
      try {
        await target.save(bytes, {resumable: false, validation: "crc32c",
          preconditionOpts: {ifGenerationMatch: 0},
          metadata: {contentType: source.contentType, cacheControl: "private,no-store", metadata: {}}});
        created = true;
      } catch (error) {
        if (error.code !== 412 && error.code !== "412") throw error;
      }
    }
    const [targetMetadata] = await target.getMetadata();
    if (Number(targetMetadata.size) !== source.size ||
        targetMetadata.contentType?.split(";")[0].trim().toLowerCase() !== source.contentType ||
        targetMetadata.metadata?.firebaseStorageDownloadTokens ||
        hash(await readBounded(target, source.size)) !== digest) {
      throw new Error("Private copy differs or contains a download token.");
    }
    staged.push({sourceHash: source.sourceHash, targetPath: source.targetPath,
      targetGeneration: String(targetMetadata.generation), sha256: digest, created});
  }
  return {planId: plan.planId, staged};
}

async function verifyStagedCopies(bucket, plan, stage, {allowMissingOld = false} = {}) {
  validatePlan(plan, bucket.name);
  if (stage?.planId !== plan.planId || stage.staged?.length !== plan.sources.length ||
      new Set(stage.staged.map((item) => item.sourceHash)).size !== plan.sources.length) {
    throw new Error("Every private copy must be staged.");
  }
  for (const source of plan.sources) {
    const copy = stage.staged.find((item) => item.sourceHash === source.sourceHash);
    if (copy?.targetPath !== source.targetPath || !/^[a-f0-9]{64}$/.test(copy.sha256)) {
      throw new Error("A staged copy does not match its plan.");
    }
    try {
      const [oldMetadata] = await bucket.file(source.oldPath).getMetadata();
      if (!sameSource(oldMetadata, source)) throw new Error("An old photo changed after staging.");
    } catch (error) {
      if (!allowMissingOld || !missing(error)) throw error;
    }
    const file = bucket.file(source.targetPath);
    const [metadata] = await file.getMetadata();
    if (copy.targetGeneration !== String(metadata.generation) ||
        Number(metadata.size) !== source.size ||
        metadata.contentType?.split(";")[0].trim().toLowerCase() !== source.contentType ||
        metadata.metadata?.firebaseStorageDownloadTokens ||
        hash(await readBounded(file, source.size)) !== copy.sha256) {
      throw new Error("A staged private photo changed.");
    }
  }
}

function sortedDocuments(plan) {
  const documents = new Set(plan.sources.flatMap((source) => source.documents));
  const priority = {trips: 0, publicProfile: 1, users: 2,
    userPublicProfile: 3, tripDiscovery: 4, chat: 5};
  return [...documents].sort((a, b) =>
    (priority[a.split("/")[0]] ?? 9) - (priority[b.split("/")[0]] ?? 9) ||
      a.localeCompare(b));
}

function checkDocument(path, data, byHash, bucketName) {
  const current = photoReferences(data, bucketName);
  if (current.capped) throw new Error("Photo document exceeds migration bound.");
  for (const reference of current.found) {
    if (reference.kind !== "tokenized" || !byHash.has(reference.sourceHash)) continue;
    const source = byHash.get(reference.sourceHash);
    if (!source.documents.includes(path) ||
        !referenceAllowed({document: path, field: reference.fieldPath}, source.anchor)) {
      throw new Error("Unplanned photo reference appeared.");
    }
    if (path.startsWith("chat/") && !data.users?.some((user) =>
      user.id === source.ownerId && user.profileImage === reference.source)) {
      throw new Error("Chat photo ownership changed.");
    }
    if (path.startsWith("tripDiscovery/") && data.createdBy !== source.ownerId) {
      throw new Error("Discovery photo ownership changed.");
    }
  }
}

async function rewritePhotoReferences(db, bucket, plan, stage) {
  await verifyStagedCopies(bucket, plan, stage);
  const byHash = new Map(plan.sources.map((source) => [source.sourceHash, source]));
  const substitutions = new Map(plan.sources.map((source) => [source.sourceHash, source.target]));
  const results = {updated: 0, unchanged: 0, missing: 0};
  for (const path of sortedDocuments(plan)) {
    const result = await db.runTransaction(async (tx) => {
      const ref = db.doc(path);
      const snapshot = await tx.get(ref);
      if (!snapshot.exists) return "missing";
      const data = snapshot.data();
      checkDocument(path, data, byHash, bucket.name);
      for (const source of plan.sources.filter((item) => item.documents.includes(path))) {
        if (path === `trips/${source.anchor.id}` && data.createdBy !== source.ownerId) {
          throw new Error("Trip photo owner changed.");
        }
      }
      const patch = {};
      for (const [field, value] of Object.entries(data)) {
        const transformed = replacePhotoReferences(value, substitutions);
        if (transformed.changed) patch[field] = transformed.updated;
      }
      if (!Object.keys(patch).length) return "unchanged";
      tx.update(ref, patch);
      return "updated";
    });
    results[result]++;
  }
  return {planId: plan.planId, ...results};
}

async function verifyPhotoMigration({db, bucket, plan, stage, inventoryOptions = {},
  allowMissingOld = false}) {
  await verifyStagedCopies(bucket, plan, stage, {allowMissingOld});
  const collections = (await db.listCollections()).map((collection) => collection.id).sort();
  const inventory = await inventoryPhotoReferences(db, bucket, {...inventoryOptions,
    collections, includeDescendants: true, checkOrphans: true});
  if (!inventory.coverageComplete || inventory.totals.tokenizedReferences !== 0) {
    throw new Error("Old photo references remain or inventory is incomplete.");
  }
  for (const source of plan.sources) {
    let oldMetadata;
    try { [oldMetadata] = await bucket.file(source.oldPath).getMetadata(); } catch (error) {
      if (!allowMissingOld || !missing(error)) throw error;
    }
    const [targetMetadata] = await bucket.file(source.targetPath).getMetadata();
    const copy = stage.staged.find((item) => item.sourceHash === source.sourceHash);
    if ((oldMetadata && !sameSource(oldMetadata, source)) ||
        (!oldMetadata && !allowMissingOld) ||
        copy?.targetPath !== source.targetPath ||
        copy?.targetGeneration !== String(targetMetadata.generation) ||
        Number(targetMetadata.size) !== source.size ||
        targetMetadata.contentType?.split(";")[0].trim().toLowerCase() !== source.contentType ||
        targetMetadata.metadata?.firebaseStorageDownloadTokens) {
      throw new Error("A migration object changed before verification.");
    }
  }
  return {planId: plan.planId, verified: true, documents: inventory.totals.documents,
    privateReferences: inventory.totals.privateReferences};
}

async function deleteOldPhotoObjects({db, bucket, plan, stage, inventoryOptions}) {
  validatePlan(plan, bucket.name);
  await verifyPhotoMigration({db, bucket, plan, stage, inventoryOptions,
    allowMissingOld: true});
  let deleted = 0;
  for (const source of plan.sources) {
    const old = bucket.file(source.oldPath);
    try {
      await old.delete({ifGenerationMatch: source.sourceGeneration});
      deleted++;
    } catch (error) {
      if (!missing(error)) throw error;
    }
  }
  return {planId: plan.planId, deleted};
}

module.exports = {validatePlan, stagePhotoCopies, rewritePhotoReferences,
  verifyStagedCopies, verifyPhotoMigration, deleteOldPhotoObjects};
