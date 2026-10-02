# Assistant trip creation

TravelCrew accepts private itineraries through an authenticated HTTP API and the
`create_trip` MCP tool. Both call the same Firestore transaction. Users connect
their existing TravelCrew account, ask an assistant to save an itinerary, and
receive an HTTPS link with an **Open in TravelCrew** button. New trips also appear
in My Trips and generate a server-owned inbox notification.

## Endpoints

All service routes use `ASSISTANT_BASE_URL`, normally
`https://universal-code-135522.web.app/assistant`.

| Route | Purpose |
| --- | --- |
| `POST /v1/trips` | Create a private trip; accepts an OAuth access token or a Firebase ID token |
| `POST /mcp` | Stateless Streamable HTTP MCP; OAuth access token required |
| `GET /openapi.json` | OpenAPI 3.1 contract generated from the validated itinerary schema |
| `GET /connect` | Sign in to list and disconnect assistants |
| `GET /trips/:id` | Privacy-preserving app-opening page; exposes no itinerary details |
| `POST /oauth/register` | Register a public OAuth client with exact HTTPS or loopback redirect URIs |
| `GET /oauth/authorize` | Firebase sign-in and explicit consent |
| `POST /oauth/token` | Exchange authorization codes or rotate refresh tokens |
| `POST /oauth/revoke` | Revoke the connection associated with a token |

Discovery is served at
`/.well-known/oauth-authorization-server/assistant` and
`/.well-known/oauth-protected-resource/assistant/mcp` on the Hosting origin.
The 401 challenge supplies the protected-resource metadata URL. The resource
indicator is the full MCP URL, including `/assistant/mcp`; the only scope is
`trips:create`. Use a fresh S256 PKCE verifier for each authorization request.
Clients must support public-client authorization-code OAuth, dynamic registration,
and Streamable HTTP. This does not automatically publish TravelCrew in any
assistant's directory. It can be added as a custom connection by compatible hosts.

## Itinerary contract

```json
{
  "title": "Tokyo weekend",
  "destination": "Tokyo",
  "country": "Japan",
  "start_date": "2027-04-10",
  "end_date": "2027-04-12",
  "is_private": true,
  "lodging": {
    "name": "A hotel selected by the user",
    "check_in": "2027-04-10",
    "check_out": "2027-04-12"
  },
  "activities": [{
    "title": "Museum visit",
    "start_datetime": "2027-04-10T10:00:00+09:00",
    "end_datetime": "2027-04-10T12:00:00+09:00"
  }]
}
```

Destination, country and calendar dates are required. Activity timestamps require
an explicit UTC offset or `Z`. Up to 50 activities and 50 expenses are accepted;
each expense requires a positive amount and date. Unknown fields are rejected,
including caller-supplied owner IDs, members and permissions. `is_private: false`
is rejected. Record only expenses the user wants entered; the tool does not book
travel and should not invent bookings or treat estimated costs as paid expenses.
The existing manual JSON importer also accepts local activity timestamps; the
external API deliberately requires their timezone to avoid ambiguous imports.

Send `Authorization: Bearer <token>` and `Idempotency-Key: <unique-request-id>`.
Keys must contain 16–128 letters, digits, underscores or hyphens. Retries must use
the same key and itinerary; different content with an existing key returns 409.
For MCP, use `{ "idempotency_key": "...", "trip": { ... } }`.

Creation returns 201, or 200 for a replay:

```json
{
  "trip_id": "<uuid>",
  "url": "https://universal-code-135522.web.app/assistant/trips/<uuid>",
  "app_url": "travelcrew://trips/<uuid>",
  "is_private": true,
  "replayed": false
}
```

HTTP errors use `error` and `error_description`. MCP creation errors use an
`isError` tool result with a structured JSON text message. An uncertain network
failure should be retried with the same idempotency key.

## Data and authorization

The creation transaction writes the private trip, creator membership, user
membership, activities, expenses, owner flight, inbox event, daily quota and
idempotency receipt. It creates no discovery listing or invitations. Existing
app services load these records without a new trip model. The normal notification
delivery trigger handles push delivery independently of trip creation.

Firebase identities are verified with revocation checks. OAuth credentials are
opaque random strings; only their SHA-256 hashes are stored. Consent is bound to
an HttpOnly SameSite cookie and the service origin. Authorization codes expire in
2 minutes and are single-use. Access tokens expire after 1 hour; refresh tokens
rotate and reuse revokes the entire grant. Connections expire after 30 days.
Disabled, deleted, restricted or credential-revoked accounts lose access.
Disconnect revokes both access and refresh tokens for the connection.

Limits: 128 KiB requests, 30 new trips per account per UTC day, 200 client
registrations and 2,000 authorization-page requests per service per UTC day.
Retries do not consume the trip quota. Public endpoint limits are conservative
deployment-wide caps; tune them for adoption and monitor 429 rates. Cross-origin
browser requests are rejected; assistant hosts should call the service from their
backend. OAuth browser navigation and same-origin consent remain supported.

`assistantOAuth*`, `assistantRequests`, and `assistantQuotas` use the existing
server-owned rules fallback; ordinary app clients cannot read or write them.
Existing moderator claims retain their administrative read access. TTL policies
remove expired requests, codes, tokens, grants, clients and quota windows.
Expiration is checked synchronously even before TTL cleanup runs. Registered
clients expire after 180 days and must register again. Idempotency receipts are
retained so old retries cannot silently recreate deleted trips; account-erasure
operations must include assistant receipts and grant records.

