"use strict";

const {validId} = require("./validation");

class ChangedDuringRepair extends Error {}

async function repairTripFavoriteCount(db, tripId, {apply = false, maxAttempts = 3} = {}) {
  if (!validId(tripId)) throw new Error("Valid trip ID required.");
  if (!Number.isInteger(maxAttempts) || maxAttempts < 1 || maxAttempts > 5) {
    throw new Error("Repair attempts must be 1–5.");
  }
  const pauseRef = db.collection("favoriteMaintenance").doc("current");
  const tripRef = db.collection("trips").doc(tripId);
  const cardRef = db.collection("tripDiscovery").doc(tripId);
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const [pauseBefore, tripBefore, cardBefore] = await Promise.all([
      pauseRef.get(), tripRef.get(), cardRef.get(),
    ]);
    if (!tripBefore.exists) return {tripId, status: "missing", attempt};
    if (apply && pauseBefore.data()?.paused !== true) {
      throw new Error("Favorite transitions must be paused before applying a repair.");
    }

    // Count every existing user document with this ID, including soft-deleted
    // accounts. Deletion cleanup removes each ID and decrements both counters.
    const query = db.collection("users").where("favouriteTrips", "array-contains", tripId);
    const countSnapshot = await query.count().get();
    const expectedCount = countSnapshot.data().count;
    if (!Number.isSafeInteger(expectedCount) || expectedCount < 0) {
      throw new Error("Invalid favorite count returned by Firestore.");
    }
    const result = {tripId, status: "unchanged", attempt, expectedCount,
      priorTripCount: tripBefore.data().favouriteCount,
      priorCardCount: cardBefore.data()?.favouriteCount,
      cardExists: cardBefore.exists};
    if (!apply) {
      return {...result, status: "preview",
        consistent: pauseBefore.data()?.paused === true};
    }
    try {
      return await db.runTransaction(async (tx) => {
        const [pauseNow, tripNow, cardNow] = await Promise.all([
          tx.get(pauseRef), tx.get(tripRef), tx.get(cardRef),
        ]);
        if (pauseNow.data()?.paused !== true ||
            !pauseNow.updateTime.isEqual(pauseBefore.updateTime)) {
          throw new Error("Favorite maintenance pause changed during repair.");
        }
        if (!tripNow.exists || !tripNow.updateTime.isEqual(tripBefore.updateTime)) {
          throw new ChangedDuringRepair("Trip changed during favorite recount.");
        }
        if (cardNow.exists !== cardBefore.exists ||
            (cardNow.exists && !cardNow.updateTime.isEqual(cardBefore.updateTime))) {
          throw new ChangedDuringRepair("Discovery card changed during favorite recount.");
        }
        const tripChanged = tripNow.data().favouriteCount !== expectedCount;
        const cardChanged = cardNow.exists && cardNow.data().favouriteCount !== expectedCount;
        if (tripChanged) tx.update(tripRef, {favouriteCount: expectedCount});
        if (cardChanged) tx.update(cardRef, {favouriteCount: expectedCount});
        return {...result, status: tripChanged || cardChanged ? "repaired" : "unchanged"};
      });
    } catch (error) {
      if (!(error instanceof ChangedDuringRepair) || attempt === maxAttempts) throw error;
    }
  }
  throw new Error("Favorite repair attempts exhausted.");
}

module.exports = {repairTripFavoriteCount};
