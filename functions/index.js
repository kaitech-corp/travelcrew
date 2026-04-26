const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {HttpsError, onCall} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// Initialize Firebase Admin SDK
initializeApp();

/**
 * Triggered when a new notification document is created.
 * This function sends a push notification to the users specified in
 * the 'sentTo' field.
 */
exports.sendPushNotification =
onDocumentCreated(
    "notifications/{userId}/notification/{notificationId}",
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
        console.log("No data associated with the event");
        return;
      }
      const notificationData = snapshot.data();

      const title = notificationData.notificationTitle;
      const body = notificationData.notificationMessage;
      const sentTo = notificationData.sentTo; // Array of UIDs.

      if (!sentTo || sentTo.length === 0) {
        console.log("No recipients specified for this notification.");
        return;
      }

      // Get the FCM tokens for all recipients.
      const db = getFirestore();
      const tokens = [];
      const tokenRefs = new Map();
      for (const userId of sentTo) {
        const userTokensSnapshot =
    await db.collection("tokens").doc(userId).collection("tokens").get();
        if (!userTokensSnapshot.empty) {
          userTokensSnapshot.forEach((tokenDoc) => {
            tokens.push(tokenDoc.id);
            tokenRefs.set(tokenDoc.id, tokenDoc.ref);
          });
        }
      }

      if (tokens.length === 0) {
        console.log("No FCM tokens found for the specified recipients.");
        return;
      }

      // Notification payload
      const payload = {
        notification: {
          title: title,
          body: body,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          notificationId: event.params.notificationId,
          type: notificationData.notificationType || "general",
        },
        tokens,
      };

      console.log(`Sending notification to ${tokens.length} tokens.`);

      try {
        const response = await getMessaging().sendEachForMulticast(payload);
        const cleanup = [];
        response.responses.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.error(
                "Failure sending notification to",
                tokens[index],
                error,
            );
            if (error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered") {
              const tokenRef = tokenRefs.get(tokens[index]);
              if (tokenRef) cleanup.push(tokenRef.delete());
            }
          }
        });
        await Promise.all(cleanup);
        return response;
      } catch (error) {
        console.error("Error sending FCM message:", error);
        return;
      }
    },
);

exports.sendTripInvites = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const {tripId, emails, tripTitle} = request.data || {};
  if (typeof tripId !== "string" || !Array.isArray(emails)) {
    throw new HttpsError("invalid-argument", "Invalid invite payload.");
  }

  const uniqueEmails = [...new Set(emails)]
      .filter((email) => typeof email === "string")
      .map((email) => email.trim().toLowerCase())
      .filter((email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
      .slice(0, 20);

  if (uniqueEmails.length === 0) {
    throw new HttpsError("invalid-argument", "No valid emails supplied.");
  }

  const db = getFirestore();
  const tripDoc = await db.collection("trips").doc(tripId).get();
  if (!tripDoc.exists || tripDoc.data().createdBy !== request.auth.uid) {
    throw new HttpsError("permission-denied", "Trip owner access required.");
  }

  const title = typeof tripTitle === "string" && tripTitle.trim() ?
    tripTitle.trim() :
    tripDoc.data().title || "your trip";

  const batch = db.batch();
  uniqueEmails.forEach((email) => {
    const mailRef = db.collection("mail").doc();
    batch.set(mailRef, {
      to: [email],
      message: {
        subject: "You have been invited to a trip!",
        text:
          `You have been invited to join the trip: ${title}. ` +
          "Open the Travel Crew app to accept.",
      },
      createdBy: request.auth.uid,
      tripId,
      createdAt: new Date(),
    });
  });

  await batch.commit();
  return {sent: uniqueEmails.length};
});

/**
 * Triggered when a new user is created.
 * This function creates a public profile for the new user.
 */
// exports.createPublicProfile = functions.auth.user()
// .onCreate(async (user) => {
//   const db = getFirestore();
//   const publicProfile = {
//     displayName: user.displayName || "New User",
//     email: user.email || "",
//     uid: user.uid,
//     urlToImage: user.photoURL || "",
//     // Initialize other fields as needed
//     followers: [],
//     following: [],
//     tripsCreated: 0,
//     tripsJoined: 0,
//   };

//   try {
//     await db.collection("publicProfile").doc(user.uid).set(publicProfile);
//     console.log(`Public profile created for user: ${user.uid}`);
//   } catch (error) {
//     console.error("Error creating public profile:", error);
//   }
// });
