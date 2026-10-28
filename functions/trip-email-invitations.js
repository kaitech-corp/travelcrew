const {createHash, randomUUID} = require("node:crypto");
const {HttpsError} = require("firebase-functions/v2/https");
const {FieldValue} = require("firebase-admin/firestore");
const {validId, normalizeEmails} = require("./validation");
const {assertActive, isBlocked} = require("./safety");

const hash = (...parts) => createHash("sha256").update(JSON.stringify(parts)).digest("hex");

function createTripEmailInvitationHandler(db, auth, log = () => {}) {
  return async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign in required.");
    const uid = request.auth.uid;
    const {tripId, emails, requestId: suppliedId} = request.data || {};
    if (!validId(tripId) || !Array.isArray(emails) || emails.length > 100 ||
        (suppliedId !== undefined && (!validId(suppliedId) || suppliedId.length > 128))) {
      throw new HttpsError("invalid-argument", "Invalid invite payload.");
    }
    const uniqueEmails = normalizeEmails(emails).sort();
    if (!uniqueEmails.length || uniqueEmails.length > 20) {
      throw new HttpsError("invalid-argument", "Supply 1 to 20 valid emails.");
    }
    // Older app versions omit requestId. Their calls remain supported during
    // rollout, but only clients sending a stable ID gain replay protection.
    const requestId = suppliedId || randomUUID();
    const fingerprint = hash(uniqueEmails);
    await assertActive(db, uid);
    const tripRef = db.collection("trips").doc(tripId);
    const receiptRef = tripRef.collection("emailInviteAttempts").doc(requestId);
    const [tripBefore, receiptBefore] = await Promise.all([tripRef.get(), receiptRef.get()]);
    const currentTrip = tripBefore.data();
    if (!currentTrip || currentTrip.createdBy !== uid) {
      throw new HttpsError("permission-denied", "Trip owner access required.");
    }
    if (currentTrip.tripStatus === "deleted" || currentTrip.moderationRemoved) {
      throw new HttpsError("failed-precondition", "This trip is unavailable.");
    }
    if (receiptBefore.exists) {
      if (receiptBefore.data().fingerprint !== fingerprint) {
        throw new HttpsError("invalid-argument", "Request ID already used for different emails.");
      }
      log("trip_email_invite_accepted", {tripId, ownerId: uid, requestId,
        queuedNow: 0, replayed: true});
      return receiptBefore.data().result;
    }
    const queueable = [];
    for (const email of uniqueEmails) {
      try {
        const recipient = await auth.getUserByEmail(email);
        if (recipient.disabled || await isBlocked(db, uid, recipient.uid)) continue;
      } catch (error) {
        if (error.code !== "auth/user-not-found") throw error;
      }
      queueable.push(email);
    }
    const outcome = await db.runTransaction(async (tx) => {
      const [tripDoc, receipt] = await Promise.all([tx.get(tripRef), tx.get(receiptRef)]);
      const trip = tripDoc.data();
      if (!trip || trip.createdBy !== uid) {
        throw new HttpsError("permission-denied", "Trip owner access required.");
      }
      if (trip.tripStatus === "deleted" || trip.moderationRemoved) {
        throw new HttpsError("failed-precondition", "This trip is unavailable.");
      }
      if (receipt.exists) {
        if (receipt.data().fingerprint !== fingerprint) {
          throw new HttpsError("invalid-argument", "Request ID already used for different emails.");
        }
        return {result: receipt.data().result, replayed: true};
      }
      const title = trip.title || trip.destination || "your trip";
      for (const email of queueable) {
        const mailId = hash(tripId, uid, requestId, email);
        tx.create(db.collection("mail").doc(mailId), {
          to: [email],
          message: {
            subject: "You have been invited to a trip!",
            text: `You have been invited to join the trip: ${title}. ` +
              "Open the Travel Crew app to request to join.",
          },
          createdBy: uid,
          tripId,
          createdAt: FieldValue.serverTimestamp(),
        });
      }
      const response = {sent: uniqueEmails.length, queued: uniqueEmails.length};
      tx.create(receiptRef, {createdBy: uid, fingerprint, result: response,
        createdAt: FieldValue.serverTimestamp()});
      tx.update(tripRef, {invitedUsers: FieldValue.arrayUnion(...uniqueEmails)});
      return {result: response, replayed: false};
    });
    log("trip_email_invite_accepted", {tripId, ownerId: uid, requestId,
      queuedNow: outcome.replayed ? 0 : queueable.length, replayed: outcome.replayed});
    return outcome.result;
  };
}

module.exports = {createTripEmailInvitationHandler};
