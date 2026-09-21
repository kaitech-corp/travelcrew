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

// Text moderation triggers (V3 export names avoid trigger type conversion errors with 1st gen functions)
const {createModerator, profileFields, tripFields, discoveryFields} =
  require("./moderation");
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
  // Compatible with existing callers; delivery needs the mail extension.
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
