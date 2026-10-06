// Suggested covers are optional. Only Commons public-domain/CC0 photographs
// are copied in this first release; arbitrary URLs never reach a fetch client.
const https = require("node:https");
const dns = require("node:dns/promises");
const {createHash, randomUUID} = require("node:crypto");
const ipaddr = require("ipaddr.js");
const sharp = require("sharp");
const {HttpsError} = require("firebase-functions/v2/https");

const MAX_BYTES = 8 * 1024 * 1024;
const unavailable = () => ({status: "unavailable", message: "Trip can be saved without a photo. Choose a public-domain or CC0 Wikimedia Commons photo, or upload your own."});
const digest = (s) => createHash("sha256").update(s).digest("hex");

function checkedUrl(value, host) {
  if (typeof value !== "string" || value.length > 2048) throw new Error("Invalid photo URL");
  const url = new URL(value);
  if (url.protocol !== "https:" || url.hostname !== host || url.username || url.password || url.port || url.hash) throw new Error("Unsupported photo URL");
  return url;
}

function commonsImageUrl(value) {
  const url = checkedUrl(value, "upload.wikimedia.org");
  // Commons imageinfo adds analytics parameters to originals and thumbnails.
  // Strip only these known parameters; arbitrary query behavior stays denied.
  if ([...url.searchParams.keys()].some((key) => !["utm_source", "utm_campaign", "utm_content"].includes(key))) throw new Error("Unexpected photo query");
  url.search = "";
  return url;
}

function commonsFile(value) {
  const url = commonsImageUrl(value);
  const match = /^\/wikipedia\/commons\/(?:thumb\/)?[a-f0-9]\/[a-f0-9]{2}\/([^/]+)(?:\/[^/]+)?$/.exec(url.pathname);
  if (!match) throw new Error("Not a Commons image");
  const name = decodeURIComponent(match[1]).replace(/ /g, "_");
  if (!/\.(jpe?g|png|webp)$/i.test(name) || /[/\\|]/.test(name) || [...name].some((c) => c.charCodeAt(0) < 32)) throw new Error("Unsupported photo type");
  return name;
}

function isPublicAddress(address) {
  try { return ipaddr.process(address).range() === "unicast"; } catch { return false; }
}

// Resolve once, reject every non-public answer, and pin the actual TLS socket
// to that result. TLS still verifies the original hostname. No redirects,
// cookies, proxy environment, auth headers, or transparent decompression.
async function download(url, {maxBytes = MAX_BYTES, lookup = dns.lookup, request = https.get} = {}) {
  if (!["upload.wikimedia.org", "commons.wikimedia.org"].includes(url.hostname)) throw new Error("Unsupported host");
  checkedUrl(url.href, url.hostname);
  let timer;
  const addresses = await Promise.race([
    lookup(url.hostname, {all: true}),
    new Promise((_, reject) => { timer = setTimeout(() => reject(new Error("DNS timeout")), 3000); }),
  ]).finally(() => clearTimeout(timer));
  if (!addresses.length || addresses.some((a) => !isPublicAddress(a.address))) throw new Error("Unsafe photo address");
  return new Promise((resolve, reject) => {
    const selected = addresses[0];
    let deadline;
    const req = request(url, {
      agent: false,
      lookup: (_host, options, callback) => options.all ? callback(null, [selected]) : callback(null, selected.address, selected.family),
      headers: {"User-Agent": "TravelCrew/1.0 (https://travelcrew.app; Support@kaitechcorp.com)", "Accept-Encoding": "identity"},
    }, (res) => {
      if (res.statusCode !== 200 || Number(res.headers["content-length"]) > maxBytes ||
          (res.headers["content-encoding"] && res.headers["content-encoding"] !== "identity")) {
        res.destroy(); req.destroy(new Error("Photo response rejected")); return;
      }
      const chunks = []; let length = 0;
      res.on("data", (chunk) => {
        length += chunk.length;
        if (length > maxBytes) { res.destroy(); req.destroy(new Error("Photo too large")); } else chunks.push(chunk);
      });
      res.on("error", reject);
      res.on("aborted", () => reject(new Error("Incomplete photo")));
      res.on("end", () => { clearTimeout(deadline); resolve(Buffer.concat(chunks)); });
    });
    req.on("error", (error) => { clearTimeout(deadline); reject(error); });
    deadline = setTimeout(() => req.destroy(new Error("Photo download timeout")), 8000);
  });
}

const plain = (v) => typeof v === "string" ? [...v.replace(/<[^>]*>/g, "")].map((c) => c.charCodeAt(0) < 32 ? " " : c).join("").slice(0, 600) : "";
async function commonsPhoto(value, fetchBytes = download) {
  const name = commonsFile(value);
  const api = new URL("https://commons.wikimedia.org/w/api.php");
  api.search = new URLSearchParams({action: "query", format: "json", prop: "imageinfo", titles: `File:${name}`,
    iiprop: "url|mime|extmetadata", iiurlwidth: "1600", iiextmetadatalanguage: "en"}).toString();
  const result = JSON.parse((await fetchBytes(api, {maxBytes: 256 * 1024})).toString("utf8"));
  const info = Object.values(result.query?.pages || {})[0]?.imageinfo?.[0];
  const metadata = info?.extmetadata || {};
  const license = metadata.LicenseShortName?.value;
  // Attribution/share-alike licenses need display support on every consumer;
  // do not silently accept them until that is implemented across app + web.
  if (!["Public domain", "CC0"].includes(license) || !["image/jpeg", "image/png", "image/webp"].includes(info.mime)) throw new Error("Unsupported license or image");
  if (commonsFile(info.url) !== name) throw new Error("Photo metadata mismatch");
  const source = checkedUrl(info.descriptionurl, "commons.wikimedia.org");
  const image = commonsImageUrl(info.thumburl || info.url);
  if (commonsFile(image.href) !== name) throw new Error("Thumbnail mismatch");
  return {bytes: await fetchBytes(image), credit: {source_url: source.href, author: plain(metadata.Artist?.value), license,
    title: name, modified: "Resized and converted to JPEG"}};
}

