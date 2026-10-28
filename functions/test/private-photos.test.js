"use strict";

const {test} = require("node:test");
const assert = require("node:assert/strict");
const {Readable} = require("node:stream");
const {createPrivatePhotoHandler, parsePrivatePhoto} = require("../private-photos");

const bucketName = "app.appspot.com";
const tripId = "trip-1";
const tripSource = `gs://${bucketName}/private_uploads/owner/trip_images/${tripId}/cover.jpg`;
const profileSource = `gs://${bucketName}/private_uploads/member/users_profile/avatar.jpg`;

function fixture() {
  const records = new Map([
    ["users/owner", {}], ["users/member", {}], ["users/outsider", {}],
    [`trips/${tripId}`, {createdBy: "owner", joinedUsers: ["member"], images: [tripSource]}],
    [`trips/${tripId}/members/member`, {status: "active"}],
    ["publicProfile/member", {profileImage: profileSource}],
  ]);
  const db = {doc(path) {
    return {
      get: async () => ({exists: records.has(path), data: () => records.get(path)}),
      collection: (name) => ({doc: (id) => db.doc(`${path}/${name}/${id}`)}),
    };
  }};
  let streams = 0;
  let duringRead = () => {};
  const bucket = {name: bucketName, file: (path) => ({
    path,
    getMetadata: async () => [{size: "5", contentType: "image/jpeg"}],
    createReadStream: () => {
      streams++;
      duringRead();
      return Readable.from([Buffer.from("image")]);
    },
  })};
  const auth = {verifyIdToken: async (token, checkRevoked) => {
    assert.equal(checkRevoked, true);
    if (token === "token_for_invalid_123456") throw Error("invalid");
    return {uid: token.replace(/^token_for_/, "").replace(/_123456$/, "")};
  }};
  const handler = createPrivatePhotoHandler({db, auth, bucket});
  async function request(uid, source = tripSource, method = "GET") {
    const response = {statusCode: 0, headers: {}, body: null,
      set(name, value) { this.headers[name] = value; return this; },
      status(code) { this.statusCode = code; return this; },
      send(body) { this.body = body; return this; }};
    await handler({method, headers: uid ? {authorization: `Bearer token_for_${uid}_123456`} : {},
      query: {ref: source}}, response);
    return response;
  }
  return {records, request, get streams() { return streams; }, set duringRead(fn) { duringRead = fn; }};
}

test("private photo paths reject other buckets, malformed and unscoped paths", () => {
  assert.deepEqual(parsePrivatePhoto(tripSource, bucketName), {
    kind: "trip", ownerId: "owner", tripId, path: `private_uploads/owner/trip_images/${tripId}/cover.jpg`,
  });
  for (const source of [
    tripSource.replace(bucketName, "other.appspot.com"),
    tripSource.replace("/cover.jpg", "/../cover.jpg"),
    `gs://${bucketName}/private_uploads/owner/trip_images/cover.jpg`,
    `gs://${bucketName}/private_uploads/member/users_profile/../avatar.jpg`,
  ]) assert.equal(parsePrivatePhoto(source, bucketName), null);
});

test("trip photo requires a current member and current trip image", async () => {
  const f = fixture();
  const success = await f.request("member");
  assert.equal(success.statusCode, 200);
  assert.equal(success.body.toString(), "image");
  assert.equal(success.headers["Cache-Control"], "private, no-store");
  assert.equal((await f.request("outsider")).statusCode, 404);
  f.records.set(`trips/${tripId}/members/member`, {status: "left"});
  assert.equal((await f.request("member")).statusCode, 404);
  f.records.delete(`trips/${tripId}/members/member`);
  assert.equal((await f.request("member")).statusCode, 200);
  f.records.get(`trips/${tripId}`).images = [];
  assert.equal((await f.request("member")).statusCode, 404);
});

test("shared and discoverable photos follow current publication state", async () => {
  const f = fixture();
  const trip = f.records.get(`trips/${tripId}`);
  trip.isShared = true;
  assert.equal((await f.request("outsider")).statusCode, 200);
  trip.isShared = false;
  assert.equal((await f.request("outsider")).statusCode, 404);
  trip.isPrivate = false;
  f.records.set(`tripDiscovery/${tripId}`, {isDiscoverable: true, images: [tripSource]});
  assert.equal((await f.request("outsider")).statusCode, 200);
  f.records.get(`tripDiscovery/${tripId}`).images = [];
  assert.equal((await f.request("outsider")).statusCode, 404);
  f.records.set("safetyAccounts/owner", {restricted: true});
  assert.equal((await f.request("member")).statusCode, 404);
});

test("a trip or profile source changed during the image read is not returned", async () => {
  const f = fixture();
  f.duringRead = () => { f.records.get(`trips/${tripId}`).images = []; };
  assert.equal((await f.request("member")).statusCode, 404);
  f.duringRead = () => { f.records.get("publicProfile/member").profileImage = ""; };
  assert.equal((await f.request("owner", profileSource)).statusCode, 404);
});

test("profile images require a current visible profile and active accounts", async () => {
  const f = fixture();
  assert.equal((await f.request("owner", profileSource)).statusCode, 200);
  f.records.set("safetyAccounts/member", {restricted: true});
  assert.equal((await f.request("owner", profileSource)).statusCode, 404);
  f.records.delete("safetyAccounts/member");
  f.records.set("users/owner", {isDeleted: true});
  assert.equal((await f.request("owner", profileSource)).statusCode, 404);
});

test("invalid sessions, methods and forged references fail before reading storage", async () => {
  const f = fixture();
  assert.equal((await f.request(null)).statusCode, 401);
  assert.equal((await f.request("invalid")).statusCode, 401);
  assert.equal((await f.request("member", tripSource, "POST")).statusCode, 405);
  assert.equal((await f.request("member", tripSource.replace("/owner/", "/outsider/"))).statusCode, 404);
  assert.equal((await f.request("member", tripSource.replace(`/${tripId}/`, "/other-trip/"))).statusCode, 404);
  assert.equal(f.streams, 0);
});
