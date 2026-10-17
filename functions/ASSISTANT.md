# Assistant trip creation

TravelCrew accepts private itineraries through an authenticated HTTP API and the
`create_trip` MCP tool. Both call the same Firestore transaction. Users connect
their existing TravelCrew account, ask an assistant to save an itinerary, and
receive an HTTPS link with an **Open in TravelCrew** button. New trips also appear
in My Trips and generate a server-owned inbox notification.

## Endpoints

The canonical MCP URL is **https://travelcrew.app/mcp**, configured by
`ASSISTANT_MCP_URL`. Other routes below are relative to `ASSISTANT_BASE_URL`,
**https://travelcrew.app/assistant**. The Cloud Run website proxies these routes
to `assistantV1`; Firebase Hosting does not serve the custom domain.

| Route | Purpose |
| --- | --- |
| `POST /v1/trips` | Create a private trip; accepts an OAuth access token or a Firebase ID token |
| `POST https://travelcrew.app/mcp` | Stateless Streamable HTTP MCP; OAuth access token required |
| `GET /openapi.json` | OpenAPI 3.1 contract generated from the validated itinerary schema |
| `GET /connect` | Sign in to list and disconnect assistants |
| `GET /trips/:id` | Privacy-preserving app-opening page; exposes no itinerary details |
| `POST /oauth/register` | Register a public OAuth client with exact HTTPS or loopback redirect URIs |
| `GET /oauth/authorize` | Firebase sign-in and explicit consent |
| `POST /oauth/token` | Exchange authorization codes or rotate refresh tokens |
| `POST /oauth/revoke` | Revoke the connection associated with a token |

Discovery is served at
`/.well-known/oauth-authorization-server/assistant` and
`/.well-known/oauth-protected-resource/mcp` on `https://travelcrew.app`.
The 401 challenge supplies the protected-resource metadata URL. The resource
indicator is exactly `https://travelcrew.app/mcp`; the only scope is
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

Activity and lodging clocks use their location's offset on the event date.
Lodging accepts a calendar date or an offset-bearing timestamp. Displays retain
those wall times without UTC offset labels. Transportation, including flights,
uses each endpoint's local clock as supplied without requiring an offset (see
below). Never guess the venue timezone from the phone.

Send `Authorization: Bearer <token>` and `Idempotency-Key: <unique-request-id>`.
Keys must contain 16–128 letters, digits, underscores or hyphens. Retries must use
the same key and itinerary; different content with an existing key returns 409.
For MCP, use `{ "idempotency_key": "...", "trip": { ... } }`.

### Transportation

An optional `transportation` array accepts up to 50 entries. Only `mode` is
required on each entry; omit unknown fields, including dates and times. Modes are
`flight`, `driving`, `rideshare`, `taxi`, `train`, `bus`, `scooter`, `bicycle`,
`walking`, `ferry`, `boat`, and `other`. The app uses mode, optional `departure`
and `arrival`, and `notes`. Put routes, provider, driver, service/flight numbers,
and traveler names in notes. The only accepted transportation fields are `mode`,
`departure`, `arrival`, and `notes`. Removed structured fields and the top-level
`airline` input are rejected; there are no compatibility aliases or migration.

```json
{
  "transportation": [
    {
      "mode": "flight",
      "departure": "2027-04-10T10:00:00",
      "arrival": "2027-04-11T14:00:00",
      "notes": "Example Air TC123, Los Angeles to Tokyo Narita. Randy and Alex."
    },
    {"mode": "rideshare", "notes": "Uber airport transfer"},
    {"mode": "scooter", "notes": "Scooter rental"}
  ]
}
```

This is a fragment to add to the required itinerary fields above. Transportation
uses each endpoint's local clock as entered, without requiring a timezone suffix.
The native editor never applies the phone timezone or asks for an offset. Dates
without times are also accepted. Unzoned clocks do not identify absolute instants;
an arrival clock can be earlier than departure when locations differ.
The server derives ownership; traveler names do not grant trip membership.

