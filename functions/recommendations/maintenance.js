const {Timestamp, FieldPath} = require("firebase-admin/firestore");
const {maintainTripFeature, tripFeatures, fitsDates, normalize, travelDay} = require("./features");

const ownedCollections = ["recommendationSessions", "recommendationEvents", "recommendationAttributions", "recommendationLastImpressions", "recommendationQuotas"];

async function cleanRecommendationData(db, uid) {
  for (const name of ["recommendationPreferences", "recommendationProfile", "recommendationDismissals"]) {
    await db.recursiveDelete(db.collection(`users/${uid}/${name}`));
  }
  for (const name of ownedCollections) {
    for (;;) {
      const docs = await db.collection(name).where("uid", "==", uid).limit(250).get();
      if (docs.empty) break;
      const batch = db.batch(); docs.docs.forEach((doc) => batch.delete(doc.ref)); await batch.commit();
    }
  }
}

async function expireRecommendations(db, now = Date.now()) {
  const counts = {};
  // Bound every run; the scheduler runs again when a backlog exceeds the cap.
  for (const name of ownedCollections) {
    const docs = await db.collection(name).where("expiresAt", "<=", Timestamp.fromMillis(now)).limit(250).get();
    const batch = db.batch(); docs.docs.forEach((doc) => batch.delete(doc.ref));
    if (!docs.empty) await batch.commit();
    counts[name] = docs.size;
  }
  return counts;
}

async function auditFeaturePage(db, {after = null, limit = 100, apply = false} = {}) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 250) throw new Error("Page limit must be 1–250.");
  let query = db.collection("trips").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const docs = await query.get();
  const counts = {scanned: docs.size, eligibleMetadata: 0, upcomingMetadata: 0, excluded: 0, unknownPublication: 0, updated: 0,
    discoverableListings: 0, upcomingDiscoverable: 0, missingDestination: 0, missingCountry: 0, missingContinent: 0,
    invalidStartDate: 0, invalidEndDate: 0, missingEndDate: 0, unknownVisibility: 0, stalePublicListing: 0};
  for (const doc of docs.docs) {
    const trip = doc.data();
    const card = (await db.doc(`tripDiscovery/${doc.id}`).get()).data();
    if (card?.isDiscoverable === true) counts.discoverableListings++;
    if (!normalize(trip.destination)) counts.missingDestination++;
    if (!normalize(trip.country)) counts.missingCountry++;
    if (!normalize(trip.continent)) counts.missingContinent++;
    const starts = travelDay(trip.tripStartDate ?? trip.startDate);
    const rawEnd = trip.tripEndDate ?? (trip.endDate || null);
    if (starts == null) counts.invalidStartDate++;
    if (rawEnd == null) counts.missingEndDate++;
    else if (travelDay(rawEnd) == null || (starts != null && travelDay(rawEnd) < starts)) counts.invalidEndDate++;
    if (typeof trip.isPrivate !== "boolean") counts.unknownVisibility++;
    const data = tripFeatures(doc.id, trip);
    if (!data && card?.isDiscoverable === true) counts.stalePublicListing++;
    if (data) {
      counts.eligibleMetadata++;
      if (fitsDates(data, {}, Date.now())) {
        counts.upcomingMetadata++;
        if (card?.isDiscoverable === true && card?.moderationRemoved !== true) counts.upcomingDiscoverable++;
      }
      if (!(await db.doc(`recommendationTripFeatures/${doc.id}`).get()).data()?.publishedAt) counts.unknownPublication++;
    } else counts.excluded++;
    if (apply && await maintainTripFeature(db, doc.id) === "updated") counts.updated++;
  }
  return {counts, nextAfter: docs.size === limit ? docs.docs.at(-1).id : null};
}

async function auditUserPage(db, {after = null, limit = 100} = {}) {
  if (!Number.isInteger(limit) || limit < 1 || limit > 250) throw new Error("Page limit must be 1–250.");
  let query = db.collection("users").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const docs = await query.get();
  const counts = {scanned: docs.size, deleted: 0, withFavorites: 0, favorites: 0, withFollows: 0, follows: 0,
    withMemberships: 0, sampledMemberships: 0, membershipSampleCapped: 0, withExplicitDestinations: 0};
  for (const doc of docs.docs) {
    if (doc.data().isDeleted === true) { counts.deleted++; continue; }
    const [profile, preferences, memberships] = await Promise.all([
      db.doc(`publicProfile/${doc.id}`).get(), db.doc(`users/${doc.id}/recommendationPreferences/current`).get(),
      db.collection(`users/${doc.id}/tripMemberships`).where("status", "==", "active").limit(50).get(),
    ]);
    const favorites = Array.isArray(doc.data().favouriteTrips) ? doc.data().favouriteTrips.length : 0;
    const follows = Array.isArray(profile.data()?.following) ? profile.data().following.length : 0;
    counts.favorites += favorites; if (favorites) counts.withFavorites++;
    counts.follows += follows; if (follows) counts.withFollows++;
    counts.sampledMemberships += memberships.size; if (memberships.size) counts.withMemberships++;
    if (memberships.size === 50) counts.membershipSampleCapped++;
    if (preferences.data()?.destinations?.length) counts.withExplicitDestinations++;
  }
  return {counts, nextAfter: docs.size === limit ? docs.docs.at(-1).id : null};
}

module.exports = {cleanRecommendationData, expireRecommendations, auditFeaturePage, auditUserPage};
