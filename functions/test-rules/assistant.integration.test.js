const {before, after, test} = require("node:test");
const assert = require("node:assert/strict");
const {createHash, randomUUID} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {Client} = require("@modelcontextprotocol/sdk/client/index.js");
const {auth: authorizeClient} = require("@modelcontextprotocol/sdk/client/auth.js");
const {StreamableHTTPClientTransport} = require("@modelcontextprotocol/sdk/client/streamableHttp.js");
const {createAssistantApp} = require("../assistant-api");
const {createTripService, hash} = require("../assistant-trip");
const {sendInboxPush} = require("../notification-delivery");
let app; let db; let auth; let server; let origin; let base; let ownerToken; let strangerToken;
const owner = "assistant-owner"; const stranger = "assistant-stranger";
const trip = {title: "Tokyo weekend", destination: "Tokyo", country: "Japan", start_date: "2027-04-10", end_date: "2027-04-12",
  activities: [{title: "Museum", description: "Exhibits", location: "Museum", address: "Tokyo", start_datetime: "2027-04-10T10:00:00+09:00", end_datetime: "2027-04-10T11:00:00+09:00"}],
  expenses: [{name: "Booked hotel", amount: 120, date: "2027-04-10"}],
  lodging: {name: "Hotel", check_in: "2027-04-10", check_out: "2027-04-12", cost_per_night: 60},
  airline: {name: "Airline", flight_number: "AB123", departure_date: "2027-04-09", arrival_date: "2027-04-10"}};
async function request(path, {method = "GET", body, token, headers = {}} = {}) {
  const response = await fetch(`${base}${path}`, {method, headers: {...(body ? {"Content-Type": "application/json"} : {}), ...(token ? {Authorization: `Bearer ${token}`} : {}), ...headers}, body: body ? JSON.stringify(body) : undefined, redirect: "manual"});
  const text = await response.text();
  let data; try { data = JSON.parse(text); } catch { data = text; }
  return {status: response.status, headers: response.headers, data};
}
async function link({approve = true, token = ownerToken} = {}) {
  const registration = await request("/oauth/register", {method: "POST", body: {client_name: "Test assistant", redirect_uris: ["https://client.example/callback"], token_endpoint_auth_method: "none"}});
  assert.equal(registration.status, 201);
  const clientId = registration.data.client_id; const verifier = "v".repeat(64);
  const query = new URLSearchParams({client_id: clientId, redirect_uri: "https://client.example/callback", response_type: "code", scope: "trips:create", resource: `${base}/mcp`, state: "state-with-&-characters", code_challenge_method: "S256", code_challenge: createHash("sha256").update(verifier).digest("base64url")});
  const authorization = await request(`/oauth/authorize?${query}`);
  assert.equal(authorization.status, 200);
  assert.match(authorization.headers.get("content-security-policy"), /frame-ancestors 'none'/);
  const cookie = authorization.headers.get("set-cookie").split(";")[0];
  const id = /"requestId":"([^"]+)"/.exec(authorization.data)[1];
  const approved = await request("/oauth/consent", {method: "POST", token, body: {request_id: id, approve}, headers: {Origin: origin, Cookie: cookie}});
  assert.equal(approved.status, 200);
  const redirect = new URL(approved.data.redirect);
  assert.equal(redirect.origin, "https://client.example"); assert.equal(redirect.searchParams.get("state"), "state-with-&-characters");
  return {clientId, verifier, code: redirect.searchParams.get("code"), redirect, id, cookie};
}
async function exchange(linked, overrides = {}) {
  return request("/oauth/token", {method: "POST", body: {grant_type: "authorization_code", client_id: linked.clientId,
    code: linked.code, code_verifier: linked.verifier, redirect_uri: "https://client.example/callback", resource: `${base}/mcp`, ...overrides}});
}
async function signIn(email, password) {
  const response = await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key`, {
    method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify({email, password, returnSecureToken: true}),
  });
  const result = await response.json(); assert.ok(result.idToken); return result.idToken;
}
before(async () => {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) throw new Error("Firestore AND Auth emulators required");
  app = initializeApp({projectId: "demo-travelcrew-safety"}, "assistant-integration");
  db = getFirestore(app, "assistant-integration"); auth = getAuth(app);
  for (const uid of [owner, stranger]) {
    try { await auth.deleteUser(uid); } catch (error) { if (error.code !== "auth/user-not-found") throw error; }
    await auth.createUser({uid, email: `${uid}@example.com`, password: "test-password-123", emailVerified: true});
    await db.doc(`users/${uid}`).set({uid});
  }
  ownerToken = await signIn(`${owner}@example.com`, "test-password-123");
  strangerToken = await signIn(`${stranger}@example.com`, "test-password-123");
  // Start with an ephemeral port, then build the application using its actual URL.
  const http = require("node:http"); let handler;
  server = http.createServer((req, res) => handler(req, res));
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  origin = `http://127.0.0.1:${server.address().port}`; base = `${origin}/assistant`;
  handler = createAssistantApp({db, auth, baseUrl: base, firebaseConfig: {apiKey: "fake-key", projectId: "demo-travelcrew-safety"}});
});
after(async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  if (db) await db.terminate(); if (app) await deleteApp(app);
});

