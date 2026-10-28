// Legacy transportation normalization. Dry run unless --apply is explicitly
// supplied with matching --confirm-project and --confirm-database. Prints
// counts and field names only.
"use strict";

const {parseArgs} = require("node:util");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {normalizeTransportationPage} = require("./transportation-normalize");

function positive(value, label, maximum) {
  const number = Number(value);
  if (!Number.isInteger(number) || number < 1 || number > maximum) {
    throw new Error(`${label} must be 1–${maximum}.`);
  }
  return number;
}

async function main(args = process.argv.slice(2), services = {}) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string"},
    limit: {type: "string", default: "10"}, pages: {type: "string", default: "1"},
    after: {type: "string"}, apply: {type: "boolean", default: false},
    "confirm-project": {type: "string"}, "confirm-database": {type: "string"},
  }});
  if (!values.project || !values.database) throw new Error("Use --project PROJECT --database DATABASE.");
  if (values.apply && (values["confirm-project"] !== values.project || values["confirm-database"] !== values.database)) {
    throw new Error("Apply requires matching --confirm-project and --confirm-database.");
  }
  const limit = positive(values.limit, "Trip page size", 50);
  const pages = positive(values.pages, "Trip pages", 100);
  const app = services.app || initializeApp({projectId: values.project});
  const db = services.db || getFirestore(app, values.database);
  let after = values.after || null;
  let complete = false;
  const totals = {tripsScanned: 0, documents: 0, changed: 0, applied: 0, unchanged: 0, invalid: 0,
    modeMapped: 0, legacyFieldCounts: {}, changedFieldCounts: {}};
  try {
    for (let page = 0; page < pages && !complete; page++) {
      const result = await normalizeTransportationPage(db, {after, limit, apply: values.apply});
      for (const [key, value] of Object.entries(result.totals)) {
        if (value && typeof value === "object") {
          for (const [name, count] of Object.entries(value)) totals[key][name] = (totals[key][name] || 0) + count;
        } else {
          totals[key] += value;
        }
      }
      after = result.nextAfter;
      complete = after === null;
    }
    const output = {project: values.project, database: values.database, mode: values.apply ? "apply" : "dry-run",
      complete, nextAfter: after, totals};
    (services.print || console.log)(JSON.stringify(output, null, 2));
    return output;
  } finally {
    if (!services.db) await db.terminate();
    if (!services.app) await deleteApp(app);
  }
}

if (require.main === module) {
  main().catch((error) => { console.error(error.message); process.exitCode = 1; });
}

module.exports = {main};
