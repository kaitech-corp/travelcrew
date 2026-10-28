"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {mkdtemp, readFile, rm} = require("node:fs/promises");
const {tmpdir} = require("node:os");
const {join} = require("node:path");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {main} = require("../favorite-deleted-backfill-cli");

test("deleted-account backfill clears old favorites and resumes safely", async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  const project = "demo-travelcrew-deleted-favorite-backfill";
  const app = initializeApp({projectId: project}, "favorite-backfill-test");
  const db = getFirestore(app);
  const directory = await mkdtemp(join(tmpdir(), "favorite-backfill-"));
  const checkpoint = join(directory, "state.json");
  const arguments_ = ["--project", project, "--database", "(default)",
    "--limit", "10", "--pages", "2", "--apply", "--confirm-project", project,
    "--confirm-database", "(default)", "--checkpoint", checkpoint];
  try {
    await db.doc("trips/trip").set({createdBy: "owner", favouriteCount: 2});
    await db.doc("tripDiscovery/trip").set({createdBy: "owner", favouriteCount: 2});
    await db.doc("users/active").set({isDeleted: false, favouriteTrips: ["trip"]});
    await db.doc("users/deleted").set({isDeleted: true,
      favouriteTrips: ["trip", "..", 42]});
    await db.doc("users/malformed").set({isDeleted: true, favouriteTrips: "bad"});
    await main(["--project", project, "--database", "(default)",
      "--limit", "10", "--pages", "1"]);
    assert.deepEqual((await db.doc("users/deleted").get()).data().favouriteTrips,
        ["trip", "..", 42]);
    await assert.rejects(main(arguments_), /must be paused/);
    assert.equal((await db.doc("trips/trip").get()).data().favouriteCount, 2);
    await db.doc("favoriteMaintenance/current").set({paused: true});
    await main(arguments_);
    assert.deepEqual((await db.doc("users/deleted").get()).data().favouriteTrips, []);
    assert.deepEqual((await db.doc("users/malformed").get()).data().favouriteTrips, []);
    assert.deepEqual((await db.doc("users/active").get()).data().favouriteTrips, ["trip"]);
    assert.equal((await db.doc("trips/trip").get()).data().favouriteCount, 1);
    assert.equal((await db.doc("tripDiscovery/trip").get()).data().favouriteCount, 1);
    const saved = JSON.parse(await readFile(checkpoint, "utf8"));
    assert.equal(saved.complete, true);
    assert.equal(saved.totals.removed, 1);
    assert.equal(saved.totals.invalidRemoved, 3);
    assert.equal(saved.totals.malformedLists, 1);
    await main(arguments_);
    assert.equal((await db.doc("trips/trip").get()).data().favouriteCount, 1);
  } finally {
    await rm(directory, {recursive: true, force: true});
    await db.terminate();
    await deleteApp(app);
  }
});
