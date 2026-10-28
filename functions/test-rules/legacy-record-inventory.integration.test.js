"use strict";

const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {auditTripRecordsPage, auditTopLevelRecordsPage} = require("../legacy-record-inventory");
const {main} = require("../legacy-record-inventory-cli");

let app; let db;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-legacy-inventory"}, "legacy-inventory");
  db = getFirestore(app);
  await db.doc("trips/a").set({tripStatus: "upcoming", hotelName: "Old hotel",
    checkInDate: "2027-04-12T00:00:00.000", checkOutDate: "2027-04-10T00:00:00.000",
    expensePerNight: 120});
  await db.doc("trips/a/activities/new").set({createdBy: "owner", contentRevision: 1,
    startDateTime: "2027-04-10T10:00:00+09:00", endDateTime: "2027-04-10T12:00:00+09:00", isDeleted: false});
  await db.doc("trips/a/activities/old").set({title: "Legacy", startDateTime: "2027-04-10 10:00"});
  await db.doc("trips/a/activities/gone").set({createdBy: "owner", contentRevision: 3, isDeleted: true,
    startDateTime: null, endDateTime: null});
  await db.doc("trips/a/transportation/t1").set({id: "t1", tripId: "a", userId: "owner", displayName: "Owner",
    mode: "flight", departure: "2027-04-10T10:00:00", arrival: null, notes: "", revision: 1, isDeleted: false});
  await db.doc("trips/a/transportation/t2").set({mode: "airplane", airline: "Old Air", departure: "2027-02-30"});
  await db.doc("trips/a/lodgings/l1").set({createdBy: "owner", lodgingType: "Hotel", hotelName: "Option",
    hotelAddress: "", checkInDate: "2027-04-10T15:00:00+09:00", checkOutDate: "2027-04-12T11:00:00+09:00",
    expensePerNight: 100, currencyCode: "JPY", revision: 1, isDeleted: false});
  await db.doc("trips/a/lodgings/l2").set({hotelName: "Bad", checkInDate: "2027-04-12", checkOutDate: "2027-04-10",
    expensePerNight: -5, legacyField: true});
  await db.doc("activity/top-linked").set({tripId: "a", createdBy: "owner"});
  await db.doc("activity/top-orphan").set({tripId: "missing-trip"});
  await db.doc("activity/top-blank").set({title: "No trip"});
  await db.doc("flights/f1").set({tripId: "a", userId: "owner"});
  await db.doc("trips/b").set({tripStatus: "deleted", lodgingRevision: 2});
});
after(async () => {
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});

test("trip scan classifies activity, transportation and lodging records without changing them", async () => {
  const first = await auditTripRecordsPage(db, {limit: 1, maxDocsPerSource: 100});
  assert.equal(first.nextAfter, "a");
  const t = first.totals;
  assert.equal(t.tripsScanned, 1);
  assert.equal(t.activities, 3);
  assert.equal(t.activitiesAuthorless, 1);
  assert.equal(t.activitiesWithoutRevision, 1);
  assert.equal(t.activityTombstones, 1);
  assert.equal(t.activitiesInvalidTime, 1);
  assert.equal(t.activitiesOneSidedTime, 1);
  assert.equal(t.legacyTopLevelActivitiesLinked, 1);
  assert.equal(t.transportation, 2);
  assert.equal(t.transportationMissingKeys, 1);
  assert.equal(t.transportationExtraKeys, 1);
  assert.equal(t.transportationInvalidMode, 1);
  assert.equal(t.transportationInvalidDate, 1);
  assert.equal(t.transportationWithoutRevision, 1);
  assert.deepEqual(t.transportationLegacyFieldCounts, {airline: 1});
  assert.equal(t.transportationMissingFieldCounts.revision, 1);
  assert.deepEqual(t.transportationLegacyModeCounts, {airplane: 1});
  assert.equal(t.lodgingOptions, 2);
  assert.equal(t.lodgingOptionsExtraKeys, 1);
  assert.equal(t.lodgingOptionsInvalidDates, 1);
  assert.equal(t.lodgingOptionsInvalidCost, 1);
  assert.equal(t.lodgingOptionsWithoutRevision, 1);
  assert.equal(t.lodgingOptionsAuthorless, 1);
  assert.equal(t.tripsWithFeaturedLodging, 1);
  assert.equal(t.featuredLodgingReversedDates, 1);
  assert.equal(t.featuredLodgingCostWithoutCurrency, 1);
  assert.equal(t.tripsWithoutLodgingRevision, 1);
  const second = await auditTripRecordsPage(db, {after: first.nextAfter, limit: 1});
  assert.equal(second.totals.deletedOrModeratedTrips, 1);
  assert.equal(second.totals.tripsWithFeaturedLodging, 0);
  assert.equal(second.totals.tripsWithoutLodgingRevision, 0);
  // A full page cannot prove the scan is complete; the next page is empty.
  assert.equal(second.nextAfter, "b");
  const third = await auditTripRecordsPage(db, {after: second.nextAfter, limit: 1});
  assert.equal(third.totals.tripsScanned, 0);
  assert.equal(third.nextAfter, null);
  assert.equal((await db.doc("trips/a/transportation/t2").get()).data().airline, "Old Air");
});

test("source caps are reported per trip", async () => {
  const capped = await auditTripRecordsPage(db, {limit: 1, maxDocsPerSource: 1});
  assert.deepEqual(capped.cappedTripIds, ["a"]);
  assert.equal(capped.totals.activities, 1);
});

test("top-level legacy scans count orphan, blank and linked references", async () => {
  const activity = await auditTopLevelRecordsPage(db, {collection: "activity", limit: 100});
  assert.equal(activity.totals.documents, 3);
  assert.equal(activity.totals.linkedToTrip, 1);
  assert.equal(activity.totals.orphanTripId, 1);
  assert.equal(activity.totals.missingTripId, 1);
  assert.equal(activity.totals.authorless, 2);
  assert.equal(activity.nextAfter, null);
  const paged = await auditTopLevelRecordsPage(db, {collection: "activity", limit: 1});
  assert.equal(paged.nextAfter, "top-blank");
  const flights = await auditTopLevelRecordsPage(db, {collection: "flights"});
  assert.equal(flights.totals.documents, 1);
  assert.equal(flights.totals.linkedToTrip, 1);
  await assert.rejects(auditTopLevelRecordsPage(db, {collection: "trips"}), /Collection must be/);
});

test("CLI requires explicit targets and prints only counts", async () => {
  await assert.rejects(main(["--scan", "trips"], {db}), /--project PROJECT --database DATABASE/);
  const printed = [];
  const output = await main(["--project", "demo", "--database", "(default)", "--scan", "trips",
    "--limit", "1", "--pages", "5"], {db, print: (text) => printed.push(text)});
  assert.equal(output.scanComplete, true);
  assert.equal(output.totals.tripsScanned, 2);
  assert.equal(printed.length, 1);
  assert.equal(printed[0].includes("Old hotel"), false);
  assert.equal(printed[0].includes("owner"), false);
  const top = await main(["--project", "demo", "--database", "(default)", "--scan", "top-activity"], {db, print: () => {}});
  assert.equal(top.totals.documents, 3);
});
