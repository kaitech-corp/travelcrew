const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const functions = require("firebase-functions");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

// Initialize Firebase Admin SDK
initializeApp();

/**
 * Triggered when a new notification document is created.
 * This function sends a push notification to the users specified in the 'sentTo' field.
 */
exports.sendPushNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }
  const notificationData = snapshot.data();

  const title = notificationData.notificationTitle;
  const body = notificationData.notificationMessage;
  const sentTo = notificationData.sentTo; // Array of UIDs

  if (!sentTo || sentTo.length === 0) {
    console.log("No recipients specified for this notification.");
    return;
  }

  // Get the FCM tokens for all recipients.
  const db = getFirestore();
  const tokens = [];
  for (const userId of sentTo) {
    const userTokensSnapshot = await db.collection('tokens').doc(userId).collection('tokens').get();
    if (!userTokensSnapshot.empty) {
      userTokensSnapshot.forEach(tokenDoc => {
        tokens.push(tokenDoc.id);
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
      type: notificationData.notificationType || 'general',
    },
  };

  console.log(`Sending notification to ${tokens.length} tokens.`);

  try {
    const response = await getMessaging().sendToDevice(tokens, payload);
    // Optional: Clean up invalid tokens based on the response
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error('Failure sending notification to', tokens[index], error);
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          // Consider implementing token cleanup logic here
        }
      }
    });
    return response;
  } catch (error) {
    console.error("Error sending FCM message:", error);
    return;
  }
});

/**
 * Triggered when a new user is created.
 * This function creates a public profile for the new user.
 */
exports.createPublicProfile = functions.auth.user().onCreate(async (user) => {
  const db = getFirestore();
  const publicProfile = {
    displayName: user.displayName || 'New User',
    email: user.email || '',
    uid: user.uid,
    urlToImage: user.photoURL || '',
    // Initialize other fields as needed
    followers: [],
    following: [],
    tripsCreated: 0,
    tripsJoined: 0,
  };

  try {
    await db.collection('publicProfile').doc(user.uid).set(publicProfile);
    console.log(`Public profile created for user: ${user.uid}`);
  } catch (error) {
    console.error("Error creating public profile:", error);
  }
});
