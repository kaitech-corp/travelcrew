"use strict";

const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {normalizeTripTransportation, normalizeTransportationPage, localClock, canonicalMode} = require("../transportation-normalize");
const {main} = require("../transportation-normalize-cli");

let app; let db;
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  app = initializeApp({projectId: "demo-travelcrew-transport-normalize"}, "transport-normalize");
  db = getFirestore(app);
  await db.doc("users/owner").set({displayName: "Owner Name"});
  await db.doc("trips/a").set({id: "a", createdBy: "owner", tripStatus: "upcoming"});
  await db.doc("trips/a/transportation/legacy-flight").set({
    id: "legacy-flight", tripId: "a", userId: "owner", displayName: "Owner Name", mode: "flight",
    airlineName: "Example Air", flightNumber: "EA 12", departureAirport: "LAX", arrivalAirport: "KIX",
    departureDate: "2027-05-01T10:15:00-07:00", arrivalDate: Timestamp.fromDate(new Date("2027-05-02T05:05:00Z")),
    transportTitle: "Outbound", travelerNames: ["Randy", "Alex"], notes: "Window seats",
  });
  await db.doc("trips/a/transportation/legacy-drive").set({
    mode: "car", title: "Rental", origin: "Airport", destination: "Hotel", provider: "Rentals Inc",
    serviceNumber: "", driver: "", travelerNames: [], departure: "2027-05-02", arrival: null, notes: "",
  });
  await db.doc("trips/a/transportation/canonical").set({
    id: "canonical", tripId: "a", userId: "owner", displayName: "Owner Name", mode: "train",
    departure: "2027-05-02T16:30:00", arrival: null, notes: "Haruka", revision: 2, isDeleted: false,
  });
  await db.doc("trips/b").set({id: "b", createdBy: "owner"});
});
after(async () => {
  if (db) await db.terminate();
  if (app) await deleteApp(app);
});

test("clock and mode conversions keep wall time and map legacy names", () => {
  assert.equal(localClock("2027-05-01T10:15:00-07:00"), "2027-05-01T10:15:00");
  assert.equal(localClock("2027-05-01T10:15:00.000Z"), "2027-05-01T10:15:00");
  assert.equal(localClock("2027-05-01 10:15"), "2027-05-01T10:15:00");
  assert.equal(localClock("2027-05-01"), "2027-05-01");
  assert.equal(localClock("2027-02-30"), null);
  assert.equal(localClock("yesterday"), null);
  assert.equal(localClock(""), null);
  assert.equal(canonicalMode("Airplane"), "flight");
  assert.equal(canonicalMode("car"), "driving");
  assert.equal(canonicalMode("hovercraft"), "other");
  assert.equal(canonicalMode(undefined), "other");
});

test("dry run reports changes without writing; apply replaces legacy records once", async () => {
  const dry = await normalizeTripTransportation(db, "a");
  assert.equal(dry.documents, 3);
  assert.equal(dry.changed, 2);
  assert.equal(dry.unchanged, 1);
  assert.equal(dry.applied, 0);
  assert.equal(dry.modeMapped, 1);
  assert.equal(dry.legacyFieldCounts.airlineName, 1);
  assert.equal(dry.legacyFieldCounts.title, 1);
  assert.equal((await db.doc("trips/a/transportation/legacy-flight").get()).data().airlineName, "Example Air");

  const applied = await normalizeTripTransportation(db, "a", {apply: true});
  assert.equal(applied.applied, 2);
  const flight = (await db.doc("trips/a/transportation/legacy-flight").get()).data();
  assert.deepEqual(Object.keys(flight).sort(), ["arrival", "departure", "displayName", "id", "isDeleted",
    "mode", "notes", "revision", "tripId", "userId"]);
  assert.equal(flight.departure, "2027-05-01T10:15:00");
  assert.equal(flight.arrival, "2027-05-02T05:05:00");
  assert.equal(flight.revision, 1);
  assert.equal(flight.isDeleted, false);
  assert.match(flight.notes, /^Window seats\n/);
  assert.match(flight.notes, /Airline: Example Air/);
  assert.match(flight.notes, /Flight: EA 12/);
  assert.match(flight.notes, /From: LAX/);
  assert.match(flight.notes, /Travelers: Randy, Alex/);
  const drive = (await db.doc("trips/a/transportation/legacy-drive").get()).data();
  assert.equal(drive.id, "legacy-drive");
  assert.equal(drive.tripId, "a");
  assert.equal(drive.userId, "owner");
  assert.equal(drive.displayName, "Owner Name");
  assert.equal(drive.mode, "driving");
  assert.equal(drive.departure, "2027-05-02");
  assert.equal(drive.arrival, null);
  assert.equal(drive.notes, "Title: Rental\nFrom: Airport\nTo: Hotel\nProvider: Rentals Inc");
  const canonical = (await db.doc("trips/a/transportation/canonical").get()).data();
  assert.equal(canonical.revision, 2);
  assert.equal(canonical.notes, "Haruka");

  const again = await normalizeTripTransportation(db, "a", {apply: true});
  assert.equal(again.changed, 0);
  assert.equal(again.unchanged, 3);
});

test("paging and CLI guard rails", async () => {
  const page = await normalizeTransportationPage(db, {limit: 1});
  assert.equal(page.nextAfter, "a");
  assert.equal(page.totals.tripsScanned, 1);
  await assert.rejects(main(["--project", "demo"], {db}), /--project PROJECT --database DATABASE/);
  await assert.rejects(main(["--project", "demo", "--database", "(default)", "--apply"], {db}),
      /matching --confirm-project/);
  const printed = [];
  const output = await main(["--project", "demo", "--database", "(default)", "--limit", "1", "--pages", "5"],
      {db, print: (text) => printed.push(text)});
  assert.equal(output.mode, "dry-run");
  assert.equal(output.complete, true);
  assert.equal(output.totals.tripsScanned, 2);
  assert.equal(output.totals.documents, 3);
  assert.equal(printed[0].includes("Window seats"), false);
  assert.equal(printed[0].includes("Owner Name"), false);
});
