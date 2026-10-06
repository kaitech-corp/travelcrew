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
function available(trip) {
  if (!trip || trip.moderationRemoved || ["deleted", "cancelled", "completed"].includes(trip.tripStatus)) {
    throw new HttpsError("failed-precondition", "This trip is no longer accepting invitations.");
  }
}
async function active(db, reader, uid) {
  const [account, safety, profile] = await Promise.all([
    reader.get(db.doc(`users/${uid}`)), reader.get(db.doc(`safetyAccounts/${uid}`)), reader.get(db.doc(`publicProfile/${uid}`)),
  ]);
  if (!account.exists || account.data().isDeleted || safety.data()?.restricted || !profile.exists || profile.data().moderationRemoved) {
    throw new HttpsError("permission-denied", "This traveler is unavailable.");
  }
  return profile.data();
}
const memberOf = (trip, uid, member) => trip.createdBy === uid || (trip.joinedUsers || []).includes(uid) || member?.status === "active";
const invitationNoteId = (tripId, uid, invitationId) => eventKey("trip_invited", tripId, uid, invitationId);

function createTripInvitations(db, auth) {
  const reader = {get: (ref) => ref.get()};
  async function ownerTrip(uid, tripId) {
    const doc = await db.doc(`trips/${tripId}`).get();
    const trip = doc.data();
    if (trip?.createdBy !== uid) throw new HttpsError("permission-denied", "Trip owner access required.");
    available(trip); await active(db, reader, uid);
    return trip;
  }
  async function registered(uid) {
    try {
      const user = await auth.getUser(uid);
      if (!user.disabled) return;
    } catch (error) {
      if (error.code !== "auth/user-not-found") throw error;
    }
    throw new HttpsError("permission-denied", "This traveler is unavailable.");
  }
  return {
    async search(request) {
      const uid = identity(request); const {tripId, query} = request.data;
      if (typeof query !== "string" || query.trim().length < 2 || query.trim().length > 80) {
        throw new HttpsError("invalid-argument", "Enter 2 to 80 characters of a traveler's name.");
      }
      const trip = await ownerTrip(uid, tripId);
      const q = query.trim();
      // Existing profiles store displayName (the app's username), without a
      // normalized search index. Support common casing without a full scan.
      const prefixes = [...new Set([q, q.toLowerCase(), q.toUpperCase(),
        q[0].toUpperCase() + q.slice(1).toLowerCase(), q.toLowerCase().replace(/\b\p{L}/gu, (c) => c.toUpperCase())])];
      const snapshots = await Promise.all(prefixes.map((prefix) => db.collection("publicProfile")
          .orderBy("displayName").startAt(prefix).endAt(prefix + "\uf8ff").limit(10).get()));
      const candidates = new Map();
      for (const snapshot of snapshots) for (const doc of snapshot.docs) candidates.set(doc.id, doc.data());
      candidates.delete(uid);
      const ids = [...candidates.keys()].filter(validId);
      if (!ids.length) return {users: []};
      const accounts = await auth.getUsers(ids.map((id) => ({uid: id})));
      const enabled = new Set(accounts.users.filter((user) => !user.disabled).map((user) => user.uid));
      const users = await Promise.all(ids.map(async (id) => {
        if (!enabled.has(id) || await isBlocked(db, uid, id)) return null;
        let profile;
        try { profile = await active(db, reader, id); } catch (error) {
          if (error.code === "permission-denied") return null;
          throw error;
        }
        const [member, invite] = await Promise.all([
          db.doc(`trips/${tripId}/members/${id}`).get(), db.doc(`trips/${tripId}/invitations/${id}`).get(),
        ]);
        return {uid: id, displayName: profile.displayName || "Traveler", profileImage: profile.profileImage || "",
          hometown: profile.hometown || "", status: memberOf(trip, id, member.data()) ? "member" : invite.data()?.status === "pending" ? "invited" : "available"};
      }));
      return {users: users.filter(Boolean).sort((a, b) => a.displayName.localeCompare(b.displayName)).slice(0, 20)};
    },
    async send(request) {
      const uid = identity(request); const {tripId, userId, requestId} = request.data;
      if (!validId(userId) || !validId(requestId) || requestId.length > 128 || userId === uid) throw new HttpsError("invalid-argument", "Choose another traveler.");
      await ownerTrip(uid, tripId); await registered(userId);
      return db.runTransaction(async (tx) => {
        const tripRef = db.doc(`trips/${tripId}`); const inviteRef = tripRef.collection("invitations").doc(userId);
        const receiptRef = db.doc(`invitationAttempts/${eventKey(tripId, uid, userId, requestId)}`);
        const [tripDoc, inviteDoc, receipt, member] = await Promise.all([
          tx.get(tripRef), tx.get(inviteRef), tx.get(receiptRef), tx.get(tripRef.collection("members").doc(userId)),
        ]);
        const trip = tripDoc.data();
        if (trip?.createdBy !== uid) throw new HttpsError("permission-denied", "Trip owner access required.");
        available(trip);
        const owner = await active(db, tx, uid); await active(db, tx, userId);
        if (await isBlocked(db, uid, userId, tx)) throw new HttpsError("permission-denied", "This traveler is unavailable.");
        if (receipt.exists) return receipt.data().result;
        if (memberOf(trip, userId, member.data())) throw new HttpsError("already-exists", "This traveler is already in the crew.");
        const pending = inviteDoc.data()?.status === "pending";
        const invitationId = pending ? inviteDoc.data().invitationId : requestId;
        const result = {ok: true, invitationId, status: "pending"};
        tx.create(receiptRef, {tripId, userId, createdBy: uid, createdAt: stamp(), result});
        if (!pending) {
          tx.set(inviteRef, {tripId, userId, invitationId, createdBy: uid, status: "pending", createdAt: stamp(), updatedAt: stamp()});
          const id = invitationNoteId(tripId, userId, invitationId);
          tx.create(inboxRef(db, userId, id), {...notification(id, uid, userId, "trip_invited", tripId,
            "Trip invitation", `${owner.displayName || "A traveler"} invited you to ${trip.title || trip.destination || "a trip"}. Tap to accept or decline.`, true), invitationId});
        }
        return result;
      });
    },
    async preview(request) {
      const uid = identity(request); const {tripId, invitationId} = request.data;
      if (!validId(invitationId)) throw new HttpsError("invalid-argument", "Invitation required.");
      return db.runTransaction(async (tx) => {
        const [doc, invite] = await Promise.all([tx.get(db.doc(`trips/${tripId}`)), tx.get(db.doc(`trips/${tripId}/invitations/${uid}`))]);
        const trip = doc.data(); available(trip);
        if (invite.data()?.invitationId !== invitationId || invite.data()?.createdBy !== trip.createdBy) {
          throw new HttpsError("not-found", "This invitation is no longer available.");
        }
        const owner = await active(db, tx, trip.createdBy); await active(db, tx, uid);
        if (await isBlocked(db, uid, trip.createdBy, tx)) throw new HttpsError("permission-denied", "This invitation is unavailable.");
        // A pending invite reveals only this summary, never the private itinerary.
        return {tripId, invitationId, status: invite.data().status, title: trip.title || trip.destination || "Trip",
          destination: trip.destination || "", inviterName: owner.displayName || "A traveler"};
      });
    },
    async respond(request) {
      const uid = identity(request); const {tripId, invitationId, accept} = request.data;
      if (!validId(invitationId) || typeof accept !== "boolean") throw new HttpsError("invalid-argument", "Choose accept or decline.");
      await registered(uid);
      return db.runTransaction(async (tx) => {
        const tripRef = db.doc(`trips/${tripId}`); const inviteRef = tripRef.collection("invitations").doc(uid);
        const memberRef = tripRef.collection("members").doc(uid); const cardRef = db.doc(`tripDiscovery/${tripId}`);
        const roomRef = db.doc(`chat/${tripId}`); const joinRef = tripRef.collection("joinRequests").doc(uid);
        const [doc, inviteDoc, member, card, room, join] = await Promise.all([
          tx.get(tripRef), tx.get(inviteRef), tx.get(memberRef), tx.get(cardRef), tx.get(roomRef), tx.get(joinRef),
        ]);
        const trip = doc.data(); available(trip); const invite = inviteDoc.data();
        if (invite?.invitationId !== invitationId || invite?.createdBy !== trip.createdBy) throw new HttpsError("not-found", "This invitation is no longer available.");
        const profile = await active(db, tx, uid); await active(db, tx, trip.createdBy);
        if (await isBlocked(db, uid, trip.createdBy, tx)) throw new HttpsError("permission-denied", "This invitation is unavailable.");
        const status = accept ? "accepted" : "declined";
        if (invite.status === status) return {ok: true, status};
        if (invite.status !== "pending") throw new HttpsError("failed-precondition", "This invitation has already been answered.");
        const noteRef = inboxRef(db, uid, invitationNoteId(tripId, uid, invitationId));
        const ownerJoinRef = inboxRef(db, trip.createdBy, eventKey("join_request", tripId, uid, join.data()?.attemptId || "legacy"));
        const [note, ownerJoin] = await Promise.all([tx.get(noteRef), tx.get(ownerJoinRef)]);
        const alreadyMember = memberOf(trip, uid, member.data());
        tx.update(inviteRef, {status, updatedAt: stamp()});
        if (note.exists) tx.update(noteRef, {invitationStatus: status, pushEnabled: false, notificationStatus: "read", updateAt: Date.now(),
          notificationMessage: `You ${status} the invitation to ${trip.title || trip.destination || "the trip"}.`});
        if (accept && !alreadyMember) {
          const attemptId = `invite_${invitationId}`;
          tx.update(tripRef, {joinedUsers: FieldValue.arrayUnion(uid)});
          tx.set(memberRef, {userId: uid, role: "member", status: "active", joinedAt: stamp(), attemptId});
          tx.set(db.doc(`users/${uid}/tripMemberships/${tripId}`), {tripId, role: "member", status: "active", joinedAt: stamp()});
          if (card.exists) tx.update(cardRef, {memberCount: FieldValue.increment(1), updatedAt: stamp()});
          if (room.exists) tx.update(roomRef, {usersIds: FieldValue.arrayUnion(uid), updatedAt: stamp()});
        }
        if (accept && join.data()?.status === "pending") {
          tx.update(joinRef, {status: "accepted", reviewedBy: trip.createdBy, reviewedAt: stamp(), updatedAt: stamp()});
          if (ownerJoin.exists) tx.update(ownerJoinRef, {requestStatus: "accepted", pushEnabled: false, updateAt: Date.now()});
        }
        if (accept && !alreadyMember) {
          const id = eventKey("invite_accepted", tripId, uid, invitationId);
          tx.create(inboxRef(db, trip.createdBy, id), notification(id, uid, trip.createdBy, "invite_accepted", tripId,
            "Invitation accepted", `${profile.displayName || "A traveler"} joined ${trip.title || trip.destination || "your trip"}.`, true));
        }
        return {ok: true, status};
      });
    },
  };
}
module.exports = {createTripInvitations, invitationNoteId};
