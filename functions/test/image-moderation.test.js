const {test} = require("node:test");
const assert = require("node:assert/strict");
const {imageTargets, visionUri, createVisionScanner, createImageModerator} = require("../image-moderation");

const bad = "https://firebasestorage.googleapis.com/v0/b/app.appspot.com/o/trips%2Fbad.jpg?alt=media&token=secret";
const good = "https://example.com/good.jpg";
const snap = (data, ref) => ({exists: data !== null, data: () => data, ref});
function fixture(data, options = {}) {
  const state = {data, updates: [], scans: [], logs: []};
  const ref = {path: "trips/trip", get: async () => snap(state.data, ref)};
  const db = {runTransaction: async (fn) => fn({
    get: async () => snap(state.data, ref),
    update: (_, patch) => {
      state.updates.push(patch);
      state.data = {...state.data, ...patch};
    },
  })};
  const handler = createImageModerator({
    db, fields: ["profileImage", "creatorProfileImage"], arrays: ["images"],
    bucket: () => "app.appspot.com",
    scan: async (uri) => {
      state.scans.push(uri);
      if (options.duringScan) options.duringScan(state);
      if (options.error || options.failUri === uri) throw new Error("provider error containing token=secret");
      return options.flagged ?? uri.includes("bad.jpg");
    },
    logger: {
      warn: (...args) => state.logs.push(args),
      error: (...args) => state.logs.push(args),
    },
  });
  state.run = (after = data, before = null) => handler({
    id: "event-1", data: {after: snap(after, ref), before: snap(before, ref)},
  });
  return state;
}

test("explicit registrations cover profile documents, trips, and discovery copies", () => {
  assert.deepEqual(Object.values(imageTargets), [
    ["users/{userId}", ["profileImage"], []],
    ["publicProfile/{userId}", ["profileImage"], []],
    ["userPublicProfile/{userId}", ["profileImage"], []],
    ["trips/{tripId}", [], ["images"]],
    ["tripDiscovery/{tripId}", ["creatorProfileImage"], ["images"]],
  ]);
});

test("owned Firebase URLs use token-free storage URIs; public HTTPS photos are supported", () => {
  assert.equal(visionUri(bad, "app.appspot.com"), "gs://app.appspot.com/trips/bad.jpg");
  assert.equal(visionUri(good, "app.appspot.com"), good);
  assert.equal(visionUri("gs://app.appspot.com/photo.jpg", "app.appspot.com"), "gs://app.appspot.com/photo.jpg");
  for (const url of ["", "asset.png", "file:///tmp/a", "http://example.com/a", "https://user:pass@example.com/a", "gs://other/a"]) {
    assert.equal(visionUri(url, "app.appspot.com"), null);
  }
});

test("only adult VERY_LIKELY is flagged, not LIKELY or racy/violence", async () => {
  for (const adult of ["VERY_UNLIKELY", "UNLIKELY", "POSSIBLE", "LIKELY", "VERY_LIKELY"]) {
    const scan = createVisionScanner(async () => ({access_token: "server-token"}), async (url, request) => {
      assert.equal(url, "https://vision.googleapis.com/v1/images:annotate");
      assert.equal(request.headers.Authorization, "Bearer server-token");
      assert.deepEqual(JSON.parse(request.body).requests, [{
        image: {source: {imageUri: good}}, features: [{type: "SAFE_SEARCH_DETECTION"}],
      }]);
      return {ok: true, json: async () => ({responses: [{
        safeSearchAnnotation: {adult, racy: "VERY_LIKELY", violence: "VERY_LIKELY"},
      }]})};
    });
    assert.equal(await scan(good), adult === "VERY_LIKELY");
  }
});

test("failed, empty, and unknown verdicts retry without exposing provider errors", async () => {
  const responses = [
    {ok: false},
    {ok: true, json: async () => ({responses: [{error: {message: bad}}]})},
    {ok: true, json: async () => ({responses: []})},
    {ok: true, json: async () => ({responses: [{safeSearchAnnotation: {adult: "UNKNOWN"}}]})},
  ];
  for (const response of responses) {
    const scan = createVisionScanner(async () => ({access_token: "token"}), async () => response);
    await assert.rejects(scan(bad), {message: "Image moderation scan failed; image reference retained for retry."});
  }
});

test("flagged URLs are cleared from scalar fields and removed from arrays, preserving other data", async () => {
  const f = fixture({profileImage: bad, creatorProfileImage: bad, images: [bad, good, bad],
    tripStatus: "upcoming", joinedUsers: ["member"], title: "Trip"});
  await f.run();
  assert.deepEqual(f.data, {profileImage: "", creatorProfileImage: "", images: [good],
    tripStatus: "upcoming", joinedUsers: ["member"], title: "Trip"});
  assert.equal(f.updates.length, 1);
  assert.equal(f.scans.length, 2);
  assert.equal(f.logs[0][0], "image_moderation_flagged");
  assert.equal(f.logs[0][1].likelihood, "VERY_LIKELY");
  assert.ok(!JSON.stringify(f.logs).includes("secret"));
  assert.ok(!JSON.stringify(f.logs).includes(bad));
});

test("clean, unchanged, self-generated, and repeated removed-image events do not write", async () => {
  const f = fixture({images: [bad]});
  await f.run();
  await f.run();
  await f.run(f.data, {images: [bad]});
  assert.equal(f.scans.length, 1);
  assert.equal(f.updates.length, 1);
  const clean = fixture({profileImage: good});
  await clean.run();
  await clean.run({profileImage: good, title: "changed"}, {profileImage: good});
  assert.equal(clean.scans.length, 1);
  assert.equal(clean.updates.length, 0);
});

test("stale events and edits during scanning preserve replacement images", async () => {
  const f = fixture({images: [good]});
  await f.run({images: [bad]});
  assert.equal(f.scans.length, 0);
  const race = fixture({images: [bad]}, {
    duringScan: (state) => { state.data = {images: [good], title: "New title"}; },
  });
  await race.run();
  assert.deepEqual(race.data, {images: [good], title: "New title"});
  assert.equal(race.updates.length, 0);
});

test("deleted documents and soft-deleted trips are never recreated or modified", async () => {
  for (const data of [null, {images: [bad], tripStatus: "deleted"}]) {
    const f = fixture(data);
    await f.run();
    await f.run({images: [bad]});
    assert.equal(f.scans.length, 0);
    assert.equal(f.updates.length, 0);
  }
  const f = fixture({images: [bad]}, {duringScan: (state) => { state.data = null; }});
  await f.run();
  assert.equal(f.updates.length, 0);
});

test("scanner failure keeps the URL and logs no secrets", async () => {
  const f = fixture({images: [bad]}, {error: true});
  await assert.rejects(f.run(), {message: "Image moderation scan failed; retry required."});
  assert.deepEqual(f.data.images, [bad]);
  assert.equal(f.updates.length, 0);
  assert.equal(f.logs[0][0], "image_moderation_scan_failed");
  assert.ok(!JSON.stringify(f.logs).includes("secret"));
});

test("one inaccessible image does not prevent other images from being moderated", async () => {
  const f = fixture({images: [good, bad]}, {failUri: good});
  await assert.rejects(f.run());
  assert.deepEqual(f.data.images, [good]);
  assert.equal(f.scans.length, 2);
});
