const {createHash} = require("node:crypto");
const {HttpsError} = require("firebase-functions/v2/https");
const {FieldValue} = require("firebase-admin/firestore");
const {validId} = require("./validation");

const reasons = new Set(["harassment", "hate", "sexual", "violence", "spam", "other"]);
const hash = (...parts) => createHash("sha256").update(JSON.stringify(parts)).digest("hex");
const blockRef = (db, a, b) => db.collection("users").doc(a).collection("blockedUsers").doc(b);
const statusRef = (db, uid) => db.collection("safetyAccounts").doc(uid);
const stamp = () => FieldValue.serverTimestamp();
function requireUser(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in required.");
  return request.auth.uid;
}
function requireId(value) {
  if (!validId(value)) throw new HttpsError("invalid-argument", "Invalid identifier.");
  return value;
}
async function assertActive(db, uid) {
  if ((await statusRef(db, uid).get()).data()?.restricted) {
    throw new HttpsError("permission-denied", "This account cannot interact right now.");
  }
}
async function isBlocked(db, a, b, reader = db) {
  if (!a || !b || a === b || a === "system") return false;
  const docs = await Promise.all([reader.get ? reader.get(blockRef(db, a, b)) : blockRef(db, a, b).get(),
    reader.get ? reader.get(blockRef(db, b, a)) : blockRef(db, b, a).get()]);
  return docs.some((doc) => doc.exists);
}
async function assertInteraction(db, a, b, reader = db) {
  if (await isBlocked(db, a, b, reader)) {
    throw new HttpsError("permission-denied", "This interaction is unavailable.");
  }
}
async function readableTrip(db, uid, id) {
  const ref = db.collection("trips").doc(id);
  const [doc, member, discovery] = await Promise.all([ref.get(), ref.collection("members").doc(uid).get(),
    db.collection("tripDiscovery").doc(id).get()]);
  const trip = doc.data();
  if (!trip || trip.tripStatus === "deleted") throw new HttpsError("not-found", "Content is no longer available.");
  const privateAccess = trip.createdBy === uid || (trip.joinedUsers || []).includes(uid) || member.data()?.status === "active";
  if (!privateAccess && !trip.isShared && !discovery.data()?.isDiscoverable) {
    throw new HttpsError("permission-denied", "Content is unavailable.");
  }
  // Discovery-only access must not expose private itinerary text in evidence.
  return {data: privateAccess || trip.isShared ? trip : discovery.data(), version: doc.updateTime?.toMillis() || 0};
}
function createSafetyHandlers(db) {
  return {
    async submitReport(request) {
      const uid = requireUser(request);
      const {targetType, targetId, roomId, reason, details = "", requestId} = request.data || {};
      requireId(targetId); requireId(requestId);
      if (!["user", "trip", "message"].includes(targetType) || !reasons.has(reason) ||
          typeof details !== "string" || details.length > 1000) {
        throw new HttpsError("invalid-argument", "Choose a reason and keep details within 1,000 characters.");
      }
      const receipt = db.collection("reportReceipts").doc(hash(uid, requestId));
      const fingerprint = hash(targetType, targetId, roomId || "", reason, details);
      const prior = await receipt.get();
      if (prior.exists) {
        if (prior.data().fingerprint !== fingerprint) throw new HttpsError("invalid-argument", "Request ID already used.");
        return {reportId: prior.data().reportId};
      }
      let source; let author; let version;
      if (targetType === "user") {
        const doc = await db.collection("publicProfile").doc(targetId).get();
        if (!doc.exists) throw new HttpsError("not-found", "Profile no longer available.");
        source = doc.data(); author = targetId; version = doc.updateTime?.toMillis() || 0;
      } else if (targetType === "trip") {
        const trip = await readableTrip(db, uid, targetId);
        source = trip.data; author = source.createdBy; version = trip.version;
      } else {
        requireId(roomId);
        const room = await db.collection("chat").doc(roomId).get();
        if (!(room.data()?.usersIds || []).includes(uid)) throw new HttpsError("permission-denied", "Chat access required.");
        const doc = await db.collection("chat").doc(roomId).collection("messages").doc(targetId).get();
        if (!doc.exists) throw new HttpsError("not-found", "Message no longer available.");
        source = doc.data(); author = source.createdBy; version = doc.updateTime?.toMillis() || 0;
      }
      requireId(author);
      if (author === uid) throw new HttpsError("invalid-argument", "You cannot report your own content.");
      const evidence = {};
      for (const key of ["displayName", "hometown", "title", "description", "data", "messageType", "profileImage"]) {
        if (typeof source[key] === "string") evidence[key] = source[key].slice(0, 8000);
      }
      if (Array.isArray(source.images)) evidence.images = source.images.filter((s) => typeof s === "string").slice(0, 5);
      let reportId = hash(uid, requestId);
      const targetIndex = db.collection("reportTargets").doc(hash(uid, targetType, targetId, roomId || "", version));
      const quota = db.collection("reportQuotas").doc(uid);
      await db.runTransaction(async (tx) => {
        const [existingReceipt, index, limit] = await Promise.all([tx.get(receipt), tx.get(targetIndex), tx.get(quota)]);
        if (existingReceipt.exists) {
          if (existingReceipt.data().fingerprint !== fingerprint) throw new HttpsError("invalid-argument", "Request ID already used.");
          reportId = existingReceipt.data().reportId;
          return;
        }
        const existing = index.exists ? await tx.get(db.collection("reports").doc(index.data().reportId)) : null;
        const now = Date.now(); const window = limit.data();
        const count = window && now - window.startedAt < 3600000 ? window.count : 0;
        if (count >= 10) throw new HttpsError("resource-exhausted", "Too many reports. Please try again later.");
        if (existing?.exists && ["open", "in_review"].includes(existing.data().status)) {
          reportId = existing.id;
          tx.create(existing.ref.collection("submissions").doc(hash(requestId)), {reason, details: details.trim(), createdAt: stamp()});
        } else {
          reportId = hash(uid, requestId);
          tx.create(db.collection("reports").doc(reportId), {reporterId: uid, targetType, targetId, roomId: roomId || null,
            targetUserId: author, reason, details: details.trim(), evidence, sourceVersion: version,
            createdAt: stamp(), status: "open"});
          tx.set(targetIndex, {reportId, reporterId: uid, createdAt: stamp()});
        }
        tx.set(quota, {startedAt: count ? window.startedAt : now, count: count + 1});
        tx.create(receipt, {reportId, fingerprint, reporterId: uid, createdAt: stamp()});
      });
      return {reportId};
    },
    async blockUser(request) {
      const uid = requireUser(request); const target = requireId(request.data?.targetUserId);
      if (uid === target) throw new HttpsError("invalid-argument", "You cannot block yourself.");
      await db.runTransaction(async (tx) => {
        const own = db.collection("publicProfile").doc(uid); const other = db.collection("publicProfile").doc(target);
        const [a, b, existing] = await Promise.all([tx.get(own), tx.get(other), tx.get(blockRef(db, uid, target))]);
        if (!b.exists) throw new HttpsError("not-found", "Profile no longer available.");
        if (!existing.exists) tx.create(blockRef(db, uid, target), {createdAt: stamp(), schemaVersion: 1});
        if (a.exists) tx.update(own, {following: FieldValue.arrayRemove(target), followers: FieldValue.arrayRemove(target)});
        tx.update(other, {following: FieldValue.arrayRemove(uid), followers: FieldValue.arrayRemove(uid)});
      });
      return {blocked: true};
    },
    async unblockUser(request) {
      const uid = requireUser(request); const target = requireId(request.data?.targetUserId);
      await blockRef(db, uid, target).delete();
      return {blocked: false};
    },
    async followUser(request) {
      const uid = requireUser(request); const target = requireId(request.data?.targetUserId);
      if (uid === target || typeof request.data?.following !== "boolean") throw new HttpsError("invalid-argument", "Invalid follow request.");
      await assertActive(db, uid);
      await db.runTransaction(async (tx) => {
        const a = db.collection("publicProfile").doc(uid); const b = db.collection("publicProfile").doc(target);
        const docs = await Promise.all([tx.get(a), tx.get(b), tx.get(statusRef(db, target))]);
        if (!docs[0].exists || !docs[1].exists || docs[2].data()?.restricted) throw new HttpsError("not-found", "Profile unavailable.");
        if (request.data.following) await assertInteraction(db, uid, target, tx);
        const op = request.data.following ? FieldValue.arrayUnion : FieldValue.arrayRemove;
        tx.update(a, {following: op(target)}); tx.update(b, {followers: op(uid)});
      });
      return {ok: true};
    },
    async acceptJoinRequest(request) {
      const uid = requireUser(request); const tripId = requireId(request.data?.tripId);
      const target = requireId(request.data?.userId); await assertActive(db, uid); await assertActive(db, target);
      const tripRef = db.collection("trips").doc(tripId);
      await db.runTransaction(async (tx) => {
        const req = tripRef.collection("joinRequests").doc(target);
        const discovery = db.collection("tripDiscovery").doc(tripId);
        const [trip, join, card] = await Promise.all([tx.get(tripRef), tx.get(req), tx.get(discovery)]);
        if (!trip.exists || trip.data().createdBy !== uid || trip.data().tripStatus === "deleted") throw new HttpsError("permission-denied", "Trip owner access required.");
        if (join.data()?.status === "accepted") return;
        if (join.data()?.status !== "pending") throw new HttpsError("failed-precondition", "No pending request.");
        await assertInteraction(db, uid, target, tx);
        tx.update(tripRef, {joinedUsers: FieldValue.arrayUnion(target)});
        tx.set(tripRef.collection("members").doc(target), {userId: target, role: "member", status: "active", joinedAt: stamp()});
        tx.set(db.collection("users").doc(target).collection("tripMemberships").doc(tripId), {tripId, role: "member", status: "active", joinedAt: stamp()});
        tx.update(req, {status: "accepted", reviewedBy: uid, reviewedAt: stamp(), updatedAt: stamp()});
        if (card.exists && !(trip.data().joinedUsers || []).includes(target)) tx.update(discovery, {memberCount: FieldValue.increment(1), updatedAt: stamp()});
      });
      return {ok: true};
    },
    async reviewReport(request) {
      const uid = requireUser(request);
      if (request.auth.token?.admin !== true) throw new HttpsError("permission-denied", "Moderator access required.");
      const {reportId, action, rationale = ""} = request.data || {}; requireId(reportId);
      if (!["review", "dismiss", "remove", "restrict"].includes(action) || typeof rationale !== "string" || !rationale.trim() || rationale.length > 1000) throw new HttpsError("invalid-argument", "Action and rationale required.");
      const ref = db.collection("reports").doc(reportId);
      await db.runTransaction(async (tx) => {
        const doc = await tx.get(ref);
        if (!doc.exists) throw new HttpsError("not-found", "Report not found.");
        const report = doc.data();
        if (["resolved", "dismissed"].includes(report.status)) throw new HttpsError("failed-precondition", "Report is already closed.");
        const target = report.targetType === "trip" ? db.collection("trips").doc(report.targetId) :
          report.targetType === "user" ? db.collection("publicProfile").doc(report.targetId) :
          db.collection("chat").doc(report.roomId).collection("messages").doc(report.targetId);
        const content = await tx.get(target);
        if (action === "remove") {
          tx.set(db.collection("removedContent").doc(hash(target.path)), {path: target.path, reportId, removedAt: stamp()});
          if (report.targetType === "trip") {
            if (content.exists) tx.update(target, {tripStatus: "deleted", moderationRemoved: true});
            tx.delete(db.collection("tripDiscovery").doc(report.targetId));
          } else if (report.targetType === "message") {
            if (content.exists) tx.update(target, {data: "", messageType: "Text", moderationRemoved: true});
          } else if (content.exists) {
            tx.update(target, {displayName: "Traveler", profileImage: "", hometown: "", facebookLink: "", instagramLink: "", firstName: "", lastName: "", topDestinations: [], moderationRemoved: true});
          }
        }
        if (action === "restrict") tx.set(statusRef(db, report.targetUserId), {restricted: true, reportId, updatedAt: stamp()});
        tx.update(ref, {status: action === "review" ? "in_review" : action === "dismiss" ? "dismissed" : "resolved",
          assignedTo: uid, reviewedAt: stamp(), resolution: rationale.trim(), actionTaken: action});
        tx.create(ref.collection("audit").doc(), {moderatorId: uid, action, rationale: rationale.trim(), createdAt: stamp()});
      });
      return {ok: true};
    },
  };
}
module.exports = {createSafetyHandlers, isBlocked, assertActive, blockRef};
