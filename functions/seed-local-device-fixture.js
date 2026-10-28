"use strict";

// Local simulator fixture only. Refuse to run unless Auth, Firestore and
// Storage target loopback emulators. iOS uses the bundled Firebase project ID,
// so the host checks are the safety boundary.
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {getStorage} = require("firebase-admin/storage");
const sharp = require("sharp");

const projectId = "universal-code-135522";
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
const storageHost = process.env.FIREBASE_STORAGE_EMULATOR_HOST ||
  process.env.STORAGE_EMULATOR_HOST;
const password = process.env.TRAVELCREW_LOCAL_TEST_PASSWORD;
const loopback = /^(localhost|127\.0\.0\.1):[0-9]{2,5}$/;
if (!loopback.test(authHost || "") || !loopback.test(firestoreHost || "") ||
    !/^https?:\/\/(localhost|127\.0\.0\.1):[0-9]{2,5}$/.test(storageHost || "") ||
    !password || password.length < 12 ||
    (process.env.GCLOUD_PROJECT && process.env.GCLOUD_PROJECT !== projectId)) {
  throw new Error("Set Auth, Firestore and Storage loopback emulator hosts and a 12+ character local test password.");
}

const app = initializeApp({projectId});
const auth = getAuth(app);
const db = getFirestore(app, "travel-crew-db-2");
const tripId = "e2e_chat";
const bucketName = `${projectId}.appspot.com`;
const photoPath = "private_uploads/e2e_owner/trip_images/e2e_chat/local-photo.png";
const photoRef = `gs://${bucketName}/${photoPath}`;

async function seedUser(uid, email) {
  const profile = {email, password, emailVerified: true, displayName: uid};
  try {
    await auth.getUser(uid);
    await auth.updateUser(uid, profile);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    await auth.createUser({uid, ...profile});
  }
  await db.doc(`users/${uid}`).set({uid, email, displayName: uid,
    emailConfirmed: true, isDeleted: false}, {merge: true});
}

async function main() {
  await seedUser("e2e_owner", "owner@example.test");
  await seedUser("e2e_member", "member@example.test");
  const tripRef = db.doc(`trips/${tripId}`);
  if (!(await tripRef.get()).exists) {
    await tripRef.create({id: tripId, createdBy: "e2e_owner",
      title: "Local chat trip", destination: "Tokyo", tripLocation: "Tokyo",
      country: "Japan",
      tripStartDate: "2027-04-10T00:00:00.000",
      tripEndDate: "2027-04-12T00:00:00.000",
      startDate: "2027-04-10T00:00:00.000", endDate: "2027-04-12",
      tripStatus: "upcoming", joinedUsers: ["e2e_member"],
      isPrivate: true, isShared: false, images: []});
  }
  for (const uid of ["e2e_owner", "e2e_member"]) {
    const role = uid === "e2e_owner" ? "creator" : "member";
    await tripRef.collection("members").doc(uid).set({userId: uid, role,
      status: "active", joinedAt: new Date()}, {merge: true});
    await db.doc(`users/${uid}/tripMemberships/${tripId}`).set({tripId,
      role, status: "active", joinedAt: new Date()}, {merge: true});
  }
  const onePixelPng = await sharp({create: {width: 1, height: 1, channels: 4,
    background: {r: 18, g: 120, b: 210, alpha: 1}}}).png().toBuffer();
  await getStorage(app).bucket(bucketName).file(photoPath).save(onePixelPng,
      {resumable: false, metadata: {contentType: "image/png", metadata: {}}});
  await tripRef.update({images: [photoRef]});
  process.stdout.write("Seeded local emulator accounts, named Firestore database and private photo.\n");
}

main().then(() => deleteApp(app)).catch(async (error) => {
  process.stderr.write(`${error.message}\n`);
  await deleteApp(app);
  process.exitCode = 1;
});
