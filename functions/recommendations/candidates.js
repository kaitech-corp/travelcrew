const {HttpsError} = require("firebase-functions/v2/https");
const {Timestamp} = require("firebase-admin/firestore");
const {validId, chunks} = require("../validation");
const {tripFeatures, fitsDates, travelDay, normalize, preview} = require("./features");

async function mapLimit(items, fn, limit = 8) {
  const output = new Array(items.length); let next = 0;
  await Promise.all(Array.from({length: Math.min(limit, items.length)}, async () => {
    for (;;) {
      const i = next++; if (i >= items.length) return;
      output[i] = await fn(items[i], i);
    }
  }));
  return output;
}

// Memoization lasts one HTTP request only. In particular, every next page gets
// fresh authorization checks. Auth API failures propagate rather than granting
// eligibility based on a stale profile.
class ReadContext {
  constructor(db, auth, now = Date.now(), budget = 2000) {
    this.db = db; this.auth = auth; this.now = now; this.budget = budget;
    this.reads = 0; this.authReads = 0; this.docs = new Map(); this.accounts = new Map();
  }
  spend(count) {
    this.reads += count;
    if (this.reads > this.budget) throw new HttpsError("resource-exhausted", "Recommendation read budget exceeded. Retry later.");
  }
  doc(path) {
    if (!this.docs.has(path)) { this.spend(1); this.docs.set(path, this.db.doc(path).get()); }
    return this.docs.get(path);
  }
  async query(query) {
    const snap = await query.get(); this.spend(Math.max(1, snap.size));
    for (const doc of snap.docs) this.docs.set(doc.ref.path, Promise.resolve(doc));
    return snap.docs;
  }
  async primeAccounts(ids) {
    const missing = [...new Set(ids)].filter((id) => validId(id) && !this.accounts.has(id));
    for (const batch of chunks(missing, 100)) {
      this.authReads += batch.length;
      const pending = this.auth.getUsers(batch.map((uid) => ({uid})));
      for (const uid of batch) this.accounts.set(uid, pending.then((result) => result.users.some((user) => user.uid === uid && !user.disabled)));
    }
    await Promise.all(ids.filter((id) => this.accounts.has(id)).map((id) => this.accounts.get(id)));
  }
  async active(uid) {
    if (!validId(uid)) return false;
    await this.primeAccounts([uid]);
    const [user, safety, profile] = await Promise.all([
      this.doc(`users/${uid}`), this.doc(`safetyAccounts/${uid}`), this.doc(`publicProfile/${uid}`),
    ]);
    return await this.accounts.get(uid) && user.exists && user.data().isDeleted !== true &&
      safety.data()?.restricted !== true && profile.exists && profile.data().moderationRemoved !== true;
  }
  async requireViewer(uid) {
    if (!await this.active(uid)) throw new HttpsError("permission-denied", "Account unavailable.");
  }
  async blocked(a, b) {
    if (a === b) return false;
    const docs = await Promise.all([this.doc(`users/${a}/blockedUsers/${b}`), this.doc(`users/${b}/blockedUsers/${a}`)]);
    return docs.some((doc) => doc.exists);
  }
}

async function loadProfile(ctx, uid) {
  const db = ctx.db;
  const [user, publicProfile, preferences, memberships] = await Promise.all([
    ctx.doc(`users/${uid}`), ctx.doc(`publicProfile/${uid}`), ctx.doc(`users/${uid}/recommendationPreferences/current`),
    ctx.query(db.collection(`users/${uid}/tripMemberships`).where("status", "==", "active").limit(50)),
  ]);
  const favorites = (Array.isArray(user.data()?.favouriteTrips) ? user.data().favouriteTrips : []).filter(validId).slice(0, 50);
  const ids = [...new Set([...favorites, ...memberships.map((doc) => doc.id)])];
  const history = (await mapLimit(ids, async (id) => {
    const [source, member, card] = await Promise.all([ctx.doc(`trips/${id}`), ctx.doc(`trips/${id}/members/${uid}`), ctx.doc(`tripDiscovery/${id}`)]);
    const trip = source.data();
    if (!trip || trip.moderationRemoved || trip.tripStatus === "deleted" || !validId(trip.createdBy)) return null;
    if (!await ctx.active(trip.createdBy) || await ctx.blocked(uid, trip.createdBy)) return null;
    const own = trip.createdBy === uid || (Array.isArray(trip.joinedUsers) && trip.joinedUsers.includes(uid)) || member.data()?.status === "active";
    // Favorites may outlive private access. A stale user membership index is
    // never sufficient proof that the viewer can still read the source trip.
    if (!own && !(trip.isPrivate === false && card.data()?.isDiscoverable === true) && trip.isShared !== true) return null;
    return {tripId: id, destinationKey: normalize(trip.destination), countryKey: normalize(trip.country),
      continentKey: normalize(trip.continent), confidence: 1};
  })).filter(Boolean);
  const legacyIds = new Set([...favorites.slice(0, 10), ...memberships.map((doc) => doc.id)]);
  return {destinations: preferences.data()?.destinations || [], filters: preferences.data()?.filters || {},
    legacyContinents: [...new Set(history.filter((item) => legacyIds.has(item.tripId)).map((item) => item.continentKey))].filter(Boolean),
    preferenceVersion: preferences.data()?.version || "initial", history,
    following: (Array.isArray(publicProfile.data()?.following) ? publicProfile.data().following : []).filter(validId).slice(0, 50)};
}

