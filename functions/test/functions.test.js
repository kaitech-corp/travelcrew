const {test} = require("node:test");
const assert = require("node:assert/strict");
const vm = require("node:vm");
const fs = require("node:fs");
const path = require("node:path");
const validation = require("../validation");

function fixture() {
  const records = new Map([
    ["trips/trip", {createdBy: "owner", title: "Real title", joinedUsers: ["member"]}],
    ["trips/trip/members/member", {status: "active"}],
    ["publicProfile/member", {displayName: "Sam"}],
  ]);
  const sends = [];
  let nextId = 0;
  const ref = (key) => ({
    id: key.split("/").at(-1),
    collection: (name) => collection(`${key}/${name}`),
    get: async () => ({exists: records.has(key), data: () => records.get(key)}),
    create: async (data) => {
      if (records.has(key)) throw Object.assign(new Error("exists"), {code: 6});
      records.set(key, data);
    },
    delete: async () => records.delete(key),
  });
  const collection = (key) => ({
    doc: (id = `auto${nextId++}`) => ref(`${key}/${id}`),
    get: async () => ({docs: [...records.keys()]
        .filter((k) => k.startsWith(`${key}/`) && k.split("/").length === key.split("/").length + 1)
        .map((k) => ({id: ref(k).id, ref: ref(k)}))}),
  });
  const mail = [];
  const db = {collection, batch: () => ({
    set: (ref, data) => mail.push(data), commit: async () => {},
  })};
  class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  }
  const modules = {
    "firebase-functions/v2/firestore": {
      onDocumentCreated: (_, fn) => fn,
      onDocumentWritten: (_, fn) => fn,
    },
    "firebase-functions/v2/https": {onCall: (fn) => fn, onRequest: (_, fn) => fn, HttpsError},
    "firebase-admin/app": {initializeApp: () => {}, getApp: () => ({options: {storageBucket: "app.appspot.com"}})},
    "firebase-admin/firestore": {getFirestore: () => db},
    "firebase-admin/messaging": {getMessaging: () => ({sendEachForMulticast: async (payload) => {
      sends.push(payload);
      return {responses: payload.tokens.map((token) => token === "expired" ?
        {error: {code: "messaging/registration-token-not-registered"}} :
        {success: true})};
    }})},
    "firebase-admin/storage": {getStorage: () => ({bucket: () => ({name: "app.appspot.com"})})},
    "google-auth-library": {GoogleAuth: class { async getAccessToken() { return "mock-token"; } }},
    "./validation": validation,
    "./moderation": require("../moderation"),
    "./image-moderation": require("../image-moderation"),
    "firebase-functions/logger": {warn: () => {}, error: () => {}},
  };
  const context = {exports: {}, require: (name) => modules[name], console,
    process: {env: {}}, URL, AbortSignal, Buffer};
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../index.js"), "utf8"), context);
  return {handlers: context.exports, records, sends, mail};
}
const event = (data, userId = "member", notificationId = "event") => ({
  data: {data: () => data}, params: {userId, notificationId},
});
const joined = {createdBy: "member", notificationType: "Trip",
  notificationForId: "trip", sentTo: ["owner", "stranger"]};

