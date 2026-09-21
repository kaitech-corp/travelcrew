const {test} = require("node:test");
const assert = require("node:assert/strict");
const {moderateText, buildPatch, createModerator, profileFields,
  tripFields, discoveryFields} = require("../moderation");

test("moderation masks profanity and leaves empty, multilingual and non-text values intact", () => {
  assert.equal(moderateText("A fucking trip"), "A ******* trip");
  for (const value of [undefined, null, 3, false, "", "   ", "!!!", "東京 🗼", "Viaje a España", "Hello\n  friends"]) {
    assert.equal(moderateText(value), value);
  }
});

test("all profile fields and destination entries are moderated in one patch", () => {
  const data = {displayName: "fuck", hometown: "shit", firstName: null,
    topDestinations: ["Paris", "fuck", null],
    instagramLink: "https://instagram.com/fuck", email: "fuck@example.com",
    uid: "fuck", followers: ["fuck"]};
  assert.deepEqual(buildPatch(data, profileFields, ["topDestinations"]), {
    displayName: "****", hometown: "****", topDestinations: ["Paris", "****", null],
  });
});

test("current and legacy trip fields are covered without changing operational fields", () => {
  const data = Object.fromEntries(tripFields.map((name) => [name, "fuck"]));
  Object.assign(data, {tripStatus: "upcoming", createdBy: "fuck", images: ["fuck"], latitude: 5});
  const patch = buildPatch(data, tripFields);
  assert.equal(Object.keys(patch).length, tripFields.length);
  for (const field of tripFields) assert.equal(patch[field], "****");
  assert.equal(patch.tripStatus, undefined);
  assert.deepEqual(buildPatch({}, tripFields), {});
  assert.deepEqual(buildPatch({title: "fuck", creatorDisplayName: "shit"}, discoveryFields),
      {title: "****", creatorDisplayName: "****"});
});

function fixture(current) {
  const state = {current, updates: [], reads: 0};
  const db = {runTransaction: async (fn) => fn({
    get: async () => {
      state.reads++;
      return {exists: state.current !== null, data: () => state.current};
    },
    update: (ref, patch) => {
      state.updates.push(patch);
      state.current = {...state.current, ...patch};
    },
  })};
  state.run = createModerator(db, tripFields);
  return state;
}
const event = (data) => ({data: {after: {
  exists: data !== null, data: () => data, ref: {path: "trips/trip"},
}}});

test("repeated and self-generated events stop without another write", async () => {
  const f = fixture({title: "fuck", comment: "shit", joinedUsers: ["member"]});
  const original = event(f.current);
  await f.run(original);
  await f.run(original);
  await f.run(event(f.current));
  assert.equal(f.updates.length, 1);
  assert.deepEqual(f.current.joinedUsers, ["member"]);
  assert.deepEqual(f.updates[0], {title: "****", comment: "****"});
});

test("stale events never overwrite a newer edit", async () => {
  const f = fixture({title: "New clean title"});
  await f.run(event({title: "fuck"}));
  assert.equal(f.updates.length, 0);
  assert.equal(f.current.title, "New clean title");
  f.current = {title: "New shit title"};
  await f.run(event({title: "fuck"}));
  assert.equal(f.current.title, "New **** title");
});

test("deletion and soft deletion never recreate or change trips", async () => {
  for (const current of [null, {title: "fuck", tripStatus: "deleted"}]) {
    const f = fixture(current);
    await f.run(event({title: "fuck"}));
    await f.run(event(null));
    await f.run({});
    assert.equal(f.updates.length, 0);
  }
});

test("clean writes do not open transactions", async () => {
  const f = fixture({title: "Paris", favouriteCount: 2});
  await f.run(event(f.current));
  assert.equal(f.reads, 0);
});

test("database failures propagate so Firebase can retry", async () => {
  const run = createModerator({runTransaction: async () => {
    throw new Error("unavailable");
  }}, tripFields);
  await assert.rejects(run(event({title: "fuck"})), /unavailable/);
});
