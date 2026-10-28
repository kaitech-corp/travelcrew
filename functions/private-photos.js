"use strict";

const {isTripMember} = require("./trip-membership");

const MAX_PHOTO_BYTES = 20 * 1024 * 1024;
const PHOTO_TYPES = new Set([
  "image/jpeg", "image/png", "image/webp", "image/gif", "image/heic", "image/heif",
]);
const ID = /^[A-Za-z0-9_-]{1,128}$/;
const FILE = /^[A-Za-z0-9._-]{1,255}$/;

function parsePrivatePhoto(value, bucketName) {
  if (typeof value !== "string" || value.length > 1200 ||
      !value.startsWith(`gs://${bucketName}/`)) return null;
  const path = value.slice(bucketName.length + 6);
  if (path.includes("\\") || path.includes("?") || path.includes("#") ||
      path.split("/").some((part) => !part || part === "." || part === "..")) return null;
  const parts = path.split("/");
  if (parts[0] !== "private_uploads" || !ID.test(parts[1])) return null;
  if (parts.length === 5 && parts[2] === "trip_images" &&
      ID.test(parts[3]) && FILE.test(parts[4])) {
    return {kind: "trip", ownerId: parts[1], tripId: parts[3], path};
  }
  if (parts.length === 4 && parts[2] === "users_profile" && FILE.test(parts[3])) {
    return {kind: "profile", ownerId: parts[1], path};
  }
  return null;
}

async function boundedBytes(stream) {
  const chunks = [];
  let size = 0;
  for await (const chunk of stream) {
    size += chunk.length;
    if (size > MAX_PHOTO_BYTES) {
      stream.destroy?.();
      throw new Error("oversized photo stream");
    }
    chunks.push(Buffer.from(chunk));
  }
  if (!size) throw new Error("empty photo stream");
  return Buffer.concat(chunks, size);
}

function createPrivatePhotoHandler({db, auth, bucket, log = () => {}}) {
  async function allowed(uid, source, photo) {
    if (photo.kind === "profile") {
      const [profile, account, safety] = await Promise.all([
        db.doc(`publicProfile/${photo.ownerId}`).get(),
        db.doc(`users/${photo.ownerId}`).get(),
        db.doc(`safetyAccounts/${photo.ownerId}`).get(),
      ]);
      return profile.exists && account.exists && !account.data()?.isDeleted &&
        !safety.data()?.restricted && !profile.data()?.moderationRemoved &&
        profile.data()?.profileImage === source;
    }
    const tripRef = db.doc(`trips/${photo.tripId}`);
    const [trip, member, owner, safety, discovery] = await Promise.all([
      tripRef.get(), tripRef.collection("members").doc(uid).get(),
      db.doc(`users/${photo.ownerId}`).get(),
      db.doc(`safetyAccounts/${photo.ownerId}`).get(),
      db.doc(`tripDiscovery/${photo.tripId}`).get(),
    ]);
    const data = trip.data();
    return trip.exists && data?.createdBy === photo.ownerId &&
      data.tripStatus !== "deleted" && !data.moderationRemoved &&
      owner.exists && !owner.data()?.isDeleted && !safety.data()?.restricted &&
      Array.isArray(data.images) && data.images.includes(source) &&
      (isTripMember(data, uid, member.exists ? member.data() : null) ||
        data.isShared === true ||
        (data.isPrivate === false && discovery.data()?.isDiscoverable === true &&
          !discovery.data()?.moderationRemoved &&
          Array.isArray(discovery.data()?.images) && discovery.data().images.includes(source)));
  }

  return async (req, res) => {
    res.set("Cache-Control", "private, no-store");
    if (req.method !== "GET") return res.status(405).send();
    const authorization = req.headers.authorization;
    const match = typeof authorization === "string" &&
      /^Bearer ([A-Za-z0-9._-]{20,4096})$/.exec(authorization);
    if (!match) return res.status(401).send();
    let uid;
    try {
      uid = (await auth.verifyIdToken(match[1], true)).uid;
      if (!ID.test(uid)) return res.status(401).send();
    } catch {
      return res.status(401).send();
    }
    const source = req.query.ref;
    const photo = parsePrivatePhoto(source, bucket.name);
    if (!photo) return res.status(400).send();
    try {
      const [account, safety] = await Promise.all([
        db.doc(`users/${uid}`).get(), db.doc(`safetyAccounts/${uid}`).get(),
      ]);
      if (!account.exists || account.data()?.isDeleted || safety.data()?.restricted ||
          !await allowed(uid, source, photo)) return res.status(404).send();
      const file = bucket.file(photo.path);
      const [metadata] = await file.getMetadata();
      const contentType = metadata.contentType?.split(";")[0].trim().toLowerCase();
      const size = Number(metadata.size);
      if (!PHOTO_TYPES.has(contentType) || !Number.isFinite(size) ||
          size <= 0 || size > MAX_PHOTO_BYTES) return res.status(404).send();
      const bytes = await boundedBytes(file.createReadStream());
      if (!await allowed(uid, source, photo)) return res.status(404).send();
      res.set("Content-Type", contentType);
      return res.status(200).send(bytes);
    } catch (error) {
      log("private_photo_failed", {code: error.code || "internal"});
      return res.status(error.code === 404 ? 404 : 503).send();
    }
  };
}

module.exports = {createPrivatePhotoHandler, parsePrivatePhoto, boundedBytes};
