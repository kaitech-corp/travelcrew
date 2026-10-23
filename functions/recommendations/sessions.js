const {createHmac, timingSafeEqual, randomBytes} = require("node:crypto");
const {HttpsError} = require("firebase-functions/v2/https");
const {Timestamp, FieldValue} = require("firebase-admin/firestore");
const {millis} = require("./features");
const {eligibleTrip, mapLimit} = require("./candidates");

const SESSION_MS = 30 * 60 * 1000;

function cursorFor(sessionId, session, offset) {
  const body = Buffer.from(JSON.stringify({sessionId, offset})).toString("base64url");
  const signature = createHmac("sha256", session.cursorSecret).update(body).digest("base64url");
  return `${body}.${signature}`;
}

function decodeCursor(cursor) {
  try {
    const [body, signature, extra] = cursor.split(".");
    const parsed = JSON.parse(Buffer.from(body, "base64url").toString());
    if (extra || !/^[A-Za-z0-9_-]{1,128}$/.test(parsed.sessionId) || !Number.isInteger(parsed.offset) || parsed.offset < 0 || parsed.offset > 200 || !signature) throw new Error();
    return {...parsed, body, signature};
  } catch { throw new HttpsError("invalid-argument", "Invalid recommendation cursor."); }
}

function validateSession(session, uid, now) {
  if (!session || session.uid !== uid) throw new HttpsError("permission-denied", "Recommendation session unavailable.");
  if (millis(session.expiresAt) <= now) throw new HttpsError("failed-precondition", "Refresh recommendations.", {reason: "session_expired"});
}

function validateCursor(decoded, session) {
  const expected = createHmac("sha256", session.cursorSecret).update(decoded.body).digest();
  const supplied = Buffer.from(decoded.signature, "base64url");
  if (supplied.length !== expected.length || !timingSafeEqual(supplied, expected) || decoded.offset > session.ranked.length) {
    throw new HttpsError("invalid-argument", "Invalid recommendation cursor.");
  }
}

function newSession({uid, ranked, pageSize, filters, preferenceVersion, algorithmVersion, experiment, now}) {
  return {uid, ranked, pageSize, filters, preferenceVersion, algorithmVersion, experiment,
    cursorSecret: randomBytes(32).toString("hex"), served: [],
    createdAt: Timestamp.fromMillis(now), expiresAt: Timestamp.fromMillis(now + SESSION_MS)};
}

async function servePage(ctx, uid, sessionId, session, offset = 0) {
  validateSession(session, uid, ctx.now);
  const items = []; const served = []; let index = offset; const stop = Math.min(session.ranked.length, offset + 60);
  // Validate a batch at a time; never return saved preview data after a privacy
  // change. The cursor advances over unavailable entries as well as visible ones.
  while (items.length < session.pageSize && index < stop) {
    const count = Math.min(session.pageSize - items.length, stop - index);
    const rows = session.ranked.slice(index, index + count);
    const available = await mapLimit(rows, (row) => eligibleTrip(ctx, uid, row.id, session.filters));
    for (let i = 0; i < rows.length; i++) {
      if (available[i]) {
        items.push({...available[i].preview, explanation: rows[i].reason, recommendation: {sessionId, position: index + i}});
        served.push(index + i);
      }
    }
    index += count;
  }
  if (served.length) await ctx.db.doc(`recommendationSessions/${sessionId}`).update({served: FieldValue.arrayUnion(...served)});
  return {items, sessionId, algorithmVersion: session.algorithmVersion, experiment: session.experiment,
    nextCursor: index < session.ranked.length ? cursorFor(sessionId, session, index) : null,
    exhausted: index >= session.ranked.length, exhaustionScope: "candidate_pool",
    budgetLimited: index < session.ranked.length && items.length < session.pageSize,
    expiresAt: millis(session.expiresAt)};
}

module.exports = {SESSION_MS, cursorFor, decodeCursor, validateCursor, validateSession, newSession, servePage};
