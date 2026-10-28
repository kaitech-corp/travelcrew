// Operational photo migration. No production write is authorized merely by
// running this tool; deploy/cutover and old-object deletion require review.
"use strict";

const {parseArgs} = require("node:util");
const {readFile, writeFile, rename, stat} = require("node:fs/promises");
const {randomUUID} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getStorage} = require("firebase-admin/storage");
const {validatePlan, stagePhotoCopies, rewritePhotoReferences,
  verifyPhotoMigration, deleteOldPhotoObjects} = require("./photo-migration-apply");

async function protectedJson(path) {
  const details = await stat(path);
  if (!details.isFile() || (details.mode & 0o077) !== 0) {
    throw new Error("Plan and journal files must be regular files with mode 0600.");
  }
  return JSON.parse(await readFile(path, "utf8"));
}

async function writeJournal(path, value) {
  const temporary = `${path}.${randomUUID()}.tmp`;
  await writeFile(temporary, `${JSON.stringify(value, null, 2)}\n`,
      {mode: 0o600, flag: "wx"});
  await rename(temporary, path);
}

async function main(args = process.argv.slice(2), services = {}) {
  const {values} = parseArgs({args, options: {
    project: {type: "string"}, database: {type: "string"}, bucket: {type: "string"},
    plan: {type: "string"}, journal: {type: "string"}, mode: {type: "string"},
    "expected-plan-id": {type: "string"}, execute: {type: "boolean"},
    "allow-delete": {type: "boolean"},
  }});
  if (!values.project || !values.database || !values.bucket ||
      !values.plan || !values.journal ||
      !["stage", "rewrite", "verify", "purge"].includes(values.mode)) {
    throw new Error("Specify project, database, bucket, protected plan/journal and mode.");
  }
  const plan = await protectedJson(values.plan);
  validatePlan(plan, values.bucket);
  if (plan.project !== values.project || plan.database !== values.database ||
      !values["expected-plan-id"] || values["expected-plan-id"] !== plan.planId) {
    throw new Error("Project, database or reviewed plan ID does not match.");
  }
  if (["stage", "rewrite", "purge"].includes(values.mode) && !values.execute) {
    throw new Error("A write mode requires --execute.");
  }
  if (values.mode === "purge" && !values["allow-delete"]) {
    throw new Error("Old-object deletion requires --allow-delete.");
  }
  let journal;
  try { journal = await protectedJson(values.journal); } catch (error) {
    if (error.code !== "ENOENT" || values.mode !== "stage") throw error;
  }
  if (journal && journal.planId !== plan.planId) {
    throw new Error("Journal belongs to another plan.");
  }
  if (!journal && values.mode !== "stage") throw new Error("A staged journal is required.");
  const app = services.app || initializeApp({projectId: values.project, storageBucket: values.bucket});
  const db = services.db || getFirestore(app, values.database);
  const bucket = services.bucket || getStorage(app).bucket(values.bucket);
  try {
    let result;
    if (values.mode === "stage") {
      result = await stagePhotoCopies(bucket, plan);
      journal = {...journal, planId: plan.planId, stage: result};
    } else if (values.mode === "rewrite") {
      result = await rewritePhotoReferences(db, bucket, plan, journal.stage);
      journal.rewrite = result;
    } else if (values.mode === "verify") {
      result = await verifyPhotoMigration({db, bucket, plan, stage: journal.stage,
        allowMissingOld: Boolean(journal.purge)});
      journal.verify = result;
    } else {
      result = await deleteOldPhotoObjects({db, bucket, plan, stage: journal.stage});
      journal.purge = result;
    }
    await writeJournal(values.journal, journal);
    const safe = {mode: values.mode, planId: plan.planId,
      ...(values.mode === "stage" ? {staged: result.staged.length,
        created: result.staged.filter((item) => item.created).length} :
        values.mode === "rewrite" ? {updated: result.updated, unchanged: result.unchanged,
          missing: result.missing} : values.mode === "verify" ?
          {verified: result.verified, privateReferences: result.privateReferences} :
          {deleted: result.deleted})};
    (services.print || console.log)(JSON.stringify(safe, null, 2));
    return safe;
  } finally {
    if (!services.db) await db.terminate();
    if (!services.app) await deleteApp(app);
  }
}

if (require.main === module) {
  main().catch((error) => { console.error(error.message); process.exitCode = 1; });
}

module.exports = {main, protectedJson, writeJournal};
