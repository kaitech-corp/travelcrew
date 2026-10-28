const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {onRequest, HttpsError, onCall} = require("firebase-functions/v2/https");
const {initializeApp, getApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const {getStorage} = require("firebase-admin/storage");
const {GoogleAuth} = require("google-auth-library");
const logger = require("firebase-functions/logger");
const {validPhoto} = require("./validation");

initializeApp();

const DATABASE_ID = process.env.FIRESTORE_DATABASE_ID || "travel-crew-db-2";
const getDb = () => getFirestore(DATABASE_ID);

// Hosting routes /assistant/** and OAuth discovery to this single service.
// Lazy construction keeps deployment inspection independent of runtime config.
let assistantApp;
exports.assistantV1 = onRequest({maxInstances: 10, timeoutSeconds: 120, memory: "512MiB", concurrency: 4, invoker: "public"}, (req, res) => {
  if (!process.env.ASSISTANT_BASE_URL || !process.env.ASSISTANT_FIREBASE_CONFIG) {
    return res.status(503).json({error: "not_configured", error_description: "Assistant connections are not configured yet"});
  }
  if (!assistantApp) {
    const {createAssistantApp} = require("./assistant-api");
    assistantApp = createAssistantApp({db: getDb(), auth: getAuth(), baseUrl: process.env.ASSISTANT_BASE_URL,
      mcpUrl: process.env.ASSISTANT_MCP_URL,
      preparePhoto: prepareSuggestedPhoto,
      firebaseConfig: JSON.parse(process.env.ASSISTANT_FIREBASE_CONFIG), logger});
  }
  return assistantApp(req, res);
});

const {getAuth} = require("firebase-admin/auth");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {createRecommendationHandlers} = require("./recommendations");
const {maintainTripFeature} = require("./recommendations/features");
const {cleanRecommendationData, expireRecommendations} = require("./recommendations/maintenance");
const recommendations = createRecommendationHandlers(getDb(), getAuth(), {log: (name, data) => logger.info(name, data)});
const recommendationOptions = {maxInstances: 10, timeoutSeconds: 60, memory: "512MiB"};
exports.getRecommendedTripsV3 = onCall(recommendationOptions, recommendations.feed);
exports.recordRecommendationEventsV3 = onCall(recommendationOptions, recommendations.events);
exports.setRecommendationDismissalV3 = onCall(recommendationOptions, recommendations.dismiss);
exports.setRecommendationPreferencesV3 = onCall(recommendationOptions, recommendations.preferences);
exports.maintainRecommendationTripV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "trips/{tripId}", retry: true},
    (event) => maintainTripFeature(getDb(), event.params.tripId, {
      newPublication: event.data?.after.data()?.isPrivate === false && event.data?.before.data()?.isPrivate !== false,
      now: event.data?.after.updateTime?.toMillis() ?? Date.now(),
    }),
);
exports.expireRecommendationsV3 = onSchedule("every 60 minutes", () => expireRecommendations(getDb()));
const {createSafetyHandlers} = require("./safety");
const {cleanBlockedPair, queueReportAlert, maintainReports, cleanSafetyData} = require("./safety-triggers");
const {cleanDeletedUserFavorites} = require("./favorite-cleanup");
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
const {createTripInvitations} = require("./trip-invitations");
const tripInvitations = createTripInvitations(getDb(), getAuth());
exports.searchTripInviteUsersV3 = onCall(tripInvitations.search);
exports.inviteTripUserV3 = onCall(tripInvitations.send);
exports.getTripInvitationV3 = onCall(tripInvitations.preview);
exports.respondToTripInvitationV3 = onCall(tripInvitations.respond);
exports.reviewReportV3 = onCall(safety.reviewReport);
const {createExpenseHandlers} = require("./finance/expense-actions");
const financeExpenses = createExpenseHandlers(getDb(), (event, fields) => logger.info(event, fields));
exports.saveFinanceExpenseV3 = onCall(financeExpenses.save);
exports.deleteFinanceExpenseV3 = onCall(financeExpenses.remove);
const {createTransferHandlers} = require("./finance/transfer-actions");
const financeTransfers = createTransferHandlers(getDb(), (event, fields) => logger.info(event, fields));
exports.recordFinanceTransferV3 = onCall(financeTransfers.record);
exports.answerFinanceTransferV3 = onCall(financeTransfers.answer);
const {createMigrationHandlers} = require("./finance/migration-actions");
const financeMigration = createMigrationHandlers(getDb(), (event, fields) => logger.info(event, fields));
exports.beginFinanceMigrationReviewV3 = onCall(financeMigration.begin);
exports.previewFinanceMigrationReviewV3 = onCall(financeMigration.preview);
exports.commitFinanceMigrationReviewV3 = onCall({timeoutSeconds: 120, memory: "512MiB"},
    financeMigration.commit);
