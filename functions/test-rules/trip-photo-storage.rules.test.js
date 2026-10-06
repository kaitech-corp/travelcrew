const {before, after, test} = require("node:test");
const fs = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {ref, uploadBytes, deleteObject, getBytes} = require("firebase/storage");
let env;
const path = "suggested_trip_photos/owner-hash/asset.jpg";
before(async () => {
  if (!process.env.FIREBASE_STORAGE_EMULATOR_HOST) throw new Error("Storage emulator required");
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-safety", storage: {rules: fs.readFileSync("../storage.rules", "utf8")}});
  await env.withSecurityRulesDisabled((context) => uploadBytes(ref(context.storage(), path), Buffer.from("backend-photo")));
});
after(async () => { if (env) await env.cleanup(); });
test("public suggested photos can be read but no client can create, overwrite, delete, or change their metadata", async () => {
  const {updateMetadata} = require("firebase/storage");
  for (const context of [env.unauthenticatedContext(), env.authenticatedContext("owner"), env.authenticatedContext("other"), env.authenticatedContext("admin", {admin: true})]) {
    const storage = context.storage();
    await assertSucceeds(getBytes(ref(storage, path)));
    await assertFails(uploadBytes(ref(storage, path), Buffer.from("replacement")));
    await assertFails(uploadBytes(ref(storage, "suggested_trip_photos/new.jpg"), Buffer.from("forgery")));
    await assertFails(updateMetadata(ref(storage, path), {customMetadata: {firebaseStorageDownloadTokens: "forged"}}));
    await assertFails(deleteObject(ref(storage, path)));
  }
});
test("existing authenticated manual-upload paths remain usable", async () => {
  const storage = env.authenticatedContext("owner").storage();
  for (const path of ["trip_images/test.jpg", "travelcrew/trips/test.jpg", "users_profile/test.jpg"]) {
    await assertSucceeds(uploadBytes(ref(storage, path), Buffer.from("manual-photo")));
    await assertSucceeds(deleteObject(ref(storage, path)));
  }
});
