"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {main} = require("../favorite-repair-cli");
const {repairTripFavoriteCount} = require("../favorite-repair");

test("favorite repair requires explicit project, database and write confirmation", async () => {
  await assert.rejects(main([]), /--project PROJECT --database DATABASE/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--apply"]), /matching --confirm-project and --confirm-database/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--apply", "--checkpoint", "state.json", "--confirm-project", "wrong",
    "--confirm-database", "(default)"]), /matching --confirm-project/);
});

test("favorite repair validates bounds and IDs before reading data", async () => {
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--limit", "51"]), /Trip page size/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--after", "trip", "--checkpoint", "state.json"]), /either --after or --checkpoint/);
  await assert.rejects(repairTripFavoriteCount(null, "../bad"), /Valid trip ID/);
  await assert.rejects(repairTripFavoriteCount(null, "trip", {maxAttempts: 6}), /Repair attempts/);
});
