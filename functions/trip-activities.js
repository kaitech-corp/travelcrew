const {FieldPath} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {validId} = require("./validation");
const {isTripMember} = require("./trip-membership");

const PAGE_SIZE = 100;
const FIELDS = ["tripId", "createdBy", "title", "description", "location",
  "startDateTime", "endDateTime", "likedBy", "likesCount", "contentRevision"];

function createActivityListHandler(db) {
  return async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    const input = request.data;
    if (!input || typeof input !== "object" || Array.isArray(input) ||
        Object.keys(input).some((key) => !["tripId", "source", "cursor"].includes(key)) ||
        !validId(input.tripId) ||
        (input.source !== undefined && !["canonical", "legacy"].includes(input.source)) ||
        (input.cursor !== undefined && !validId(input.cursor)) ||
        (input.cursor !== undefined && input.source === undefined)) {
      throw new HttpsError("invalid-argument", "Invalid activity page request.");
    }
    const tripRef = db.collection("trips").doc(input.tripId);
    const [tripDoc, memberDoc, accountDoc, safetyDoc] = await Promise.all([
      tripRef.get(), tripRef.collection("members").doc(uid).get(),
      db.collection("users").doc(uid).get(), db.collection("safetyAccounts").doc(uid).get(),
    ]);
    const trip = tripDoc.data();
    if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved ||
        !isTripMember(trip, uid, memberDoc.data()) ||
        accountDoc.data()?.isDeleted || safetyDoc.data()?.restricted) {
      throw new HttpsError("permission-denied", "Trip unavailable.");
    }
    const canonicalRef = tripRef.collection("activities");
    // Preserve the legacy-only response for native builds that do not yet
    // understand nextSource. Mixed trips transition after canonical pages.
    const source = input.source ||
      ((await canonicalRef.limit(1).get()).empty ? "legacy" : "canonical");
    const ref = source === "canonical" ? canonicalRef : db.collection("activity");
    let query = source === "canonical" ? ref : ref.where("tripId", "==", input.tripId);
    query = query.orderBy(FieldPath.documentId()).limit(PAGE_SIZE + 1);
    if (input.cursor !== undefined) query = query.startAfter(ref.doc(input.cursor));
    const snapshot = await query.get();
    const page = snapshot.docs.slice(0, PAGE_SIZE);
    const visible = page.filter((doc) => {
      const data = doc.data();
      return data.moderationRemoved !== true && data.isDeleted !== true;
    });
    const canonicalForLegacy = source === "legacy" && visible.length ?
      await db.getAll(...visible.map((doc) => canonicalRef.doc(doc.id))) : [];
    const activities = visible.filter((_, index) =>
      source === "canonical" || !canonicalForLegacy[index].exists).map((doc) => {
      const data = doc.data();
      const result = {id: doc.id, isLegacy: source === "legacy"};
      for (const field of FIELDS) {
        if (data[field] !== undefined) result[field] = data[field];
      }
      return result;
    });
    return {source, activities,
      nextCursor: snapshot.docs.length > PAGE_SIZE ? page.at(-1).id : null,
      nextSource: source === "canonical" && snapshot.docs.length <= PAGE_SIZE ? "legacy" : null};
  };
}

module.exports = {createActivityListHandler};
