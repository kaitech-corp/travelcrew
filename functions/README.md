# Travel Crew functions

## Assistant trip creation

`assistantV1` serves the authenticated trip API, MCP `create_trip` tool, OAuth
account linking and connection management. See [configuration, contracts and release instructions](ASSISTANT.md).
Assistant integration tests require **both Auth and Firestore emulators**.

Use Node 22 (`nvm use`), then `npm ci`, `npm run lint`, and `npm test`.

## App contracts

- Notifications are server-owned inbox documents under `notifications/{recipient}/notification/{id}`.
  `requestToJoinTripV3`, `cancelJoinRequestV3`, `acceptJoinRequestV3`, `rejectJoinRequestV3`,
  and `leaveTripV3` atomically commit membership/request changes and their inbox events.
  Each request attempt has an ID; retries reuse it, and a later request uses a new ID.
- `sendPushNotificationV3` sends eligible schema-version-2 inbox notifications, rechecking
  read/dismissal state, blocks, restrictions and trip/request availability. It no longer
  forwards client-authored Trip Joined events. Per-token delivery receipts prevent
  ordinary retries from resending successful tokens. FCM is still at-least-once.
- `sendChatPushV3` sends generic trip-message pushes and maintains private conversation
  activity. It skips the sender, blocked/restricted users, departed members and messages
  already read. It creates no general inbox rows.
- `followUserV3` creates an in-app-only notification on an actual follow transition.
  Unfollow, block and unblock are silent. Reports keep their private form confirmation.
- `maintainNotificationReceiptsV3` removes up to 500 push receipts older than 30 days daily.
  Monitor backlog at higher volumes. Join-attempt receipts are retained for replay safety.
- `sendTripInvitesV3` keeps the existing callable payload. Only the owner
  can invite to a non-deleted trip. Emails are normalized before deduplication;
  more than 20 unique valid emails are rejected rather than silently discarded.
  `sent` and `queued` acknowledge submitted addresses for compatibility;
  blocked registered recipients are silently omitted to avoid revealing relationships.
  This does not accept join requests or change membership automatically.
- `sendWelcomeNotificationV3` fires when a user profile is created under `publicProfile/{userId}`.
  It generates a welcome notification in the user's inbox (`notifications/{userId}/notification/welcome_{userId}`)
  and sends an FCM push notification to any registered device tokens.
- `placePhotoV3` remains public for image clients. It accepts only a Places photo
  resource name and a width of 1–4800, with a 15-second upstream timeout and a
  maximum of 10 function instances. It does not change trip data. Public access
  can still incur API costs; use Google API quotas appropriate to the deployment.

## Deployment requirements

### In-app trip invitations

The trip owner's Invite action now offers **Travel Crew users** and **Email**. In-app search uses the existing `publicProfile.displayName` (the app's name/username field), matches prefixes with common casing, and returns at most 20 public results. It does not search private email addresses or expose them. Active means an enabled, non-deleted account with an available profile, not currently online. Blocked, restricted, deleted, disabled, and moderation-removed users are excluded. Current members and pending invitees are labeled in the picker.

| Callable | Payload | Behavior |
| --- | --- | --- |
| `searchTripInviteUsersV3` | `tripId`, `query` | Owner-only public-profile search; query is 2–80 characters. |
| `inviteTripUserV3` | `tripId`, `userId`, `requestId` | Owner-only invitation with an Inbox event and push. Retries reuse the request ID. |
| `getTripInvitationV3` | `tripId`, `invitationId` | Recipient-only title, destination, inviter name, and current status. |
| `respondToTripInvitationV3` | `tripId`, `invitationId`, `accept` | Recipient accepts or declines the current invitation. |

Invitation state lives at `trips/{tripId}/invitations/{recipientUid}` and retry receipts at `invitationAttempts/{hash}`. Both are server-only under the current rules; clients cannot forge acceptance. Sending an invitation leaves `isShared` unchanged. Before acceptance, the recipient only sees a summary from the callable. Accepting atomically joins the crew, creates membership records, updates any existing chat/discovery count, resolves a pending join request, and notifies the owner. Declining does not join the trip. Stale responses cannot answer a replacement invitation or rejoin after leaving. Current restrictions, blocks, ownership, and trip availability are rechecked on response. Existing email invitations still use the mail processor, with invite tracking and queued mail committed together.