test("API rejects anonymous requests and advertises discoverable OAuth metadata", async () => {
  const denied = await request("/v1/trips", {method: "POST", body: trip}); assert.equal(denied.status, 401);
  const metadataUrl = /resource_metadata="([^"]+)"/.exec(denied.headers.get("www-authenticate"))[1];
  const meta = await (await fetch(metadataUrl)).json(); assert.equal(meta.resource, `${base}/mcp`);
  const issuer = await (await fetch(`${origin}/.well-known/oauth-authorization-server/assistant`)).json();
  assert.equal(issuer.issuer, base); assert.deepEqual(issuer.code_challenge_methods_supported, ["S256"]);
  const spec = await request("/openapi.json"); assert.equal(spec.status, 200); assert.ok(spec.data.paths["/v1/trips"].post.requestBody);
  const mcp = await request("/mcp", {method: "POST", body: {}}); assert.equal(mcp.status, 401);
  assert.equal((await request("/v1/trips", {method: "POST", body: trip, token: "forged"})).status, 401);
});
test("API atomically persists Flutter-compatible private itinerary, memberships and one notification", async () => {
  const key = randomUUID();
  const response = await request("/v1/trips", {method: "POST", body: trip, token: ownerToken, headers: {"Idempotency-Key": key}});
  assert.equal(response.status, 201); const id = response.data.trip_id;
  const saved = (await db.doc(`trips/${id}`).get()).data();
  assert.equal(saved.createdBy, owner); assert.equal(saved.isPrivate, true); assert.equal(saved.isShared, false); assert.deepEqual(saved.images, []);
  assert.equal(saved.tripStartDate, "2027-04-10T00:00:00.000"); assert.deepEqual(saved.joinedUsers, []);
  assert.equal((await db.doc(`tripDiscovery/${id}`).get()).exists, false);
  assert.equal((await db.doc(`users/${owner}/tripMemberships/${id}`).get()).data().role, "creator");
  assert.equal((await db.doc(`trips/${id}/members/${owner}`).get()).data().status, "active");
  assert.equal((await db.doc(`trips/${id}/activities/activity_0`).get()).data().startDateTime, trip.activities[0].start_datetime);
  assert.deepEqual((await db.doc(`trips/${id}/expenses/expense_0`).get()).data().owners, {[owner]: 120});
  assert.equal((await db.doc(`trips/${id}/flights/${owner}`).get()).data().userId, owner);
  const note = (await db.doc(`notifications/${owner}/notification/assistant_${id}`).get()).data(); assert.equal(note.notificationType, "Trip");
  const retry = await request("/v1/trips", {method: "POST", body: trip, token: ownerToken, headers: {"Idempotency-Key": key}});
  assert.equal(retry.status, 200); assert.equal(retry.data.trip_id, id);
  const conflict = await request("/v1/trips", {method: "POST", body: {...trip, title: "Different"}, token: ownerToken, headers: {"Idempotency-Key": key}});
  assert.equal(conflict.status, 409);
  const other = await request("/v1/trips", {method: "POST", body: trip, token: strangerToken, headers: {"Idempotency-Key": key}});
  assert.equal(other.status, 201); assert.notEqual(other.data.trip_id, id);
  const landing = await request(`/trips/${id}`); assert.equal(landing.status, 200); assert.ok(landing.data.includes(`travelcrew://trips/${id}`));
  assert.ok(!landing.data.includes("Tokyo weekend"), "Unauthenticated landing page must not leak trip data");
  await db.doc(`tokens/${owner}/tokens/test-device`).set({});
  let pushes = 0;
  await sendInboxPush(db, {sendEachForMulticast: async () => { pushes++; return {responses: [{success: true}]}; }}, {params: {userId: owner, notificationId: `assistant_${id}`}});
  assert.equal(pushes, 1);
});
test("concurrent requests with one key produce exactly one trip", async () => {
  const service = createTripService(db, base); const key = randomUUID();
  const results = await Promise.all(Array.from({length: 5}, () => service(owner, trip, key)));
  assert.equal(new Set(results.map((r) => r.trip_id)).size, 1); assert.equal(results.filter((r) => !r.replayed).length, 1);
});
test("invalid input, forbidden identity fields, cross-origin requests and oversized bodies are rejected", async () => {
  for (const body of [{...trip, createdBy: stranger}, {...trip, is_private: false}, {...trip, end_date: "2027-04-01"}]) {
    assert.equal((await request("/v1/trips", {method: "POST", body, token: ownerToken, headers: {"Idempotency-Key": randomUUID()}})).status, 400);
  }
  assert.equal((await request("/v1/trips", {method: "POST", body: trip, token: ownerToken})).status, 400);
  assert.equal((await request("/v1/trips", {method: "POST", body: trip, token: ownerToken, headers: {Origin: "https://evil.example"}})).status, 403);
  assert.equal((await request("/v1/trips", {method: "POST", body: {huge: "x".repeat(140000)}, token: ownerToken})).status, 413);
});
test("OAuth requires exact redirect, PKCE, resource and explicit cookie-bound consent", async () => {
  assert.equal((await request("/oauth/register", {method: "POST", body: {redirect_uris: ["javascript:alert(1)"]}})).status, 400);
  const linked = await link();
  assert.equal((await request(`/oauth/authorize?client_id=${linked.clientId}&redirect_uri=https://evil.example`)).status, 400);
  assert.equal((await exchange(linked, {code_verifier: "x".repeat(64)})).status, 400);
  assert.equal((await exchange(linked, {client_id: "wrong"})).status, 400);
  assert.equal((await exchange(linked, {resource: "https://evil.example"})).status, 400);
  assert.equal((await exchange(linked, {redirect_uri: "https://evil.example"})).status, 400);
  const issued = await exchange(linked); assert.equal(issued.status, 200);
  assert.equal((await exchange(linked)).status, 400);
  assert.equal((await request("/oauth/consent", {method: "POST", token: ownerToken, headers: {Origin: origin}, body: {request_id: linked.id, approve: true}})).status, 400);
  const denied = await link({approve: false}); assert.equal(denied.redirect.searchParams.get("error"), "access_denied"); assert.equal(denied.code, null);
});
test("official MCP client initializes, discovers create_trip, creates and retries through OAuth", async () => {
  const linked = await link(); const tokens = (await exchange(linked)).data;
  const client = new Client({name: "integration-test", version: "1.0.0"});
  const transport = new StreamableHTTPClientTransport(new URL(`${base}/mcp`), {requestInit: {headers: {Authorization: `Bearer ${tokens.access_token}`}}});
  try {
    await client.connect(transport);
    const tools = await client.listTools(); assert.deepEqual(tools.tools.map((t) => t.name), ["create_trip"]);
    const args = {trip, idempotency_key: randomUUID()};
    const result = await client.callTool({name: "create_trip", arguments: args});
    assert.ok(!result.isError, JSON.stringify(result)); assert.equal(result.structuredContent.is_private, true);
    const retry = await client.callTool({name: "create_trip", arguments: args}); assert.equal(retry.structuredContent.trip_id, result.structuredContent.trip_id);
    const conflict = await client.callTool({name: "create_trip", arguments: {...args, trip: {...trip, title: "Changed"}}}); assert.equal(conflict.isError, true);
    assert.equal((await db.doc(`trips/${result.structuredContent.trip_id}`).get()).data().createdBy, owner);
  } finally { await client.close(); }
});
test("refresh rotates tokens, detects reuse, and revokes the entire connection", async () => {
  const linked = await link(); const tokens = (await exchange(linked)).data;
  const body = {grant_type: "refresh_token", client_id: linked.clientId, refresh_token: tokens.refresh_token, resource: `${base}/mcp`};
  const rotated = await request("/oauth/token", {method: "POST", body}); assert.equal(rotated.status, 200);
  assert.notEqual(rotated.data.refresh_token, tokens.refresh_token);
  assert.equal((await request("/oauth/token", {method: "POST", body})).status, 400);
  const rejected = await request("/v1/trips", {method: "POST", token: rotated.data.access_token, body: trip, headers: {"Idempotency-Key": randomUUID()}});
  assert.equal(rejected.status, 401);
});
test("official SDK discovers OAuth, registers, builds PKCE authorization and exchanges the code", async () => {
  const store = {};
  const provider = {
    redirectUrl: "https://client.example/callback",
    clientMetadata: {client_name: "SDK OAuth test", redirect_uris: ["https://client.example/callback"], token_endpoint_auth_method: "none", grant_types: ["authorization_code", "refresh_token"], response_types: ["code"]},
    state: () => "sdk-state", clientInformation: () => store.client,
    saveClientInformation: (value) => { store.client = value; },
    tokens: () => store.tokens, saveTokens: (value) => { store.tokens = value; },
    redirectToAuthorization: (value) => { store.redirect = value; },
    saveCodeVerifier: (value) => { store.verifier = value; }, codeVerifier: () => store.verifier,
  };
  assert.equal(await authorizeClient(provider, {serverUrl: `${base}/mcp`, scope: "trips:create"}), "REDIRECT");
  assert.equal(store.redirect.searchParams.get("resource"), `${base}/mcp`);
  const response = await fetch(store.redirect); assert.equal(response.status, 200);
  const html = await response.text(); const cookie = response.headers.get("set-cookie").split(";")[0];
  const id = /"requestId":"([^"]+)"/.exec(html)[1];
  const consent = await request("/oauth/consent", {method: "POST", token: ownerToken, body: {request_id: id, approve: true}, headers: {Origin: origin, Cookie: cookie}});
  assert.equal(consent.status, 200);
  const callback = new URL(consent.data.redirect); assert.equal(callback.searchParams.get("state"), "sdk-state");
  assert.equal(await authorizeClient(provider, {serverUrl: `${base}/mcp`, authorizationCode: callback.searchParams.get("code"), scope: "trips:create"}), "AUTHORIZED");
  assert.ok(store.tokens.access_token.startsWith("tc_at_")); assert.equal(store.tokens.issuer, base);
});
test("only the account owner can disconnect and revoked tokens stop working immediately", async () => {
  const linked = await link(); const tokens = (await exchange(linked)).data;
  const connections = await request("/connections", {token: ownerToken}); assert.equal(connections.status, 200);
  const record = (await db.doc(`assistantOAuthTokens/${hash(tokens.access_token)}`).get()).data();
  assert.ok(connections.data.connections.some((c) => c.id === record.grant));
  assert.equal((await request(`/connections/${record.grant}`, {method: "DELETE", body: {}, token: strangerToken})).status, 404);
  assert.equal((await request(`/connections/${record.grant}`, {method: "DELETE", body: {}, token: ownerToken})).status, 200);
  assert.equal((await request("/v1/trips", {method: "POST", token: tokens.access_token, body: trip, headers: {"Idempotency-Key": randomUUID()}})).status, 401);
});
test("expired codes and access tokens fail closed", async () => {
  const linked = await link();
  await db.doc(`assistantOAuthCodes/${hash(linked.code)}`).update({expiresAt: new Date(0)});
  assert.equal((await exchange(linked)).status, 400);
  const another = await link(); const tokens = (await exchange(another)).data;
  await db.doc(`assistantOAuthTokens/${hash(tokens.access_token)}`).update({expiresAt: new Date(0)});
  assert.equal((await request("/v1/trips", {method: "POST", token: tokens.access_token, body: trip, headers: {"Idempotency-Key": randomUUID()}})).status, 401);
});
test("restrictions, deleted accounts and quotas prevent writes, but retries do not consume quota", async () => {
  await db.doc(`safetyAccounts/${owner}`).set({restricted: true});
  assert.equal((await request("/v1/trips", {method: "POST", body: trip, token: ownerToken, headers: {"Idempotency-Key": randomUUID()}})).status, 403);
  await db.doc(`safetyAccounts/${owner}`).delete();
  await db.doc(`users/${owner}`).update({isDeleted: true});
  assert.equal((await request("/v1/trips", {method: "POST", body: trip, token: ownerToken, headers: {"Idempotency-Key": randomUUID()}})).status, 403);
  await db.doc(`users/${owner}`).update({isDeleted: false});
  const create = createTripService(db, base); const key = randomUUID(); const initial = await create(owner, trip, key);
  await db.doc(`assistantQuotas/${hash(`${owner}:${Math.floor(Date.now() / 86400000)}`)}`).set({count: 30});
  assert.equal((await create(owner, trip, key)).trip_id, initial.trip_id);
  await assert.rejects(create(owner, trip, randomUUID()), (e) => e.status === 429);
});
