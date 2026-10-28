"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {mkdtemp, writeFile, readFile, chmod, rm} = require("node:fs/promises");
const {tmpdir} = require("node:os");
const path = require("node:path");
const {createHash} = require("node:crypto");
const {main, protectedJson, writeJournal} = require("../photo-migration-apply-cli");

test("operational CLI requires reviewed identity and explicit write flags", async () => {
  const dir = await mkdtemp(path.join(tmpdir(), "photo-migration-cli-"));
  try {
    const body = {version: 1, project: "demo-project", database: "travel-crew-db-2",
      bucket: "demo-project.appspot.com", sources: []};
    const plan = {...body,
      planId: createHash("sha256").update(JSON.stringify(body)).digest("hex")};
    const planPath = path.join(dir, "plan.json");
    const journalPath = path.join(dir, "journal.json");
    await writeFile(planPath, JSON.stringify(plan), {mode: 0o600});
    const base = ["--project", body.project, "--database", body.database,
      "--bucket", body.bucket, "--plan", planPath, "--journal", journalPath,
      "--expected-plan-id", plan.planId];
    await assert.rejects(main([...base, "--mode", "stage"]), /--execute/);
    await assert.rejects(main([...base, "--mode", "stage", "--execute",
      "--expected-plan-id", "wrong"]), /plan ID/);
    await assert.rejects(main([...base, "--mode", "purge", "--execute"]), /--allow-delete/);
    await assert.rejects(main([...base, "--mode", "verify"]), /ENOENT/);
    await chmod(planPath, 0o644);
    await assert.rejects(protectedJson(planPath), /0600/);
    await chmod(planPath, 0o600);
    await writeJournal(journalPath, {planId: plan.planId, stage: {planId: plan.planId,
      staged: []}});
    assert.equal((await protectedJson(journalPath)).planId, plan.planId);
    await writeJournal(journalPath, {planId: "different"});
    assert.equal(JSON.parse(await readFile(journalPath, "utf8")).planId, "different");
    await assert.rejects(main([...base, "--mode", "verify"]), /another plan/);
  } finally {
    await rm(dir, {recursive: true, force: true});
  }
});
