const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {onRequest, HttpsError, onCall} = require("firebase-functions/v2/https");
const {initializeApp, getApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {getStorage} = require("firebase-admin/storage");
const {GoogleAuth} = require("google-auth-library");
const logger = require("firebase-functions/logger");
const {validId, normalizeEmails, validPhoto} = require("./validation");

initializeApp();

const DATABASE_ID = process.env.FIRESTORE_DATABASE_ID || "travel-crew-db-2";
const getDb = () => getFirestore(DATABASE_ID);

// Hosting routes /assistant/** and OAuth discovery to this single service.
// Lazy construction keeps deployment inspection independent of runtime config.
let assistantApp;
exports.assistantV1 = onRequest({maxInstances: 10, timeoutSeconds: 60, memory: "256MiB", invoker: "public"}, (req, res) => {
  if (!process.env.ASSISTANT_BASE_URL || !process.env.ASSISTANT_FIREBASE_CONFIG) {
    return res.status(503).json({error: "not_configured", error_description: "Assistant connections are not configured yet"});
  }
  if (!assistantApp) {
    const {createAssistantApp} = require("./assistant-api");
    assistantApp = createAssistantApp({db: getDb(), auth: getAuth(), baseUrl: process.env.ASSISTANT_BASE_URL,
      firebaseConfig: JSON.parse(process.env.ASSISTANT_FIREBASE_CONFIG), logger});
  }
  return assistantApp(req, res);
});

const {getAuth} = require("firebase-admin/auth");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {createSafetyHandlers, isBlocked, assertActive} = require("./safety");
const {cleanBlockedPair, queueReportAlert, maintainReports, cleanSafetyData} = require("./safety-triggers");
const safety = createSafetyHandlers(getDb());
exports.submitReportV3 = onCall(safety.submitReport);
exports.blockUserV3 = onCall(safety.blockUser);
exports.unblockUserV3 = onCall(safety.unblockUser);
exports.followUserV3 = onCall(safety.followUser);
const {createTripActions} = require("./trip-actions");
const {notification} = require("./notification-data");
const {sendInboxPush, sendChatPush} = require("./notification-delivery");
const tripActions = createTripActions(getDb());
exports.requestToJoinTripV3 = onCall(tripActions.requestJoin);
exports.cancelJoinRequestV3 = onCall((request) => tripActions.transition(request, "cancelled"));
exports.acceptJoinRequestV3 = onCall((request) => tripActions.transition(request, "accepted"));
exports.rejectJoinRequestV3 = onCall((request) => tripActions.transition(request, "rejected"));
exports.leaveTripV3 = onCall(tripActions.leave);
exports.reviewReportV3 = onCall(safety.reviewReport);
exports.cleanBlockedPairV3 = onDocumentCreated(
    {database: DATABASE_ID, document: "users/{uid}/blockedUsers/{target}", retry: true},
    (event) => cleanBlockedPair(getDb(), event.params.uid, event.params.target),
);
exports.alertReportV3 = onDocumentCreated(
    {database: DATABASE_ID, document: "reports/{reportId}", retry: true},
    async (event) => {
      if (!await queueReportAlert(getDb(), event.params.reportId)) {
        logger.error("Moderation alert destination is not configured", {reportId: event.params.reportId});
      }
    },
);
exports.maintainReportsV3 = onSchedule("every 60 minutes", () => maintainReports(getDb()));
exports.maintainNotificationReceiptsV3 = onSchedule("every 24 hours", async () => {
  // Keep receipts beyond Eventarc's retry window. Bound each cleanup run.
  const stale = await getDb().collection("pushDeliveries")
      .where("createdAt", "<", new Date(Date.now() - 30 * 86400000)).limit(500).get();
  const batch = getDb().batch();
  for (const doc of stale.docs) batch.delete(doc.ref);
  if (stale.size) await batch.commit();
});
exports.cleanDeletedUserSafetyV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "users/{uid}", retry: true},
    async (event) => {
      if (!event.data.after.exists || event.data.after.data().isDeleted === true) {
        await cleanSafetyData(getDb(), event.params.uid);
      }
    },
);

// Text moderation triggers (V3 export names avoid trigger type conversion errors with 1st gen functions)
const {createModerator, profileFields, tripFields, discoveryFields} =
  require("./moderation");
exports.moderateChatTextV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "chat/{roomId}/messages/{messageId}", retry: true},
    async (event) => {
      if (event.data?.after?.data()?.messageType !== "Text") return;
      await createModerator(getDb(), ["data"])(event);
    },
);
exports.moderatePublicProfileTextV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "publicProfile/{userId}", retry: true},
    createModerator(getDb(), profileFields, ["topDestinations"]),
);
exports.moderateLegacyPublicProfileTextV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "userPublicProfile/{userId}", retry: true},
    createModerator(getDb(), profileFields, ["topDestinations"]),
);
exports.moderateTripTextV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "trips/{tripId}", retry: true},
    createModerator(getDb(), tripFields),
);
exports.moderateTripDiscoveryTextV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "tripDiscovery/{tripId}", retry: true},
    createModerator(getDb(), discoveryFields),
);

// Image moderation triggers
const {imageTargets, createVisionScanner, createImageModerator} =
  require("./image-moderation");
