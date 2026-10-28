// Resumable cleanup of favorites on accounts deleted before the cleanup trigger.
"use strict";

const {parseArgs} = require("node:util");
const {readFile, writeFile, rename} = require("node:fs/promises");
const {randomUUID} = require("node:crypto");
const {FieldPath} = require("firebase-admin/firestore");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {validId} = require("./validation");
const {cleanDeletedUserFavorites} = require("./favorite-cleanup");

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
    checkpoint: {type: "string"}, after: {type: "string"},
    apply: {type: "boolean", default: false},
    "confirm-project": {type: "string"}, "confirm-database": {type: "string"},
  }});
  if (!values.project || !values.database) {
    throw new Error("Use --project PROJECT --database DATABASE.");
  }
  const limit = positive(values.limit, "User page size", 50);
  const pages = positive(values.pages, "User pages", 100);
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
  let totals = {usersScanned: 0, deletedUsers: 0, withFavorites: 0,
    malformedLists: 0, favoriteEntries: 0, removed: 0, invalidRemoved: 0};
  if (values.checkpoint) {
    try {
      const prior = JSON.parse(await readFile(values.checkpoint, "utf8"));
      if (JSON.stringify(prior.identity) !== JSON.stringify(identity)) {
        throw new Error("Checkpoint belongs to another backfill configuration.");
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
  const pauseRef = db.collection("favoriteMaintenance").doc("current");
  try {
    if (values.apply && (await pauseRef.get()).data()?.paused !== true) {
      throw new Error("Favorite transitions must be paused before applying a backfill.");
    }
    for (let page = 0; page < pages && !complete; page++) {
      let query = db.collection("users").orderBy(FieldPath.documentId()).limit(limit);
      if (after) query = query.startAfter(after);
      const users = await query.get();
      for (const user of users.docs) {
        totals.usersScanned++;
        if (user.data().isDeleted === true) {
          totals.deletedUsers++;
          const raw = user.data().favouriteTrips;
          const malformed = raw != null && !Array.isArray(raw);
          if (malformed) totals.malformedLists++;
          const entries = Array.isArray(raw) ? raw.length : malformed ? 1 : 0;
          totals.favoriteEntries += entries;
          if (entries) totals.withFavorites++;
          if (values.apply && entries) {
            const pause = await pauseRef.get();
            if (pause.data()?.paused !== true) {
              throw new Error("Favorite maintenance pause ended during backfill.");
            }
            const result = await cleanDeletedUserFavorites(db, user.id,
                Array.isArray(raw) ? raw.filter(validId) : []);
            totals.removed += result.removed;
            totals.invalidRemoved += result.invalidRemoved;
            const remaining = (await user.ref.get()).data()?.favouriteTrips;
            if (remaining != null && (!Array.isArray(remaining) || remaining.length)) {
              throw new Error("Deleted account still has favorite entries; resume after review.");
            }
          }
        }
        after = user.id;
        if (values.checkpoint) {
          const temporary = `${values.checkpoint}.${randomUUID()}.tmp`;
          await writeFile(temporary, `${JSON.stringify({identity, after, complete: false, totals}, null, 2)}\n`,
              {mode: 0o600, flag: "wx"});
          await rename(temporary, values.checkpoint);
        }
      }
      complete = users.size < limit;
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
