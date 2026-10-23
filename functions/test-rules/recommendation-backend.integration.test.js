const {before, beforeEach, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {createRecommendationHandlers} = require("../recommendations");
const {maintainTripFeature} = require("../recommendations/features");
const {ReadContext, loadProfile} = require("../recommendations/candidates");
const {decodeCursor, newSession, cursorFor} = require("../recommendations/sessions");
const {hash, attributionRef, readAttribution} = require("../recommendations/events");
const {createTripActions} = require("../trip-actions");
const {createTripInvitations} = require("../trip-invitations");
const {cleanBlockedPair} = require("../safety-triggers");
const {main: auditMain} = require("../recommendations/audit");
const {mkdtemp, readFile, stat, rm} = require("node:fs/promises");
const {tmpdir} = require("node:os");
const {join} = require("node:path");
const {auditFeaturePage, cleanRecommendationData, expireRecommendations} = require("../recommendations/maintenance");

let app; let db; let auth; let handlers; let now;
const start = Date.parse("2026-10-18T12:00:00Z");
const request = (data = {}, uid = "rec-viewer") => ({auth: {uid}, data});
const collections = ["users", "publicProfile", "safetyAccounts", "trips", "tripDiscovery", "recommendationConfig", "recommendationTripFeatures",
  "recommendationSessions", "recommendationEvents", "recommendationLastImpressions", "recommendationAttributions", "recommendationQuotas", "notifications", "joinAttempts"];

before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) throw new Error("Auth and Firestore emulators required.");
  app = initializeApp({projectId: "demo-travelcrew-reco-backend"}, "recommendation-backend");
  db = getFirestore(app, "travel-crew-db-2"); auth = getAuth(app);
  for (const uid of ["rec-viewer", "rec-other", "rec-a", "rec-b", "rec-disabled"]) {
    try { await auth.createUser({uid, disabled: uid === "rec-disabled"}); } catch (error) { if (error.code !== "auth/uid-already-exists") throw error; }
  }
});
beforeEach(async () => {
  now = start;
  for (const name of collections) await db.recursiveDelete(db.collection(name));
  for (const uid of ["rec-viewer", "rec-other", "rec-a", "rec-b", "rec-disabled"]) {
    await db.doc(`users/${uid}`).set({isDeleted: false, favouriteTrips: []});
    await db.doc(`publicProfile/${uid}`).set({displayName: uid, following: []});
  }
  await db.doc("recommendationConfig/current").set({enabled: true, percent: 100, experiment: "test-v1"});
  for (let i = 0; i < 8; i++) await seed(`rec-trip-${i}`, {createdBy: i % 2 ? "rec-b" : "rec-a", destination: i % 2 ? "Tokyo" : "Paris", country: i % 2 ? "Japan" : "France", continent: i % 2 ? "Asia" : "Europe"});
  handlers = createRecommendationHandlers(db, auth, {clock: () => now});
});
after(async () => { if (app) { await db.terminate(); await deleteApp(app); } });

async function seed(id, patch = {}) {
  await db.doc(`trips/${id}`).set({id, createdBy: "rec-a", destination: "Paris", country: "France", continent: "Europe", isPrivate: false,
    isShared: false, tripStartDate: "2026-11-10", tripEndDate: "2026-11-14", favouriteCount: 0, joinedUsers: [], ...patch});
  await db.doc(`tripDiscovery/${id}`).set({id, createdBy: patch.createdBy || "rec-a", isDiscoverable: true, favouriteCount: 0});
  await maintainTripFeature(db, id, {now});
}
const code = (expected) => (error) => error.code === expected;
const impression = (page, index = 0, eventId = "event-one") => ({eventId, type: "impression", tripId: page.items[index].id,
  sessionId: page.sessionId, position: page.items[index].recommendation.position});

