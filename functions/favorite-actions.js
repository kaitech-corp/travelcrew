const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {validId} = require("./validation");
const {isBlocked} = require("./safety");

function createFavoriteHandler(db, log = () => {}) {
  return async function setTripFavorite(request) {
    const uid = request.auth?.uid;
    const tripId = request.data?.tripId;
    const favorite = request.data?.favorite;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    if (!validId(tripId) || typeof favorite !== "boolean") {
      throw new HttpsError("invalid-argument", "Trip and favorite state are required.");
    }

    const userRef = db.collection("users").doc(uid);
    const tripRef = db.collection("trips").doc(tripId);
    const cardRef = db.collection("tripDiscovery").doc(tripId);
    const result = await db.runTransaction(async (tx) => {
      const [maintenanceDoc, userDoc, tripDoc, cardDoc, viewerSafety] = await Promise.all([
        tx.get(db.collection("favoriteMaintenance").doc("current")),
        tx.get(userRef), tx.get(tripRef), tx.get(cardRef),
        tx.get(db.collection("safetyAccounts").doc(uid)),
      ]);
      if (maintenanceDoc.data()?.paused === true) {
        throw new HttpsError("unavailable", "Favorites are temporarily paused. Try again later.");
      }
      const user = userDoc.data();
      if (!user || user.isDeleted || viewerSafety.data()?.restricted) {
        throw new HttpsError("permission-denied", "Account unavailable.");
      }
      const trip = tripDoc.data();
      const card = cardDoc.data();
      const favorites = Array.isArray(user.favouriteTrips) ? user.favouriteTrips : [];
      const currentlyFavorite = favorites.includes(tripId);

      if (favorite) {
        if (!trip || !card || !card.isDiscoverable || card.moderationRemoved ||
            card.createdBy !== trip.createdBy || card.id !== tripId || trip.isPrivate ||
            trip.moderationRemoved || ["deleted", "cancelled", "completed"].includes(trip.tripStatus)) {
          throw new HttpsError("failed-precondition", "Trip is unavailable.");
        }
        if (trip.createdBy === uid || !validId(trip.createdBy)) {
          throw new HttpsError("failed-precondition", "Cannot favorite this trip.");
        }
        const [ownerDoc, ownerSafety] = await Promise.all([
          tx.get(db.collection("users").doc(trip.createdBy)),
          tx.get(db.collection("safetyAccounts").doc(trip.createdBy)),
        ]);
        if (!ownerDoc.exists || ownerDoc.data()?.isDeleted || ownerSafety.data()?.restricted ||
            await isBlocked(db, uid, trip.createdBy, tx)) {
          throw new HttpsError("permission-denied", "Trip is unavailable.");
        }
        if (!currentlyFavorite && favorites.length >= 500) {
          throw new HttpsError("resource-exhausted", "Favorite list is full.");
        }
      }

      const count = Number.isSafeInteger(trip?.favouriteCount) && trip.favouriteCount >= 0 ?
        trip.favouriteCount : 0;
      if (currentlyFavorite === favorite) {
        return {favorite, changed: false, favouriteCount: count};
      }

      const nextCount = Math.max(0, count + (favorite ? 1 : -1));
      tx.update(userRef, {favouriteTrips: favorite ? FieldValue.arrayUnion(tripId) : FieldValue.arrayRemove(tripId)});
      if (tripDoc.exists) tx.update(tripRef, {favouriteCount: nextCount});
      if (cardDoc.exists) tx.update(cardRef, {favouriteCount: nextCount});
      return {favorite, changed: true, favouriteCount: nextCount};
    });
    log("trip_favorite_set", {tripId, favorite, changed: result.changed});
    return result;
  };
}

module.exports = {createFavoriteHandler};