async function retrieveCandidates(ctx, profile, mode = "weighted") {
  const collection = ctx.db.collection("recommendationTripFeatures");
  const today = Timestamp.fromMillis(travelDay(new Date(ctx.now)));
  const base = collection.where("startDay", ">=", today).orderBy("startDay");
  const destinations = [...new Set([...profile.destinations, ...profile.history.flatMap((item) => [item.destinationKey, item.countryKey])])].filter(Boolean).slice(0, 10);
  const pools = [];
  if (mode === "control") {
    if (!profile.legacyContinents.length) {
      return (await ctx.query(ctx.db.collection("tripDiscovery").where("isDiscoverable", "==", true)
          .orderBy("favouriteCount", "desc").limit(200))).map((doc) => doc.id);
    }
    return (await ctx.query(base.where("continentKey", "in", profile.legacyContinents.slice(0, 10)).limit(200))).map((doc) => doc.id);
  }
  if (destinations.length && mode === "weighted") pools.push(await ctx.query(base.where("destinationKeys", "array-contains-any", destinations).limit(60)));
  if (profile.following.length && mode === "weighted") {
    const follows = chunks(profile.following, 25);
    pools.push((await Promise.all(follows.map((ids) => ctx.query(base.where("createdBy", "in", ids).limit(30))))).flat());
  }
  pools.push(await ctx.query(base.limit(60)));
  // Give newly published and unpopular trips an independent retrieval route.
  pools.push(await ctx.query(collection.orderBy("publishedAt", "desc").limit(20)));
  // Backfill/rollout compatibility: safe final validation still reads trips.
  const cards = await ctx.query(ctx.db.collection("tripDiscovery").where("isDiscoverable", "==", true).orderBy("favouriteCount", "desc").limit(60));
  pools.push(cards);
  const seen = new Map();
  // Round-robin reserves capacity for broad/fresh/popular sources even when
  // destination and follow pools are both full and entirely disjoint.
  for (let i = 0; i < Math.max(...pools.map((pool) => pool.length)); i++) {
    for (const pool of pools) {
      const doc = pool[i];
      if (doc && !seen.has(doc.id) && seen.size < 200) seen.set(doc.id, doc);
    }
  }
  return [...seen.keys()];
}

async function eligibleTrip(ctx, uid, id, filters = {}) {
  if (!validId(id)) return null;
  const [source, card, member, dismissal, projected] = await Promise.all([
    ctx.doc(`trips/${id}`), ctx.doc(`tripDiscovery/${id}`), ctx.doc(`trips/${id}/members/${uid}`),
    ctx.doc(`users/${uid}/recommendationDismissals/${id}`), ctx.doc(`recommendationTripFeatures/${id}`),
  ]);
  const trip = source.data();
  if (!trip || trip.createdBy === uid || (Array.isArray(trip.joinedUsers) && trip.joinedUsers.includes(uid)) || member.data()?.status === "active" ||
      dismissal.data()?.dismissed === true || card.data()?.isDiscoverable !== true || card.data()?.moderationRemoved === true) return null;
  const feature = tripFeatures(id, trip, projected.data()?.publishedAt);
  if (!feature || !fitsDates(feature, filters, ctx.now)) return null;
  if (!await ctx.active(trip.createdBy) || await ctx.blocked(uid, trip.createdBy)) return null;
  return {feature, preview: preview(id, trip, (await ctx.doc(`publicProfile/${trip.createdBy}`)).data())};
}

async function refillCandidates(ctx, uid, ids, trips, filters, pageSize) {
  const seen = new Set(ids); let after = null;
  // A blocked or expired popular pool must not manufacture an empty feed.
  // Scan further upcoming features with strict per-request read/scan bounds.
  while (trips.length < pageSize && seen.size < 400) {
    const count = Math.min(60, 400 - seen.size, Math.floor((ctx.budget - ctx.reads - 20) / 12));
    if (count < 1) break;
    let query = ctx.db.collection("recommendationTripFeatures")
        .where("startDay", ">=", Timestamp.fromMillis(travelDay(new Date(ctx.now)))).orderBy("startDay").limit(count);
    if (after) query = query.startAfter(after);
    const docs = await ctx.query(query);
    const fresh = docs.filter((doc) => !seen.has(doc.id));
    for (const doc of fresh) { seen.add(doc.id); ids.push(doc.id); }
    trips.push(...(await mapLimit(fresh, (doc) => eligibleTrip(ctx, uid, doc.id, filters))).filter(Boolean));
    if (docs.length < count) break;
    after = docs.at(-1);
  }
  return trips;
}

module.exports = {ReadContext, mapLimit, loadProfile, retrieveCandidates, eligibleTrip, refillCandidates};