test("named database feed ranks preferences, preserves order and binds cursors to the viewer", async () => {
  await handlers.preferences(request({destinations: ["Paris"]}));
  const first = await handlers.feed(request({pageSize: 3}));
  assert.equal(first.algorithmVersion, "weighted-v1"); assert.equal(first.items[0].destination, "Paris");
  assert.equal(first.items.length, 3); assert.ok(first.nextCursor);
  const second = await handlers.feed(request({pageSize: 3, cursor: first.nextCursor}));
  assert.equal(new Set([...first.items, ...second.items].map((trip) => trip.id)).size, 6);
  await assert.rejects(handlers.feed(request({pageSize: 3, cursor: first.nextCursor}, "rec-other")), code("permission-denied"));
  const decoded = decodeCursor(first.nextCursor);
  const tampered = Buffer.from(JSON.stringify({sessionId: decoded.sessionId, offset: 7})).toString("base64url") + "." + decoded.signature;
  await assert.rejects(handlers.feed(request({pageSize: 3, cursor: tampered})), code("invalid-argument"));
  const session = (await db.doc(`recommendationSessions/${first.sessionId}`).get()).data();
  assert.deepEqual([...first.items, ...second.items].map((item) => item.id), session.ranked.slice(0, 6).map((item) => item.id));
});

test("authoritative eligibility excludes private share links, unavailable dates and disabled creators", async () => {
  await seed("bad-private", {isPrivate: true, isShared: true});
  await seed("bad-ended", {tripStartDate: "2026-10-01", tripEndDate: "2026-10-20"});
  await seed("bad-cancelled", {tripStatus: "cancelled"});
  await seed("bad-removed", {moderationRemoved: true});
  await seed("bad-date", {tripStartDate: "invalid"});
  await seed("bad-member", {joinedUsers: ["rec-viewer"]});
  await seed("bad-disabled", {createdBy: "rec-disabled"});
  await seed("bad-owner", {createdBy: "rec-viewer"});
  const page = await handlers.feed(request());
  assert.equal(page.items.length, 8);
  assert.equal(page.items.some((item) => item.id.startsWith("bad-")), false);
});

test("privacy, reverse blocks and restrictions are rechecked after session creation", async () => {
  const page = await handlers.feed(request({pageSize: 2}));
  const session = (await db.doc(`recommendationSessions/${page.sessionId}`).get()).data();
  await db.doc(`trips/${session.ranked[2].id}`).update({isPrivate: true});
  await db.doc("users/rec-a/blockedUsers/rec-viewer").set({});
  const next = await handlers.feed(request({pageSize: 2, cursor: page.nextCursor}));
  assert.equal(next.items.some((item) => item.createdBy === "rec-a" || item.id === session.ranked[2].id), false);
  await db.doc("safetyAccounts/rec-b").set({restricted: true});
  const refreshed = await handlers.feed(request());
  assert.deepEqual(refreshed.items, []);
});

test("stale favorites and membership indexes do not restore private history access", async () => {
  await seed("rec-private", {isPrivate: true, destination: "Secret", isShared: false});
  await db.doc("users/rec-viewer").update({favouriteTrips: ["rec-private", "missing", "rec-trip-0"]});
  await db.doc("users/rec-viewer/tripMemberships/rec-private").set({status: "active", joinedAt: Timestamp.fromMillis(now)});
  const ctx = new ReadContext(db, auth, now);
  const profile = await loadProfile(ctx, "rec-viewer");
  assert.deepEqual(profile.history.map((item) => item.tripId), ["rec-trip-0"]);
});

test("feedback deduplicates impressions and rejects forged outcomes and unserved positions", async () => {
  const page = await handlers.feed(request({pageSize: 2}));
  const event = impression(page);
  const first = await handlers.events(request({events: [event]}));
  assert.equal(first.results[0].status, "accepted");
  const second = await handlers.events(request({events: [{...event, eventId: "new-retry-id"}, {...event, type: "accepted"}, {...event, eventId: "forged", position: 199, type: "open"}]}));
  assert.deepEqual(second.results.map((result) => result.status), ["duplicate", "invalid", "invalid"]);
  const stranger = await handlers.events(request({events: [event]}, "rec-other"));
  assert.equal(stranger.results[0].status, "invalid");
  const records = await db.collection("recommendationEvents").where("type", "==", "impression").get();
  assert.equal(records.size, 1);
  const record = records.docs[0].data();
  assert.equal(record.observation, "client"); assert.equal(record.featureSnapshot.id, event.tripId);
});