Deploy these handlers and the updated push handler before distributing the mobile build:

```sh
firebase deploy --project universal-code-135522 --only functions:searchTripInviteUsersV3,functions:inviteTripUserV3,functions:getTripInvitationV3,functions:respondToTripInvitationV3,functions:sendPushNotificationV3,functions:sendTripInvitesV3
```

The tests include real Auth/Firestore emulator search and invitation flows, concurrent accept/decline, duplicate delivery, membership/chat consistency, private-preview access, and widget search/retry/response behavior. No new index or data backfill is required. Live FCM and email delivery still require device tokens and the configured mail extension.

### Coordinated release

Deploy the new functions, coordinated rules, and updated Flutter app together in staging
before production. Older clients that write join requests/inbox events directly or call
acceptance without an attempt ID are incompatible with the new contract. The rules let
recipients read, mark read/unread, and dismiss inbox rows; they prohibit client creation,
hard deletion, and content/identity changes. These rules target `travel-crew-db-2`.

See [notification lifecycle documentation](../resources/notification_lifecycle_implementation.md)
for the event matrix, callable contracts, validation, rollout and delivery limitations.

Email delivery requires a configured Firebase Trigger Email extension (or other
mail processor) watching `mail`, with working SMTP credentials. Writing a mail
document is not evidence of delivery.

Photos require `GOOGLE_MAPS_SERVER_KEY` (or legacy `GOOGLE_MAPS_API_KEY`) in the
function environment, with Places API access. Secret Manager values must be
explicitly bound to the function before deployment; this implementation retains
the existing environment-variable configuration. Never commit key values.

The lockfile is generated from the package manifest without a UUID override, so
`npm ci` installs the UUID version declared by the resolved gaxios dependency.
Keeping the manifest and lockfile aligned is required by Firebase Cloud Build.

Local handler tests use mocked Firestore/FCM. They do not prove deployed rule
behavior, live push delivery, mail delivery, or availability of the photo key.

## Text moderation

The updated moderators use second-generation `onDocumentWritten` triggers and
`bad-words` 4.x. They mask matched profanity with asterisks, as the old sample did.

| Function | Collection | Text fields |
| --- | --- | --- |
| `moderatePublicProfileTextV3` | `publicProfile` | `displayName`, `firstName`, `lastName`, `hometown`, string entries in `topDestinations` |
| `moderateLegacyPublicProfileTextV3` | `userPublicProfile` | Same profile fields, for older stored profiles |
| `moderateTripTextV3` | `trips` | `title`, `destination`, `tripLocation`, `country`, `hotelName`; legacy `location`, `travelType`, `comment`, `tripName` |
| `moderateTripDiscoveryTextV3` | `tripDiscovery` | `title`, `destination`, `country`, `creatorDisplayName` |

The discovery copy is moderated independently because current clients write it
separately from the trip. Moderation does not create discovery listings or change
visibility, ownership, membership, counters, or deletion status. Only existing
fields with changed text are updated. URLs (including Instagram/Facebook links),
emails, image references and identifiers are intentionally excluded to avoid
breaking functional data. Chat, activities, expense names, private user documents,
and historical content are not included in these profile/trip moderators.

Delete events and soft-deleted trips are ignored. Transactions read the latest
document before applying a partial update, preventing stale events from replacing
newer edits. Clean/repeated events produce no writes, avoiding trigger loops.
Transient failures propagate for retry; raw user text is never logged.

These are asynchronous post-write filters, not a publication gate: original text
may briefly be visible and clients holding local copies need to refresh. Existing
documents are not automatically backfilled on deployment. The default list is
primarily English, can produce false positives, and is not a comprehensive abuse
or multilingual moderation service. Filter policy is centralized in `moderation.js`.

### Migrating the old example

New export names avoid an unsupported in-place v1-to-v2 conversion. If the old
`publicProfileModerator`, `moderator`, `tripTypeModerator`,
`tripCommentModerator`, or `tripNameModerator` functions are deployed, retire them
as part of a reviewed deployment rather than leaving duplicate moderators active.
`example-moderator.txt` is retained solely as a reference and is not executed.
No deployed functions or existing Firestore documents were changed locally.

