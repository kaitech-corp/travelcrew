// Run with Firebase Auth and Firestore emulators. No production accounts or data.
const assert = require("node:assert/strict");
const {createHash, randomUUID} = require("node:crypto");
const http = require("node:http");
const {chromium} = require("playwright");
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getAuth} = require("firebase-admin/auth");
const {createAssistantApp} = require("../assistant-api");

async function main() {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST && process.env.FIREBASE_AUTH_EMULATOR_HOST, "Emulators required");
  const app = initializeApp({projectId: "demo-travelcrew-safety"}, "assistant-browser");
  const db = getFirestore(app, "assistant-browser"); const auth = getAuth(app);
  const uid = "assistant-browser"; const email = "assistant-browser@example.com";
  let browser; let server; let upstream;
  try {
    try { await auth.deleteUser(uid); } catch (error) { if (error.code !== "auth/user-not-found") throw error; }
    await auth.createUser({uid, email, password: "test-password-123", emailVerified: true});
    await db.doc(`users/${uid}`).set({uid});
    let handler;
    upstream = http.createServer((req, res) => handler(req, res));
    await new Promise((resolve) => upstream.listen(0, "127.0.0.1", resolve));
    const {createWebServer} = await import("../../travel_crew_web/server.mjs");
    server = createWebServer({assistantUpstream: `http://127.0.0.1:${upstream.address().port}`});
    await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
    const base = `http://127.0.0.1:${server.address().port}/assistant`;
    const mcpUrl = `http://127.0.0.1:${server.address().port}/mcp`;
    handler = createAssistantApp({db, auth, baseUrl: base, mcpUrl, firebaseConfig: {apiKey: "fake-key", projectId: "demo-travelcrew-safety", authDomain: "demo-travelcrew-safety.firebaseapp.com"}});
    const post = async (path, body, token, headers = {}) => {
      const response = await fetch(base + path, {method: "POST", headers: {"Content-Type": "application/json", ...(token ? {Authorization: `Bearer ${token}`} : {}), ...headers}, body: JSON.stringify(body)});
      return {status: response.status, body: await response.json()};
    };
    const registered = await post("/oauth/register", {client_name: "My travel assistant", redirect_uris: ["https://client.example/callback"]});
    assert.equal(registered.status, 201);
    const clientId = registered.body.client_id; const verifier = "v".repeat(64);
    const query = new URLSearchParams({client_id: clientId, redirect_uri: "https://client.example/callback", response_type: "code", scope: "trips:create", resource: mcpUrl, state: "browser-state", code_challenge_method: "S256", code_challenge: createHash("sha256").update(verifier).digest("base64url")});
    browser = await chromium.launch({headless: true});
    const page = await browser.newPage({viewport: {width: 390, height: 844}});
    const errors = []; page.on("pageerror", (error) => errors.push(error.message));
    // Exercise the real Firebase browser SDK against Auth emulator responses.
    // Only this test intercepts Google requests; production pages are unchanged.
    await page.route("https://identitytoolkit.googleapis.com/**", async (route) => {
      const target = new URL(route.request().url());
      const response = await route.fetch({url: `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com${target.pathname}${target.search}`});
      await route.fulfill({response});
    });
    await page.route("https://client.example/callback**", (route) => route.fulfill({contentType: "text/html", body: "<h1>Connected</h1>"}));
    await page.goto(`${base}/oauth/authorize?${query}`);
    await page.getByLabel("Email", {exact: true}).fill(email);
    await page.getByLabel("Password", {exact: true}).fill("test-password-123");
    await page.getByRole("button", {name: "Sign in", exact: true}).click();
    await page.getByRole("button", {name: "Allow trip creation"}).waitFor({state: "visible"});
    await page.screenshot({path: process.env.ASSISTANT_SCREENSHOT || "/private/tmp/travelcrew-assistant-consent.png", fullPage: true});
    await page.getByRole("button", {name: "Allow trip creation"}).click();
    await page.waitForURL("https://client.example/callback**");
    const callback = new URL(page.url()); assert.equal(callback.searchParams.get("state"), "browser-state"); assert.equal(callback.searchParams.get("iss"), base);
    const issued = await post("/oauth/token", {client_id: clientId, grant_type: "authorization_code", code: callback.searchParams.get("code"), code_verifier: verifier, redirect_uri: "https://client.example/callback", resource: mcpUrl});
    assert.equal(issued.status, 200);
    const itinerary = {destination: "Tokyo", country: "Japan", start_date: "2027-04-10", end_date: "2027-04-12"};
    const saved = await post("/v1/trips", itinerary, issued.body.access_token, {"Idempotency-Key": randomUUID()}); assert.equal(saved.status, 201);
    await page.goto(saved.body.url);
    assert.equal(await page.getByRole("link", {name: "Open in TravelCrew"}).getAttribute("href"), saved.body.app_url);
    await page.goto(`${base}/connect`);
    await page.getByLabel("Email", {exact: true}).fill(email);
    await page.getByLabel("Password", {exact: true}).fill("test-password-123");
    await page.getByRole("button", {name: "Sign in", exact: true}).click();
    await page.getByRole("button", {name: "Disconnect", exact: true}).click();
    await page.getByText("No assistants are connected.").waitFor();
    assert.equal((await post("/v1/trips", itinerary, issued.body.access_token, {"Idempotency-Key": randomUUID()})).status, 401);
    assert.deepEqual(errors, []);
    console.log("Browser passed: real Firebase email sign-in, consent, callback, trip creation, app link and disconnect.");
  } finally {
    if (browser) await browser.close();
    if (server) await new Promise((resolve) => server.close(resolve));
    if (upstream) await new Promise((resolve) => upstream.close(resolve));
    await db.terminate(); await deleteApp(app);
  }
}
main().catch((error) => { console.error(error); process.exitCode = 1; });
