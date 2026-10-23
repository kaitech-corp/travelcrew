# Recommendation backend

The first-release backend and Flutter Recommended feed are implemented locally. This runbook covers validation and the release gates; nothing has been deployed or backfilled in production. The original design is in `resources/recommendation_system_build_plan.md` at the repository root (the repository ignores `resources/`; keep this runbook with the implementation).

Use Node 22. The existing login shell may select Node 20 inside `functions/`; select the manifest's runtime explicitly before running commands.

## Current endpoints

| Callable | Contract |
| --- | --- |
| `getRecommendedTripsV3` | Optional `pageSize` (1–20), `filters`, and opaque `cursor`. Returns ordered `items`, session/algorithm/experiment identifiers, `nextCursor`, `exhausted`, and `budgetLimited`. Exhaustion describes the bounded candidate pool, not every trip in the database. |
| `recordRecommendationEventsV3` | `events` array of up to 25 objects containing event ID, session ID, trip ID, served position, type, and optional occurrence time. Types: `impression`, `open`, `favorite`, `unfavorite`. Returns accepted/duplicate/invalid per event. |
| `setRecommendationDismissalV3` | `tripId`, `dismissed`, optional `sessionId`. Records suppression and authoritative dismiss/undo transitions. |
| `setRecommendationPreferencesV3` | Up to ten destination strings and optional date/duration `filters`. Writes private preferences and invalidates existing sessions through a version change. |

Callables derive the viewer from Firebase Auth. They check Auth account status, profile availability, and moderation restrictions. Backend eligibility also checks trip privacy/status/dates, membership, both block directions, and dismissals. Direct client writes to new data are denied. Existing administrator read policy still applies through the rules' administrative catchall.

`filters` accepts optional `from` and `to` calendar dates (`YYYY-MM-DD`) and `minDays` and `maxDays` (1–365). Trip dates are compared as UTC calendar days, including today's date; trips whose start day is earlier are excluded. Missing end dates use the start day. Malformed dates are excluded, not substituted with today's date.

Sessions last 30 minutes. Repeat the original page size and filters when continuing a cursor. Cursors are signed, owner-bound, and cannot choose arbitrary offsets. `failed-precondition` with `session_expired` or `session_changed` requires a visible refresh action. Do not silently append a new session to an old list.

## Rollout configuration

The server-only `recommendationConfig/current` document accepts `enabled`, `percent` (0–100), `experiment`, and `shadow`. An absent configuration serves a safe upcoming-trip fallback. Enabled users are assigned by a stable hash of user ID and experiment name. Keep the experiment name stable during a comparison.

Disabled mode uses `upcoming-v1`, ordered by departure date. With `enabled: true`, assigned users receive `weighted-v1`; the remaining users receive `legacy-continent-v1`. The control reproduces the old strategy: accessible continents from up to 50 active memberships and the first 10 favorites, or a popular pool when history is absent, followed by departure-date ordering. It uses the new normalized features, bounded 200-candidate session, date filters, and shared eligibility contract; it is not byte-for-byte pagination of the old client implementation. Preferences and follows do not influence control ranking. Freeze percent and experiment name during a comparison. A mode or experiment change invalidates existing sessions on continuation.

`shadow: true` evaluates the complete weighted candidate pools and reranking for control/fallback requests, without persisting a treatment session or recording treatment impressions. Logs contain candidate counts, top-20 overlap, reads, Auth lookups, and elapsed time. Shadow has its own bounded read context, adds request latency/cost, and catches failures without failing the displayed feed. Turn it off before collecting the online comparison unless that cost is intentional.

The scorer uses weights 0.55 destination affinity, 0.25 followed creator, 0.15 capped logarithmic popularity, and 0.05 publication freshness. Weights for absent user history/follows are omitted and the rest renormalized. Unknown publication time gets freshness 0.5; unknown action times receive no fabricated recency decay. One exploration slot per full page of at least ten entries and diversity limits (two per creator/four per destination) are initial parameters, not measured improvements.

Initial retrieval reserves source capacity by round-robin selection of at most 200 distinct candidates. When exclusions leave fewer than a page, weighted/fallback retrieval may inspect further upcoming features, bounded by 400 distinct candidates and remaining read budget. A ranked session still contains at most 200 eligible entries. Read accounting has a 3,500-document guard per context; each continuation inspects at most 60 entries. Query reads are counted after execution, so this is not a billing-exact cap. Profile history is reconstructed from current access on every new session; only its count is persisted, avoiding stale private-source locations in saved summaries.

