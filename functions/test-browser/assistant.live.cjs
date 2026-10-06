// Explicit live qualification. Creates only a uniquely named test account and
// its private trips, then removes those records. Never uses a customer's login.
const assert = require("node:assert/strict");
const {execFileSync} = require("node:child_process");
const {randomUUID, randomBytes} = require("node:crypto");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {Firestore} = require("@google-cloud/firestore");
const {OAuth2Client} = require("google-auth-library");
const {Client} = require("@modelcontextprotocol/sdk/client/index.js");
const {auth: authorizeClient} = require("@modelcontextprotocol/sdk/client/auth.js");
const {StreamableHTTPClientTransport} = require("@modelcontextprotocol/sdk/client/streamableHttp.js");
const {chromium} = require("playwright");
const {hash} = require("../assistant-trip");
const project = "universal-code-135522";
const origin = "https://travelcrew.app";
const base = `${origin}/assistant`;
const mcp = `${origin}/mcp`;

async function main() {
  assert.ok(process.argv.includes("--live"), "Pass --live to authorize temporary production test records");
  const credential = {getAccessToken: async () => ({access_token: execFileSync("gcloud", ["auth", "print-access-token"], {encoding: "utf8"}).trim(), expires_in: 3500})};
  const app = initializeApp({projectId: project, credential}, "assistant-live");
  // Firestore's Admin wrapper rejects custom credentials. Give its underlying
  // client the same short-lived gcloud token used for the Auth test account.
  const authClient = new OAuth2Client();
  authClient.setCredentials({access_token: (await credential.getAccessToken()).access_token});
  const db = new Firestore({projectId: project, databaseId: "travel-crew-db-2", authClient}); const auth = getAuth(app);
  const uid = `mcp-test-${randomUUID()}`; const email = `${uid}@example.com`; const password = randomBytes(24).toString("base64url");
  const store = {}; const tripIds = []; let browser; let client; let created = false;
  const provider = {
    redirectUrl: "http://127.0.0.1:49371/oauth/callback",
    clientMetadata: {client_name: "Travel Crew release qualification", redirect_uris: ["http://127.0.0.1:49371/oauth/callback"], token_endpoint_auth_method: "none", grant_types: ["authorization_code", "refresh_token"], response_types: ["code"]},
    state: () => "travelcrew-live-state", clientInformation: () => store.client,
    saveClientInformation: (v) => { store.client = v; }, tokens: () => store.tokens,
    saveTokens: (v) => { store.tokens = v; }, redirectToAuthorization: (v) => { store.redirect = v; },
    saveCodeVerifier: (v) => { store.verifier = v; }, codeVerifier: () => store.verifier,
  };
  try {
    const metadata = await (await fetch(`${origin}/.well-known/oauth-protected-resource/mcp`)).json();
    assert.equal(metadata.resource, mcp);
    assert.equal(await authorizeClient(provider, {serverUrl: mcp, scope: "trips:create"}), "REDIRECT");
    assert.equal(store.redirect.searchParams.get("resource"), mcp);
    await auth.createUser({uid, email, password, emailVerified: true}); created = true;
    await db.doc(`users/${uid}`).set({uid, displayName: "MCP Release Test", isDeleted: false});
    browser = await chromium.launch({headless: true});
    const page = await browser.newPage({viewport: {width: 390, height: 844}});
    const errors = []; page.on("pageerror", (error) => errors.push(error.message));
    // Only intercept the local OAuth callback; Firebase and service calls are live.
    await page.route("http://127.0.0.1:49371/oauth/callback**", (route) => route.fulfill({contentType: "text/html", body: "<h1>Travel Crew connected</h1>"}));
    await page.goto(store.redirect.href);
    await page.getByLabel("Email", {exact: true}).fill(email);
    await page.getByLabel("Password", {exact: true}).fill(password);
    await page.getByRole("button", {name: "Sign in", exact: true}).click();
    await page.getByRole("button", {name: "Allow trip creation"}).waitFor({state: "visible"});
    await page.screenshot({path: "/private/tmp/travelcrew-mcp-live-consent.png", fullPage: true});
    await page.getByRole("button", {name: "Allow trip creation"}).click();
    await page.waitForURL("http://127.0.0.1:49371/oauth/callback**");
    const callback = new URL(page.url()); assert.equal(callback.searchParams.get("iss"), base); assert.equal(callback.searchParams.get("state"), "travelcrew-live-state");
    assert.equal(await authorizeClient(provider, {serverUrl: mcp, authorizationCode: callback.searchParams.get("code"), scope: "trips:create"}), "AUTHORIZED");
    client = new Client({name: "travelcrew-live-test", version: "1.0.0"});
    await client.connect(new StreamableHTTPClientTransport(new URL(mcp), {requestInit: {headers: {Authorization: `Bearer ${store.tokens.access_token}`}}}));
    const tools = await client.listTools(); assert.deepEqual(tools.tools.map((v) => v.name), ["create_trip"]);
    assert.ok(tools.tools[0].outputSchema); assert.deepEqual(tools.tools[0]._meta.securitySchemes, [{type: "oauth2", scopes: ["trips:create"]}]);
    const trip = {title: "MCP verification — delete after test", destination: "Tokyo", country: "Japan", start_date: "2027-04-10", end_date: "2027-04-12"};
    const variants = [trip, {...trip, activities: [{title: "Museum", start_datetime: "2027-04-10T10:00:00+09:00"}]}, {...trip, lodging: {name: "User-specified hotel", check_in: "2027-04-10", check_out: "2027-04-12"}}, {...trip, airline: {name: "User-specified airline", flight_number: "TEST123"}}, {...trip, expenses: [{name: "User-requested expense", amount: 20, date: "2027-04-10"}]}];
    for (const input of variants) {
      const args = {trip: input, idempotency_key: randomUUID()};
      const saved = await client.callTool({name: "create_trip", arguments: args});
      assert.ok(!saved.isError, JSON.stringify(saved)); tripIds.push(saved.structuredContent.trip_id);
      const retry = await client.callTool({name: "create_trip", arguments: args});
      assert.equal(retry.structuredContent.trip_id, saved.structuredContent.trip_id); assert.equal(retry.structuredContent.replayed, true);
      const record = (await db.doc(`trips/${saved.structuredContent.trip_id}`).get()).data();
      assert.equal(record.createdBy, uid); assert.equal(record.isPrivate, true); assert.equal(record.isShared, false);
      assert.equal((await db.doc(`users/${uid}/tripMemberships/${record.id}`).get()).data().status, "active");
      const denied = await fetch(`${origin}/api/shared-trip?tripId=${record.id}`); assert.equal(denied.status, 404);
    }
    for (const invalid of [{...trip, is_private: false}, {...trip, createdBy: "someone-else"}, {...trip, start_date: "2027-02-30"}]) {
      const result = await client.callTool({name: "create_trip", arguments: {trip: invalid, idempotency_key: randomUUID()}});
      assert.equal(result.isError, true);
    }
    await page.goto(`${base}/trips/${tripIds[0]}`);
    assert.equal(await page.getByRole("link", {name: "Open in TravelCrew"}).getAttribute("href"), `travelcrew://trips/${tripIds[0]}`);
    assert.ok(!(await page.content()).includes(trip.title));
    await page.goto(`${base}/connect`);
    await page.getByLabel("Email", {exact: true}).fill(email); await page.getByLabel("Password", {exact: true}).fill(password);
    await page.getByRole("button", {name: "Sign in", exact: true}).click();
    await page.getByRole("button", {name: "Disconnect", exact: true}).click();
    await page.getByText("No assistants are connected.").waitFor();
    assert.equal((await fetch(mcp, {method: "POST", headers: {Authorization: `Bearer ${store.tokens.access_token}`, "Content-Type": "application/json"}, body: "{}"})).status, 401);
    assert.deepEqual(errors, []);
    console.log("PASS live: OAuth discovery/DCR/PKCE, real browser sign-in and consent, issuer callback, MCP initialize/list/call, five trip variants and retries, private app memberships, three invalid inputs, app link, disconnect and revoked token.");
  } finally {
    if (client) await client.close(); if (browser) await browser.close();
    if (created) {
      // Query by this run's unique uid, including writes whose responses were lost.
      const trips = await db.collection("trips").where("createdBy", "==", uid).get();
      for (const doc of trips.docs) { await db.recursiveDelete(doc.ref); await db.doc(`tripDiscovery/${doc.id}`).delete(); }
      for (const collection of ["assistantRequests", "assistantOAuthCodes", "assistantOAuthTokens", "assistantOAuthGrants"]) {
        const docs = await db.collection(collection).where("uid", "==", uid).get();
        for (const doc of docs.docs) await doc.ref.delete();
      }
      for (const collection of ["users", "publicProfile", "public_profile", "notifications", "tokens", "safetyAccounts"]) await db.recursiveDelete(db.doc(`${collection}/${uid}`));
      await db.doc(`assistantQuotas/${hash(`${uid}:${Math.floor(Date.now() / 86400000)}`)}`).delete();
      await auth.deleteUser(uid);
    }
    if (store.client) {
      const requests = await db.collection("assistantOAuthRequests").where("clientId", "==", store.client.client_id).get();
      for (const doc of requests.docs) await doc.ref.delete();
      await db.doc(`assistantOAuthClients/${hash(store.client.client_id)}`).delete();
    }
    await db.terminate(); await deleteApp(app);
    console.log("Temporary live test account, trips and OAuth records cleaned up.");
  }
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
