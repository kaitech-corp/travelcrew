const {FieldValue} = require("firebase-admin/firestore");
const {isBlocked} = require("./safety");

async function cleanBlockedPair(db, uid, target) {
  // The block is already durable. This retryable cleanup never changes memberships.
  for (const [owner, other] of [[uid, target], [target, uid]]) {
    const trips = await db.collection("trips").where("createdBy", "==", owner).get();
    for (const trip of trips.docs) {
      const ref = trip.ref.collection("joinRequests").doc(other);
      await db.runTransaction(async (tx) => {
        const req = await tx.get(ref);
        if (await isBlocked(db, uid, target, tx) && req.data()?.status === "pending") {
          tx.update(ref, {status: "cancelled", updatedAt: FieldValue.serverTimestamp()});
        }
      });
    }
    const notifications = await db.collection("notifications").doc(owner)
        .collection("notification").where("createdBy", "==", other).get();
    for (const doc of notifications.docs) {
      await db.runTransaction(async (tx) => {
        if (await isBlocked(db, uid, target, tx)) tx.delete(doc.ref);
      });
    }
  }
}
async function queueReportAlert(db, reportId, overdue = false) {
  const recipient = process.env.MODERATION_ALERT_EMAIL;
  if (!recipient) return false;
  const id = `moderation_${overdue ? "overdue_" : ""}${reportId}`;
  const project = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT;
  const database = process.env.FIRESTORE_DATABASE_ID || "travel-crew-db-2";
  const link = `https://console.firebase.google.com/project/${project}/firestore/databases/${database}/data`;
  try {
    await db.collection("mail").doc(id).create({
      to: [recipient], message: {subject: overdue ? "Report awaiting review" : "New content report",
        text: `Report: ${reportId}\nReview in the restricted moderation queue: ${link}`},
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    if (error.code !== 6 && error.code !== "already-exists") throw error;
  }
  return true;
}
async function maintainReports(db) {
  const cutoff = new Date(Date.now() - 86400000);
  for (const status of ["open", "in_review"]) {
    const reports = await db.collection("reports").where("status", "==", status).get();
    for (const doc of reports.docs) {
      if (doc.data().createdAt?.toDate() < cutoff) await queueReportAlert(db, doc.id, true);
    }
  }
  // A 90-day retention window for closed evidence; open cases remain reviewable.
  const expired = await db.collection("reports").where("createdAt", "<", new Date(Date.now() - 90 * 86400000)).get();
  for (const doc of expired.docs) {
    if (["resolved", "dismissed"].includes(doc.data().status)) await db.recursiveDelete(doc.ref);
  }
  for (const name of ["reportReceipts", "reportTargets", "reportQuotas"]) {
    const field = name === "reportQuotas" ? "startedAt" : "createdAt";
    const cutoffValue = Date.now() - 90 * 86400000;
    const docs = await db.collection(name).where(field, "<", name === "reportQuotas" ? cutoffValue : new Date(cutoffValue)).get();
    const writer = db.bulkWriter();
    for (const doc of docs.docs) writer.delete(doc.ref);
    await writer.close();
  }
}
async function cleanSafetyData(db, uid) {
  await db.recursiveDelete(db.collection("users").doc(uid).collection("blockedUsers"));
  await db.collection("reportQuotas").doc(uid).delete();
  const receipts = await db.collection("reportReceipts").where("reporterId", "==", uid).get();
  for (const doc of receipts.docs) await doc.ref.delete();
  const targets = await db.collection("reportTargets").where("reporterId", "==", uid).get();
  for (const doc of targets.docs) await doc.ref.delete();
  const reports = await db.collection("reports").where("reporterId", "==", uid).get();
  for (const doc of reports.docs) await doc.ref.update({reporterId: null});
}
module.exports = {cleanBlockedPair, queueReportAlert, maintainReports, cleanSafetyData};
