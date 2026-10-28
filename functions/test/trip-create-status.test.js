const {test} = require("node:test");
const assert = require("node:assert/strict");
const {createTripStatusHandler} = require("../trip-create-status");

const id = "c26799c4-f72d-46e4-9984-8d6fb7377daa";
const request = (uid, tripId = id) => ({auth: uid ? {uid} : null, data: {tripId}});

test("trip creation status reveals only the caller's committed trip", async () => {
  const db = {doc: () => ({get: async () => ({exists: true,
    data: () => ({createdBy: "owner"})})})};
  const check = createTripStatusHandler(db);
  assert.deepEqual(await check(request("owner")), {exists: true});
  assert.deepEqual(await check(request("other")), {exists: false});
  await assert.rejects(check(request(null)), (error) => error.code === "unauthenticated");
  await assert.rejects(check(request("owner", "../../users/owner")),
      (error) => error.code === "invalid-argument");
  await assert.rejects(check({auth: {uid: "owner"}, data: {tripId: id, role: "admin"}}),
      (error) => error.code === "invalid-argument");
});

test("absent trip is false and backend failure is never treated as absence", async () => {
  const absent = createTripStatusHandler({doc: () => ({get: async () => ({exists: false})})});
  assert.deepEqual(await absent(request("owner")), {exists: false});
  const failed = createTripStatusHandler({doc: () => ({get: async () => {
    throw new Error("database unavailable");
  }})});
  await assert.rejects(failed(request("owner")), /database unavailable/);
});
