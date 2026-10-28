// Read-only inventory of historical activity, transportation and lodging
// records. Emits counts and a resume cursor only; never titles, notes,
// addresses, user IDs or individual trip records.
"use strict";

const {FieldPath} = require("firebase-admin/firestore");
const {validId} = require("./validation");

const MODES = ["flight", "driving", "rideshare", "taxi", "train", "bus",
  "scooter", "bicycle", "walking", "ferry", "boat", "other"];
const TRANSPORT_KEYS = ["id", "tripId", "userId", "displayName", "mode",
  "departure", "arrival", "notes", "revision", "isDeleted"];
const LODGING_KEYS = ["createdBy", "lodgingType", "hotelName", "hotelAddress",
  "checkInDate", "checkOutDate", "expensePerNight", "currencyCode", "revision",
  "isDeleted"];
const LOCAL_DATE = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])(T([01]\d|2[0-3]):[0-5]\d:[0-5]\d)?$/;
const LODGING_TIME = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(\.\d{1,6})?(Z|[+-]([01]\d|2[0-3]):?[0-5]\d)?$/;
const ACTIVITY_TIME = /^\d{4}-\d{2}-\d{2}T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(\.\d{1,6})?(Z|[+-]([01]\d|2[0-3]):?[0-5]\d)?$/;

function bounded(value, name, maximum) {
  if (!Number.isInteger(value) || value < 1 || value > maximum) {
    throw new Error(`${name} must be 1–${maximum}.`);
  }
}

function realCalendarDay(value) {
  const day = value.slice(0, 10);
  const parsed = new Date(`${day}T00:00:00Z`);
  return Number.isFinite(+parsed) && parsed.toISOString().slice(0, 10) === day;
}
const validLocalDate = (value) => value == null ||
  (typeof value === "string" && value.length <= 40 && LOCAL_DATE.test(value) && realCalendarDay(value));
const validLodgingTime = (value) => value == null ||
  (typeof value === "string" && value.length <= 40 && LODGING_TIME.test(value) && realCalendarDay(value));
const validActivityTime = (value) => value == null ||
  (typeof value === "string" && value.length <= 40 && ACTIVITY_TIME.test(value) && realCalendarDay(value));
const nonEmpty = (value) => typeof value === "string" && value.trim().length > 0;

function featuredLodgingPresent(trip) {
  return nonEmpty(trip.hotelName) || nonEmpty(trip.hotelAddress) ||
    trip.checkInDate != null || trip.checkOutDate != null ||
    (trip.expensePerNight != null && trip.expensePerNight !== 0);
}

const emptyTotals = () => ({
  tripsScanned: 0, deletedOrModeratedTrips: 0,
  activities: 0, activitiesAuthorless: 0, activitiesWithoutRevision: 0,
  activityTombstones: 0, activitiesModerated: 0, activitiesInvalidTime: 0,
  activitiesOneSidedTime: 0, legacyTopLevelActivitiesLinked: 0,
  transportation: 0, transportationMissingKeys: 0, transportationExtraKeys: 0,
  transportationInvalidMode: 0, transportationInvalidDate: 0,
  transportationWithoutRevision: 0, transportationAuthorless: 0,
  transportationTombstones: 0,
  transportationLegacyFieldCounts: {}, transportationMissingFieldCounts: {},
  transportationLegacyModeCounts: {},
  lodgingOptions: 0, lodgingOptionsExtraKeys: 0, lodgingOptionsInvalidDates: 0,
  lodgingOptionsInvalidCost: 0, lodgingOptionsWithoutRevision: 0,
  lodgingOptionsAuthorless: 0, lodgingTombstones: 0,
  tripsWithFeaturedLodging: 0, featuredLodgingUnparseableDates: 0,
  featuredLodgingReversedDates: 0, featuredLodgingInvalidCost: 0,
  featuredLodgingCostWithoutCurrency: 0, tripsWithoutLodgingRevision: 0,
  sourceCappedTrips: 0,
});

function auditActivity(data, totals) {
  totals.activities++;
  if (!nonEmpty(data.createdBy)) totals.activitiesAuthorless++;
  if (!Number.isInteger(data.contentRevision)) totals.activitiesWithoutRevision++;
  if (data.isDeleted === true) totals.activityTombstones++;
  if (data.moderationRemoved === true) totals.activitiesModerated++;
  if (!validActivityTime(data.startDateTime) || !validActivityTime(data.endDateTime)) {
    totals.activitiesInvalidTime++;
  }
  if ((data.startDateTime == null) !== (data.endDateTime == null)) totals.activitiesOneSidedTime++;
}