`recommendation_feed`/`recommendation_page` logs include logical reads, Auth lookups, result counts, and duration; initial logs also identify algorithm and experiment. A nonempty new session normally writes five documents/updates (quota, summary, session creation, served positions, durable `feed_session` event), plus a quota transaction read outside the context counter. Continuations normally write quota and served positions. Transaction retries, index reads, TTL deletes, and feedback/join writes require separate billing measurements.

## Audit and backfill

Commands default to read-only inspection and require an explicit project. Run from `functions/` with the intended credentials. No production audit or backfill has been performed as part of this implementation.

```sh
node recommendations/audit.js --project PROJECT_ID --kind trips --pages 1 --limit 100
node recommendations/audit.js --project PROJECT_ID --kind users --pages 1 --limit 100
node recommendations/audit.js --project PROJECT_ID --kind trips --apply --pages 10 --checkpoint /private/tmp/travelcrew-recommendation-backfill.json
```

The backfill checkpoint binds to project, database, kind, and apply mode. Rerunning resumes at the next document. A checkpoint is private because it contains a document-ID cursor. Aggregate user audits count current favorites/follows and sample at most 50 active memberships per user, reporting when that sample is capped. These are metadata coverage measurements, not validated signals or unique conversion counts.

Feature maintenance reads the current trip within a transaction. A delayed event cannot publish a trip that is now private or removed. Backfills leave publication time unknown. New public transitions use the source event's update time; ordinary edits preserve it. Private/deleted projections are removed, so republishing begins a new public period. The trigger and backfill never change trip visibility or create discovery listings.

The scheduler removes up to 250 expired records per collection each hour, alongside configured Firestore TTL policies. Session expiry is enforced in handlers independently of asynchronous cleanup. Raw events and attribution use a provisional 90-day retention period; verify against the app's retention policy before production release. Account cleanup removes private preferences, summaries, dismissals, and records owned by the deleted user. No anonymous aggregate store is created by this release.

## Verification

```sh
npm test
npm run lint
firebase emulators:exec --only firestore,auth --project demo-travelcrew-safety 'node --test test-rules/recommendation-backend.integration.test.js test-rules/recommendations.rules.test.js'
```

Use Java 21 for the emulators. The integration suite uses an isolated demo project and the named database `travel-crew-db-2`, with real emulator Auth accounts. Multiple-project emulator warnings are expected. Emulator success does not verify deployed indexes, real billing, production throughput, or mobile impression behavior.

## Flutter integration

`RecommendationRuntime` binds private preference and dismissal listeners to the signed-in account. `RecommendationService` owns ordered pages, cursor state, errors, suppression, and a bounded transient feedback queue. Account changes discard queued observations and late responses; preference changes require a fresh session. The previous departure-date sort is no longer used by the Recommended tab. Other discovery tabs retain their existing behavior.

The feed includes preference editing, explanation text, dismiss/undo, retry, refresh, and load-more controls. A pending continuation retains existing cards. Session expiry requires an explicit refresh rather than appending a replacement session. Visibility checks require at least half the card inside the feed viewport for one continuous second, with the Recommended tab settled, the app resumed, and no covering route. Impression and open deduplication uses session/trip identity.

Feedback batches retain event IDs across retries and never fail a favorite or join action. The queue is capped at 100 events and retries a failed batch up to five times while the process is alive; it is not durable offline telemetry. The join flow waits up to two seconds for an outstanding feedback flush before proceeding. No observation is manufactured for an unseen trip. These delivery limits must be included when assessing attribution completeness.

Run the focused mobile tests with `flutter test --no-pub test/recommendation_service_test.dart test/recommendation_widgets_test.dart`. Tests cover server order, pagination failures, refresh races, account changes, feedback retries, visibility dwell, inactive tabs, background state, covered routes, phone/tablet layout order, blocking, and preference save errors. Deployment must precede distribution of the updated app because it now calls the recommendation endpoints.

## Attribution and experiment analysis

An impression is accepted only for the authenticated owner of an unexpired session and a served trip/position. Impression/open retries deduplicate per session/trip/type; favorite events deduplicate by client event ID and fingerprint. Features and scoring components come from the ranked session, never client claims. These snapshots describe the ranking decision; previews are revalidated on every page.

The latest qualifying impression is ordered by validated observation time, with a deterministic event-ID tie-break. Observation time must be within the session's lifetime allowance and no more than five minutes ahead of receipt, and is clamped to receipt time. An older delayed event cannot replace the newer pointer. Client occurrence times are still observations, not tamper-proof evidence. Joins use the latest stored qualifying impression within seven days, regardless of stale navigation context; missing or expired evidence produces an unattributed join. Context is optional for older app versions.