test("join outcomes are transactionally attributed after session expiry and retries stay idempotent", async () => {
  const page = await handlers.feed(request());
  const event = impression(page); await handlers.events(request({events: [event]}));
  // Attribution uses server wall time in the production join transaction.
  const realNow = Date.now();
  await db.doc(`recommendationEvents/${hash("rec-viewer", page.sessionId, event.tripId, "impression")}`).update({createdAt: Timestamp.fromMillis(realNow), occurredAt: Timestamp.fromMillis(realNow)});
  const actions = createTripActions(db); const attemptId = "rec-attempt";
  await actions.requestJoin(request({tripId: event.tripId, attemptId}));
  await actions.requestJoin(request({tripId: event.tripId, attemptId}));
  await db.doc(`recommendationSessions/${page.sessionId}`).delete();
  const owner = page.items[0].createdBy;
  await actions.transition(request({tripId: event.tripId, userId: "rec-viewer", attemptId}, owner), "accepted");
  await actions.transition(request({tripId: event.tripId, userId: "rec-viewer", attemptId}, owner), "accepted");
  const ref = attributionRef(db, "rec-viewer", event.tripId, attemptId);
  assert.equal((await ref.get()).data().outcome, "accepted");
  assert.equal((await db.collection("recommendationEvents").where("type", "==", "join_accepted").get()).size, 1);
  await actions.leave(request({tripId: event.tripId, membershipAttemptId: attemptId}));
  const left = (await ref.get()).data();
  assert.equal(left.outcome, "left"); assert.ok(left.acceptedAt); assert.ok(left.leftAt);
});

test("preference changes, expired sessions and rollout rollback require an explicit refresh", async () => {
  let page = await handlers.feed(request({pageSize: 2}));
  await handlers.preferences(request({destinations: ["Tokyo"]}));
  await assert.rejects(handlers.feed(request({pageSize: 2, cursor: page.nextCursor})), code("failed-precondition"));
  page = await handlers.feed(request({pageSize: 2}));
  now += 31 * 60000;
  await assert.rejects(handlers.feed(request({pageSize: 2, cursor: page.nextCursor})), code("failed-precondition"));
  page = await handlers.feed(request({pageSize: 2}));
  await db.doc("recommendationConfig/current").set({enabled: false});
  await assert.rejects(handlers.feed(request({pageSize: 2, cursor: page.nextCursor})), code("failed-precondition"));
  assert.equal((await handlers.feed(request())).algorithmVersion, "upcoming-v1");
});

test("dismiss and undo suppress only the viewer's recommendations", async () => {
  const page = await handlers.feed(request()); const tripId = page.items[0].id;
  await handlers.dismiss(request({tripId, dismissed: true}));
  assert.equal((await handlers.feed(request())).items.some((item) => item.id === tripId), false);
  assert.equal((await handlers.feed(request({}, "rec-other"))).items.some((item) => item.id === tripId), true);
  await handlers.dismiss(request({tripId, dismissed: false}));
  assert.equal((await handlers.feed(request())).items.some((item) => item.id === tripId), true);
});

test("feature maintenance is idempotent, follows current privacy, and backfill supports checkpoints", async () => {
  assert.equal(await maintainTripFeature(db, "rec-trip-0", {now}), "unchanged");
  const audit = await auditFeaturePage(db, {limit: 3});
  assert.equal(audit.counts.scanned, 3); assert.ok(audit.nextAfter);
  assert.equal(audit.counts.discoverableListings, 3); assert.equal(audit.counts.missingCountry, 0);
  const next = await auditFeaturePage(db, {after: audit.nextAfter, limit: 3, apply: true});
  assert.equal(next.counts.scanned, 3);
  await db.doc("trips/rec-trip-0").update({isPrivate: true});
  await maintainTripFeature(db, "rec-trip-0", {newPublication: true, now});
  assert.equal((await db.doc("recommendationTripFeatures/rec-trip-0").get()).exists, false);
});

test("expiry and account cleanup remove private recommendation records", async () => {
  const page = await handlers.feed(request()); await handlers.events(request({events: [impression(page)]}));
  const counts = await expireRecommendations(db, now + 31 * 60000);
  assert.equal(counts.recommendationSessions, 1);
  assert.equal(counts.recommendationEvents, 0);
  await cleanRecommendationData(db, "rec-viewer");
  assert.equal((await db.collection("recommendationEvents").where("uid", "==", "rec-viewer").get()).size, 0);
  assert.equal((await db.doc("users/rec-viewer/recommendationProfile/current").get()).exists, false);
});