function auditTransportation(data, totals) {
  totals.transportation++;
  const keys = Object.keys(data);
  // Field names describe the legacy schema, not traveler content.
  for (const key of keys) {
    if (!TRANSPORT_KEYS.includes(key) && /^[A-Za-z0-9_]{1,40}$/.test(key)) {
      totals.transportationLegacyFieldCounts[key] = (totals.transportationLegacyFieldCounts[key] || 0) + 1;
    }
  }
  for (const key of TRANSPORT_KEYS) {
    if (!keys.includes(key)) {
      totals.transportationMissingFieldCounts[key] = (totals.transportationMissingFieldCounts[key] || 0) + 1;
    }
  }
  if (typeof data.mode === "string" && !MODES.includes(data.mode) && /^[A-Za-z0-9_ -]{1,40}$/.test(data.mode)) {
    totals.transportationLegacyModeCounts[data.mode] = (totals.transportationLegacyModeCounts[data.mode] || 0) + 1;
  }
  if (TRANSPORT_KEYS.some((key) => !keys.includes(key))) totals.transportationMissingKeys++;
  if (keys.some((key) => !TRANSPORT_KEYS.includes(key))) totals.transportationExtraKeys++;
  if (!MODES.includes(data.mode)) totals.transportationInvalidMode++;
  if (!validLocalDate(data.departure) || !validLocalDate(data.arrival)) totals.transportationInvalidDate++;
  if (!Number.isInteger(data.revision) || data.revision < 1) totals.transportationWithoutRevision++;
  if (!nonEmpty(data.userId)) totals.transportationAuthorless++;
  if (data.isDeleted === true) totals.transportationTombstones++;
}

function auditLodgingOption(data, totals) {
  totals.lodgingOptions++;
  const keys = Object.keys(data);
  if (keys.some((key) => !LODGING_KEYS.includes(key))) totals.lodgingOptionsExtraKeys++;
  const datesValid = validLodgingTime(data.checkInDate) && validLodgingTime(data.checkOutDate) &&
    ((data.checkInDate == null && data.checkOutDate == null) ||
     (data.checkInDate != null && data.checkOutDate != null &&
       String(data.checkOutDate).slice(0, 16) > String(data.checkInDate).slice(0, 16)));
  if (!datesValid) totals.lodgingOptionsInvalidDates++;
  const cost = data.expensePerNight;
  const costValid = cost == null || (Number.isFinite(cost) && cost >= 0 && cost < 1000000000);
  const currencyValid = data.currencyCode == null || /^[A-Z]{3}$/.test(data.currencyCode);
  if (!costValid || !currencyValid || (cost != null && cost > 0 && data.currencyCode == null)) {
    totals.lodgingOptionsInvalidCost++;
  }
  if (!Number.isInteger(data.revision) || data.revision < 1) totals.lodgingOptionsWithoutRevision++;
  if (!nonEmpty(data.createdBy)) totals.lodgingOptionsAuthorless++;
  if (data.isDeleted === true) totals.lodgingTombstones++;
}

function auditFeaturedLodging(trip, totals) {
  if (!Number.isInteger(trip.lodgingRevision)) totals.tripsWithoutLodgingRevision++;
  if (!featuredLodgingPresent(trip)) return;
  totals.tripsWithFeaturedLodging++;
  const parse = (value) => value == null ? null : Date.parse(String(value));
  const checkIn = parse(trip.checkInDate); const checkOut = parse(trip.checkOutDate);
  if ((checkIn !== null && Number.isNaN(checkIn)) || (checkOut !== null && Number.isNaN(checkOut))) {
    totals.featuredLodgingUnparseableDates++;
  } else if (checkIn !== null && checkOut !== null && checkOut < checkIn) {
    totals.featuredLodgingReversedDates++;
  }
  const cost = trip.expensePerNight;
  if (cost != null && (!Number.isFinite(cost) || cost < 0)) totals.featuredLodgingInvalidCost++;
  if (Number.isFinite(cost) && cost > 0 && !/^[A-Z]{3}$/.test(String(trip.lodgingCurrencyCode || ""))) {
    totals.featuredLodgingCostWithoutCurrency++;
  }
}

function mergeTotals(target, source) {
  for (const [key, value] of Object.entries(source)) {
    if (value && typeof value === "object") {
      target[key] = target[key] || {};
      for (const [name, count] of Object.entries(value)) target[key][name] = (target[key][name] || 0) + count;
    } else {
      target[key] = (target[key] || 0) + value;
    }
  }
  return target;
}

