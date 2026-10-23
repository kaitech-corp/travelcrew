const {test} = require("node:test");
const assert = require("node:assert/strict");
const {Timestamp} = require("firebase-admin/firestore");
const {travelDay, tripFeatures, fitsDates, preview} = require("../recommendations/features");
const {score} = require("../recommendations/scoring");
const {diversify} = require("../recommendations/diversity");
const {parse, preferencesSchema, feedSchema} = require("../recommendations/contracts");

const now = Date.parse("2026-10-18T12:00:00Z");
const trip = (patch = {}) => ({createdBy: "owner", isPrivate: false, destination: " Paris ", country: "France", continent: "Europe",
  tripStartDate: "2026-11-10", tripEndDate: "2026-11-14", favouriteCount: 0, ...patch});
const feature = (id, patch = {}) => tripFeatures(id, trip(patch));

test("travel days reject missing, malformed and rolling dates without manufacturing today", () => {
  for (const value of [null, undefined, "", "tomorrow", "2026-02-29", "2026-04-31", "2026-13-01", "2026-10-18T24:00:00", "2026-10-18T10:99:00"]) {
    assert.equal(travelDay(value), null, String(value));
  }
  assert.equal(travelDay("2024-02-29"), Date.UTC(2024, 1, 29));
  assert.equal(travelDay("2026-10-18T00:00:00.000"), Date.UTC(2026, 9, 18));
  assert.equal(travelDay("2026-10-18T23:30:00-07:00"), Date.UTC(2026, 9, 19));
  assert.equal(travelDay(Timestamp.fromMillis(now)), Date.UTC(2026, 9, 18));
});

test("feature extraction requires explicit public visibility, real dates, and available content", () => {
  for (const patch of [{isPrivate: true}, {isPrivate: undefined}, {moderationRemoved: true}, {tripStatus: "cancelled"},
    {tripStatus: "deleted"}, {tripStatus: "completed"}, {tripStartDate: ""}, {tripEndDate: "invalid"}, {tripEndDate: "2026-11-09"}]) {
    assert.equal(feature("trip", patch), null);
  }
  const normalized = feature("trip");
  assert.equal(normalized.destinationKey, "paris");
  assert.equal(normalized.publishedAt, null);
  assert.equal(feature("trip", {favouriteCount: 1000000}).popularity, 1000);
  assert.equal(feature("trip", {tripEndDate: undefined}).endDay.toMillis(), normalized.startDay.toMillis());
});

test("date filters enforce inclusive trip duration and explicit availability", () => {
  const f = feature("trip");
  assert.equal(fitsDates(f, {from: "2026-11-10", to: "2026-11-14", minDays: 5, maxDays: 5}, now), true);
  for (const filters of [{from: "2026-11-11"}, {to: "2026-11-13"}, {minDays: 6}, {maxDays: 4}]) assert.equal(fitsDates(f, filters, now), false);
  assert.equal(fitsDates(f, {}, Date.parse("2026-11-11T00:00:00Z")), false);
});

test("preference match beats unrelated popularity and social affinity raises relevant creators", () => {
  const profile = {destinations: ["paris"], following: ["friend"], history: []};
  const match = score(feature("match"), profile, now);
  const popular = score(feature("popular", {destination: "Tokyo", country: "Japan", favouriteCount: 1000000}), profile, now);
  const followed = score(feature("friend", {createdBy: "friend"}), profile, now);
  assert.ok(match.score > popular.score);
  assert.ok(followed.score > match.score);
  assert.equal(followed.reason, "followed_creator");
  assert.equal(match.reason, "preferred_destination");
});

test("cold start and missing publication time produce finite neutral scores", () => {
  const result = score(feature("new"), {}, now);
  assert.ok(Number.isFinite(result.score));
  assert.equal(result.components.freshness, 0.5);
  assert.ok(score(feature("popular", {favouriteCount: 10}), {}, now).score > result.score);
});

test("diversity limits creator repetition where alternatives exist and fills small inventories", () => {
  const candidates = Array.from({length: 30}, (_, i) => score(feature(`trip${i}`, {
    createdBy: i < 10 ? "repeated" : `creator${i}`, destination: i < 10 ? "Paris" : `Place ${i}`, favouriteCount: 100 - i,
  }), {}, now));
  const ranked = diversify(candidates, {seed: "session", pageSize: 20, explore: false});
  assert.equal(ranked.slice(0, 20).filter((item) => item.createdBy === "repeated").length, 2);
  assert.equal(new Set(ranked.map((item) => item.id)).size, 30);
  assert.deepEqual(diversify(candidates, {seed: "session"}), diversify(candidates, {seed: "session"}));
  assert.equal(diversify(candidates.slice(0, 8), {seed: "session"}).length, 8);
  assert.equal(diversify(candidates, {seed: "session"})[19].selection, "seeded_exploration_v1");
  assert.deepEqual(diversify([], {seed: "session"}), []);
});

test("safe previews exclude private itinerary, identity and expense fields", () => {
  const result = preview("trip", trip({email: "private@example.invalid", expenses: ["secret"], hotelName: "secret", joinedUsers: ["friend"],
    images: ["https://example.invalid/photo", "file:///private"]}), {displayName: "Owner", email: "hidden"});
  assert.equal(result.email, undefined); assert.equal(result.expenses, undefined); assert.equal(result.joinedUsers, undefined);
  assert.equal(result.hotelName, undefined); assert.equal(result.memberCount, 2);
  assert.deepEqual(result.images, ["https://example.invalid/photo"]);
});

test("contracts reject arbitrary fields, bad ranges and oversized pages", () => {
  assert.deepEqual(parse(preferencesSchema, {destinations: [" Paris ", "PARIS"]}), {destinations: ["paris"], filters: {}});
  for (const input of [{pageSize: 21}, {userId: "other"}, {filters: {from: "2026-02-30"}},
    {filters: {from: "2026-11-10", to: "2026-11-01"}}]) {
    assert.throws(() => parse(feedSchema, input), (e) => e.code === "invalid-argument");
  }
});
