"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {main} = require("../favorite-deleted-backfill-cli");

test("deleted-favorite backfill requires explicit target and write confirmation", async () => {
  await assert.rejects(main([]), /--project PROJECT --database DATABASE/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--apply"]), /matching --confirm-project and --confirm-database/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--limit", "51"]), /User page size/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--after", "user", "--checkpoint", "state.json"]), /either --after or --checkpoint/);
});