## Image moderation (Cloud Functions only)

New Firestore v2 write triggers scan newly added/changed image URLs:

| Function | Document | Fields |
| --- | --- | --- |
| `moderateUserImagesV3` | `users/{userId}` | `profileImage` |
| `moderatePublicProfileImagesV3` | `publicProfile/{userId}` | `profileImage` |
| `moderateLegacyProfileImagesV3` | `userPublicProfile/{userId}` | `profileImage` |
| `moderateTripImagesV3` | `trips/{tripId}` | `images` |
| `moderateDiscoveryImagesV3` | `tripDiscovery/{tripId}` | `images`, `creatorProfileImage` |

Only SafeSearch **`adult: VERY_LIKELY`** removes a reference. `LIKELY`, racy,
violence, medical, and spoof ratings do not trigger removal. Profile URL fields
are cleared to `""`; matching entries are removed from image arrays. The stored
image file is not deleted, no document is deleted, and unrelated fields remain
unchanged. Each discovery/profile copy is moderated independently when written.
Transactions preserve newer replacement URLs and skip missing or soft-deleted
documents. Moderation's own removals do not trigger another scan.

The scanner calls the [Vision REST API](https://cloud.google.com/vision/docs/reference/rest/v1/images/annotate)
using the existing Firebase Admin service-account credential (no API key or
additional npm package). Owned Firebase download URLs are converted to `gs://`
references using the configured Firebase default storage bucket. Public HTTPS
image URLs are also supported; local assets, malformed URLs, plain HTTP, and
foreign `gs://` references are skipped. Inaccessible URLs and failed/unknown
verdicts retain their references, log an error, and retry via the event trigger.
Other images in that event are still processed. Persistent failures need operator
attention; repeated attempts can incur costs and retries are not indefinite.

Cloud Logging entries use `image_moderation_flagged` with document path, event ID,
image SHA-256 hash, category, likelihood, and removed field names. They contain no
raw image URLs, download tokens, image bytes, or provider error messages. Error
entries use `image_moderation_scan_failed`. Logs are subject to Cloud Logging
retention; they are not a permanent Firestore audit ledger.

Before deploying these five functions, enable `vision.googleapis.com`, enable
billing, and ensure the runtime service account can call Vision and read the
relevant Storage objects. Keep Firebase's `storageBucket` configuration set to the
app's bucket. Deploy only these functions if other pending changes are not ready:

```sh
firebase deploy --only functions:moderateUserImagesV3,functions:moderatePublicProfileImagesV3,functions:moderateLegacyProfileImagesV3,functions:moderateTripImagesV3,functions:moderateDiscoveryImagesV3
```

This is post-publication reference removal, not access revocation: cached copies
and existing download links can still show the image. Existing documents are not
backfilled. Overwriting image bytes at an unchanged URL is not a Firestore URL
change and is not rescanned. URLs cached in chat records or other fields outside
the table are not rewritten. No app or rules changes are included. In particular,
some current app screens use `images.first` without checking for an empty list;
removing the last image can expose that existing issue. Local tests use mocked
Vision/Firestore and do not validate live API access, billing, or IAM permissions.

## Reporting and blocking

See [implementation and operations runbook](../resources/reporting_and_blocking_implementation.md) for callable contracts, private collections, moderator actions, block migration, retention, and rollout requirements.

`functions/.env.example` includes the moderation alert setting. Local configuration uses `Support@kaitechcorp.com`. Deploy the Trigger Email extension against `travel-crew-db-2` and verify delivery. The report alert and hourly overdue check queue mail without report contents.

Follow mutations and join acceptance now use callables. Coordinate the updated app and restrictive rules rollout: old builds cannot continue writing follow/member relationships directly. The general notification deployment note above applies to the notification-only feature; follow the runbook sequence for this safety release.

Run `npm run test:rules` through `firebase emulators:exec --only firestore,auth --project demo-travelcrew-safety` with Java 21. This includes rules assertions and named-database integration flows. Unit tests remain `npm test`.
