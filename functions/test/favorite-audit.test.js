const {test} = require("node:test");
const assert = require("node:assert/strict");
const {main} = require("../favorite-audit-cli");
const {auditTripFavoriteCount, auditFavoriteTripPage,
  auditFavoriteCardPage, auditFavoriteUserPage} = require("../favorite-audit");

test("favorite audit requires an explicit project and database", async () => {
  await assert.rejects(main([]), /--project PROJECT --database DATABASE/);
  await assert.rejects(main(["--project", "demo-project"]), /--database DATABASE/);
});

test("favorite audit rejects unbounded or conflicting scans before connecting", async () => {
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--limit", "51"]), /Trip page size/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--after", "trip", "--checkpoint", "state.json"]), /either --after or --checkpoint/);
  await assert.rejects(auditTripFavoriteCount(null, "trip", {maxUserPages: 21}), /Maximum user pages/);
  await assert.rejects(auditFavoriteTripPage(null, {limit: 0}), /Trip page size/);
  await assert.rejects(auditFavoriteCardPage(null, {limit: 51}), /Card page size/);
  await assert.rejects(auditFavoriteUserPage(null, {maxLinksPerUser: 501}), /Favorite links per user/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--scan", "unsupported"]), /Scan must be trips, cards or users/);
  await assert.rejects(main(["--project", "demo-project", "--database", "(default)",
    "--scan", "users", "--max-links-per-user", "501"]), /Favorite links per user/);
});
