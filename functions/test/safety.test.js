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
  let safetyModule;
  const context = {module: {exports: {}}, require: (name) => {
    if (name === "firebase-admin/firestore") return {FieldValue};
    if (name === "firebase-functions/v2/https") return {HttpsError};
    if (name === "./notification-data") return require("../notification-data");
    if (name === "./safety") return safetyModule;
    if (name === "./validation") return require("../validation");
    return require(name);
  }, Date};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../safety.js"), "utf8"), context);
  safetyModule = context.module.exports;
  const handlers = safetyModule.createSafetyHandlers(db);
  context.module = {exports: {}};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../trip-actions.js"), "utf8"), {...context});
  const trips = context.module.exports.createTripActions(db);
  return {records, ...handlers, ...trips,
    acceptJoinRequest: (request) => trips.transition({...request, data: {...request.data, attemptId: "legacy"}}, "accepted")};
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

const inbox = (f, uid) => [...f.records.entries()].filter(([key]) => key.startsWith(`notifications/${uid}/notification/`)).map(([, value]) => value);
function joinFixture() {
  const f = fixture();
  f.records.get("trips/trip").joinedUsers = [];
  f.records.get("trips/trip").isShared = true;
  f.records.set("tripDiscovery/trip", {isDiscoverable: true, memberCount: 1});
  return f;
}
test("cancel, re-request and stale retries keep distinct attempts and preserve creation date", async () => {
  const f = joinFixture();
  const first = request({tripId: "trip", attemptId: "one"});
  await f.requestJoin(first); await f.requestJoin(first);
  const concurrent = request({tripId: "trip", attemptId: "concurrent"});
  await f.requestJoin(concurrent);
  assert.equal(inbox(f, "bob").length, 1);
  const createdAt = f.records.get("trips/trip/joinRequests/alice").createdAt;
  await f.transition(first, "cancelled");
  assert.equal((await f.requestJoin(concurrent)).status, "cancelled");
  assert.equal(inbox(f, "bob")[0].requestStatus, "cancelled");
  assert.equal(inbox(f, "bob")[0].pushEnabled, false);
  await f.requestJoin(request({tripId: "trip", attemptId: "two"}));
  assert.equal(inbox(f, "bob").length, 2);
  assert.equal(f.records.get("trips/trip/joinRequests/alice").createdAt, createdAt);
  await f.requestJoin(first);
  assert.equal(f.records.get("trips/trip/joinRequests/alice").attemptId, "two");
  await rejectsCode(f.transition(first, "cancelled"), "failed-precondition");
});
test("acceptance is owner-only, atomically creates membership/chat and one recipient event", async () => {
  const f = joinFixture();
  await f.requestJoin(request({tripId: "trip", attemptId: "one"}));
  const action = request({tripId: "trip", userId: "alice", attemptId: "one"}, "bob");
  await rejectsCode(f.transition({...action, auth: {uid: "stranger"}}, "accepted"), "permission-denied");
  await f.transition(action, "accepted"); await f.transition(action, "accepted");
  assert.equal(f.records.get("trips/trip/members/alice").status, "active");
  assert.equal(f.records.get("tripDiscovery/trip").memberCount, 2);
  assert.ok(f.records.get("chat/trip").usersIds.includes("alice"));
  assert.equal(inbox(f, "alice").length, 1);
  assert.equal(inbox(f, "alice")[0].pushEnabled, true);
  await rejectsCode(f.transition(request({tripId: "trip", attemptId: "one"}), "cancelled"), "failed-precondition");
  await f.leave(request({tripId: "trip", membershipAttemptId: "one"})); await f.leave(request({tripId: "trip", membershipAttemptId: "one"}));
  assert.equal(f.records.get("tripDiscovery/trip").memberCount, 1);
  assert.equal(f.records.get("chat/trip").usersIds.includes("alice"), false);
  assert.equal(inbox(f, "bob").filter((n) => n.eventType === "member_left").length, 1);
  await f.requestJoin(request({tripId: "trip", attemptId: "two"}));
  await f.transition(request({...action.data, attemptId: "two"}, "bob"), "accepted");
  await rejectsCode(f.leave(request({tripId: "trip", membershipAttemptId: "one"})), "failed-precondition");
  await f.leave(request({tripId: "trip", membershipAttemptId: "two"}));
  assert.equal(inbox(f, "bob").filter((n) => n.eventType === "member_left").length, 2);
});
test("decline is in-app only and a new request is allowed; cancelled attempts cannot be accepted", async () => {
  const f = joinFixture();
  const req = request({tripId: "trip", attemptId: "one"});
  await f.requestJoin(req);
  await f.transition(request({...req.data, userId: "alice"}, "bob"), "rejected");
  assert.equal(inbox(f, "alice")[0].pushEnabled, false);
  await f.requestJoin(request({...req.data, attemptId: "two"}));
  await f.transition(request({...req.data, attemptId: "two"}), "cancelled");
  await rejectsCode(f.transition(request({tripId: "trip", userId: "alice", attemptId: "two"}, "bob"), "accepted"), "failed-precondition");
});
test("join request rejects blocked/restricted users, unavailable trips and existing members", async () => {
  for (const reason of ["block", "reverse", "restricted", "private", "deleted", "member", "removed"]) {
    const f = joinFixture();
    if (reason === "block") f.records.set("users/alice/blockedUsers/bob", {});
    if (reason === "reverse") f.records.set("users/bob/blockedUsers/alice", {});
    if (reason === "restricted") f.records.set("safetyAccounts/alice", {restricted: true});
    if (reason === "private") { f.records.get("trips/trip").isShared = false; f.records.delete("tripDiscovery/trip"); }
    if (reason === "deleted") f.records.get("trips/trip").tripStatus = "deleted";
    if (reason === "removed") f.records.get("trips/trip").moderationRemoved = true;
    if (reason === "member") f.records.get("trips/trip").joinedUsers = ["alice"];
    await assert.rejects(f.requestJoin(request({tripId: "trip", attemptId: "one"})));
    assert.equal(inbox(f, "bob").length, 0);
  }
});
test("follow emits once per actual follow transition; unfollow and block stay silent", async () => {
  const f = fixture();
  const follow = request({targetUserId: "bob", following: true});
  await f.followUser(follow); assert.equal(inbox(f, "bob").length, 0);
  await f.followUser(request({...follow.data, following: false}));
  await f.followUser(follow); await f.followUser(follow);
  assert.equal(inbox(f, "bob").length, 1);
  assert.equal(inbox(f, "bob")[0].pushEnabled, false);
  await f.followUser(request({...follow.data, following: false}));
  await f.followUser(follow); assert.equal(inbox(f, "bob").length, 2);
});
