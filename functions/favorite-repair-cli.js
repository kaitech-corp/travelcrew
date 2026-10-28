// Favorite-count repair. Dry run unless --apply is explicitly supplied.
"use strict";

const {parseArgs} = require("node:util");
const {readFile, writeFile, rename} = require("node:fs/promises");
const {randomUUID} = require("node:crypto");
const {FieldPath} = require("firebase-admin/firestore");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {repairTripFavoriteCount} = require("./favorite-repair");

function positive(value, label, maximum) {
  const number = Number(value);
  if (!Number.isInteger(number) || number < 1 || number > maximum) {
    throw new Error(`${label} must be 1–${maximum}.`);
  }
  return number;
}

async function main(args = process.argv.slice(2)) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string"},
    limit: {type: "string", default: "10"}, pages: {type: "string", default: "1"},
    after: {type: "string"}, checkpoint: {type: "string"},
    apply: {type: "boolean", default: false},
    "confirm-project": {type: "string"},
    "confirm-database": {type: "string"},
  }});
  if (!values.project || !values.database) {
    throw new Error("Use --project PROJECT --database DATABASE.");
  }
  const limit = positive(values.limit, "Trip page size", 50);
  const pages = positive(values.pages, "Trip pages", 100);
  if (values.after && values.checkpoint) {
    throw new Error("Use either --after or --checkpoint, not both.");
  }
  if (values.apply && (!values.checkpoint ||
      values["confirm-project"] !== values.project ||
      values["confirm-database"] !== values.database)) {
    throw new Error("Apply requires --checkpoint and matching --confirm-project and --confirm-database.");
  }
  const identity = {project: values.project, database: values.database,
    limit, apply: values.apply};
  let after = values.after || null;
  let complete = false;
  let totals = {preview: 0, repaired: 0, unchanged: 0, missing: 0};
  if (values.checkpoint) {
    try {
      const prior = JSON.parse(await readFile(values.checkpoint, "utf8"));
      if (JSON.stringify(prior.identity) !== JSON.stringify(identity)) {
        throw new Error("Checkpoint belongs to another repair configuration.");
      }
      after = prior.after;
      complete = prior.complete;
      totals = prior.totals;
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
    }
  }

  const app = initializeApp({projectId: values.project});
  const db = getFirestore(app, values.database);
  try {
    if (values.apply &&
        (await db.collection("favoriteMaintenance").doc("current").get()).data()?.paused !== true) {
      throw new Error("Favorite transitions must be paused before applying a repair.");
    }
    for (let page = 0; page < pages && !complete; page++) {
      let query = db.collection("trips").orderBy(FieldPath.documentId()).limit(limit);
      if (after) query = query.startAfter(after);
      const trips = await query.get();
      for (const trip of trips.docs) {
        const outcome = await repairTripFavoriteCount(db, trip.id, {apply: values.apply});
        console.log(JSON.stringify(outcome));
        totals[outcome.status]++;
        after = trip.id;
        if (values.checkpoint) {
          const temporary = `${values.checkpoint}.${randomUUID()}.tmp`;
          await writeFile(temporary, `${JSON.stringify({identity, after, complete: false, totals}, null, 2)}\n`,
              {mode: 0o600, flag: "wx"});
          await rename(temporary, values.checkpoint);
        }
      }
      complete = trips.size < limit;
    }
    if (values.checkpoint && complete) {
      const temporary = `${values.checkpoint}.${randomUUID()}.tmp`;
      await writeFile(temporary, `${JSON.stringify({identity, after, complete, totals}, null, 2)}\n`,
          {mode: 0o600, flag: "wx"});
      await rename(temporary, values.checkpoint);
    }
    console.log(JSON.stringify({identity, complete, totals, nextAfter: after}));
  } finally {
    await db.terminate();
    await deleteApp(app);
  }
}

if (require.main === module) {
  main().catch((error) => {console.error(error.message); process.exitCode = 1;});
}

module.exports = {main};