async function auditTripRecords(db, tripDoc, maxDocsPerSource) {
  bounded(maxDocsPerSource, "Maximum documents per source", 5000);
  const trip = tripDoc.data() || {};
  const tripRef = db.collection("trips").doc(tripDoc.id);
  const [activities, transportation, lodgings, legacyActivities] = await Promise.all([
    tripRef.collection("activities").limit(maxDocsPerSource + 1).get(),
    tripRef.collection("transportation").limit(maxDocsPerSource + 1).get(),
    tripRef.collection("lodgings").limit(maxDocsPerSource + 1).get(),
    db.collection("activity").where("tripId", "==", tripDoc.id).limit(maxDocsPerSource + 1).get(),
  ]);
  const sources = [activities, transportation, lodgings, legacyActivities];
  const totals = emptyTotals();
  totals.tripsScanned = 1;
  totals.sourceCappedTrips = sources.some((snapshot) => snapshot.size > maxDocsPerSource) ? 1 : 0;
  if (trip.tripStatus === "deleted" || trip.moderationRemoved === true) totals.deletedOrModeratedTrips = 1;
  for (const doc of activities.docs.slice(0, maxDocsPerSource)) auditActivity(doc.data() || {}, totals);
  for (const doc of transportation.docs.slice(0, maxDocsPerSource)) auditTransportation(doc.data() || {}, totals);
  for (const doc of lodgings.docs.slice(0, maxDocsPerSource)) auditLodgingOption(doc.data() || {}, totals);
  totals.legacyTopLevelActivitiesLinked = Math.min(legacyActivities.size, maxDocsPerSource);
  auditFeaturedLodging(trip, totals);
  return {totals, capped: totals.sourceCappedTrips === 1};
}

async function auditTripRecordsPage(db, {after = null, limit = 10, maxDocsPerSource = 1000} = {}) {
  bounded(limit, "Trip page size", 50);
  let query = db.collection("trips").orderBy(FieldPath.documentId()).limit(limit);
  if (after != null) {
    if (!validId(after)) throw new Error("Invalid resume cursor.");
    query = query.startAfter(after);
  }
  const page = await query.get();
  const totals = emptyTotals();
  const cappedTripIds = [];
  for (const tripDoc of page.docs) {
    const result = await auditTripRecords(db, tripDoc, maxDocsPerSource);
    mergeTotals(totals, result.totals);
    if (result.capped) cappedTripIds.push(tripDoc.id);
  }
  return {totals, cappedTripIds, nextAfter: page.size < limit ? null : page.docs[page.size - 1].id};
}

const emptyTopLevelTotals = () => ({documents: 0, missingTripId: 0, invalidTripId: 0,
  orphanTripId: 0, linkedToTrip: 0, authorless: 0, tombstones: 0});

// Legacy top-level collections ("activity", "flights") are scanned by document
// ID. Trip existence is checked per page so orphans are counted without a
// second pass.
async function auditTopLevelRecordsPage(db, {collection = "activity", after = null, limit = 100} = {}) {
  if (!["activity", "flights"].includes(collection)) throw new Error("Collection must be activity or flights.");
  bounded(limit, "Page size", 500);
  let query = db.collection(collection).orderBy(FieldPath.documentId()).limit(limit);
  if (after != null) {
    if (!validId(after)) throw new Error("Invalid resume cursor.");
    query = query.startAfter(after);
  }
  const page = await query.get();
  const totals = emptyTopLevelTotals();
  const tripIds = new Set();
  for (const doc of page.docs) {
    const data = doc.data() || {};
    totals.documents++;
    if (data.tripId == null || data.tripId === "") totals.missingTripId++;
    else if (!validId(data.tripId)) totals.invalidTripId++;
    else tripIds.add(data.tripId);
    if (!nonEmpty(data.createdBy) && !nonEmpty(data.userId)) totals.authorless++;
    if (data.isDeleted === true) totals.tombstones++;
  }
  const ids = [...tripIds];
  const existing = new Set();
  for (let index = 0; index < ids.length; index += 100) {
    const refs = ids.slice(index, index + 100).map((id) => db.collection("trips").doc(id));
    for (const snapshot of await db.getAll(...refs)) if (snapshot.exists) existing.add(snapshot.id);
  }
  for (const doc of page.docs) {
    const tripId = (doc.data() || {}).tripId;
    if (tripId != null && tripId !== "" && validId(tripId)) {
      if (existing.has(tripId)) totals.linkedToTrip++; else totals.orphanTripId++;
    }
  }
  return {totals, nextAfter: page.size < limit ? null : page.docs[page.size - 1].id};
}

module.exports = {auditTripRecordsPage, auditTopLevelRecordsPage, auditTripRecords,
  mergeTotals, emptyTotals, emptyTopLevelTotals};
