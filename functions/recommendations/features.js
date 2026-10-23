const {Timestamp} = require("firebase-admin/firestore");

const DAY = 86400000;
const FEATURE_VERSION = 1;
const unavailable = new Set(["deleted", "cancelled", "completed"]);

function normalize(value) {
  return typeof value === "string" ? value.normalize("NFKC").trim().toLowerCase().replace(/\s+/gu, " ").slice(0, 160) : "";
}

// Travel dates are calendar days. Unzoned Flutter ISO strings preserve their
// written day; explicit offsets and Firestore timestamps use the UTC day.
// Invalid calendar dates must never roll over or become today's date.
function travelDay(value) {
  if (value && typeof value.toDate === "function") value = value.toDate();
  if (value instanceof Date) {
    return Number.isFinite(value.getTime()) ? Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()) : null;
  }
  if (typeof value !== "string") return null;
  const match = /^(\d{4})-(\d{2})-(\d{2})(?:T\d{2}:\d{2}(?::\d{2}(?:\.\d{1,9})?)?(?:Z|[+-]\d{2}:\d{2})?)?$/.exec(value);
  if (!match) return null;
  const [year, month, day] = match.slice(1).map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  if (year < 1900 || date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) return null;
  if (value.includes("T")) {
    const time = /T(\d{2}):(\d{2})(?::(\d{2}))?/.exec(value);
    if (Number(time[1]) > 23 || Number(time[2]) > 59 || Number(time[3] || 0) > 59) return null;
    const parsed = new Date(/(?:Z|[+-]\d{2}:\d{2})$/.test(value) ? value : `${value}Z`);
    if (!Number.isFinite(parsed.getTime())) return null;
    return travelDay(parsed);
  }
  return date.getTime();
}

function millis(value) {
  if (value && typeof value.toMillis === "function") return value.toMillis();
  if (value instanceof Date) return value.getTime();
  return null;
}

function tripFeatures(id, trip, publishedAt = null) {
  if (!trip || trip.isPrivate !== false || trip.moderationRemoved === true || unavailable.has(trip.tripStatus)) return null;
  const starts = travelDay(trip.tripStartDate ?? trip.startDate);
  const ends = travelDay(trip.tripEndDate ?? (trip.endDate || null)) ?? starts;
  // An explicitly malformed end date is not a missing end date.
  const rawEnd = trip.tripEndDate ?? (trip.endDate || null);
  if (starts === null || ends === null || ends < starts || (rawEnd != null && travelDay(rawEnd) === null)) return null;
  const countryKey = normalize(trip.country);
  const destinationKey = normalize(trip.destination);
  if (!destinationKey || !countryKey || typeof trip.createdBy !== "string" || !trip.createdBy) return null;
  return {id, createdBy: trip.createdBy, destinationKey, countryKey, continentKey: normalize(trip.continent),
    destinationKeys: [destinationKey, `${destinationKey}|${countryKey}`, countryKey].filter((v, i, a) => a.indexOf(v) === i),
    startDay: Timestamp.fromMillis(starts), endDay: Timestamp.fromMillis(ends),
    publishedAt: millis(publishedAt) == null ? null : Timestamp.fromMillis(millis(publishedAt)),
    popularity: Math.max(0, Math.min(1000, Number.isFinite(trip.favouriteCount) ? trip.favouriteCount : 0)),
    featureVersion: FEATURE_VERSION};
}

function fitsDates(feature, filters, now) {
  const start = millis(feature.startDay); const end = millis(feature.endDay);
  if (start == null || end == null || start < travelDay(new Date(now))) return false;
  if (filters.from && start < travelDay(filters.from)) return false;
  if (filters.to && end > travelDay(filters.to)) return false;
  const days = (end - start) / DAY + 1;
  return !(filters.minDays && days < filters.minDays) && !(filters.maxDays && days > filters.maxDays);
}

function preview(id, trip, creator) {
  const feature = tripFeatures(id, trip);
  if (!feature) return null;
  const start = feature.startDay.toDate().toISOString(); const end = feature.endDay.toDate().toISOString();
  const text = (v, limit = 200) => typeof v === "string" ? v.slice(0, limit) : "";
  const url = (v) => typeof v === "string" && /^https:\/\//.test(v) && v.length <= 4096 ? v : "";
  return {id, destination: text(trip.destination), country: text(trip.country), continent: text(trip.continent),
    title: text(trip.title), createdBy: trip.createdBy, startDate: start, endDate: end,
    tripStartDate: start, tripEndDate: end, tripStatus: text(trip.tripStatus), isDiscoverable: true,
    images: (Array.isArray(trip.images) ? trip.images : []).map(url).filter(Boolean).slice(0, 5),
    creatorDisplayName: text(creator.displayName), creatorProfileImage: url(creator.profileImage),
    memberCount: new Set([trip.createdBy, ...(Array.isArray(trip.joinedUsers) ? trip.joinedUsers.filter((x) => typeof x === "string") : [])]).size,
    favouriteCount: feature.popularity};
}

// Read the latest trip inside the transaction so an older trigger cannot undo
// a more recent privacy change. Backfills leave first-publication time unknown.
async function maintainTripFeature(db, id, {newPublication = false, now = Date.now()} = {}) {
  return db.runTransaction(async (tx) => {
    const source = db.doc(`trips/${id}`); const target = db.doc(`recommendationTripFeatures/${id}`);
    const [trip, current] = await Promise.all([tx.get(source), tx.get(target)]);
    const old = current.data();
    const publication = old?.publishedAt ?? (newPublication ? Timestamp.fromMillis(now) : null);
    const data = tripFeatures(id, trip.data(), publication);
    if (!data) { if (current.exists) tx.delete(target); return "excluded"; }
    const {updatedAt: ignored, ...oldFeatures} = old || {}; void ignored;
    if (JSON.stringify(oldFeatures) === JSON.stringify(data)) return "unchanged";
    tx.set(target, {...data, updatedAt: Timestamp.fromMillis(now)});
    return "updated";
  });
}

module.exports = {DAY, FEATURE_VERSION, normalize, travelDay, millis, tripFeatures, fitsDates, preview, maintainTripFeature};
