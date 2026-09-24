const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {onRequest, HttpsError, onCall} = require("firebase-functions/v2/https");
const {initializeApp, getApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {getStorage} = require("firebase-admin/storage");
const {GoogleAuth} = require("google-auth-library");
const logger = require("firebase-functions/logger");
const {validId, normalizeEmails, chunks, validPhoto} = require("./validation");

initializeApp();

const DATABASE_ID = process.env.FIRESTORE_DATABASE_ID || "travel-crew-db-2";
const getDb = () => getFirestore(DATABASE_ID);

const {getAuth} = require("firebase-admin/auth");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {createSafetyHandlers, isBlocked, assertActive} = require("./safety");
const {cleanBlockedPair, queueReportAlert, maintainReports, cleanSafetyData} = require("./safety-triggers");
const safety = createSafetyHandlers(getDb());
exports.submitReportV3 = onCall(safety.submitReport);
exports.blockUserV3 = onCall(safety.blockUser);
exports.unblockUserV3 = onCall(safety.unblockUser);
exports.followUserV3 = onCall(safety.followUser);
exports.acceptJoinRequestV3 = onCall(safety.acceptJoinRequest);
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

// Welcome notification for newly registered users when publicProfile is created.
exports.sendWelcomeNotificationV3 = onDocumentCreated(
    {
      database: DATABASE_ID,
      document: "publicProfile/{userId}",
    },
    async (event) => {
      if (!event.data) return;
      const {userId} = event.params;
      const data = event.data.data();
      const name = data?.displayName || data?.firstName || "Traveler";
      const db = getDb();

      const target = db
          .collection("notifications")
          .doc(userId)
          .collection("notification")
          .doc(`welcome_${userId}`);

      const title = "Welcome to Travel Crew!";
      const message = `Yo! Hey ${name}, welcome to Travel Crew! Let's
          get you started with your first trip.`;

      try {
        await target.create({
          notificationId: target.id,
          notificationTitle: title,
          notificationMessage: message,
          notificationType: "Welcome",
          notificationForId: userId,
          notificationStatus: "unread",
          createdBy: "system",
          sentTo: [userId],
          createdAt: Date.now(),
          updateAt: Date.now(),
          updateBy: "system",
          isActive: true,
          isTopic: false,
          notificationTopic: [],
          serverForwarded: true,
        });
      } catch (error) {
        if (error.code !== 6 && error.code !== "already-exists") throw error;
        return;
      }

      try {
        const tokenDocs = await db.collection("tokens").doc(userId)
            .collection("tokens").get();
        if (tokenDocs.empty) return;

        for (const docs of chunks(tokenDocs.docs)) {
          const result = await getMessaging().sendEachForMulticast({
            tokens: docs.map((doc) => doc.id),
            notification: {
              title,
              body: message,
            },
            data: {
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              notificationId: target.id,
              notificationForId: userId,
              type: "Welcome",
            },
          });
          await Promise.all(result.responses.map(async (response, index) => {
            const code = response.error?.code;
            if (code === "messaging/invalid-registration-token" ||
                code === "messaging/registration-token-not-registered") {
              await docs[index].ref.delete();
            } else if (code) {
              console.error("Welcome push delivery failed", {userId, code});
            }
          }));
        }
      } catch (error) {
        console.error("Welcome notification push failed", {userId, error: error.message});
      }
    },
);

// Existing clients submit Trip Joined events under the sender's UID.
// A server-created recipient document triggers the push, without fan-out loops.
exports.sendPushNotificationV3 = onDocumentCreated(
    {
      database: DATABASE_ID,
      document: "notifications/{userId}/notification/{notificationId}",
    },
    async (event) => {
      if (!event.data) return;
      const data = event.data.data();
      const {userId, notificationId} = event.params;
      if (data.notificationType !== "Trip" ||
          !validId(data.notificationForId) || !validId(data.createdBy)) return;
      const db = getDb();
      const tripRef = db.collection("trips").doc(data.notificationForId);
      const tripDoc = await tripRef.get();
      if (!tripDoc.exists || tripDoc.data().tripStatus === "deleted") return;
      const trip = tripDoc.data();
      if (await isBlocked(db, data.createdBy, trip.createdBy)) return;
      if ((await db.collection("safetyAccounts").doc(data.createdBy).get()).data()?.restricted) return;
      if (data.serverForwarded !== true) {
        if (userId !== data.createdBy || userId === trip.createdBy ||
            !Array.isArray(data.sentTo) ||
            !data.sentTo.includes(trip.createdBy)) return;
        const member = await tripRef.collection("members").doc(userId).get();
        const isMember = member.exists ? member.data().status === "active" :
          Array.isArray(trip.joinedUsers) && trip.joinedUsers.includes(userId);
        if (!isMember) return;
        const profile = await db.collection("publicProfile").doc(userId).get();
        const name = profile.data()?.displayName || "A traveler";
        const target = db.collection("notifications").doc(trip.createdBy)
            .collection("notification").doc(`${userId}_${notificationId}`);
        try {
          await target.create({
            notificationId: target.id,
            notificationTitle: "Trip Joined",
            notificationMessage: `${name} joined your trip.`,
            notificationType: "Trip",
            notificationForId: data.notificationForId,
            notificationStatus: "unread",
            createdBy: userId,
            sentTo: [trip.createdBy],
            createdAt: Date.now(),
            updateAt: Date.now(),
            updateBy: userId,
            isActive: true,
            isTopic: false,
            notificationTopic: [],
            serverForwarded: true,
          });
        } catch (error) {
          // Re-delivery must not reset read state or create another inbox row.
          if (error.code !== 6 && error.code !== "already-exists") throw error;
        }
        return;
      }
      if (userId !== trip.createdBy) return;
      const tokenDocs = await db.collection("tokens").doc(userId)
          .collection("tokens").get();
      for (const docs of chunks(tokenDocs.docs)) {
        const result = await getMessaging().sendEachForMulticast({
          tokens: docs.map((doc) => doc.id),
          notification: {
            title: data.notificationTitle,
            body: data.notificationMessage,
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            notificationId,
            notificationForId: data.notificationForId,
            type: "Trip",
          },
        });
        await Promise.all(result.responses.map(async (response, index) => {
          const code = response.error?.code;
          if (code === "messaging/invalid-registration-token" ||
              code === "messaging/registration-token-not-registered") {
            await docs[index].ref.delete();
          } else if (code) {
            console.error("Push delivery failed", {notificationId, code});
          }
        }));
      }
    },
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