async function normalizePhoto(bytes) {
  if (!Buffer.isBuffer(bytes) || bytes.length > MAX_BYTES || bytes.length < 12) throw new Error("Invalid photo bytes");
  const raster = bytes.subarray(0, 3).equals(Buffer.from([255, 216, 255])) ||
    bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])) ||
    (bytes.toString("ascii", 0, 4) === "RIFF" && bytes.toString("ascii", 8, 12) === "WEBP");
  if (!raster) throw new Error("Only raster photos are accepted");
  const image = sharp(bytes, {limitInputPixels: 16000000, failOn: "warning"});
  const meta = await image.metadata();
  if (!meta.width || !meta.height || (meta.pages || 1) !== 1) throw new Error("Invalid image dimensions");
  return image.rotate().resize({width: 1600, height: 1200, fit: "inside", withoutEnlargement: true})
      .flatten({background: "#ffffff"}).jpeg({quality: 85}).toBuffer();
}

function createPhotoService({db, bucket, scan, load = commonsPhoto, normalize = normalizePhoto, now = () => Date.now()}) {
  return async (uid, url) => {
    if (typeof uid !== "string" || !uid || uid.includes("/")) throw new HttpsError("unauthenticated", "Sign in required.");
    try { commonsFile(url); } catch { return unavailable(); }
    const id = digest(`${uid}:${url}`); const ref = db.doc(`tripPhotoAssets/${id}`);
    const time = now(); const quotaRef = db.doc(`tripPhotoQuotas/${digest(`${uid}:${Math.floor(time / 86400000)}`)}`);
    const claim = randomUUID();
    const existing = await db.runTransaction(async (tx) => {
      const [user, safety, asset, quota] = await Promise.all([tx.get(db.doc(`users/${uid}`)), tx.get(db.doc(`safetyAccounts/${uid}`)), tx.get(ref), tx.get(quotaRef)]);
      if (!user.exists || user.data().isDeleted || safety.data()?.restricted) throw new HttpsError("permission-denied", "Active account required.");
      if (asset.data()?.status === "ready") return asset.data().result;
      if ((asset.data()?.retryAfter || 0) > time || (quota.data()?.count || 0) >= 20) return unavailable();
      tx.set(ref, {uid, claim, status: "pending", retryAfter: time + 120000});
      tx.set(quotaRef, {count: (quota.data()?.count || 0) + 1, expiresAt: new Date(time + 2 * 86400000)});
      return null;
    });
    if (existing) return existing;
    let file;
    try {
      const {bytes, credit} = await load(url);
      const normalized = await normalize(bytes);
      if (await scan(normalized)) throw new Error("Photo rejected by moderation");
      const token = randomUUID();
      const path = `suggested_trip_photos/${digest(uid)}/${id}-${claim}.jpg`;
      const storage = bucket(); file = storage.file(path);
      await file.save(normalized, {resumable: false, validation: "crc32c", metadata: {contentType: "image/jpeg",
        cacheControl: "public,max-age=31536000,immutable", metadata: {firebaseStorageDownloadTokens: token}}});
      const result = {status: "ready", url: `https://firebasestorage.googleapis.com/v0/b/${storage.name}/o/${encodeURIComponent(path)}?alt=media&token=${token}`, credit};
      const committed = await db.runTransaction(async (tx) => {
        const [user, safety, asset] = await Promise.all([tx.get(db.doc(`users/${uid}`)), tx.get(db.doc(`safetyAccounts/${uid}`)), tx.get(ref)]);
        if (!user.exists || user.data().isDeleted || safety.data()?.restricted || asset.data()?.claim !== claim) return false;
        tx.update(ref, {status: "ready", result, storagePath: path, createdAt: new Date(now())}); return true;
      });
      if (!committed) throw new Error("Photo preparation superseded");
      return result;
    } catch {
      if (file) await file.delete({ignoreNotFound: true}).catch(() => {});
      await db.runTransaction(async (tx) => {
        const asset = await tx.get(ref);
        if (asset.data()?.claim === claim) tx.update(ref, {status: "unavailable", retryAfter: now() + 300000});
      });
      return unavailable();
    }
  };
}

function createPhotoCallable(prepare) {
  return async (request) => {
    if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Sign in required.");
    if (!request.data || Object.keys(request.data).some((key) => key !== "image_url") || typeof request.data.image_url !== "string") {
      throw new HttpsError("invalid-argument", "Supply only an image_url.");
    }
    return prepare(request.auth.uid, request.data.image_url);
  };
}

module.exports = {commonsFile, isPublicAddress, download, commonsPhoto, normalizePhoto, createPhotoService, createPhotoCallable, unavailable};
