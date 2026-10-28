const {HttpsError} = require("firebase-functions/v2/https");

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function createTripStatusHandler(db) {
  return async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
    const data = request.data;
    if (!data || typeof data !== "object" || Array.isArray(data) ||
        Object.keys(data).length !== 1 || !uuid.test(data.tripId)) {
      throw new HttpsError("invalid-argument", "Trip ID required.");
    }
    const trip = await db.doc(`trips/${data.tripId}`).get();
    // Another account's trip is indistinguishable from an unused ID.
    return {exists: trip.exists && trip.data()?.createdBy === uid};
  };
}

module.exports = {createTripStatusHandler};
