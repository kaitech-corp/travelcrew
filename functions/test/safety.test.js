const {test} = require("node:test");
const assert = require("node:assert/strict");
const vm = require("node:vm");
const fs = require("node:fs");
const path = require("node:path");

function fixture() {
  const records = new Map([
    ["publicProfile/alice", {displayName: "Alice", following: ["bob"], followers: ["bob"]}],
    ["publicProfile/bob", {displayName: "Bob", following: ["alice"], followers: ["alice"]}],
    ["trips/trip", {createdBy: "bob", joinedUsers: ["alice"], isShared: false, title: "Private trip"}],
    ["chat/trip", {usersIds: ["alice", "bob"]}],
    ["chat/trip/messages/message", {createdBy: "bob", data: "Reported text", messageType: "Text"}],
  ]);
  const value = (op, values) => ({op, values});
  const FieldValue = {
    serverTimestamp: () => value("time", []),
    arrayRemove: (...v) => value("remove", v),
    arrayUnion: (...v) => value("union", v),
    increment: (v) => value("increment", [v]),
  };
  let auto = 0;
  function write(key, data, merge = false) {
    const result = merge ? {...records.get(key)} : {};
    for (const [field, v] of Object.entries(data)) {
      if (v?.op === "time") result[field] = Date.now();
      else if (v?.op === "remove") result[field] = (result[field] || []).filter((x) => !v.values.includes(x));
      else if (v?.op === "union") result[field] = [...new Set([...(result[field] || []), ...v.values])];
      else if (v?.op === "increment") result[field] = (result[field] || 0) + v.values[0];
      else result[field] = v;
    }
    records.set(key, result);
  }
  const ref = (key) => ({path: key, id: key.split("/").at(-1),
    get: async () => ({exists: records.has(key), id: key.split("/").at(-1), ref: ref(key),
      data: () => records.get(key), updateTime: {toMillis: () => 123}}),
    collection: (name) => collection(`${key}/${name}`),
    delete: async () => records.delete(key),
  });
  const collection = (key) => ({doc: (id = `auto${auto++}`) => ref(`${key}/${id}`)});
  const db = {collection, runTransaction: async (fn) => {
    const pending = [];
    const tx = {get: (r) => { assert.equal(pending.length, 0, "all reads precede writes"); return r.get(); },
      set: (r, data) => pending.push(() => write(r.path, data)),
      create: (r, data) => pending.push(() => { assert.equal(records.has(r.path), false); write(r.path, data); }),
      update: (r, data) => pending.push(() => { assert.equal(records.has(r.path), true); write(r.path, data, true); }),
      delete: (r) => pending.push(() => records.delete(r.path)),
    };
    const result = await fn(tx); pending.forEach((fn) => fn()); return result;
  }};
  class HttpsError extends Error { constructor(code, message) { super(message); this.code = code; } }
  const context = {module: {exports: {}}, require: (name) => {
    if (name === "firebase-admin/firestore") return {FieldValue};
    if (name === "firebase-functions/v2/https") return {HttpsError};
    if (name === "./validation") return require("../validation");
    return require(name);
  }, Date};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../safety.js"), "utf8"), context);
  return {records, ...context.module.exports.createSafetyHandlers(db)};
}
const request = (data, uid = "alice", admin = false) => ({auth: {uid, token: {admin}}, data});
const report = (extra = {}) => request({targetType: "message", targetId: "message", roomId: "trip", reason: "harassment", details: "Please review", requestId: "request1", ...extra});
const rejectsCode = (promise, code) => assert.rejects(promise, (e) => e.code === code);

