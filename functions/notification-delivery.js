const {isBlocked} = require("./safety");
const {eventKey} = require("./notification-data");

async function eligible(db, actor, recipient) {
  if (actor === recipient || await isBlocked(db, actor, recipient)) return false;
  const ids = actor === "system" ? [recipient] : [actor, recipient];
  for (const id of ids) {
    if ((await db.collection("safetyAccounts").doc(id).get()).data()?.restricted) return false;
  }
  return true;
}

// FCM is at-least-once. Per-token receipts prevent repeating successful sends
// during ordinary retries; a crash between FCM acceptance and receipt can repeat.
async function deliver(db, messaging, recipient, key, payload, stillEligible) {
  const tokens = await db.collection("tokens").doc(recipient).collection("tokens").get();
  for (const token of tokens.docs) {
    if (!await stillEligible()) return;
    const receipt = db.collection("pushDeliveries").doc(eventKey(key, recipient, token.id));
    const claimed = await db.runTransaction(async (tx) => {
      const current = (await tx.get(receipt)).data();
      if (current?.done) return false;
      if (current?.leaseUntil > Date.now()) throw new Error("Push delivery is in progress; retry later");
      tx.set(receipt, {leaseUntil: Date.now() + 60000, createdAt: new Date()});
      return true;
    });
    if (!claimed) continue;
    try {
      const result = await messaging.sendEachForMulticast({tokens: [token.id], ...payload});
      const error = result.responses[0]?.error;
      if (error && !["messaging/invalid-registration-token", "messaging/registration-token-not-registered"].includes(error.code)) throw error;
      if (error) await token.ref.delete();
      await receipt.set({done: true, createdAt: new Date()});
    } catch (error) {
      await receipt.set({leaseUntil: 0, createdAt: new Date()});
      throw error;
    }
  }
}

async function sendInboxPush(db, messaging, event) {
  const {userId, notificationId} = event.params;
  const ref = db.collection("notifications").doc(userId).collection("notification").doc(notificationId);
  const current = async () => {
    const n = (await ref.get()).data();
    if (!n || n.schemaVersion !== 2 || !n.pushEnabled || !n.isActive || n.notificationStatus === "read" || !n.sentTo?.includes(userId)) return null;
    if (!await eligible(db, n.createdBy, userId)) return null;
    if (n.notificationType === "Trip" || n.notificationType === "Invitation") {
      const trip = (await db.collection("trips").doc(n.notificationForId).get()).data();
      if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved) return null;
      if (n.eventType === "trip_invited") {
        const invite = (await db.doc(`trips/${n.notificationForId}/invitations/${userId}`).get()).data();
        if (invite?.status !== "pending" || invite.invitationId !== n.invitationId || invite.createdBy !== trip.createdBy ||
            ["cancelled", "completed"].includes(trip.tripStatus) || trip.createdBy !== n.createdBy) return null;
        const [recipient, owner] = await Promise.all([db.doc(`users/${userId}`).get(), db.doc(`users/${trip.createdBy}`).get()]);
        if (!recipient.exists || recipient.data().isDeleted || !owner.exists || owner.data().isDeleted) return null;
      } else if (n.eventType === "join_requested") {
        const join = (await db.collection("trips").doc(n.notificationForId).collection("joinRequests").doc(n.requestUserId).get()).data();
        if (join?.status !== "pending" || join.attemptId !== n.attemptId || trip.createdBy !== userId) return null;
      } else if (trip.createdBy !== userId && !(trip.joinedUsers || []).includes(userId)) return null;
    }
    return n;
  };
  const n = await current(); if (!n) return;
  await deliver(db, messaging, userId, notificationId, {
    notification: {title: n.notificationTitle, body: n.notificationMessage},
    data: {notificationId, notificationForId: n.notificationForId, type: n.notificationType, recipientUid: userId},
  }, async () => !!await current());
}

async function sendChatPush(db, messaging, event) {
  if (!event.data) return;
  const {roomId, messageId} = event.params;
  const roomRef = db.collection("chat").doc(roomId);
  const msgRef = roomRef.collection("messages").doc(messageId);
  const snapshot = await msgRef.get();
  const msg = snapshot.data();
  if (!msg?.createdBy || msg.moderationRemoved) return;
  const room = (await roomRef.get()).data();
  const trip = (await db.collection("trips").doc(roomId).get()).data();
  if (!trip || trip.tripStatus === "deleted" || trip.moderationRemoved || !room?.usersIds?.includes(msg.createdBy)) return;
  const members = new Set([trip.createdBy, ...(trip.joinedUsers || [])]);
  if (!members.has(msg.createdBy)) return;
  for (const uid of [...new Set(room.usersIds)].filter((id) => members.has(id) && id !== msg.createdBy)) {
    if (!await eligible(db, msg.createdBy, uid)) continue;
    const activity = db.collection("users").doc(uid).collection("chatActivity").doc(roomId);
    const sentAt = snapshot.createTime.toMillis();
    await db.runTransaction(async (tx) => {
      const old = (await tx.get(activity)).data();
      if ((old?.lastMessageAt || 0) >= sentAt) return;
      tx.set(activity, {lastMessageAt: sentAt, lastSenderId: msg.createdBy, roomId}, {merge: true});
    });
    await deliver(db, messaging, uid, eventKey("chat", roomId, messageId), {
      notification: {title: "New trip message", body: "You have a new message in your trip chat."},
      data: {type: "Chat", notificationForId: roomId, recipientUid: uid},
    }, async () => {
      const [latestRoom, latestMsg, state, latestTrip] = await Promise.all([roomRef.get(), msgRef.get(), activity.get(), db.collection("trips").doc(roomId).get()]);
      const t = latestTrip.data();
      return latestRoom.data()?.usersIds?.includes(uid) && latestRoom.data()?.usersIds?.includes(msg.createdBy) &&
        t && t.tripStatus !== "deleted" && !t.moderationRemoved &&
        [t.createdBy, ...(t.joinedUsers || [])].includes(uid) && [t.createdBy, ...(t.joinedUsers || [])].includes(msg.createdBy) &&
        latestMsg.exists && !latestMsg.data().moderationRemoved &&
        (state.data()?.readAt?.toMillis?.() || 0) < sentAt && await eligible(db, msg.createdBy, uid);
    });
  }
}
module.exports = {sendInboxPush, sendChatPush, deliver, eligible};
