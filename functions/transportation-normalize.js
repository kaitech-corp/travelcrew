// Converts legacy nested transportation records to the canonical shape that
// the current client transaction and Firestore rules accept. Dry run reports
// field-level changes only; apply replaces each document in its own
// transaction after re-reading it.
"use strict";

const {FieldPath} = require("firebase-admin/firestore");
const {validId} = require("./validation");

const MODES = ["flight", "driving", "rideshare", "taxi", "train", "bus",
  "scooter", "bicycle", "walking", "ferry", "boat", "other"];
const CANONICAL_KEYS = ["id", "tripId", "userId", "displayName", "mode",
  "departure", "arrival", "notes", "revision", "isDeleted"];
const LEGACY_MODES = {airplane: "flight", plane: "flight", air: "flight", car: "driving",
  drive: "driving", uber: "rideshare", lyft: "rideshare", cab: "taxi", rail: "train",
  subway: "train", metro: "train", coach: "bus", bike: "bicycle", walk: "walking",
  ship: "boat", cruise: "boat"};
// Legacy detail fields are folded into notes so no traveler-entered text is lost.
const DETAIL_FIELDS = [["title", "Title"], ["transportTitle", "Title"], ["origin", "From"],
  ["departureAirport", "From"], ["destination", "To"], ["arrivalAirport", "To"],
  ["provider", "Provider"], ["airlineName", "Airline"], ["serviceNumber", "Service"],
  ["flightNumber", "Flight"], ["driver", "Driver"], ["travelerNames", "Travelers"]];
const LOCAL_DATE = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])(T([01]\d|2[0-3]):[0-5]\d:[0-5]\d)?$/;

function realCalendarDay(value) {
  const day = value.slice(0, 10);
  const parsed = new Date(`${day}T00:00:00Z`);
  return Number.isFinite(+parsed) && parsed.toISOString().slice(0, 10) === day;
}

// Keeps the wall clock exactly as written; a trailing offset or Z is dropped
// rather than converted because legacy entries never recorded the location's
// timezone reliably. Firestore Timestamps are rendered in UTC.
function localClock(value) {
  if (value == null || value === "") return null;
  if (typeof value === "object" && typeof value.toDate === "function") {
    return value.toDate().toISOString().slice(0, 19);
  }
  if (typeof value !== "string") return null;
  const text = value.trim();
  if (LOCAL_DATE.test(text) && realCalendarDay(text)) return text;
  const match = /^(\d{4}-\d{2}-\d{2})(?:[T ](\d{2}:\d{2})(?::(\d{2}))?(?:\.\d+)?)?(?:Z|[+-]\d{2}:?\d{2})?$/.exec(text);
  if (!match || !realCalendarDay(match[1])) return null;
  if (!match[2]) return match[1];
  const candidate = `${match[1]}T${match[2]}:${match[3] || "00"}`;
  return LOCAL_DATE.test(candidate) ? candidate : null;
}

function canonicalMode(value) {
  if (typeof value !== "string") return "other";
  const lower = value.trim().toLowerCase();
  if (MODES.includes(lower)) return lower;
  return LEGACY_MODES[lower] || "other";
}

function detailLines(data) {
  const lines = [];
  const seen = new Set();
  for (const [field, label] of DETAIL_FIELDS) {
    const value = data[field];
    const text = Array.isArray(value) ? value.filter((item) => typeof item === "string").join(", ") :
      typeof value === "string" ? value : "";
    const trimmed = text.trim();
    if (!trimmed || seen.has(`${label}:${trimmed}`)) continue;
    seen.add(`${label}:${trimmed}`);
    lines.push(`${label}: ${trimmed}`);
  }
  return lines;
}

function canonicalRecord({docId, tripId, data, trip, displayName}) {
  const legacyKeys = Object.keys(data).filter((key) => !CANONICAL_KEYS.includes(key));
  const baseNotes = typeof data.notes === "string" ? data.notes.trim() : "";
  const extra = detailLines(data).filter((line) => !baseNotes.includes(line));
  let notes = [baseNotes, ...extra].filter(Boolean).join("\n");
  if (notes.length > 4000) notes = notes.slice(0, 4000);
  const userId = typeof data.userId === "string" && data.userId && !data.userId.includes("/") ?
    data.userId : (typeof trip.createdBy === "string" ? trip.createdBy : "");
  const record = {
    id: docId, tripId,
    userId,
    displayName: typeof data.displayName === "string" ? data.displayName.slice(0, 200) :
      (typeof displayName === "string" ? displayName.slice(0, 200) : ""),
    mode: canonicalMode(data.mode),
    departure: localClock(data.departure ?? data.departureDate),
    arrival: localClock(data.arrival ?? data.arrivalDate),
    notes,
    revision: Number.isInteger(data.revision) && data.revision >= 1 ? data.revision : 1,
    isDeleted: data.isDeleted === true,
  };
  const changedKeys = CANONICAL_KEYS.filter((key) => JSON.stringify(record[key] ?? null) !== JSON.stringify(data[key] ?? null));
  return {record, legacyKeys, changedKeys, modeMapped: record.mode !== data.mode,
    valid: record.userId.length > 0 && validId(record.userId)};
}

