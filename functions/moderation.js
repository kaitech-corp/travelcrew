const {Filter} = require("bad-words");
const {isDeepStrictEqual} = require("node:util");

const filter = new Filter();
const profileFields = ["displayName", "firstName", "lastName", "hometown"];
const tripFields = [
  "title", "description", "destination", "tripLocation", "country", "hotelName",
  // Older clients used these fields; absent fields are never added.
  "location", "travelType", "comment", "tripName",
];
const discoveryFields = ["title", "destination", "country", "creatorDisplayName"];

function moderateText(value) {
  if (typeof value !== "string" || !value.trim()) return value;
  return filter.isProfane(value) ? filter.clean(value) : value;
}

function buildPatch(data, fields, arrayFields = []) {
  const patch = {};
  for (const field of fields) {
    const value = data[field];
    const cleaned = moderateText(value);
    if (cleaned !== value) patch[field] = cleaned;
  }
  for (const field of arrayFields) {
    if (!Array.isArray(data[field])) continue;
    const cleaned = data[field].map(moderateText);
    if (!isDeepStrictEqual(cleaned, data[field])) patch[field] = cleaned;
  }
  return patch;
}

// Re-read inside a transaction: Firestore events can arrive out of order.
// Updating only changed fields also makes the function's own event a no-op.
function createModerator(db, fields, arrayFields = []) {
  return async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    if (after.data().tripStatus === "deleted") return;
    if (!Object.keys(buildPatch(after.data(), fields, arrayFields)).length) return;
    await db.runTransaction(async (transaction) => {
      const current = await transaction.get(after.ref);
      if (!current.exists || current.data().tripStatus === "deleted") return;
      const patch = buildPatch(current.data(), fields, arrayFields);
      if (Object.keys(patch).length) transaction.update(after.ref, patch);
    });
  };
}

module.exports = {
  moderateText, buildPatch, createModerator,
  profileFields, tripFields, discoveryFields,
};