test("control preserves continent selection and shadow evaluates the full treatment pools", async () => {
  await db.doc("users/rec-viewer").update({favouriteTrips: ["rec-trip-0"]});
  await db.doc("recommendationConfig/current").set({enabled: true, percent: 0, experiment: "control-test", shadow: true});
  const logs = [];
  const handler = createRecommendationHandlers(db, auth, {clock: () => now, log: (name, data) => logs.push({name, ...data})});
  const page = await handler.feed(request());
  assert.equal(page.algorithmVersion, "legacy-continent-v1");
  assert.equal(page.items.length, 4); assert.ok(page.items.every((item) => item.continent === "Europe"));
  const shadow = logs.find((entry) => entry.name === "recommendation_shadow");
  assert.equal(shadow.eligible, 8); assert.equal(shadow.overlapAt20, 4);
  const sessions = await db.collection("recommendationEvents").where("type", "==", "feed_session").get();
  assert.equal(sessions.size, 1); assert.equal(sessions.docs[0].data().algorithmVersion, page.algorithmVersion);
  assert.equal((await db.doc("users/rec-viewer/recommendationProfile/current").get()).data().history, undefined);
});

test("concurrent cursor retries preserve order and feedback remains idempotent", async () => {
  const page = await handlers.feed(request({pageSize: 2}));
  const pages = await Promise.all([handlers.feed(request({pageSize: 2, cursor: page.nextCursor})), handlers.feed(request({pageSize: 2, cursor: page.nextCursor}))]);
  assert.deepEqual(pages[0], pages[1]);
  const event = impression(pages[0]);
  const results = await Promise.all([handlers.events(request({events: [event]})), handlers.events(request({events: [event]}))]);
  assert.deepEqual(results.map((result) => result.results[0].status).sort(), ["accepted", "duplicate"]);
  const before = (await db.doc(`recommendationEvents/${hash("rec-viewer", event.sessionId, event.tripId, "impression")}`).get()).data();
  await db.doc(`trips/${event.tripId}`).update({destination: "Changed", isPrivate: true});
  const replay = await handlers.feed(request({pageSize: 2, cursor: page.nextCursor}));
  assert.equal(replay.items.some((trip) => trip.id === event.tripId), false);
  const after = (await db.doc(`recommendationEvents/${hash("rec-viewer", event.sessionId, event.tripId, "impression")}`).get()).data();
  assert.deepEqual(after.featureSnapshot, before.featureSnapshot);
});

test("out-of-order observations cannot replace the newest impression and attribution expires at seven days", async () => {
  const first = await handlers.feed(request());
  const tripId = first.items[0].id;
  now += 60000;
  const second = await handlers.feed(request());
  const secondIndex = second.items.findIndex((item) => item.id === tripId);
  const recent = {...impression(second, secondIndex, "recent"), occurredAt: now};
  await handlers.events(request({events: [recent]}));
  now += 60000;
  await handlers.events(request({events: [{...impression(first, 0, "delayed"), occurredAt: start}]}));
  const read = () => db.runTransaction((tx) => readAttribution(db, tx, "rec-viewer", tripId, {sessionId: first.sessionId}, now));
  assert.equal((await read()).sessionId, second.sessionId);
  now += 7 * 86400000;
  assert.equal(await read(), null);
});

test("block cancellation and invitation supersession resolve attributed pending requests", async () => {
  const actions = createTripActions(db);
  const prepare = async (tripId, attemptId) => {
    const page = await handlers.feed(request()); const i = page.items.findIndex((item) => item.id === tripId);
    const event = impression(page, i, attemptId); await handlers.events(request({events: [event]}));
    await db.doc(`recommendationEvents/${hash("rec-viewer", page.sessionId, tripId, "impression")}`)
        .update({occurredAt: Timestamp.now()});
    await actions.requestJoin(request({tripId, attemptId}));
    return attributionRef(db, "rec-viewer", tripId, attemptId);
  };
  const blocked = await prepare("rec-trip-0", "blocked-attempt");
  await db.doc("users/rec-a/blockedUsers/rec-viewer").set({});
  await cleanBlockedPair(db, "rec-a", "rec-viewer"); await cleanBlockedPair(db, "rec-a", "rec-viewer");
  assert.equal((await blocked.get()).data().outcome, "cancelled");
  const invited = await prepare("rec-trip-1", "invite-attempt");
  const invitations = createTripInvitations(db, auth);
  await invitations.send(request({tripId: "rec-trip-1", userId: "rec-viewer", requestId: "invite-one"}, "rec-b"));
  await invitations.respond(request({tripId: "rec-trip-1", invitationId: "invite-one", accept: true}));
  assert.equal((await invited.get()).data().outcome, "superseded");
  assert.equal((await db.collection("recommendationEvents").where("type", "==", "join_accepted").get()).size, 0);
});