## Configuration and release

Implementation and local tests do not deploy the feature. Release the backend,
Hosting configuration, indexes and updated mobile app together. Before using the
Hosting deployment below, review the project's existing Hosting site: deploying
this configuration replaces its currently deployed routes and static files.
If that site already hosts another product, use a dedicated Hosting site/custom
domain and set the same base URL in the backend and Flutter build.

1. Use Node 22 and run `npm --prefix functions ci`.
2. Put these settings in your environment-specific Functions dotenv file, such
   as `functions/.env.universal-code-135522`. This is browser Firebase configuration,
   never a service-account key. Copy the web app values from Firebase project settings
   or `lib/firebase_options.dart`:

   ```dotenv
   ASSISTANT_BASE_URL=https://universal-code-135522.web.app/assistant
   ASSISTANT_FIREBASE_CONFIG={"apiKey":"<web-api-key>","authDomain":"universal-code-135522.firebaseapp.com","projectId":"universal-code-135522","appId":"<web-app-id>"}
   ```

3. Add the Hosting origin to Firebase Authentication's authorized domains. Enable
   the sign-in providers used by your accounts. Email/password works with the
   existing account credentials; Google and Apple buttons use Firebase web popup
   sign-in and need those providers' web configuration. Complete new profiles in
   the mobile app before connecting an assistant. OAuth client consent never
   receives the user's password or Firebase token.
4. Confirm the named database is `travel-crew-db-2` (or set
   `FIRESTORE_DATABASE_ID`). Deploy the new function, Hosting routes and indexes:

   ```sh
   firebase deploy --only functions:assistantV1,hosting,firestore:indexes
   ```

   Deploy the repository's coordinated Firestore rules and notification lifecycle
   separately if not already released. `sendPushNotificationV3` must be deployed
   for mobile push notifications; creation and the inbox record do not depend on
   successful push delivery. Wait for the `tripMemberships` index to finish building
   before releasing the app's new membership query.
5. Build and release the mobile app with the same base URL:

   ```sh
   flutter build appbundle --dart-define=ASSISTANT_BASE_URL=https://universal-code-135522.web.app/assistant
   flutter build ipa --dart-define=ASSISTANT_BASE_URL=https://universal-code-135522.web.app/assistant
   ```

   The app registers `travelcrew://trips/<uuid>` on Android and iOS, waits for the
   authenticated session, and checks normal Firestore access before opening the
   trip. The HTTPS landing page works without universal-link domain association.
6. Add `<base>/mcp` to a compatible assistant; sign in, approve, create a trip,
   retry once, open the trip on a device, then disconnect and verify further
   creation fails. Also verify Google/Apple sign-in for whichever providers are
   enabled in production. Their external login pages are not exercised locally.

If configuration is absent, `assistantV1` returns 503 instead of exposing an
unauthenticated fallback. Disable the function/Hosting route to stop new external
requests; existing private trips remain normal app records.

## Verification

```sh
npm --prefix functions run lint
npm --prefix functions test
# Java 21 is required by the installed Firestore emulator.
firebase emulators:exec --only firestore,auth --project demo-travelcrew-safety \
  'npm --prefix functions run test:rules'
# Install the Chromium test browser once from the functions directory:
cd functions
npx playwright install chromium
cd ..
firebase emulators:exec --only firestore,auth --project demo-travelcrew-safety \
  'npm --prefix functions run test:assistant:browser'
flutter analyze
flutter test
```

The integration suite uses real Firestore transactions, Firebase Auth emulator
tokens and the official MCP client. It covers concurrent retries, privacy,
ownership, invalid inputs, PKCE, consent, token rotation/reuse, revocation,
expiration and quotas. Browser verification uses the real Firebase web SDK with
its identity requests routed to the Auth emulator. It exercises email sign-in,
consent, callback, trip creation, the app-opening page and disconnect. It saves a
consent screenshot to `/private/tmp/travelcrew-assistant-consent.png` (override with
`ASSISTANT_SCREENSHOT`). Flutter tests cover app-link parsing, model compatibility,
and copying the connection URL at phone/tablet widths with large text.

Protocol references: [official MCP SDK](https://ts.sdk.modelcontextprotocol.io/server),
[MCP authorization](https://apps.extensions.modelcontextprotocol.io/api/documents/authorization.html),
[Firestore TTL configuration](https://firebase.google.com/docs/reference/firestore/indexes).

### Local verification recorded October 2, 2026

- Backend lint and all 41 unit tests passed using Node 22.
- All 23 rules/integration cases passed; a subsequent assistant-only run also
  passed the additional official SDK automatic OAuth discovery/registration case
  (12 assistant schema/integration cases in that run).
- Chromium browser sign-in, consent, creation, landing page and disconnect passed.
- Full Flutter analysis passed; all 29 Flutter tests passed after replacing the
  obsolete generated counter-app test with connection-card coverage.
- iOS URL configuration passed `plutil` validation.

These checks used local emulators and did not deploy to Firebase, publish a mobile
build, exercise Google/Apple's external login pages, or launch a native device.
The existing npm dependency audit reports seven findings in Firebase test
dependencies and the gaxios/uuid dependency chain; the new MCP, Express, Zod and
Playwright packages were not the reported vulnerable packages. No forced dependency
downgrades or unrelated dependency replacements were applied.