test("join notification goes only to the owner and replay preserves read state", async () => {
  const f = fixture();
  await f.handlers.sendPushNotificationV3(event(joined));
  const key = "notifications/owner/notification/member_event";
  const data = f.records.get(key);
  assert.equal(data.notificationMessage, "Sam joined your trip.");
  assert.equal(data.sentTo.join(), "owner");
  assert.equal(f.sends.length, 0);
  data.notificationStatus = "read";
  await f.handlers.sendPushNotificationV3(event(joined));
  assert.equal(f.records.get(key).notificationStatus, "read");
});
test("unrelated senders, inactive members and deleted trips cannot forward", async () => {
  for (const kind of ["stranger", "inactive", "deleted"]) {
    const f = fixture();
    if (kind === "inactive") f.records.set("trips/trip/members/member", {status: "left"});
    if (kind === "deleted") f.records.get("trips/trip").tripStatus = "deleted";
    await f.handlers.sendPushNotificationV3(event(joined, kind === "stranger" ? "stranger" : "member"));
    assert.equal([...f.records.keys()].some((k) => k.startsWith("notifications/")), false);
  }
});
test("recipient pushes split 501 tokens and do not forward again", async () => {
  const f = fixture();
  await f.handlers.sendPushNotificationV3(event(joined));
  for (let i = 0; i < 501; i++) f.records.set(`tokens/owner/tokens/t${i}`, {});
  await f.handlers.sendPushNotificationV3(event(f.records.get("notifications/owner/notification/member_event"), "owner", "member_event"));
  assert.equal(f.sends.length, 2);
  assert.equal(f.sends[0].tokens.length, 500);
  assert.equal(f.sends[1].tokens.length, 1);
});
test("invites normalize before deduplication and use the stored title", async () => {
  const f = fixture();
  const result = await f.handlers.sendTripInvitesV3({auth: {uid: "owner"}, data: {
    tripId: "trip", tripTitle: "Forged", emails: [" SAM@example.com ", "sam@example.com"],
  }});
  assert.equal(result.queued, 1);
  assert.equal(f.mail.length, 1);
  assert.match(f.mail[0].message.text, /Real title/);
});
test("invites reject unauthenticated, non-owner, deleted and invalid trip requests", async () => {
  const f = fixture();
  const data = {tripId: "trip", emails: ["sam@example.com"]};
  for (const request of [{data}, {auth: {uid: "member"}, data},
    {auth: {uid: "owner"}, data: {...data, tripId: "trips/trip"}}]) {
    await assert.rejects(f.handlers.sendTripInvitesV3(request));
  }
  f.records.get("trips/trip").tripStatus = "deleted";
  await assert.rejects(f.handlers.sendTripInvitesV3({auth: {uid: "owner"}, data}));
  assert.equal(f.mail.length, 0);
});
test("photo input rejects URLs, query injection, arrays and excessive dimensions", () => {
  assert.equal(validation.validPhoto("places/abc/photos/xyz", "800"), true);
  for (const name of ["https://evil.test", "places/abc/photos/xyz?key=other", ["places/a/photos/b"]]) {
    assert.equal(validation.validPhoto(name, "800"), false);
  }
  assert.equal(validation.validPhoto("places/a/photos/b", "4801"), false);
  assert.equal(validation.validPhoto("places/a/photos/b", ["800"]), false);
});

test("invalid device tokens are removed without removing valid tokens", async () => {
  const f = fixture();
  await f.handlers.sendPushNotificationV3(event(joined));
  f.records.set("tokens/owner/tokens/expired", {});
  f.records.set("tokens/owner/tokens/valid", {});
  await f.handlers.sendPushNotificationV3(event(f.records.get("notifications/owner/notification/member_event"), "owner", "member_event"));
  assert.equal(f.records.has("tokens/owner/tokens/expired"), false);
  assert.equal(f.records.has("tokens/owner/tokens/valid"), true);
});

test("photo handler rejects bad requests and reports missing configuration", async () => {
  const {handlers} = fixture();
  for (const [request, status] of [
    [{method: "POST", query: {}}, 405],
    [{method: "GET", query: {name: "bad"}}, 400],
    [{method: "GET", query: {name: "places/a/photos/b"}}, 503],
  ]) {
    let actual;
    const res = {status: (code) => {actual = code; return res;}, send: () => {}};
    await handlers.placePhotoV3(request, res);
    assert.equal(actual, status);
  }
});

test("index exports all required text moderation, image moderation, and service functions", () => {
  const {handlers} = fixture();
  const expected = [
    "moderatePublicProfileTextV3",
    "moderateLegacyPublicProfileTextV3",
    "moderateTripTextV3",
    "moderateTripDiscoveryTextV3",
    "moderateUserImagesV3",
    "moderatePublicProfileImagesV3",
    "moderateLegacyProfileImagesV3",
    "moderateTripImagesV3",
    "moderateDiscoveryImagesV3",
    "sendPushNotificationV3",
    "sendTripInvitesV3",
    "placePhotoV3",
  ];
  for (const fn of expected) {
    assert.equal(typeof handlers[fn], "function", `Expected ${fn} to be exported`);
  }
});

