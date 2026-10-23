// Explicit project selection prevents accidental writes to the active CLI project.
const {parseArgs} = require("node:util");
const {readFile, writeFile, rename} = require("node:fs/promises");
const {randomUUID} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {auditFeaturePage, auditUserPage} = require("./maintenance");

async function main(args = process.argv.slice(2)) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string", default: "travel-crew-db-2"},
    kind: {type: "string", default: "trips"}, limit: {type: "string", default: "100"},
    pages: {type: "string", default: "1"}, after: {type: "string"}, checkpoint: {type: "string"},
    apply: {type: "boolean", default: false},
  }});
  if (!values.project || !["trips", "users"].includes(values.kind) || (values.apply && values.kind !== "trips")) {
    throw new Error("Use --project PROJECT --kind trips|users. --apply is only valid for trip feature backfills.");
  }
  const limit = Number(values.limit); const pages = Number(values.pages);
  if (!Number.isInteger(pages) || pages < 1 || pages > 100 || !Number.isInteger(limit) || limit < 1 || limit > 250) {
    throw new Error("Use 1–100 pages and 1–250 records per page.");
  }
  const identity = {project: values.project, database: values.database, kind: values.kind, apply: values.apply};
  let after = values.after || null; let totals = {}; let complete = false;
  if (values.checkpoint) {
    try {
      const prior = JSON.parse(await readFile(values.checkpoint, "utf8"));
      if (JSON.stringify(prior.identity) !== JSON.stringify(identity)) throw new Error("Checkpoint belongs to a different project, database, kind, or apply mode.");
      if (values.after) throw new Error("Use either a checkpoint or --after, not both.");
      after = prior.after; totals = prior.totals; complete = prior.complete;
    } catch (error) { if (error.code !== "ENOENT") throw error; }
  }
  const app = initializeApp({projectId: values.project}); const db = getFirestore(app, values.database);
  try {
    for (let page = 0; page < pages && !complete; page++) {
      const result = await (values.kind === "users" ? auditUserPage : auditFeaturePage)(db, {after, limit, apply: values.apply});
      for (const [key, count] of Object.entries(result.counts)) totals[key] = (totals[key] || 0) + count;
      after = result.nextAfter; complete = after === null;
      if (values.checkpoint) {
        const temporary = `${values.checkpoint}.${randomUUID()}.tmp`;
        await writeFile(temporary, JSON.stringify({identity, after, totals, complete}, null, 2) + "\n", {mode: 0o600, flag: "wx"});
        await rename(temporary, values.checkpoint);
      }
    }
    console.log(JSON.stringify({...identity, complete, totals, nextAfter: after}, null, 2));
  } finally { await db.terminate(); await deleteApp(app); }
}

if (require.main === module) main().catch((error) => { console.error(error.message); process.exitCode = 1; });
module.exports = {main};