test("reports derive identity, author and bounded evidence; retries survive deletion", async () => {
  const f = fixture();
  const req = report({reporterId: "forged", targetUserId: "forged", status: "resolved", evidence: {data: "forged"}});
  const first = await f.submitReport(req);
  const saved = f.records.get(`reports/${first.reportId}`);
  assert.equal(saved.reporterId, "alice"); assert.equal(saved.targetUserId, "bob");
  assert.equal(saved.status, "open"); assert.equal(saved.evidence.data, "Reported text");
  f.records.delete("chat/trip/messages/message");
  assert.equal((await f.submitReport(req)).reportId, first.reportId);
  await rejectsCode(f.submitReport(report({details: "changed"})), "invalid-argument");
});
test("report access rejects strangers, missing targets, invalid input and self reports", async () => {
  const f = fixture();
  await rejectsCode(f.submitReport({data: report().data}), "unauthenticated");
  await rejectsCode(f.submitReport(request(report().data, "stranger")), "permission-denied");
  await rejectsCode(f.submitReport(report({details: "a".repeat(1001)})), "invalid-argument");
  await rejectsCode(f.submitReport(report({targetId: "x/y"})), "invalid-argument");
  await rejectsCode(f.submitReport(report({targetType: "user", targetId: "alice"})), "invalid-argument");
  await rejectsCode(f.submitReport(report({targetId: "missing"})), "not-found");
  await rejectsCode(f.submitReport(request({targetType: "trip", targetId: "trip", reason: "other", requestId: "r"}, "stranger")), "permission-denied");
});
test("open reports deduplicate, closed incidents can be reported again, and rate limits hold", async () => {
  const f = fixture(); const a = await f.submitReport(report());
  const b = await f.submitReport(report({requestId: "second", details: "More evidence"}));
  assert.equal(a.reportId, b.reportId);
  f.records.get(`reports/${a.reportId}`).status = "resolved";
  const c = await f.submitReport(report({requestId: "third"})); assert.notEqual(c.reportId, a.reportId);
  for (let i = 0; i < 7; i++) await f.submitReport(report({requestId: `extra${i}`}));
  await rejectsCode(f.submitReport(report({requestId: "limited"})), "resource-exhausted");
  assert.equal((await f.submitReport(report())).reportId, a.reportId);
});
test("blocking is private and idempotent, removes follows, and unblocking never restores them", async () => {
  const f = fixture(); const req = request({targetUserId: "bob"});
  await f.blockUser(req); await f.blockUser(req);
  assert.equal(f.records.has("users/alice/blockedUsers/bob"), true);
  assert.equal(f.records.get("publicProfile/alice").following.length, 0);
  assert.equal(f.records.get("publicProfile/bob").following.length, 0);
  await rejectsCode(f.followUser(request({targetUserId: "alice", following: true}, "bob")), "permission-denied");
  await rejectsCode(f.followUser(request({targetUserId: "bob", following: true})), "permission-denied");
  await f.unblockUser(req); await f.unblockUser(req);
  assert.equal(f.records.get("publicProfile/alice").following.length, 0);
  await f.followUser(request({targetUserId: "bob", following: true}));
  assert.equal(f.records.get("publicProfile/alice").following[0], "bob");
  await rejectsCode(f.blockUser(request({targetUserId: "alice"})), "invalid-argument");
});
test("join admission checks both block directions and preserves membership on rejection", async () => {
  for (const [a, b] of [["alice", "bob"], ["bob", "alice"]]) {
    const f = fixture(); f.records.set(`users/${a}/blockedUsers/${b}`, {});
    f.records.set("trips/trip/joinRequests/alice", {status: "pending"});
    await rejectsCode(f.acceptJoinRequest(request({tripId: "trip", userId: "alice"}, "bob")), "permission-denied");
    assert.equal(f.records.get("trips/trip/joinRequests/alice").status, "pending");
  }
});
test("moderators remove messages with an audit trail; users cannot review reports", async () => {
  const f = fixture(); const {reportId} = await f.submitReport(report());
  const data = {reportId, action: "remove", rationale: "Violates community policy"};
  await rejectsCode(f.reviewReport(request(data)), "permission-denied");
  await f.reviewReport(request(data, "moderator", true));
  assert.equal(f.records.get("chat/trip/messages/message").moderationRemoved, true);
  assert.equal(f.records.get("chat/trip/messages/message").data, "");
  assert.equal(f.records.get(`reports/${reportId}`).status, "resolved");
  assert.equal([...f.records.keys()].some((k) => k.startsWith(`reports/${reportId}/audit/`)), true);
});
test("restriction is server controlled and prevents an already authenticated user's interactions", async () => {
  const f = fixture(); const {reportId} = await f.submitReport(report());
  await f.reviewReport(request({reportId, action: "restrict", rationale: "Repeated abuse"}, "moderator", true));
  await rejectsCode(f.followUser(request({targetUserId: "alice", following: true}, "bob")), "permission-denied");
});
