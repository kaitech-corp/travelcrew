# Travel Crew functions

Use Node 22 (`nvm use`), then `npm ci`, `npm run lint`, and `npm test`.

## App contracts

- `sendPushNotificationV3` accepts the existing client Trip Joined event under
  `notifications/{sender}/notification/{id}`. It verifies active membership and
  forwards a server-authored event only to the trip owner. Recipient copies use
  the app's existing millisecond dates, unread status, and notification fields.
  A deterministic ID prevents repeated source events from duplicating inbox rows.
  Recipient copies trigger push delivery in batches of at most 500 tokens.
  FCM/Eventarc delivery is not exactly-once; duplicate pushes remain possible.
- `sendTripInvitesV3` keeps the existing callable payload. Only the owner
  can invite to a non-deleted trip. Emails are normalized before deduplication;
  more than 20 unique valid emails are rejected rather than silently discarded.
  `sent` is retained for compatibility and means queued; `queued` is also returned.
  This does not accept join requests or change membership automatically.
- `placePhotoV3` remains public for image clients. It accepts only a Places photo
  resource name and a width of 1–4800, with a 15-second upstream timeout and a
  maximum of 10 function instances. It does not change trip data. Public access
  can still incur API costs; use Google API quotas appropriate to the deployment.

## Deployment requirements

Deploy the notification rules in the repository before the functions. The rules
disallow clients from forging `serverForwarded` recipient copies. These changes
do not alter trip deletion rules. Older app builds keep submitting the same events.

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
