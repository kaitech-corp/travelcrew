// Read-only favorite-count inventory. Requires explicit project and database.
const {parseArgs} = require("node:util");
const {readFile, writeFile, rename} = require("node:fs/promises");
const {randomUUID} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {auditFavoriteTripPage, auditFavoriteCardPage, auditFavoriteUserPage} = require("./favorite-audit");

function numberOption(value, name, max) {
  const number = Number(value);
  if (!Number.isInteger(number) || number < 1 || number > max) {
    throw new Error(`${name} must be 1–${max}.`);
  }
  return number;
}

async function main(args = process.argv.slice(2)) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string"},
    scan: {type: "string", default: "trips"},
    limit: {type: "string", default: "10"}, pages: {type: "string", default: "1"},
    "user-page-size": {type: "string", default: "100"},
    "max-user-pages": {type: "string", default: "5"},
    "max-links-per-user": {type: "string", default: "100"},
    after: {type: "string"}, checkpoint: {type: "string"},
  }});
  if (!values.project || !values.database) {
    throw new Error("Use --project PROJECT --database DATABASE for a read-only audit.");
  }
  if (!["trips", "cards", "users"].includes(values.scan)) {
    throw new Error("Scan must be trips, cards or users.");
  }
  const limit = numberOption(values.limit, "Trip page size", 50);
  const pages = numberOption(values.pages, "Trip pages", 100);
  const userPageSize = numberOption(values["user-page-size"], "User page size", 250);
  const maxUserPages = numberOption(values["max-user-pages"], "Maximum user pages", 20);
  const maxLinksPerUser = numberOption(values["max-links-per-user"], "Favorite links per user", 500);
  if (values.after && values.checkpoint) {
    throw new Error("Use either --after or --checkpoint, not both.");
  }
  const identity = {project: values.project, database: values.database, scan: values.scan,
    limit, userPageSize, maxUserPages, maxLinksPerUser};
  let after = values.after || null;
  let totals = {};
  let complete = false;
  if (values.checkpoint) {
    try {
      const prior = JSON.parse(await readFile(values.checkpoint, "utf8"));
      if (JSON.stringify(prior.identity) !== JSON.stringify(identity)) {
        throw new Error("Checkpoint belongs to another project, database or page configuration.");
      }
      after = prior.after;
      totals = prior.totals;
      complete = prior.complete;
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
    }
  }

  const app = initializeApp({projectId: values.project});
  const db = getFirestore(app, values.database);
  try {
    for (let page = 0; page < pages && !complete; page++) {
      const result = values.scan === "cards" ?
        await auditFavoriteCardPage(db, {after, limit}) :
        values.scan === "users" ?
          await auditFavoriteUserPage(db, {after, limit, maxLinksPerUser}) :
          await auditFavoriteTripPage(db, {after, limit, userPageSize, maxUserPages});
      for (const [key, count] of Object.entries(result.totals)) {
        totals[key] = (totals[key] || 0) + count;
      }
      after = result.nextAfter;
      complete = after === null;
      if (values.checkpoint) {
        const temporary = `${values.checkpoint}.${randomUUID()}.tmp`;
        await writeFile(temporary, `${JSON.stringify({identity, after, totals, complete}, null, 2)}\n`,
            {mode: 0o600, flag: "wx"});
        await rename(temporary, values.checkpoint);
      }
    }
    console.log(JSON.stringify({...identity, complete, totals, nextAfter: after}, null, 2));
  } finally {
    await db.terminate();
    await deleteApp(app);
  }
}

if (require.main === module) {
  main().catch((error) => { console.error(error.message); process.exitCode = 1; });
}
module.exports = {main};
