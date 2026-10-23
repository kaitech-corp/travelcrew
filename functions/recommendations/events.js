const {createHash} = require("node:crypto");
const {Timestamp} = require("firebase-admin/firestore");
const {HttpsError} = require("firebase-functions/v2/https");
const {eventSchema} = require("./contracts");
const {DAY, millis} = require("./features");

const RETENTION_MS = 90 * DAY;
const hash = (...parts) => createHash("sha256").update(JSON.stringify(parts)).digest("hex");
const impressionId = (uid, sessionId, tripId) => hash(uid, sessionId, tripId, "impression");

async function quota(db, uid, kind, limit, now) {
  const ref = db.doc(`recommendationQuotas/${hash(uid, kind)}`);
  await db.runTransaction(async (tx) => {
    const record = (await tx.get(ref)).data();
    const count = record && now - record.windowStart < 3600000 ? record.count : 0;
    if (count >= limit) throw new HttpsError("resource-exhausted", "Too many recommendation requests. Try again later.");
    tx.set(ref, {uid, count: count + 1, windowStart: count ? record.windowStart : now, expiresAt: Timestamp.fromMillis(now + DAY)});
  });
}

async function recordEvent(db, uid, input, now) {
  const parsed = eventSchema.safeParse(input);
  if (!parsed.success) return {eventId: typeof input?.eventId === "string" ? input.eventId.slice(0, 128) : null, status: "invalid"};
  const event = parsed.data;
  const once = event.type === "impression" || event.type === "open";
  const key = once ? hash(uid, event.sessionId, event.tripId, event.type) : hash(uid, event.eventId);
  const fingerprint = hash(event);
  return db.runTransaction(async (tx) => {
    const ref = db.doc(`recommendationEvents/${key}`);
    const [prior, sessionDoc] = await Promise.all([tx.get(ref), tx.get(db.doc(`recommendationSessions/${event.sessionId}`))]);
    if (prior.exists) return {eventId: event.eventId, status: once || prior.data().fingerprint === fingerprint ? "duplicate" : "invalid"};
    const session = sessionDoc.data();
    if (!session || session.uid !== uid || millis(session.expiresAt) <= now ||
        session.ranked[event.position]?.id !== event.tripId || !session.served.includes(event.position) ||
        (event.occurredAt != null && (event.occurredAt < millis(session.createdAt) - 300000 || event.occurredAt > now + 300000))) {
      return {eventId: event.eventId, status: "invalid"};
    }
    const item = session.ranked[event.position];
    const pointerRef = db.doc(`recommendationLastImpressions/${hash(uid, event.tripId)}`);
    const priorPointer = event.type === "impression" ? (await tx.get(pointerRef)).data() : null;
    const data = {uid, tripId: event.tripId, sessionId: event.sessionId, position: event.position, type: event.type,
      algorithmVersion: session.algorithmVersion, experiment: session.experiment, selection: item.selection,
      featureSnapshot: item.feature, scoreComponents: item.components || null,
      fingerprint, observation: "client", impressionDefinition: "half_visible_one_second_v1",
      createdAt: Timestamp.fromMillis(now), occurredAt: Timestamp.fromMillis(Math.min(now, event.occurredAt ?? now)),
      expiresAt: Timestamp.fromMillis(now + RETENTION_MS)};
    tx.create(ref, data);
    if (event.type === "impression" && (!priorPointer || millis(data.occurredAt) > millis(priorPointer.occurredAt || priorPointer.createdAt) ||
        (millis(data.occurredAt) === millis(priorPointer.occurredAt || priorPointer.createdAt) && key > priorPointer.eventId))) {
      // Durable pointer survives session expiry. Request transitions still read
      // and validate the actual impression record and viewer identity.
      tx.set(pointerRef, {
        uid, tripId: event.tripId, eventId: key, sessionId: event.sessionId, createdAt: data.createdAt, occurredAt: data.occurredAt, expiresAt: data.expiresAt,
      });
    }
    return {eventId: event.eventId, status: "accepted"};
  });
}

// Called during the join transaction, before its first write. No telemetry
// network call can block the committed outcome. Missing/invalid context simply
// produces no attribution; client claims never become authoritative outcomes.
async function readAttribution(db, tx, uid, tripId, context, now = Date.now()) {
  const pointer = await tx.get(db.collection("recommendationLastImpressions").doc(hash(uid, tripId)));
  // Use the most recent validated observation, even when navigation still
  // carries an older session. A client cannot select its experiment attribution.
  const id = pointer.data()?.eventId;
  void context;
  if (!id) return null;
  const record = (await tx.get(db.collection("recommendationEvents").doc(id))).data();
  const observedAt = millis(record?.occurredAt || record?.createdAt);
  if (!record || record.uid !== uid || record.tripId !== tripId || record.type !== "impression" ||
      observedAt > now || now - observedAt > 7 * DAY) return null;
  return {uid, tripId, impressionId: id, sessionId: record.sessionId, position: record.position,
    algorithmVersion: record.algorithmVersion, experiment: record.experiment,
    impressionAt: Timestamp.fromMillis(observedAt), attributionVersion: "last_impression_7d_v1", createdAt: Timestamp.fromMillis(now), expiresAt: Timestamp.fromMillis(now + RETENTION_MS)};
}

function attributionRef(db, uid, tripId, attemptId) {
  return db.collection("recommendationAttributions").doc(hash(uid, tripId, attemptId));
}

function writeOutcome(db, tx, ref, attribution, outcome, now = Date.now()) {
  const data = {...attribution, outcome, outcomeAt: Timestamp.fromMillis(now)};
  if (outcome === "accepted") data.acceptedAt = data.outcomeAt;
  if (outcome === "left") data.leftAt = data.outcomeAt;
  tx.set(ref, data);
  tx.set(db.collection("recommendationEvents").doc(hash(ref.id, outcome)), {
    ...data, type: `join_${outcome}`, observation: "server", createdAt: data.outcomeAt,
  });
}

module.exports = {RETENTION_MS, hash, impressionId, quota, recordEvent, readAttribution, attributionRef, writeOutcome};
