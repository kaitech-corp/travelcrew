const {createHash} = require("node:crypto");

// Keep fields explicit: never walk arbitrary user data or change trip state.
const imageTargets = {
  moderateUserImagesV3: ["users/{userId}", ["profileImage"], []],
  moderatePublicProfileImagesV3: ["publicProfile/{userId}", ["profileImage"], []],
  moderateLegacyProfileImagesV3: ["userPublicProfile/{userId}", ["profileImage"], []],
  moderateTripImagesV3: ["trips/{tripId}", [], ["images"]],
  moderateDiscoveryImagesV3: ["tripDiscovery/{tripId}", ["creatorProfileImage"], ["images"]],
};

function imageUrls(data, fields, arrays) {
  return new Set([
    ...fields.map((field) => data[field]),
    ...arrays.flatMap((field) => Array.isArray(data[field]) ? data[field] : []),
  ].filter((value) => typeof value === "string" && value.trim()));
}

function visionUri(value, bucket) {
  try {
    const url = new URL(value);
    if (url.username || url.password) return null;
    if (url.protocol === "gs:") {
      return bucket && url.hostname === bucket && url.pathname.length > 1 ? value : null;
    }
    if (url.protocol !== "https:") return null;
    // Scan owned Firebase objects with service-account credentials, not download tokens.
    if (url.hostname === "firebasestorage.googleapis.com") {
      const match = url.pathname.match(/^\/v0\/b\/([^/]+)\/o\/(.+)$/);
      if (match && decodeURIComponent(match[1]) === bucket) {
        return `gs://${bucket}/${decodeURIComponent(match[2])}`;
      }
    }
    // Public third-party profile/trip photos can also be scanned by Vision.
    return url.href;
  } catch {
    return null;
  }
}

// REST avoids an extra SDK dependency; Firebase's credential includes cloud-platform scope.
function createVisionScanner(getAccessToken, request = fetch) {
  return async (uri) => {
    try {
      const {access_token: token} = await getAccessToken();
      const response = await request("https://vision.googleapis.com/v1/images:annotate", {
        method: "POST",
        headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
        body: JSON.stringify({requests: [{
          image: {source: {imageUri: uri}},
          features: [{type: "SAFE_SEARCH_DETECTION"}],
        }]}),
        signal: AbortSignal.timeout(30000),
      });
      if (!response.ok) throw new Error("Vision request failed");
      const result = (await response.json()).responses?.[0];
      const adult = result?.safeSearchAnnotation?.adult;
      if (result?.error || !["VERY_UNLIKELY", "UNLIKELY", "POSSIBLE", "LIKELY", "VERY_LIKELY"].includes(adult)) {
        throw new Error("Vision returned no usable verdict");
      }
      return adult === "VERY_LIKELY";
    } catch {
      // Provider errors can contain the original URL/token. Never propagate those.
      throw new Error("Image moderation scan failed; image reference retained for retry.");
    }
  };
}

function createImageModerator({db, fields, arrays, scan, bucket, logger}) {
  return async (event) => {
    const after = event.data?.after;
    if (!after?.exists || after.data().tripStatus === "deleted") return;
    const previous = imageUrls(event.data.before?.data() || {}, fields, arrays);
    const candidates = [...imageUrls(after.data(), fields, arrays)]
        .filter((url) => !previous.has(url));
    let scanFailed = false;
    for (const url of candidates) {
      const uri = visionUri(url, bucket());
      if (!uri) continue;
      // Avoid scanning references already removed/replaced by newer writes or retries.
      const current = await after.ref.get();
      if (!current.exists || current.data().tripStatus === "deleted" ||
          !imageUrls(current.data(), fields, arrays).has(url)) continue;
      const imageHash = createHash("sha256").update(uri).digest("hex");
      let flagged;
      try {
        flagged = await scan(uri);
      } catch {
        logger.error("image_moderation_scan_failed", {
          documentPath: after.ref.path, imageHash, eventId: event.id,
        });
        scanFailed = true;
        continue;
      }
      if (!flagged) continue;
      const removedFields = await db.runTransaction(async (transaction) => {
        const latest = await transaction.get(after.ref);
        if (!latest.exists || latest.data().tripStatus === "deleted") return [];
        const data = latest.data();
        const patch = {};
        // Empty string is compatible with existing profile consumers and local fallbacks.
        for (const field of fields) if (data[field] === url) patch[field] = "";
        for (const field of arrays) {
          if (Array.isArray(data[field]) && data[field].includes(url)) {
            patch[field] = data[field].filter((value) => value !== url);
          }
        }
        const changed = Object.keys(patch);
        if (changed.length) transaction.update(after.ref, patch);
        return changed;
      });
      logger.warn("image_moderation_flagged", {
        documentPath: after.ref.path, imageHash, eventId: event.id,
        category: "adult", likelihood: "VERY_LIKELY", removedFields,
      });
    }
    if (scanFailed) throw new Error("Image moderation scan failed; retry required.");
  };
}

module.exports = {imageTargets, imageUrls, visionUri, createVisionScanner, createImageModerator};