async function normalizeTripTransportation(db, tripId, {apply = false, maxDocs = 500} = {}) {
  if (!validId(tripId)) throw new Error("Invalid trip ID.");
  const tripRef = db.collection("trips").doc(tripId);
  const trip = (await tripRef.get()).data();
  if (!trip) return {tripId, skipped: "missing-trip", documents: 0, changed: 0, applied: 0, invalid: 0, legacyFieldCounts: {}};
  const snapshot = await tripRef.collection("transportation").limit(maxDocs + 1).get();
  if (snapshot.size > maxDocs) throw new Error(`Trip ${tripId} has more than ${maxDocs} transportation records.`);
  const summary = {tripId, documents: snapshot.size, changed: 0, applied: 0, unchanged: 0, invalid: 0,
    modeMapped: 0, legacyFieldCounts: {}, changedFieldCounts: {}};
  const names = new Map();
  for (const doc of snapshot.docs) {
    const data = doc.data() || {};
    const uid = typeof data.userId === "string" && data.userId ? data.userId : trip.createdBy;
    if (typeof uid === "string" && uid && !names.has(uid) && validId(uid)) {
      const user = await db.collection("users").doc(uid).get();
      names.set(uid, user.data()?.displayName);
    }
    const plan = canonicalRecord({docId: doc.id, tripId, data, trip, displayName: names.get(uid)});
    for (const key of plan.legacyKeys) summary.legacyFieldCounts[key] = (summary.legacyFieldCounts[key] || 0) + 1;
    if (plan.modeMapped) summary.modeMapped++;
    if (!plan.valid) { summary.invalid++; continue; }
    if (plan.changedKeys.length === 0 && plan.legacyKeys.length === 0) { summary.unchanged++; continue; }
    summary.changed++;
    for (const key of plan.changedKeys) summary.changedFieldCounts[key] = (summary.changedFieldCounts[key] || 0) + 1;
    if (!apply) continue;
    await db.runTransaction(async (tx) => {
      const [currentTrip, current] = await Promise.all([tx.get(tripRef), tx.get(doc.ref)]);
      if (!currentTrip.exists || !current.exists) return;
      if (JSON.stringify(current.data()) !== JSON.stringify(data)) {
        throw new Error(`Transportation ${tripId}/${doc.id} changed during normalization; rerun.`);
      }
      tx.set(doc.ref, plan.record);
      summary.applied++;
    });
  }
  return summary;
}

async function normalizeTransportationPage(db, {after = null, limit = 10, apply = false, maxDocs = 500} = {}) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 50) throw new Error("Trip page size must be 1–50.");
  let query = db.collection("trips").orderBy(FieldPath.documentId()).limit(limit);
  if (after != null) {
    if (!validId(after)) throw new Error("Invalid resume cursor.");
    query = query.startAfter(after);
  }
  const page = await query.get();
  const totals = {tripsScanned: 0, documents: 0, changed: 0, applied: 0, unchanged: 0, invalid: 0,
    modeMapped: 0, legacyFieldCounts: {}, changedFieldCounts: {}};
  for (const tripDoc of page.docs) {
    const summary = await normalizeTripTransportation(db, tripDoc.id, {apply, maxDocs});
    totals.tripsScanned++;
    for (const key of ["documents", "changed", "applied", "unchanged", "invalid", "modeMapped"]) totals[key] += summary[key] || 0;
    for (const name of ["legacyFieldCounts", "changedFieldCounts"]) {
      for (const [key, count] of Object.entries(summary[name] || {})) totals[name][key] = (totals[name][key] || 0) + count;
    }
  }
  return {totals, nextAfter: page.size < limit ? null : page.docs[page.size - 1].id};
}

module.exports = {canonicalRecord, localClock, canonicalMode, normalizeTripTransportation,
  normalizeTransportationPage, CANONICAL_KEYS};
