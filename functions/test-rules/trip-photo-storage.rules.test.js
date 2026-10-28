const {before, after, test} = require("node:test");
const fs = require("node:fs");
const {initializeTestEnvironment, assertFails, assertSucceeds} = require("@firebase/rules-unit-testing");
const {ref, uploadBytes, deleteObject, getBytes, getDownloadURL, updateMetadata, listAll} = require("firebase/storage");
let env;
const path = "suggested_trip_photos/owner-hash/asset.jpg";
before(async () => {
  if (!process.env.FIREBASE_STORAGE_EMULATOR_HOST) throw new Error("Storage emulator required");
  env = await initializeTestEnvironment({projectId: "demo-travelcrew-safety", storage: {rules: fs.readFileSync("../storage.rules", "utf8")}});
  await env.withSecurityRulesDisabled((context) => uploadBytes(ref(context.storage(), path), Buffer.from("backend-photo")));
});
after(async () => { if (env) await env.cleanup(); });
test("public suggested photos can be read but no client can create, overwrite, delete, or change their metadata", async () => {
  for (const context of [env.unauthenticatedContext(), env.authenticatedContext("owner"), env.authenticatedContext("other"), env.authenticatedContext("admin", {admin: true})]) {
    const storage = context.storage();
    await assertSucceeds(getBytes(ref(storage, path)));
    await assertFails(uploadBytes(ref(storage, path), Buffer.from("replacement")));
    await assertFails(uploadBytes(ref(storage, "suggested_trip_photos/new.jpg"), Buffer.from("forgery")));
    await assertFails(updateMetadata(ref(storage, path), {customMetadata: {firebaseStorageDownloadTokens: "forged"}}));
    await assertFails(deleteObject(ref(storage, path)));
  }
});
test("new manual photos are scoped to their owner and immutable after creation", async () => {
  const owner = env.authenticatedContext("owner").storage();
  for (const folder of ["trip_images", "users_profile"]) {
    const path = `uploads/owner/${folder}/unique-photo.jpg`;
    const object = ref(owner, path);
    await assertSucceeds(uploadBytes(object, Buffer.from("photo"), {contentType: "image/jpeg"}));
    for (const context of [env.unauthenticatedContext(), env.authenticatedContext("other"), env.authenticatedContext("admin", {admin: true})]) {
      const foreign = ref(context.storage(), path);
      await assertFails(uploadBytes(foreign, Buffer.from("replacement"), {contentType: "image/jpeg"}));
      await assertFails(deleteObject(foreign));
      await assertFails(updateMetadata(foreign, {contentType: "image/png"}));
      await assertFails(uploadBytes(ref(context.storage(), `uploads/owner/${folder}/forged.jpg`), Buffer.from("photo"), {contentType: "image/jpeg"}));
    }
    await assertFails(uploadBytes(object, Buffer.from("replacement"), {contentType: "image/jpeg"}));
    await assertFails(updateMetadata(object, {contentType: "text/html"}));
    await assertSucceeds(getBytes(ref(env.unauthenticatedContext().storage(), path)));
    await assertFails(listAll(ref(owner, `uploads/owner/${folder}`)));
    await assertSucceeds(deleteObject(object));
  }
});

test("private photo uploads never grant direct client reads", async () => {
  const owner = env.authenticatedContext("owner").storage();
  for (const path of [
    "private_uploads/owner/trip_images/trip-1/cover.jpg",
    "private_uploads/owner/users_profile/avatar.jpg",
  ]) {
    const object = ref(owner, path);
    await assertSucceeds(uploadBytes(object, Buffer.from("photo"), {contentType: "image/jpeg"}));
    for (const context of [env.unauthenticatedContext(), env.authenticatedContext("owner"),
      env.authenticatedContext("other")]) {
      const candidate = ref(context.storage(), path);
      await assertFails(getBytes(candidate));
      await assertFails(getDownloadURL(candidate));
      await assertFails(updateMetadata(candidate, {contentType: "image/png"}));
    }
    await assertFails(uploadBytes(object, Buffer.from("replacement"), {contentType: "image/jpeg"}));
    await assertFails(deleteObject(ref(env.authenticatedContext("other").storage(), path)));
    await assertSucceeds(deleteObject(object));
  }
  await assertFails(uploadBytes(ref(env.authenticatedContext("other").storage(),
    "private_uploads/owner/trip_images/trip-1/forged.jpg"), Buffer.from("photo"), {contentType: "image/jpeg"}));
});

test("unowned legacy and unknown paths reject all client writes without breaking existing reads", async () => {
  for (const path of ["trip_images/legacy.jpg", "users_profile/legacy.jpg", "trips/trip/photo.jpg", "travelcrew/trips/legacy.jpg", "unknown/file.jpg"]) {
    await env.withSecurityRulesDisabled((context) => uploadBytes(ref(context.storage(), path), Buffer.from("legacy")));
    for (const context of [env.unauthenticatedContext(), env.authenticatedContext("owner")]) {
      await assertFails(uploadBytes(ref(context.storage(), path), Buffer.from("replacement"), {contentType: "image/jpeg"}));
      await assertFails(deleteObject(ref(context.storage(), path)));
    }
    if (!path.startsWith("unknown/")) await assertSucceeds(getBytes(ref(env.unauthenticatedContext().storage(), path)));
  }
});

test("manual uploads reject unsupported types, empty files and oversized files", async () => {
  const storage = env.authenticatedContext("owner").storage();
  for (const [id, bytes, type] of [
    ["html", Buffer.from("<script>bad</script>"), "text/html"],
    ["svg", Buffer.from("<svg/>"), "image/svg+xml"],
    ["empty", Buffer.alloc(0), "image/png"],
    ["large", Buffer.alloc(20 * 1024 * 1024 + 1), "image/jpeg"],
  ]) await assertFails(uploadBytes(ref(storage, `uploads/owner/trip_images/${id}`), bytes, {contentType: type}));
  await assertFails(uploadBytes(ref(storage, "uploads/owner/arbitrary/file.jpg"), Buffer.from("photo"), {contentType: "image/jpeg"}));
});