The join transaction freezes attribution to its canonical attempt. Owner acceptance/rejection, cancellation, leaving, and block-triggered cancellation update it transactionally and idempotently. Invitation acceptance that closes a pending request records `superseded` with reason `invitation`, not a recommendation acceptance. Acceptance time remains available if the member later leaves.

Every successful initial feed persists one server `feed_session` event for 90 days, including empty results. This supplies the session denominator after 30-minute sessions expire. In analysis, select a fixed experiment and session cohort; join attributions by `sessionId`, deduplicate by attempt, and count acceptance within 30 days of the request. Keep requests from the final seven days of the session cohort and their 30-day follow-up immature until complete (up to 37 days from the final cohort impression). Report accepted joins per feed session alongside requests, favorite observations, dismissals, empty feeds, and creator/destination exposure coverage. Separate invitation outcomes and non-recommendation traffic.

Use user-level confidence intervals/randomization because assignment is by user; repeated sessions are not independent users. Choose sample size and minimum useful effect from baseline traffic before launch. Report missing telemetry (queue eviction, exhausted retries, session expiry, app termination), attribution coverage, and new-user results. No effectiveness improvement or trained model is claimed by this implementation.

## Local evidence, October 18, 2026

The full Flutter suite passes 97 tests. Node unit tests pass 60 tests and ESLint passes. The complete Auth/Firestore/Storage emulator regression suite passes 68 tests, including recommendation, invitation, notification, safety, assistant, and photo flows; a subsequent focused recommendation run passes 21 tests, including the additional page-scan-limit regression and enriched metadata audit. Scoped Flutter analysis is clean. The named-database integration suite calls the real handlers with emulator Auth accounts; it does not exercise deployed callable HTTP transport or mobile network delivery.

`benchmark.js` seeds only a disposable `demo-` emulator project and refuses to run without both emulator endpoints. The fixture has 240 trips, 20 creators, ten favorites, three follows, and two explicit destinations. Six sequential requests per mode returned 20 results each with no empty feed. [Raw local samples](benchmark.local.json) are reproducible with:

```sh
firebase emulators:exec --only firestore,auth --project demo-travelcrew-safety 'node recommendations/benchmark.js'
firebase emulators:exec --only firestore,auth,storage --project demo-travelcrew-safety 'node --test --test-concurrency=1 test-rules/*.test.js'
```

| Mode | Local p50 / p95 | Logical reads per initial request | Auth lookups | Eligible candidates |
| --- | --- | --- | --- | --- |
| Upcoming fallback | 394 / 756 ms | 736 | 21 | 125 |
| Continent control | 259 / 325 ms | 656 | 11 | 120 |
| Weighted treatment | 332 / 362 ms | 883 | 21 | 140 |
| Control plus shadow | 500 / 519 ms | 656 + 877 shadow | 11 + 20 shadow | 120 displayed / 140 shadow |

These six-sample percentiles are diagnostic, not statistical latency estimates or release targets. The benchmark excludes network transport, real indexes/billing, Cloud Functions cold starts, and production concurrency. Read volume is material: staging must establish an acceptable cost per session before expansion. Phone/tablet widget tests verify layout, order, dwell, inactive routes/tabs, background state, blocking, and recoverable failures. No physical-device or staged end-to-end test has been performed; no simulator was booted during local verification.

## Deployment and rollback runbook

Run from the repository root with an explicit staging project first. The named database must be `travel-crew-db-2`, matching `firebase.json` and the function trigger options. Review the repository's existing unrelated changes before release. Deployment is intentionally separate from this local development goal.

