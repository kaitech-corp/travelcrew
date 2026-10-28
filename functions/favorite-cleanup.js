"use strict";

const {createHash} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {validId} = require("./validation");

// Called after an account is marked deleted or its document is removed. Each
// favorite is its own transaction so a retry resumes after a partial cleanup.
async function cleanDeletedUserFavorites(db, uid, favoriteIds = [], deletionEventId = null) {
  const userRef = db.collection("users").doc(uid);
  const ids = [...new Set((Array.isArray(favoriteIds) ? favoriteIds : []).filter(validId))];
  let removed = 0;
  let invalidRemoved = 0;
  for (const tripId of ids) {
    const tripRef = db.collection("trips").doc(tripId);
    const cardRef = db.collection("tripDiscovery").doc(tripId);
    // A deleted document has no list to make replay safe, so retain a receipt.
    const receiptId = createHash("sha256")
        .update(`${deletionEventId || "active-document"}\0${uid}\0${tripId}`).digest("hex");
    const receiptRef = db.collection("favoriteDeletionReceipts").doc(receiptId);
    const changed = await db.runTransaction(async (tx) => {
      const [userDoc, tripDoc, cardDoc, receiptDoc] = await Promise.all([
        tx.get(userRef), tx.get(tripRef), tx.get(cardRef),
        deletionEventId ? tx.get(receiptRef) : Promise.resolve(null),
      ]);
      if (receiptDoc?.exists && !userDoc.exists) return false;
      if (userDoc.exists) {
        const user = userDoc.data();
        if (user.isDeleted !== true || !Array.isArray(user.favouriteTrips) ||
            !user.favouriteTrips.includes(tripId)) return false;
        tx.update(userRef, {favouriteTrips: FieldValue.arrayRemove(tripId)});
      } else if (!deletionEventId) {
        // The deletion event will carry the before-image and finish this ID.
        return false;
      } else {
        tx.create(receiptRef, {createdAt: FieldValue.serverTimestamp()});
      }
      for (const doc of [tripDoc, cardDoc]) {
        if (!doc.exists) continue;
        const count = doc.data().favouriteCount;
        tx.update(doc.ref, {favouriteCount:
          Number.isSafeInteger(count) && count > 0 ? count - 1 : 0});
      }
      return true;
    });
    if (changed) removed++;
  }
  if (!deletionEventId) {
    invalidRemoved = await db.runTransaction(async (tx) => {
      const userDoc = await tx.get(userRef);
      if (!userDoc.exists || userDoc.data().isDeleted !== true) return 0;
      const list = userDoc.data().favouriteTrips;
      if (list == null || (Array.isArray(list) && list.length === 0)) return 0;
      // A valid ID added by an unexpected Admin writer needs its own counter
      // transition; never silently clear it here.
      if (Array.isArray(list) && list.some(validId)) return 0;
      tx.update(userRef, {favouriteTrips: []});
      return Array.isArray(list) ? list.length : 1;
    });
  }
  return {examined: ids.length, removed, invalidRemoved};
}

module.exports = {cleanDeletedUserFavorites};
