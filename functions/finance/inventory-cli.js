// Read-only expense migration inventory. Emits counts and a resume cursor,
// never expense names, user IDs, amounts or individual trip records.
"use strict";

const {parseArgs} = require("node:util");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {auditFinancePage, auditTopLevelExpensePage} = require("./inventory");

function numberOption(value, name, maximum) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > maximum) {
    throw new Error(`${name} must be 1–${maximum}.`);
  }
  return parsed;
}

async function main(args = process.argv.slice(2), services = {}) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string"},
    scan: {type: "string", default: "trips"},
    limit: {type: "string", default: "10"},
    pages: {type: "string", default: "1"},
    "max-docs-per-source": {type: "string", default: "1000"},
    after: {type: "string"},
  }});
  if (!values.project || !values.database) {
    throw new Error("Use --project PROJECT --database DATABASE for a read-only inventory.");
  }
  if (!["trips", "top-level"].includes(values.scan)) {
    throw new Error("Scan must be trips or top-level.");
  }
  const limit = numberOption(values.limit, "Trip page size", 50);
  const pages = numberOption(values.pages, "Trip pages", 100);
  const maxDocsPerSource = numberOption(values["max-docs-per-source"],
      "Maximum documents per source", 5000);
  const app = services.app || initializeApp({projectId: values.project});
  const db = services.db || getFirestore(app, values.database);
  let after = values.after || null;
  let scanComplete = false;
  const totals = {};
  const cappedTripIds = [];
  try {
    for (let page = 0; page < pages && !scanComplete; page++) {
      const result = values.scan === "top-level" ?
        await auditTopLevelExpensePage(db, {after, limit}) :
        await auditFinancePage(db, {after, limit, maxDocsPerSource});
      for (const [key, count] of Object.entries(result.totals)) {
        totals[key] = (totals[key] || 0) + count;
      }
      cappedTripIds.push(...(result.cappedTripIds || []));
      after = result.nextAfter;
      scanComplete = after === null;
    }
    const output = {project: values.project, database: values.database,
      scan: values.scan, scanComplete,
      coverageComplete: scanComplete && cappedTripIds.length === 0,
      nextAfter: after, cappedTripIds, totals};
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