1. Keep `recommendationConfig/current` absent or `{enabled: false, percent: 0, shadow: false, experiment: "launch-v1"}`. Deploy rules/indexes and wait until indexes and TTL policies are ready:

   ```sh
   firebase deploy --project PROJECT_ID --only firestore:rules,firestore:indexes
   firebase firestore:indexes --project PROJECT_ID --database travel-crew-db-2
   ```

   Added composite indexes are `destinationKeys CONTAINS + startDay ASC`, `createdBy ASC + startDay ASC`, and `continentKey ASC + startDay ASC` on `recommendationTripFeatures`. Single-field indexes support upcoming/freshness retrieval and expiry cleanup. TTL fields retain their ascending collection index for the scheduler. Ranked arrays, cursor secrets, and event feature snapshots are exempted from indexing. See the [Firebase index definition reference](https://firebase.google.com/docs/reference/firestore/indexes) and [TTL policy documentation](https://firebase.google.com/docs/firestore/ttl).

2. Deploy the new functions and every existing transition/cleanup function affected by attribution:

   ```sh
   firebase deploy --project PROJECT_ID --only functions:getRecommendedTripsV3,functions:recordRecommendationEventsV3,functions:setRecommendationDismissalV3,functions:setRecommendationPreferencesV3,functions:maintainRecommendationTripV3,functions:expireRecommendationsV3
   firebase deploy --project PROJECT_ID --only functions:requestToJoinTripV3,functions:cancelJoinRequestV3,functions:acceptJoinRequestV3,functions:rejectJoinRequestV3,functions:leaveTripV3,functions:respondToTripInvitationV3,functions:cleanBlockedPairV3,functions:cleanDeletedUserSafetyV3
   ```

   Function targeting follows the [Firebase CLI deployment reference](https://firebase.google.com/docs/cli#partial_deploys). Verify the four authenticated callable contracts in staging; do not interpret handler-only emulator tests as transport verification.

3. Run both read-only audit commands above; record metadata exclusions and unknown publication coverage. Run the checkpointed trip backfill, then repeat the read-only audit and spot-check privacy changes while triggers run. Resolve malformed dates, missing country/destination, unknown visibility, and stale discovery cards through normal app data maintenance; the backfill never makes them public. Retain aggregate audit output with the release record.

4. Distribute a staging build after the endpoints are available. On a phone and tablet, confirm initial/continued page order, scrolling and one-second visibility, background/resume, navigation, favorites, dismiss/undo, preferences, account switch, offline/retry, and expired-session refresh. Verify a request/owner acceptance after session expiry, a leave, block cancellation, and invitation supersession in stored events. Check logs and real read/write/index costs under sparse history, dense history, many blocks, cold starts, and concurrent users. Set p50/p95 latency, read/write, error-rate, and empty-feed gates from those results before proceeding.

5. Enable instrumented control with `{enabled: true, percent: 0, shadow: true, experiment: "launch-v1"}` to collect the baseline and compare full treatment retrieval. Once operational gates pass, set `shadow: false` and a small treatment percent such as 5. Keep percent/name fixed for the planned comparison. Review mature outcomes and guardrails before expanding or starting a new versioned experiment.

6. Roll back by setting `enabled: false` and `shadow: false`. A weighted or control continuation must return `failed-precondition`; Refresh must return `upcoming-v1` with the same privacy/block checks. This rollback is covered in emulator tests and must be rehearsed against deployed staging callables. Do not delete additive data/APIs needed by released clients. If the shared API itself is broken, redeploy the last verified compatible backend; changing ranking configuration cannot repair an unavailable service.

Any unauthorized result blocks release. The release record must include project/database, source revision, index readiness, audit/backfill aggregates, app/device versions, transport and attribution smoke results, cost/latency gates, telemetry completeness, experiment assignment/sample plan, retention decision, and rollback evidence. Production data audit, deployment, device verification, and online effectiveness remain release work, not unperformed claims in this document.

## Build-plan reconciliation

| Plan area | Delivered locally | Release evidence still required |
| --- | --- | --- |
| Baseline and data readiness | Read-only user/trip audit, atomic resumable backfill, metadata validation, synthetic operation/latency samples | Actual catalog coverage, staged throughput, billing and cold-start baseline |
| Features and feedback | Current-source projection, owner-private preferences/dismissals, validated/idempotent events, 90-day retention and account cleanup | Production retention decision and deployed trigger/TTL behavior |
| Ranking | Content/social/popularity/freshness scoring, bounded mixed pools/refill, diversity, seeded exploration, explanations, cold start | Measured relevance and new-user performance |
| API and privacy | Signed owner/filter-bound sessions, fresh eligibility checks, explicit expiry/budget continuation, protected collections | Deployed indexes, callable transport, scale |
| Flutter | Ordered feed, pagination/retry/refresh, preferences, dismiss/undo, visibility telemetry, context propagation, account isolation | Phone/tablet network and lifecycle smoke against staging |
| Experiment/release | Stable user assignment, instrumented continent control, full-pool shadow, durable session denominator, authoritative delayed outcomes, rollback test/runbook | Powered mature-cohort experiment and rollout approval/process |

Implementation choices refine the draft: private-source affinities are rebuilt rather than persisted; timing is a hard optional API filter rather than an inferred preference; existing action timestamps are not invented; public-period freshness resets after a private projection is removed. The legacy control uses the shared modern eligibility contract and bounded session. Python/LightGBM remains deferred until exposure/outcome completeness, chronological evaluation, and statistical power justify training. The weighted scorer is the initial baseline, not a proven best algorithm.
