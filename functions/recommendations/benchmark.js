// Reproducible local operation/latency baseline. This script can only write to
// the disposable demo project while both emulators are explicitly configured.
const {performance} = require("node:perf_hooks");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {createRecommendationHandlers} = require("./index");
const {tripFeatures, DAY} = require("./features");

async function main() {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) throw new Error("Both local emulators are required.");
  const app = initializeApp({projectId: "demo-travelcrew-recommendation-benchmark"}, "recommendation-benchmark");
  const db = getFirestore(app, "travel-crew-db-2"); const auth = getAuth(app);
  const now = Date.now(); const report = [];
  try {
    for (const name of ["users", "publicProfile", "trips", "tripDiscovery", "recommendationTripFeatures", "recommendationConfig",
      "recommendationSessions", "recommendationEvents", "recommendationQuotas"]) await db.recursiveDelete(db.collection(name));
    for (const uid of ["viewer", ...Array.from({length: 20}, (_, i) => `creator-${i}`)]) {
      try { await auth.createUser({uid}); } catch (error) { if (error.code !== "auth/uid-already-exists") throw error; }
      await db.doc(`users/${uid}`).set({}); await db.doc(`publicProfile/${uid}`).set({displayName: uid});
    }
    for (let offset = 0; offset < 240; offset += 80) {
      const batch = db.batch();
      for (let i = offset; i < offset + 80; i++) {
        const id = `trip-${String(i).padStart(3, "0")}`;
        const trip = {createdBy: `creator-${i % 20}`, destination: `City ${i % 12}`, country: `Country ${i % 4}`,
          continent: i % 2 ? "Europe" : "Asia", isPrivate: false, favouriteCount: i % 100, joinedUsers: [],
          tripStartDate: new Date(now + (14 + i % 20) * DAY).toISOString().slice(0, 10),
          tripEndDate: new Date(now + (20 + i % 20) * DAY).toISOString().slice(0, 10)};
        batch.set(db.doc(`trips/${id}`), trip);
        batch.set(db.doc(`tripDiscovery/${id}`), {isDiscoverable: true, favouriteCount: trip.favouriteCount});
        batch.set(db.doc(`recommendationTripFeatures/${id}`), tripFeatures(id, trip, Timestamp.fromMillis(now - i * 60000)));
      }
      await batch.commit();
    }
    await db.doc("users/viewer").set({favouriteTrips: Array.from({length: 10}, (_, i) => `trip-${String(i * 2).padStart(3, "0")}`)});
    await db.doc("publicProfile/viewer").update({following: ["creator-0", "creator-1", "creator-2"]});
    await db.doc("users/viewer/recommendationPreferences/current").set({destinations: ["city 1", "city 2"], version: "benchmark"});
    for (const [mode, config] of Object.entries({fallback: {enabled: false}, control: {enabled: true, percent: 0},
      weighted: {enabled: true, percent: 100}, shadow: {enabled: true, percent: 0, shadow: true}})) {
      await db.doc("recommendationConfig/current").set({...config, experiment: "benchmark"});
      const samples = [];
      for (let i = 0; i < 6; i++) {
        const logs = [];
        const handlers = createRecommendationHandlers(db, auth, {log: (name, data) => logs.push({name, ...data})});
        const began = performance.now();
        const page = await handlers.feed({auth: {uid: "viewer"}, data: {pageSize: 20}});
        const elapsedMs = Math.round(performance.now() - began);
        const feed = logs.find((log) => log.name === "recommendation_feed");
        const shadow = logs.find((log) => log.name === "recommendation_shadow");
        samples.push({elapsedMs, reads: feed.reads, authReads: feed.authReads, candidates: feed.candidates,
          eligible: feed.eligible, results: page.items.length, shadowReads: shadow?.reads || 0, shadowAuthReads: shadow?.authReads || 0});
      }
      const durations = samples.map((sample) => sample.elapsedMs).sort((a, b) => a - b);
      report.push({mode, fixtureTrips: 240, fixtureCreators: 20, samples,
        p50Ms: durations[Math.ceil(durations.length * 0.5) - 1], p95Ms: durations[Math.ceil(durations.length * 0.95) - 1]});
    }
    console.log(JSON.stringify({environment: "local Auth/Firestore emulators; in-process handlers; not production billing or Cloud Functions cold starts", report}, null, 2));
  } finally { await db.terminate(); await deleteApp(app); }
}

if (require.main === module) main().catch((error) => { console.error(error.message); process.exitCode = 1; });
module.exports = {main};