test("authorization, rate limits and changed filters fail explicitly", async () => {
  await assert.rejects(handlers.feed({data: {}}), code("unauthenticated"));
  await assert.rejects(handlers.feed(request({}, "rec-disabled")), code("permission-denied"));
  const page = await handlers.feed(request({pageSize: 2}));
  await assert.rejects(handlers.feed(request({pageSize: 3, cursor: page.nextCursor})), code("failed-precondition"));
  await assert.rejects(handlers.feed(request({pageSize: 2, cursor: page.nextCursor, filters: {minDays: 3}})), code("failed-precondition"));
  await db.doc(`recommendationQuotas/${hash("rec-viewer", "feed")}`).set({uid: "rec-viewer", count: 120, windowStart: now});
  await assert.rejects(handlers.feed(request()), code("resource-exhausted"));
  await db.doc("safetyAccounts/rec-viewer").set({restricted: true});
  await assert.rejects(handlers.events(request({events: [impression(page)]})), code("permission-denied"));
});

test("audit CLI resumes atomic private checkpoints and refuses cross-project reuse", async () => {
  const directory = await mkdtemp(join(tmpdir(), "recommendation-audit-"));
  const checkpoint = join(directory, "checkpoint.json");
  const args = ["--project", "demo-travelcrew-reco-backend", "--limit", "3", "--checkpoint", checkpoint, "--apply"];
  try {
    await auditMain(args); await auditMain(args);
    const result = JSON.parse(await readFile(checkpoint, "utf8"));
    assert.equal(result.totals.scanned, 6); assert.equal(result.complete, false);
    assert.equal((await stat(checkpoint)).mode & 0o777, 0o600);
    await assert.rejects(auditMain(["--project", "different-project", "--checkpoint", checkpoint, "--apply"]), /different project/);
    await auditMain([...args, "--pages", "3"]);
    assert.equal(JSON.parse(await readFile(checkpoint, "utf8")).totals.scanned, 8);
  } finally { await rm(directory, {recursive: true, force: true}); }
});

test("refill reaches eligible trips beyond blocked initial pools within the read budget", async () => {
  const batch = db.batch();
  for (let i = 0; i < 90; i++) {
    const id = `early-${String(i).padStart(3, "0")}`;
    const data = {createdBy: "rec-a", isPrivate: false, destination: "Paris", country: "France", tripStartDate: "2026-10-20", tripEndDate: "2026-10-21"};
    batch.set(db.doc(`trips/${id}`), data);
    batch.set(db.doc(`tripDiscovery/${id}`), {isDiscoverable: true, favouriteCount: 100});
    batch.set(db.doc(`recommendationTripFeatures/${id}`), require("../recommendations/features").tripFeatures(id, data));
  }
  await batch.commit(); await db.doc("users/rec-viewer/blockedUsers/rec-a").set({});
  const logs = [];
  const measured = createRecommendationHandlers(db, auth, {log: (name, data) => logs.push({name, ...data}), clock: () => now});
  const page = await measured.feed(request({pageSize: 3}));
  assert.equal(page.items.length, 3); assert.ok(page.items.every((item) => item.createdBy === "rec-b"));
  assert.ok(logs[0].reads <= 3500); assert.ok(logs[0].candidates > 60);
});

test("a page scan limit returns a continuation instead of claiming catalog exhaustion", async () => {
  const ranked = [...Array.from({length: 65}, (_, i) => ({id: `missing-${i}`, reason: "upcoming_trip"})),
    ...Array.from({length: 8}, (_, i) => ({id: `rec-trip-${i}`, reason: "upcoming_trip"}))];
  const session = newSession({uid: "rec-viewer", ranked, pageSize: 3, filters: {}, preferenceVersion: "initial",
    algorithmVersion: "weighted-v1", experiment: "test-v1", now});
  await db.doc("recommendationSessions/budget-test").set(session);
  const first = await handlers.feed(request({pageSize: 3, cursor: cursorFor("budget-test", session, 0)}));
  assert.deepEqual(first.items, []); assert.equal(first.budgetLimited, true); assert.equal(first.exhausted, false);
  const second = await handlers.feed(request({pageSize: 3, cursor: first.nextCursor}));
  assert.equal(second.items.length, 3); assert.equal(second.budgetLimited, false);
});
