const {createHash} = require("node:crypto");

const eventKey = (...parts) => createHash("sha256").update(JSON.stringify(parts)).digest("hex");
const inboxRef = (db, uid, id) => db.collection("notifications").doc(uid).collection("notification").doc(id);

function notification(id, actor, recipient, type, target, title, message, push = false) {
  return {notificationId: id, eventType: type, notificationType: type === "trip_invited" ? "Invitation" : type.startsWith("join_") || type === "member_left" || type === "invite_accepted" ? "Trip" : type === "follow" ? "Profile" : "Welcome",
    notificationForId: target, notificationTitle: title, notificationMessage: message,
    notificationStatus: "unread", createdBy: actor, sentTo: [recipient],
    createdAt: Date.now(), updateAt: Date.now(), updateBy: actor,
    isActive: true, isTopic: false, notificationTopic: [], serverForwarded: true,
    schemaVersion: 2, pushEnabled: push};
}

module.exports = {eventKey, inboxRef, notification};
