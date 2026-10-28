"use strict";

const {FieldPath} = require("firebase-admin/firestore");
const {validId} = require("../validation");
const {currencyPrecision, validateAllocation} = require("./money");

function bounded(value, name, maximum) {
  if (!Number.isInteger(value) || value < 1 || value > maximum) {
    throw new Error(`${name} must be 1–${maximum}.`);
  }
}

function legacyShape(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return "malformed";
  if (!Number.isFinite(value.amount) || value.amount <= 0 ||
      typeof value.name !== "string" || !value.name.trim()) return "malformed";
  // Neither field establishes an exact, immutable split or a trustworthy
  // payment event. Even a complete-looking legacy record needs review.
  if (Array.isArray(value.paidByUsers) && value.paidByUsers.length > 0) {
    return "ambiguousPayer";
  }
  return "missingPayer";
}

function countLegacy(values, totals) {
  for (const value of values) {
    totals.legacyRecords++;
    const shape = legacyShape(value);
    totals[shape]++;
    if (value && typeof value === "object" &&
        ((value.owners && Object.keys(value.owners).length) ||
         (value.owedTo && Object.keys(value.owedTo).length))) {
      totals.allocationHints++;
    }
  }
}

const emptyTotals = () => ({tripsScanned: 0, legacyTrips: 0, v2Trips: 0,
  mixedTrips: 0, embeddedRecords: 0, nestedRecords: 0, topLevelRecords: 0,
  legacyRecords: 0, malformed: 0, ambiguousPayer: 0, missingPayer: 0,
  allocationHints: 0, legacyIdCollisions: 0, legacyMissingIds: 0,
  v2Records: 0, malformedV2: 0, transferRecords: 0,
  currencyWithoutV2: 0, v2WithoutCurrency: 0, sourceCappedTrips: 0});

async function auditFinanceTrip(db, tripDoc, maxDocsPerSource) {
  bounded(maxDocsPerSource, "Maximum documents per source", 5000);
  const trip = tripDoc.data();
  const tripRef = db.collection("trips").doc(tripDoc.id);
  const [nested, top, v2, transfers] = await Promise.all([
    tripRef.collection("expenses").limit(maxDocsPerSource + 1).get(),
    db.collection("expense").where("tripId", "==", tripDoc.id)
        .limit(maxDocsPerSource + 1).get(),
    tripRef.collection("financeExpenses").limit(maxDocsPerSource + 1).get(),
    tripRef.collection("financeTransfers").limit(maxDocsPerSource + 1).get(),
  ]);
  const sources = [nested, top, v2, transfers];
  const capped = sources.some((snapshot) => snapshot.size > maxDocsPerSource);
  const totals = emptyTotals();
  totals.tripsScanned = 1;
  totals.sourceCappedTrips = capped ? 1 : 0;
  const embedded = Array.isArray(trip.expenses) ? trip.expenses :
    trip.expenses == null ? [] : [trip.expenses];
  totals.embeddedRecords = embedded.length;
  totals.nestedRecords = Math.min(nested.size, maxDocsPerSource);
  totals.topLevelRecords = Math.min(top.size, maxDocsPerSource);
  countLegacy(embedded, totals);
  countLegacy([...nested.docs.slice(0, maxDocsPerSource),
    ...top.docs.slice(0, maxDocsPerSource)].map((doc) => doc.data()), totals);
  const legacyIds = [
    ...embedded.map((value) => value?.id),
    ...nested.docs.slice(0, maxDocsPerSource).map((doc) => doc.id),
    ...top.docs.slice(0, maxDocsPerSource).map((doc) => doc.id),
  ];
  const seen = new Set();
  for (const id of legacyIds) {
    if (typeof id !== "string" || !id) totals.legacyMissingIds++;
    else if (seen.has(id)) totals.legacyIdCollisions++;
    else seen.add(id);
  }
  totals.v2Records = Math.min(v2.size, maxDocsPerSource);
  totals.transferRecords = Math.min(transfers.size, maxDocsPerSource);
  totals.legacyTrips = totals.legacyRecords > 0 ? 1 : 0;
  totals.v2Trips = v2.size > 0 ? 1 : 0;
  totals.mixedTrips = totals.legacyTrips && totals.v2Trips ? 1 : 0;
  totals.currencyWithoutV2 = trip.financeCurrency && !v2.size ? 1 : 0;
  totals.v2WithoutCurrency = v2.size && !trip.financeCurrency ? 1 : 0;
  for (const doc of v2.docs.slice(0, maxDocsPerSource)) {
    const value = doc.data();
    let invalidAllocation = false;
    let invalidPrecision = false;
    try { validateAllocation(value); } catch { invalidAllocation = true; }
    try { invalidPrecision = currencyPrecision(value.currencyCode) !== value.currencyPrecision; }
    catch { invalidPrecision = true; }
    if (invalidAllocation || invalidPrecision ||
        value.financeSchemaVersion !== 2 || value.tripId !== tripDoc.id ||
        value.id !== doc.id || value.currencyCode !== trip.financeCurrency ||
        !Number.isSafeInteger(value.revision) || value.revision < 1 ||
        ![true, false].includes(value.isDeleted)) totals.malformedV2++;
  }
  return totals;
}

async function auditFinancePage(db, {after = null, limit = 10,
  maxDocsPerSource = 1000} = {}) {
  bounded(limit, "Trip page size", 50);
  bounded(maxDocsPerSource, "Maximum documents per source", 5000);
  let query = db.collection("trips").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const trips = await query.get();
  const totals = emptyTotals();
  const cappedTripIds = [];
  for (const trip of trips.docs) {
    const result = await auditFinanceTrip(db, trip, maxDocsPerSource);
    if (result.sourceCappedTrips) cappedTripIds.push(trip.id);
    for (const [key, count] of Object.entries(result)) totals[key] += count;
  }
  return {totals, cappedTripIds,
    nextAfter: trips.size === limit ? trips.docs.at(-1).id : null};
}

async function auditTopLevelExpensePage(db, {after = null, limit = 10} = {}) {
  bounded(limit, "Expense page size", 50);
  let query = db.collection("expense").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const page = await query.get();
  const totals = {recordsScanned: page.size, missingTripId: 0,
    orphanTripId: 0, linkedToTrip: 0, malformed: 0,
    ambiguousPayer: 0, missingPayer: 0, allocationHints: 0};
  const links = page.docs.map((doc) => ({data: doc.data(), tripId: doc.data().tripId}));
  const tripIds = [...new Set(links.map(({tripId}) => tripId).filter(validId))];
  const tripDocs = tripIds.length ? await db.getAll(...tripIds.map((id) =>
    db.collection("trips").doc(id))) : [];
  const exists = new Map(tripDocs.map((doc, index) => [tripIds[index], doc.exists]));
  for (const {data, tripId} of links) {
    if (!validId(tripId)) totals.missingTripId++;
    else if (!exists.get(tripId)) totals.orphanTripId++;
    else totals.linkedToTrip++;
    totals[legacyShape(data)]++;
    if ((data.owners && typeof data.owners === "object" &&
         Object.keys(data.owners).length) ||
        (data.owedTo && typeof data.owedTo === "object" &&
         Object.keys(data.owedTo).length)) totals.allocationHints++;
  }
  return {totals, nextAfter: page.size === limit ? page.docs.at(-1).id : null};
}

module.exports = {legacyShape, auditFinanceTrip, auditFinancePage,
  auditTopLevelExpensePage};
