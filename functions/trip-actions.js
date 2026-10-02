const {FieldValue} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {validId} = require("./validation");
const {isBlocked} = require("./safety");
const {eventKey, inboxRef, notification} = require("./notification-data");

const stamp = () => FieldValue.serverTimestamp();
function identity(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in required.");
  if (!validId(request.data?.tripId)) throw new HttpsError("invalid-argument", "Trip required.");
  return request.auth.uid;
}
async function active(db, tx, uid) {
  if ((await tx.get(db.collection("safetyAccounts").doc(uid))).data()?.restricted) {
    throw new HttpsError("permission-denied", "Account unavailable.");
  }
}
function available(trip) {
  if (!trip || trip.moderationRemoved || ["deleted", "cancelled", "completed"].includes(trip.tripStatus)) {
    throw new HttpsError("failed-precondition", "This trip is no longer accepting requests.");
  }
}
function attemptMatches(join, attemptId) {
  if ((join?.attemptId || "legacy") !== attemptId) throw new HttpsError("failed-precondition", "This request has changed. Refresh and try again.");
}

function createTripActions(db) {
  return {
    async requestJoin(request) {
      const uid = identity(request); const {tripId, attemptId, message = null} = request.data;
      if (!validId(attemptId) || (message !== null && (typeof message !== "string" || message.length > 1000))) throw new HttpsError("invalid-argument", "Invalid request.");
      return db.runTransaction(async (tx) => {
        const tripRef = db.collection("trips").doc(tripId);
        const req = tripRef.collection("joinRequests").doc(uid);
        const receipt = db.collection("joinAttempts").doc(eventKey(tripId, uid, attemptId));
        const [tripDoc, joinDoc, prior, card, profile, member] = await Promise.all([
          tx.get(tripRef), tx.get(req), tx.get(receipt), tx.get(db.collection("tripDiscovery").doc(tripId)),
          tx.get(db.collection("publicProfile").doc(uid)), tx.get(tripRef.collection("members").doc(uid)),
        ]);
        await active(db, tx, uid);
        const trip = tripDoc.data(); available(trip);
        if (await isBlocked(db, uid, trip.createdBy, tx)) throw new HttpsError("permission-denied", "This interaction is unavailable.");
        await active(db, tx, trip.createdBy);
        if (prior.exists) return {ok: true, attemptId: joinDoc.data()?.attemptId || attemptId, status: joinDoc.data()?.status || "cancelled"};
        if (trip.createdBy === uid || (trip.joinedUsers || []).includes(uid) || member.data()?.status === "active") throw new HttpsError("failed-precondition", "Already a trip member.");
        if (!trip.isShared && !card.data()?.isDiscoverable) throw new HttpsError("permission-denied", "This trip is unavailable.");
        if (joinDoc.data()?.status === "pending") {
          // Remember an alias too: a retry of this concurrent request must not
          // reopen the original request after it has been cancelled/reviewed.
          const canonicalAttemptId = joinDoc.data().attemptId || "legacy";
          tx.create(receipt, {tripId, userId: uid, attemptId, canonicalAttemptId, createdAt: stamp()});
          return {ok: true, attemptId: canonicalAttemptId, status: "pending"};
        }
        tx.create(receipt, {tripId, userId: uid, attemptId, createdAt: stamp()});
        tx.set(req, {tripId, userId: uid, attemptId, status: "pending", message,
          createdAt: joinDoc.data()?.createdAt || stamp(), updatedAt: stamp(), requestedAt: stamp(), reviewedAt: null, reviewedBy: null});
        const id = eventKey("join_request", tripId, uid, attemptId);
        tx.create(inboxRef(db, trip.createdBy, id), {...notification(id, uid, trip.createdBy, "join_requested", tripId,
          "Join request", `${profile.data()?.displayName || "A traveler"} requested to join ${trip.title || trip.destination || "your trip"}.`, true), attemptId, requestUserId: uid, requestStatus: "pending"});
        return {ok: true, attemptId, status: "pending"};
      });
    },
    async transition(request, status) {
      const uid = identity(request); const {tripId, attemptId} = request.data;
      const target = status === "cancelled" ? uid : request.data.userId;
      if (!validId(target) || !validId(attemptId)) throw new HttpsError("invalid-argument", "Request identity required.");
      return db.runTransaction(async (tx) => {
        const tripRef = db.collection("trips").doc(tripId); const req = tripRef.collection("joinRequests").doc(target);
        const cardRef = db.collection("tripDiscovery").doc(tripId); const roomRef = db.collection("chat").doc(tripId);
        const [tripDoc, joinDoc, card, room] = await Promise.all([tx.get(tripRef), tx.get(req), tx.get(cardRef), tx.get(roomRef)]);
        const trip = tripDoc.data();
        if (!trip || (status !== "cancelled" && trip.createdBy !== uid)) throw new HttpsError("permission-denied", "Trip owner access required.");
        await active(db, tx, uid);
        const join = joinDoc.data(); attemptMatches(join, attemptId);
        if (join?.status === status) return {ok: true};
        if (join?.status !== "pending") throw new HttpsError("failed-precondition", "No pending request.");
        if (status !== "cancelled") {
          available(trip); await active(db, tx, target);
          if (await isBlocked(db, uid, target, tx)) throw new HttpsError("permission-denied", "This interaction is unavailable.");
        }
        const ownerNote = inboxRef(db, trip.createdBy, eventKey("join_request", tripId, target, attemptId));
        const existingNote = await tx.get(ownerNote);
        tx.update(req, {status, updatedAt: stamp(), reviewedAt: status === "cancelled" ? null : stamp(), reviewedBy: status === "cancelled" ? null : uid});
        if (existingNote.exists) tx.update(ownerNote, {requestStatus: status, pushEnabled: false, updateAt: Date.now(),
          notificationTitle: status === "cancelled" ? "Join request cancelled" : `Join request ${status}`,
          notificationMessage: status === "cancelled" ? "The traveler cancelled this join request." : `You ${status === "rejected" ? "declined" : "accepted"} this join request.`});
        if (status === "accepted") {
          tx.update(tripRef, {joinedUsers: FieldValue.arrayUnion(target)});
          tx.set(tripRef.collection("members").doc(target), {userId: target, role: "member", status: "active", joinedAt: stamp(), attemptId});
          tx.set(db.collection("users").doc(target).collection("tripMemberships").doc(tripId), {tripId, role: "member", status: "active", joinedAt: stamp()});
          if (card.exists && !(trip.joinedUsers || []).includes(target)) tx.update(cardRef, {memberCount: FieldValue.increment(1), updatedAt: stamp()});
          if (room.exists) tx.update(roomRef, {usersIds: FieldValue.arrayUnion(target), updatedAt: stamp()});
        }
        if (status !== "cancelled") {
          const id = eventKey(status, tripId, target, attemptId);
          tx.create(inboxRef(db, target, id), {...notification(id, uid, target, `join_${status}`, tripId,
            status === "accepted" ? "Join request accepted" : "Join request update",
            `Your request to join ${trip.title || trip.destination || "the trip"} was ${status === "accepted" ? "accepted" : "declined"}.`, status === "accepted"), attemptId});
        }
        return {ok: true};
      });
    },
    async leave(request) {
      const uid = identity(request); const {tripId, membershipAttemptId} = request.data;
      if (!validId(membershipAttemptId)) throw new HttpsError("invalid-argument", "Membership identity required.");
      return db.runTransaction(async (tx) => {
        const tripRef = db.collection("trips").doc(tripId); const memberRef = tripRef.collection("members").doc(uid);
        const cardRef = db.collection("tripDiscovery").doc(tripId); const roomRef = db.collection("chat").doc(tripId);
        const [doc, member, card, room, profile] = await Promise.all([tx.get(tripRef), tx.get(memberRef), tx.get(cardRef), tx.get(roomRef), tx.get(db.collection("publicProfile").doc(uid))]);
        const trip = doc.data();
        if (!trip || trip.createdBy === uid) throw new HttpsError("failed-precondition", "The trip creator cannot leave.");
        await active(db, tx, uid);
        if ((member.data()?.attemptId || "legacy") !== membershipAttemptId) throw new HttpsError("failed-precondition", "Membership changed. Refresh before leaving.");
        if (!(trip.joinedUsers || []).includes(uid) && member.data()?.status !== "active") return {ok: true};
        const blocked = await isBlocked(db, uid, trip.createdBy, tx);
        const id = eventKey("member_left", tripId, uid, member.data()?.attemptId || member.data()?.joinedAt || "legacy");
        const note = inboxRef(db, trip.createdBy, id); const existing = await tx.get(note);
        tx.update(tripRef, {joinedUsers: FieldValue.arrayRemove(uid)});
        tx.set(memberRef, {userId: uid, role: "member", status: "left", attemptId: membershipAttemptId, removedAt: stamp()});
        tx.delete(db.collection("users").doc(uid).collection("tripMemberships").doc(tripId));
        if (card.exists) tx.update(cardRef, {memberCount: Math.max(1, (card.data().memberCount || 1) - 1), updatedAt: stamp()});
        if (room.exists) tx.update(roomRef, {usersIds: FieldValue.arrayRemove(uid), updatedAt: stamp()});
        if (!blocked && !existing.exists) tx.create(note, notification(id, uid, trip.createdBy, "member_left", tripId,
          "Traveler left trip", `${profile.data()?.displayName || "A traveler"} left ${trip.title || trip.destination || "your trip"}.`));
        return {ok: true};
      });
    },
  };
}
module.exports = {createTripActions};
