"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {mkdtemp, readFile, rm} = require("node:fs/promises");
const {tmpdir} = require("node:os");
const {join} = require("node:path");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {main} = require("../favorite-repair-cli");

test("repair CLI applies only under pause and resumes from its checkpoint", async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error("Firestore emulator required");
  const project = "demo-travelcrew-favorite-repair-cli";
  const app = initializeApp({projectId: project}, "favorite-repair-cli-test");
  const db = getFirestore(app);
  const directory = await mkdtemp(join(tmpdir(), "favorite-repair-"));
  const checkpoint = join(directory, "state.json");
  const arguments_ = ["--project", project, "--database", "(default)",
    "--limit", "10", "--pages", "2", "--apply", "--confirm-project", project,
    "--confirm-database", "(default)", "--checkpoint", checkpoint];
  try {
    await db.doc("trips/trip").set({createdBy: "owner", favouriteCount: 9});
    await db.doc("tripDiscovery/trip").set({createdBy: "owner", favouriteCount: 1});
    await db.doc("users/viewer").set({favouriteTrips: ["trip"]});
    await assert.rejects(main(arguments_), /must be paused/);
    assert.equal((await db.doc("trips/trip").get()).data().favouriteCount, 9);
    await db.doc("favoriteMaintenance/current").set({paused: true});
    await main(arguments_);
    assert.equal((await db.doc("trips/trip").get()).data().favouriteCount, 1);
    assert.equal((await db.doc("tripDiscovery/trip").get()).data().favouriteCount, 1);
    const saved = JSON.parse(await readFile(checkpoint, "utf8"));
    assert.equal(saved.complete, true);
    assert.equal(saved.totals.repaired, 1);
    await main(arguments_);
    assert.equal((await db.doc("trips/trip").get()).data().favouriteCount, 1);
  } finally {
    await rm(directory, {recursive: true, force: true});
    await db.terminate();
    await deleteApp(app);
  }
});