const auth = new GoogleAuth({scopes: "https://www.googleapis.com/auth/cloud-platform"});
const scan = createVisionScanner(async () => ({access_token: await auth.getAccessToken()}));
const getBucketName = () => {
  try {
    return getStorage().bucket().name;
  } catch {
    return getApp().options.storageBucket ||
      `${process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT}.appspot.com`;
  }
};

for (const [name, [document, fields, arrays]] of Object.entries(imageTargets)) {
  exports[name] = onDocumentWritten(
      {database: DATABASE_ID, document, retry: true},
      createImageModerator({
        db: getDb(),
        fields,
        arrays,
        scan,
        bucket: getBucketName,
        logger,
      }),
  );
}

// Inbox creation and delivery are separate: push failure cannot lose the inbox row.
exports.sendWelcomeNotificationV3 = onDocumentCreated(
    {database: DATABASE_ID, document: "publicProfile/{userId}", retry: true},
    async (event) => {
      if (!event.data) return;
      const {userId} = event.params;
      const name = event.data.data()?.displayName || "Traveler";
      const target = getDb().collection("notifications").doc(userId).collection("notification").doc(`welcome_${userId}`);
      try {
        await target.create(notification(target.id, "system", userId, "welcome", userId,
            "Welcome to Travel Crew!", `Hey ${name}, welcome to Travel Crew! Get started with your first trip.`, true));
      } catch (error) {
        if (error.code !== 6 && error.code !== "already-exists") throw error;
      }
    },
);
exports.sendPushNotificationV3 = onDocumentCreated(
    {database: DATABASE_ID, document: "notifications/{userId}/notification/{notificationId}", retry: true},
    (event) => sendInboxPush(getDb(), getMessaging(), event),
);
exports.sendChatPushV3 = onDocumentCreated(
    {database: DATABASE_ID, document: "chat/{roomId}/messages/{messageId}", retry: true},
    (event) => sendChatPush(getDb(), getMessaging(), event),
);

exports.sendTripInvitesV3 = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const {tripId, emails} = request.data || {};
  if (!validId(tripId) || !Array.isArray(emails) || emails.length > 100) {
    throw new HttpsError("invalid-argument", "Invalid invite payload.");
  }
  const uniqueEmails = normalizeEmails(emails);
  if (!uniqueEmails.length || uniqueEmails.length > 20) {
    throw new HttpsError("invalid-argument", "Supply 1 to 20 valid emails.");
  }
  const db = getDb();
  await assertActive(db, request.auth.uid);
  const tripDoc = await db.collection("trips").doc(tripId).get();
  if (!tripDoc.exists || tripDoc.data().createdBy !== request.auth.uid) {
    throw new HttpsError("permission-denied", "Trip owner access required.");
  }
  const trip = tripDoc.data();
  if (trip.tripStatus === "deleted") {
    throw new HttpsError("failed-precondition", "This trip was deleted.");
  }
  const title = trip.title || trip.destination || "your trip";
  const batch = db.batch();
  for (const email of uniqueEmails) {
    try {
      const recipient = await getAuth().getUserByEmail(email);
      if (await isBlocked(db, request.auth.uid, recipient.uid)) continue;
    } catch (error) {
      if (error.code !== "auth/user-not-found") throw error;
    }
    batch.set(db.collection("mail").doc(), {
      to: [email],
      message: {
        subject: "You have been invited to a trip!",
        text: `You have been invited to join the trip: ${title}. ` +
          "Open the Travel Crew app to request to join.",
      },
      createdBy: request.auth.uid,
      tripId,
      createdAt: new Date(),
    });
  }
  await batch.commit();
  // Acknowledge submitted addresses without revealing registered or blocked recipients.
  // Delivery needs the mail extension.
  return {sent: uniqueEmails.length, queued: uniqueEmails.length};
});

// Remains public for image consumers that cannot attach auth headers.
exports.placePhotoV3 = onRequest({cors: true, maxInstances: 10}, async (req, res) => {
  if (req.method !== "GET") return res.status(405).send("Use GET");
  const name = req.query.name;
  const width = req.query.maxWidthPx || "800";
  if (!validPhoto(name, width)) {
    return res.status(400).send("Invalid photo name or width");
  }
  const apiKey = process.env.GOOGLE_MAPS_SERVER_KEY ||
    process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) return res.status(503).send("Photo service is not configured");
  try {
    const url = new URL(`https://places.googleapis.com/v1/${name}/media`);
    url.searchParams.set("maxWidthPx", width);
    const response = await fetch(url, {
      headers: {"X-Goog-Api-Key": apiKey},
      signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) {
      return res.status(response.status).send("Failed to fetch place photo");
    }
    const contentType = response.headers.get("content-type") || "";
    if (!contentType.startsWith("image/")) {
      return res.status(502).send("Unexpected photo response");
    }
    const buffer = Buffer.from(await response.arrayBuffer());
    res.set("Content-Type", contentType);
    res.set("Cache-Control", "public, max-age=86400, s-maxage=86400");
    return res.status(200).send(buffer);
  } catch (error) {
    console.error("Photo request failed", {name: error.name});
    return res.status(502).send("Photo service unavailable");
  }
});
