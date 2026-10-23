const {randomUUID} = require("node:crypto");
const {Timestamp} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {ReadContext, mapLimit, loadProfile, retrieveCandidates, eligibleTrip, refillCandidates} = require("./candidates");
const {identity, parse, feedSchema, eventsSchema, dismissalSchema, preferencesSchema} = require("./contracts");
const {ALGORITHM_VERSION, score} = require("./scoring");
const {diversify} = require("./diversity");
const {newSession, decodeCursor, validateCursor, validateSession, servePage} = require("./sessions");
const {quota, recordEvent, hash, RETENTION_MS} = require("./events");

function rollout(config, uid) {
  const bucket = parseInt(hash(uid, config.experiment || "launch-v1").slice(0, 8), 16) % 100;
  const percent = Math.min(100, Math.max(0, Number(config.percent) || 0));
  return config.enabled === true ? (bucket < percent ? "weighted" : "control") : "fallback";
}

const algorithm = (mode) => mode === "weighted" ? ALGORITHM_VERSION : mode === "control" ? "legacy-continent-v1" : "upcoming-v1";
const experiment = (config) => String(config.experiment || "launch-v1").slice(0, 80);

function createRecommendationHandlers(db, auth, {clock = Date.now, log = () => {}} = {}) {
  const context = () => new ReadContext(db, auth, clock(), 3500);
  return {
    async feed(request) {
      const uid = identity(request); const input = parse(feedSchema, request.data);
      const ctx = context(); await ctx.requireViewer(uid);
      await quota(db, uid, "feed", 120, ctx.now);
      const config = (await ctx.doc("recommendationConfig/current")).data() || {};
      if (input.cursor) {
        const decoded = decodeCursor(input.cursor);
        const session = (await ctx.doc(`recommendationSessions/${decoded.sessionId}`)).data();
        validateSession(session, uid, ctx.now); validateCursor(decoded, session);
        const preferences = (await ctx.doc(`users/${uid}/recommendationPreferences/current`)).data();
        if (session.preferenceVersion !== (preferences?.version || "initial") || input.pageSize !== session.pageSize ||
            (input.filters && JSON.stringify(input.filters) !== JSON.stringify(session.filters)) ||
            session.algorithmVersion !== algorithm(rollout(config, uid)) || session.experiment !== experiment(config)) {
          throw new HttpsError("failed-precondition", "Refresh recommendations.", {reason: "session_changed"});
        }
        const page = await servePage(ctx, uid, decoded.sessionId, session, decoded.offset);
        log("recommendation_page", {reads: ctx.reads, authReads: ctx.authReads, results: page.items.length, durationMs: clock() - ctx.now});
        return page;
      }
      const profile = await loadProfile(ctx, uid);
      const filters = input.filters ?? profile.filters;
      const mode = rollout(config, uid);
      const ids = await retrieveCandidates(ctx, profile, mode);
      const trips = (await mapLimit(ids, (id) => eligibleTrip(ctx, uid, id, filters))).filter(Boolean);
      if (mode !== "control") await refillCandidates(ctx, uid, ids, trips, filters, input.pageSize);
      const id = randomUUID();
      let ranked = diversify(trips.map(({feature}) => score(feature, profile, ctx.now)), {seed: id, pageSize: input.pageSize});
      if (mode !== "weighted") {
        ranked = trips.sort((a, b) => a.feature.startDay.toMillis() - b.feature.startDay.toMillis() || a.feature.id.localeCompare(b.feature.id))
            .map(({feature}) => ({id: feature.id, reason: "upcoming_trip", selection: mode === "control" ? "legacy_continent_v1" : "upcoming_v1", feature}));
      }
      const session = newSession({uid, ranked, filters, pageSize: input.pageSize, preferenceVersion: profile.preferenceVersion,
        algorithmVersion: algorithm(mode), experiment: experiment(config), now: ctx.now});
      await db.doc(`recommendationSessions/${id}`).create(session);
      // Store coverage only. Private source locations/IDs must not linger in a
      // saved profile after access is revoked; history is rebuilt per request.
      await db.doc(`users/${uid}/recommendationProfile/current`).set({historyCount: profile.history.length, featureVersion: 1, updatedAt: Timestamp.fromMillis(ctx.now)});
      const page = await servePage(ctx, uid, id, session);
      await db.doc(`recommendationEvents/${hash(id, "session")}`).create({uid, sessionId: id, type: "feed_session", observation: "server",
        algorithmVersion: session.algorithmVersion, experiment: session.experiment, results: page.items.length,
        createdAt: Timestamp.fromMillis(ctx.now), expiresAt: Timestamp.fromMillis(ctx.now + RETENTION_MS)});
      if (config.shadow === true && mode !== "weighted") {
        // A separate bounded context gives shadow the complete treatment pools.
        // Shadow failure never replaces or fails the user's control response.
        const shadow = context();
        try {
          const shadowIds = await retrieveCandidates(shadow, profile, "weighted");
          const shadowTrips = (await mapLimit(shadowIds, (tripId) => eligibleTrip(shadow, uid, tripId, filters))).filter(Boolean);
          await refillCandidates(shadow, uid, shadowIds, shadowTrips, filters, input.pageSize);
          const top = diversify(shadowTrips.map(({feature}) => score(feature, profile, shadow.now)), {seed: id, pageSize: input.pageSize}).slice(0, 20);
          const controlIds = new Set(ranked.slice(0, 20).map((row) => row.id));
          log("recommendation_shadow", {algorithmVersion: ALGORITHM_VERSION, controlVersion: session.algorithmVersion,
            candidates: shadowIds.length, eligible: shadowTrips.length, overlapAt20: top.filter((row) => controlIds.has(row.id)).length,
            reads: shadow.reads, authReads: shadow.authReads, durationMs: clock() - shadow.now});
        } catch (error) { log("recommendation_shadow_error", {code: error.code || "unknown", reads: shadow.reads}); }
      }
      log("recommendation_feed", {reads: ctx.reads, authReads: ctx.authReads, candidates: ids.length, eligible: trips.length,
        results: page.items.length, algorithmVersion: session.algorithmVersion, experiment: session.experiment, durationMs: clock() - ctx.now});
      return page;
    },
    async events(request) {
      const uid = identity(request); const input = parse(eventsSchema, request.data);
      const ctx = context(); await ctx.requireViewer(uid); await quota(db, uid, "events", 240, ctx.now);
      const results = [];
      for (const event of input.events) results.push(await recordEvent(db, uid, event, ctx.now));
      return {results};
    },
    async dismiss(request) {
      const uid = identity(request); const input = parse(dismissalSchema, request.data);
      const ctx = context(); await ctx.requireViewer(uid); await quota(db, uid, "dismiss", 120, ctx.now);
      const ref = db.doc(`users/${uid}/recommendationDismissals/${input.tripId}`);
      if (input.dismissed && !await eligibleTrip(ctx, uid, input.tripId)) {
        if ((await ref.get()).data()?.dismissed !== true) throw new HttpsError("not-found", "Trip unavailable.");
      }
      await db.runTransaction(async (tx) => {
        const prior = (await tx.get(ref)).data();
        const session = input.sessionId ? (await tx.get(db.doc(`recommendationSessions/${input.sessionId}`))).data() : null;
        if (prior?.dismissed === input.dismissed) return;
        const position = session?.uid === uid ? session.ranked.findIndex((item) => item.id === input.tripId) : -1;
        const attributed = position >= 0 && session.served.includes(position);
        tx.set(ref, {dismissed: input.dismissed, updatedAt: Timestamp.fromMillis(ctx.now)});
        tx.create(db.collection("recommendationEvents").doc(), {uid, tripId: input.tripId,
          type: input.dismissed ? "dismiss" : "undo_dismiss", observation: "server",
          sessionId: attributed ? input.sessionId : null, position: attributed ? position : null,
          algorithmVersion: attributed ? session.algorithmVersion : null, experiment: attributed ? session.experiment : null,
          createdAt: Timestamp.fromMillis(ctx.now), expiresAt: Timestamp.fromMillis(ctx.now + RETENTION_MS)});
      });
      return {tripId: input.tripId, dismissed: input.dismissed};
    },
    async preferences(request) {
      const uid = identity(request); const input = parse(preferencesSchema, request.data);
      const ctx = context(); await ctx.requireViewer(uid); await quota(db, uid, "preferences", 60, ctx.now);
      const preferences = {...input, schemaVersion: 1, version: randomUUID(), updatedAt: Timestamp.fromMillis(ctx.now)};
      await db.doc(`users/${uid}/recommendationPreferences/current`).set(preferences);
      return {destinations: preferences.destinations, filters: preferences.filters, version: preferences.version};
    },
  };
}

module.exports = {createRecommendationHandlers, rollout};