const {createBatchMigrationHandlers} = require("./finance/migration-batch-actions");
const financeMigrationBatches = createBatchMigrationHandlers(getDb(),
    (event, fields) => logger.info(event, fields));
exports.stageFinanceMigrationBatchV3 = onCall({timeoutSeconds: 120, memory: "512MiB"},
    financeMigrationBatches.stage);
exports.finishFinanceMigrationBatchV3 = onCall({timeoutSeconds: 300, memory: "1GiB"},
    financeMigrationBatches.finish);
exports.abortFinanceMigrationBatchV3 = onCall({timeoutSeconds: 120, memory: "512MiB"},
    financeMigrationBatches.abort);
const {currencyOptions} = require("./finance/money");
exports.getFinanceCurrenciesV3 = onCall((request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in required.");
  return {currencies: currencyOptions()};
});
const {createTripStatusHandler} = require("./trip-create-status");
exports.checkTripCreateV3 = onCall(createTripStatusHandler(getDb()));
const {createFavoriteHandler} = require("./favorite-actions");
exports.setTripFavoriteV3 = onCall(createFavoriteHandler(getDb(),
    (event, fields) => logger.info(event, fields)));
const {createActivityListHandler} = require("./trip-activities");
exports.listTripActivitiesV3 = onCall({timeoutSeconds: 60, memory: "256MiB"},
    createActivityListHandler(getDb()));
const {createChatRoomHandler, createChatRoomListHandler, removeInactiveChatUser} = require("./chat-rooms");
exports.ensureChatRoomV3 = onCall({timeoutSeconds: 60, memory: "256MiB"},
    createChatRoomHandler(getDb(), (event, fields) => logger.info(event, fields)));
exports.listChatRoomsV3 = onCall({timeoutSeconds: 60, memory: "256MiB"},
    createChatRoomListHandler(getDb()));
exports.cleanInactiveChatAccountV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "users/{uid}", retry: true, timeoutSeconds: 540},
    async (event) => {
      const before = event.data?.before;
      const after = event.data?.after;
      if (!before || !after ||
          (after.exists && after.data()?.isDeleted !== true) ||
          (before.exists && before.data()?.isDeleted === true)) return;
      await removeInactiveChatUser(getDb(), event.params.uid,
          (name, fields) => logger.info(name, fields));
    },
);
exports.cleanRestrictedChatAccountV3 = onDocumentWritten(
    {database: DATABASE_ID, document: "safetyAccounts/{uid}", retry: true, timeoutSeconds: 540},
    async (event) => {
      if (event.data?.after.data()?.restricted !== true ||
          event.data?.before.data()?.restricted === true) return;
      await removeInactiveChatUser(getDb(), event.params.uid,
          (name, fields) => logger.info(name, fields));
    },
);
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
    {database: DATABASE_ID, document: "users/{uid}", retry: true, timeoutSeconds: 540},
    async (event) => {
      const becameDeleted = event.data.after.exists && event.data.after.data().isDeleted === true &&
        event.data.before.data()?.isDeleted !== true;
      if (!event.data.after.exists || becameDeleted) {
        const deletedDocument = !event.data.after.exists;
        const favorites = deletedDocument ? event.data.before.data()?.favouriteTrips :
          event.data.after.data()?.favouriteTrips;
        await cleanDeletedUserFavorites(getDb(), event.params.uid, favorites,
            deletedDocument ? event.id : null);
        await cleanSafetyData(getDb(), event.params.uid);
        await cleanRecommendationData(getDb(), event.params.uid);
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
const {createPhotoService, createPhotoCallable} = require("./trip-photos");
const prepareSuggestedPhoto = createPhotoService({db: getDb(), bucket: () => getStorage().bucket(), scan});
exports.prepareSuggestedTripPhotoV3 = onCall({maxInstances: 5, concurrency: 4, memory: "512MiB", timeoutSeconds: 120}, createPhotoCallable(prepareSuggestedPhoto));
const getBucketName = () => {
  try {
    return getStorage().bucket().name;
  } catch {
    return getApp().options.storageBucket ||
      `${process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT}.appspot.com`;
  }
};
const {createPrivatePhotoHandler} = require("./private-photos");
let privatePhotoHandler;
exports.privatePhotoV3 = onRequest(
    {cors: true, maxInstances: 10, concurrency: 4, timeoutSeconds: 60,
      memory: "512MiB", invoker: "public"},
    (req, res) => {
      privatePhotoHandler ||= createPrivatePhotoHandler({db: getDb(), auth: getAuth(),
        bucket: getStorage().bucket(), log: (event, fields) => logger.error(event, fields)});
      return privatePhotoHandler(req, res);
    },
);

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
        emulator: process.env.FUNCTIONS_EMULATOR === "true",
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

const {createTripEmailInvitationHandler} = require("./trip-email-invitations");
exports.sendTripInvitesV3 = onCall(createTripEmailInvitationHandler(
    getDb(), getAuth(), (event, fields) => logger.info(event, fields),
));

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
