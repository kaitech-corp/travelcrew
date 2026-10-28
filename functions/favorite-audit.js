const {FieldPath} = require("firebase-admin/firestore");
const {validId} = require("./validation");

function bounded(value, name, maximum) {
  if (!Number.isInteger(value) || value < 1 || value > maximum) {
    throw new Error(`${name} must be 1–${maximum}.`);
  }
}

async function auditTripFavoriteCount(db, tripId, {userPageSize = 100, maxUserPages = 5} = {}) {
  bounded(userPageSize, "User page size", 250);
  bounded(maxUserPages, "Maximum user pages", 20);
  const [tripDoc, cardDoc] = await Promise.all([
    db.collection("trips").doc(tripId).get(),
    db.collection("tripDiscovery").doc(tripId).get(),
  ]);
  if (!tripDoc.exists) throw new Error("Audited trip no longer exists.");

  let after = null;
  let activeFavorites = 0;
  let deletedUserRefs = 0;
  let complete = false;
  for (let page = 0; page < maxUserPages; page++) {
    let query = db.collection("users")
        .where("favouriteTrips", "array-contains", tripId)
        .limit(userPageSize);
    if (after) query = query.startAfter(after);
    const users = await query.get();
    for (const user of users.docs) {
      if (user.data().isDeleted === true) deletedUserRefs++;
      else activeFavorites++;
    }
    if (users.size < userPageSize) {
      complete = true;
      break;
    }
    after = users.docs.at(-1);
  }

  const tripCount = tripDoc.data().favouriteCount;
  const cardCount = cardDoc.data()?.favouriteCount;
  const validTripCount = Number.isSafeInteger(tripCount) && tripCount >= 0;
  const validCardCount = !cardDoc.exists ||
      (Number.isSafeInteger(cardCount) && cardCount >= 0);
  return {
    complete, activeFavorites, deletedUserRefs, cardExists: cardDoc.exists,
    invalidTripCount: !validTripCount,
    invalidCardCount: !validCardCount,
    tripCardDivergent: cardDoc.exists && tripCount !== cardCount,
    tripMismatch: complete && (!validTripCount || tripCount !== activeFavorites),
    cardMismatch: complete && cardDoc.exists &&
      (!validCardCount || cardCount !== activeFavorites),
  };
}

async function auditFavoriteTripPage(db, {after = null, limit = 10,
  userPageSize = 100, maxUserPages = 5} = {}) {
  bounded(limit, "Trip page size", 50);
  let query = db.collection("trips").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const trips = await query.get();
  const totals = {tripsScanned: 0, withCard: 0, missingCard: 0,
    countScanCapped: 0, deletedUserRefs: 0, invalidTripCount: 0,
    invalidCardCount: 0, tripCardDivergent: 0, tripMismatch: 0, cardMismatch: 0};
  for (const trip of trips.docs) {
    const result = await auditTripFavoriteCount(db, trip.id, {userPageSize, maxUserPages});
    totals.tripsScanned++;
    totals[result.cardExists ? "withCard" : "missingCard"]++;
    if (!result.complete) totals.countScanCapped++;
    totals.deletedUserRefs += result.deletedUserRefs;
    for (const key of ["invalidTripCount", "invalidCardCount", "tripCardDivergent",
      "tripMismatch", "cardMismatch"]) {
      if (result[key]) totals[key]++;
    }
  }
  return {totals, nextAfter: trips.size === limit ? trips.docs.at(-1).id : null};
}

async function auditFavoriteCardPage(db, {after = null, limit = 10} = {}) {
  bounded(limit, "Card page size", 50);
  let query = db.collection("tripDiscovery").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const cards = await query.get();
  const totals = {cardsScanned: 0, orphanCards: 0, creatorMismatchCards: 0,
    privateSourceCards: 0, removedSourceCards: 0, invalidCardCount: 0};
  for (const card of cards.docs) {
    totals.cardsScanned++;
    const trip = await db.collection("trips").doc(card.id).get();
    if (!trip.exists) {
      totals.orphanCards++;
    } else {
      const source = trip.data();
      if (card.data().createdBy !== source.createdBy) totals.creatorMismatchCards++;
      if (source.isPrivate === true) totals.privateSourceCards++;
      if (source.moderationRemoved === true ||
          ["deleted", "cancelled"].includes(source.tripStatus)) totals.removedSourceCards++;
    }
    const count = card.data().favouriteCount;
    if (!Number.isSafeInteger(count) || count < 0) totals.invalidCardCount++;
  }
  return {totals, nextAfter: cards.size === limit ? cards.docs.at(-1).id : null};
}

async function auditFavoriteUserPage(db, {after = null, limit = 10,
  maxLinksPerUser = 100} = {}) {
  bounded(limit, "User page size", 50);
  bounded(maxLinksPerUser, "Favorite links per user", 500);
  let query = db.collection("users").orderBy(FieldPath.documentId()).limit(limit);
  if (after) query = query.startAfter(after);
  const users = await query.get();
  const totals = {usersScanned: 0, deletedUsers: 0, malformedLists: 0,
    invalidLinks: 0, duplicateLinks: 0, deletedUserLinks: 0,
    linkScanCappedUsers: 0, linksChecked: 0, missingTripLinks: 0,
    unavailableTripLinks: 0, selfFavoriteLinks: 0};
  for (const user of users.docs) {
    totals.usersScanned++;
    const raw = user.data().favouriteTrips;
    if (raw != null && !Array.isArray(raw)) {
      totals.malformedLists++;
      continue;
    }
    const favorites = raw || [];
    const unique = [...new Set(favorites)];
    totals.duplicateLinks += favorites.length - unique.length;
    const ids = unique.filter((id) => {
      if (validId(id)) return true;
      totals.invalidLinks++;
      return false;
    });
    if (user.data().isDeleted === true) {
      totals.deletedUsers++;
      totals.deletedUserLinks += ids.length;
      continue;
    }
    if (ids.length > maxLinksPerUser) totals.linkScanCappedUsers++;
    const inspected = ids.slice(0, maxLinksPerUser);
    for (let start = 0; start < inspected.length; start += 100) {
      const refs = inspected.slice(start, start + 100).map((id) => db.collection("trips").doc(id));
      const trips = await db.getAll(...refs);
      for (const trip of trips) {
        totals.linksChecked++;
        if (!trip.exists) {
          totals.missingTripLinks++;
          continue;
        }
        const source = trip.data();
        if (source.createdBy === user.id) totals.selfFavoriteLinks++;
        if (source.isPrivate === true || source.moderationRemoved === true ||
            ["deleted", "cancelled", "completed"].includes(source.tripStatus)) {
          totals.unavailableTripLinks++;
        }
      }
    }
  }
  return {totals, nextAfter: users.size === limit ? users.docs.at(-1).id : null};
}

module.exports = {auditTripFavoriteCount, auditFavoriteTripPage,
  auditFavoriteCardPage, auditFavoriteUserPage};