Every mode, including `flight`, is stored in `trips/{id}/transportation` using
mode, optional times, and notes. The server adds the authenticated account's
user ID and display name; the assistant cannot supply author metadata. No flight
summary fields or duplicate flight documents are written. The updated mobile app
and shared trip page read these entries in Transportation. The manual JSON
importer is a separate input path. Source changes require coordinated backend and
mobile releases; these documentation changes do not deploy them.

Creation returns 201, or 200 for a replay:

```json
{
  "trip_id": "<uuid>",
  "url": "https://travelcrew.app/assistant/trips/<uuid>",
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

The deployment has two components: `assistantV1` for OAuth/MCP and the existing
`travel-crew-web` Cloud Run service for `travelcrew.app` routing. Do not replace
this website with a Firebase Hosting deployment.

1. Use Node 22 and install dependencies with `npm --prefix functions ci`.
2. Set these values in the ignored Functions environment file. Firebase browser
   configuration comes from `lib/firebase_options.dart`; never use an Admin key.

   ```dotenv
   ASSISTANT_BASE_URL=https://travelcrew.app/assistant
   ASSISTANT_MCP_URL=https://travelcrew.app/mcp
   ASSISTANT_FIREBASE_CONFIG={"apiKey":"<web-api-key>","authDomain":"universal-code-135522.firebaseapp.com","projectId":"universal-code-135522","appId":"<web-app-id>"}
   ```

3. Ensure `travelcrew.app` is an authorized Firebase Authentication domain. Enable
   the providers your travelers use. The browser uses existing accounts; new
   profiles must first be completed in the app. OAuth clients never receive a
   Firebase token or the user's password. Inspect/configure the domain with:

   ```sh
   node functions/test-browser/assistant-auth-config.cjs --configure
   ```

4. Verify the database is `travel-crew-db-2`. Deploy the assistant function and
   website separately, after their tests pass:

   ```sh
   firebase deploy --only functions:assistantV1 --project universal-code-135522
   gcloud builds submit travel_crew_web --config=travel_crew_web/cloudbuild.yaml --project=universal-code-135522 --region=us-central1 --gcs-source-staging-dir=gs://universal-code-135522_cloudbuild/source
   ```

   The website's `ASSISTANT_UPSTREAM_URL` is the fixed HTTPS origin of
   `assistantV1`. Its public settings are `VITE_ASSISTANT_BASE_URL` and
   `VITE_ASSISTANT_MCP_URL`. Preserve the website's other settings and secrets.
   Current source includes optional suggested-photo preparation: follow the
   [photo rollout prerequisites](../resources/trip_editor_suggested_photos_review.md)
   before deploying that version. Existing deployed MCP functionality and pending
   source changes must be evaluated separately.

5. Confirm the `tripMemberships` index and the six OAuth/quota `expiresAt` TTL
   policies in `firestore.indexes.json` are active. Coordinate Firestore rules and
   notification releases independently. `sendPushNotificationV3` delivers mobile
   pushes; creating the private trip and inbox record does not depend on a push.
6. The Flutter defaults now use the canonical URLs. For a custom environment,
   override both `ASSISTANT_BASE_URL` and `ASSISTANT_MCP_URL`. Build and release the
   mobile app through its normal release process; changing source does not update
   an installed app. The app recognizes `travelcrew://trips/<uuid>`, waits for
   sign-in, and checks normal Firestore access before opening the trip.
7. Follow the [client setup and submission guide](../integrations/README.md),
   connect an account, create and retry a trip, open it in the app, disconnect,
   and verify further creation fails. Google/Apple provider configuration and
   interactive sign-in need separate verification from email/password.

OAuth uses DCR, S256 PKCE, exact redirect URIs, and RFC 9207 `iss` callbacks. The
canonical resource metadata URL is supplied in the 401 challenge. `/MCP` is
accepted by the website without redirecting the POST. `/assistant/mcp` remains
an alias, but all new clients must use the canonical `/mcp` resource indicator.
Missing backend/proxy configuration fails closed with 503.

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

Production qualification is explicitly opt-in:

```sh
node functions/test-browser/assistant.live.cjs --live
```

It uses the active gcloud identity to create a uniquely named temporary account,
performs real browser email sign-in and MCP calls through `travelcrew.app`, then
removes its test records. It does not exercise a ChatGPT model, Gemini model, or
native device UI. See the integration guide for the current verification status.

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
