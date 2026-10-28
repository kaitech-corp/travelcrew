// Read-only inventory for replacing historical Firebase download-token URLs.
// Stdout never includes tokens, account IDs or individual source URLs.
"use strict";

const {parseArgs} = require("node:util");
const {writeFile} = require("node:fs/promises");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getStorage} = require("firebase-admin/storage");
const {COLLECTIONS, inventoryPhotoReferences} = require("./photo-migration-inventory");
const {buildPhotoMigrationPlan} = require("./photo-migration");

function bounded(value, name, max) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > max) {
    throw new Error(`${name} must be 1–${max}.`);
  }
  return parsed;
}

async function main(args = process.argv.slice(2), services = {}) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string"}, bucket: {type: "string"},
    "page-size": {type: "string", default: "50"},
    "max-pages": {type: "string", default: "100"},
    collections: {type: "string"}, "all-top-level": {type: "boolean"},
    descendants: {type: "boolean"}, "check-orphans": {type: "boolean"},
    "max-documents": {type: "string", default: "10000"},
    "max-nested-collections": {type: "string", default: "2000"},
    manifest: {type: "string"}, plan: {type: "string"},
  }});
  if (!values.project || !values.database || !values.bucket ||
      !/^[A-Za-z0-9._-]{3,255}$/.test(values.bucket)) {
    throw new Error("Use explicit --project, --database, and --bucket for this read-only inventory.");
  }
  const pageSize = bounded(values["page-size"], "Page size", 100);
  const maxPages = bounded(values["max-pages"], "Maximum pages", 1000);
  const maxDocuments = bounded(values["max-documents"], "Maximum documents", 100000);
  const maxNestedCollections = bounded(values["max-nested-collections"],
      "Maximum nested collections", 10000);
  if (values.collections && values["all-top-level"]) {
    throw new Error("Use either --collections or --all-top-level.");
  }
  if (values["check-orphans"] && !values.descendants) {
    throw new Error("--check-orphans requires --descendants.");
  }
  if (values.plan && !(values["all-top-level"] && values.descendants &&
      values["check-orphans"])) {
    throw new Error("--plan requires --all-top-level --descendants --check-orphans.");
  }
  const app = services.app || initializeApp({projectId: values.project});
  const db = services.db || getFirestore(app, values.database);
  try {
    const collections = values["all-top-level"] ?
      (await db.listCollections()).map((collection) => collection.id).sort() :
      values.collections ? values.collections.split(",") : COLLECTIONS;
    if (!collections.length || collections.length > 200 ||
        collections.some((name) => !/^[A-Za-z0-9_-]{1,128}$/.test(name)) ||
        new Set(collections).size !== collections.length) {
      throw new Error("Collections must be unique bounded Firestore names.");
    }
    const bucket = services.bucket || getStorage(app).bucket(values.bucket);
    const inventory = await inventoryPhotoReferences(db, bucket, {pageSize, maxPages,
      collections, includeDescendants: values.descendants === true, maxDocuments,
      maxNestedCollections, checkOrphans: values["check-orphans"] === true});
    const output = {project: values.project, database: values.database,
      bucket: values.bucket, descendants: values.descendants === true,
      orphanCheck: values["check-orphans"] === true,
      coverageComplete: inventory.coverageComplete,
      coverage: inventory.coverage, totals: inventory.totals};
    if (values.plan) {
      const plan = await buildPhotoMigrationPlan({inventory, db, bucket,
        project: values.project, database: values.database});
      await writeFile(values.plan, `${JSON.stringify(plan, null, 2)}\n`,
          {mode: 0o600, flag: "wx"});
      output.planId = plan.planId;
      output.plannedSources = plan.sources.length;
    }
    if (values.manifest) {
      await writeFile(values.manifest, `${JSON.stringify({...output,
        references: inventory.manifest}, null, 2)}\n`, {mode: 0o600, flag: "wx"});
    }
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
