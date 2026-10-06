const {randomBytes, timingSafeEqual, createHash} = require("node:crypto");
const {ApiError, hash} = require("./assistant-trip");
const {z} = require("zod");
const random = () => randomBytes(32).toString("base64url");
const equal = (a, b) => typeof a === "string" && typeof b === "string" && a.length === b.length && timingSafeEqual(Buffer.from(a), Buffer.from(b));
const fail = (message = "Invalid or expired authorization") => new ApiError(400, "invalid_grant", message);
const redirectUri = z.string().max(2048).refine((value) => {
  try {
    const u = new URL(value);
    return !u.hash && !u.username && !u.password && (u.protocol === "https:" ||
      (u.protocol === "http:" && ["127.0.0.1", "[::1]", "localhost"].includes(u.hostname)));
  } catch { return false; }
});
const registrationSchema = z.object({
  client_name: z.string().trim().min(1).max(100).default("AI assistant"),
  redirect_uris: z.array(redirectUri).min(1).max(5),
  token_endpoint_auth_method: z.literal("none").default("none"),
  grant_types: z.array(z.enum(["authorization_code", "refresh_token"])).default(["authorization_code", "refresh_token"]),
  response_types: z.array(z.literal("code")).default(["code"]),
}).strip();

function createOAuth(db, auth, baseUrl, now = () => Date.now(), resource = `${baseUrl}/mcp`) {
  const ref = (kind, token) => db.doc(`assistantOAuth${kind}/${hash(token)}`);
  async function firebaseIdentity(token) {
    try {
      const identity = await auth.verifyIdToken(token, true);
      if (!identity.uid || identity.uid.includes("/")) throw Error();
      await active(identity.uid);
      return identity;
    } catch (error) {
      if (error instanceof ApiError) throw error;
      throw new ApiError(401, "invalid_token", "Sign in to TravelCrew again");
    }
  }
  async function active(uid, authTime) {
    let user;
    try { user = await auth.getUser(uid); } catch (error) {
      if (error.code === "auth/user-not-found") throw new ApiError(401, "invalid_token", "This account no longer exists");
      throw error;
    }
    const [safety, profile] = await Promise.all([db.doc(`safetyAccounts/${uid}`).get(), db.doc(`users/${uid}`).get()]);
    if (user.disabled || !profile.exists || profile.data().isDeleted || safety.data()?.restricted ||
      (authTime && Date.parse(user.tokensValidAfterTime || "1970-01-01") > authTime * 1000)) {
      throw new ApiError(403, "account_unavailable", "An active TravelCrew account is required. Reconnect if your credentials changed.");
    }
  }
  async function publicQuota(kind, limit) {
    const quota = db.doc(`assistantQuotas/${kind}_${Math.floor(now() / 86400000)}`);
    await db.runTransaction(async (tx) => {
      const record = (await tx.get(quota)).data();
      if ((record?.count || 0) >= limit) throw new ApiError(429, "rate_limit", "Too many requests; try again later");
      tx.set(quota, {count: (record?.count || 0) + 1, expiresAt: new Date(now() + 2 * 86400000)});
    });
  }
  async function register(body) {
    const parsed = registrationSchema.safeParse(body);
    if (!parsed.success) throw new ApiError(400, "invalid_client_metadata", "Use HTTPS redirect URIs (HTTP loopback is allowed) and public-client PKCE authentication");
    await publicQuota("registrations", 200);
    const client = {...parsed.data, client_id: random(), client_id_issued_at: Math.floor(now() / 1000)};
    await ref("Clients", client.client_id).create({...client, expiresAt: new Date(now() + 180 * 86400000)});
    return client;
  }
  async function authorize(query) {
    const {client_id: clientId, redirect_uri: redirect, code_challenge: challenge, state} = query;
    if (typeof clientId !== "string" || clientId.length > 128) throw new ApiError(400, "invalid_client", "Unknown client");
    const client = (await ref("Clients", clientId).get()).data();
    if (!client || client.expiresAt.toMillis() <= now() || !client.redirect_uris.includes(redirect)) throw new ApiError(400, "invalid_request", "Unregistered or expired client redirect URI");
    if (query.response_type !== "code" || query.code_challenge_method !== "S256" ||
      typeof challenge !== "string" || !/^[A-Za-z0-9_-]{43}$/.test(challenge) ||
      (state !== undefined && (typeof state !== "string" || state.length > 2048))) throw new ApiError(400, "invalid_request", "Authorization code with S256 PKCE is required");
    if (query.scope !== "trips:create") throw new ApiError(400, "invalid_scope", "Request only trips:create");
    if (query.resource !== resource) throw new ApiError(400, "invalid_target", "Use the advertised MCP resource URL");
    await publicQuota("authorizations", 2000);
    const id = random(); const cookie = random();
    await ref("Requests", id).create({clientId, clientName: client.client_name, redirect, challenge,
      state: state || "", resource, cookieHash: hash(cookie), expiresAt: new Date(now() + 600000)});
    return {id, cookie, clientName: client.client_name, redirect};
  }
  async function consent(id, cookie, identity, approve) {
    if (typeof id !== "string" || id.length > 128 || typeof cookie !== "string") throw fail();
    const requestRef = ref("Requests", id); const code = random(); const grant = random();
    return db.runTransaction(async (tx) => {
      const request = (await tx.get(requestRef)).data();
      if (!request || request.expiresAt.toMillis() <= now() || !equal(request.cookieHash, hash(cookie))) throw fail();
      const destination = new URL(request.redirect);
      destination.searchParams.set("iss", baseUrl);
      if (request.state) destination.searchParams.set("state", request.state);
      tx.delete(requestRef);
      if (approve) {
        if (!identity?.uid) throw fail();
        tx.create(ref("Codes", code), {uid: identity.uid, authTime: identity.auth_time, clientId: request.clientId,
          redirect: request.redirect, challenge: request.challenge, resource, grant, expiresAt: new Date(now() + 120000)});
        tx.create(db.doc(`assistantOAuthGrants/${grant}`), {uid: identity.uid, clientId: request.clientId,
          clientName: request.clientName, authTime: identity.auth_time, createdAt: new Date(now()), expiresAt: new Date(now() + 30 * 86400000), revoked: false});
        destination.searchParams.set("code", code);
      } else destination.searchParams.set("error", "access_denied");
      return destination.href;
    });
  }
  function issue(tx, grant, uid, clientId) {
    const access = `tc_at_${random()}`; const refresh = `tc_rt_${random()}`;
    tx.create(ref("Tokens", access), {grant, uid, clientId, resource, type: "access", expiresAt: new Date(now() + 3600000)});
    tx.create(ref("Tokens", refresh), {grant, uid, clientId, resource, type: "refresh", expiresAt: new Date(now() + 30 * 86400000)});
    return {access_token: access, refresh_token: refresh, token_type: "Bearer", expires_in: 3600, scope: "trips:create"};
  }
  async function exchange(body) {
    const {client_id: clientId, grant_type: type} = body;
    if (typeof clientId !== "string" || clientId.length > 128) throw fail();
    if (body.resource && body.resource !== resource) throw new ApiError(400, "invalid_target", "Resource does not match this service");
    if (!["authorization_code", "refresh_token"].includes(type)) throw new ApiError(400, "unsupported_grant_type", "Unsupported grant type");
    const token = type === "authorization_code" ? body.code : body.refresh_token;
    if (typeof token !== "string" || token.length > 256) throw fail();
    const tokenRef = ref(type === "authorization_code" ? "Codes" : "Tokens", token);
    const initial = (await tokenRef.get()).data();
    if (!initial || initial.clientId !== clientId) throw fail();
    const g = (await db.doc(`assistantOAuthGrants/${initial.grant}`).get()).data();
    if (!g || g.revoked) throw fail();
    await active(g.uid, g.authTime);
    const result = await db.runTransaction(async (tx) => {
      const current = (await tx.get(tokenRef)).data();
      if (!current || current.clientId !== clientId || current.resource !== resource || current.expiresAt.toMillis() <= now()) throw fail();
      const grantRef = db.doc(`assistantOAuthGrants/${current.grant}`);
      const grant = (await tx.get(grantRef)).data();
      if (!grant || grant.revoked || grant.expiresAt.toMillis() <= now()) throw fail();
      if (type === "authorization_code") {
        const verifier = body.code_verifier;
        if (typeof verifier !== "string" || !/^[A-Za-z0-9._~-]{43,128}$/.test(verifier) || body.redirect_uri !== current.redirect ||
          !equal(current.challenge, createHash("sha256").update(verifier).digest("base64url"))) throw fail("Invalid PKCE verifier or redirect URI");
        tx.delete(tokenRef);
      } else {
        if (current.type !== "refresh") throw fail();
        if (current.used) { tx.update(grantRef, {revoked: true}); return null; }
        tx.update(tokenRef, {used: true});
      }
      return issue(tx, current.grant, current.uid, clientId);
    });
    if (!result) throw fail("Refresh token reuse detected; reconnect this assistant");
    return result;
  }
  async function verify(token, allowFirebase = false) {
    if (typeof token !== "string" || token.length > 8192) throw new ApiError(401, "invalid_token", "Bearer token required");
    if (allowFirebase && !token.startsWith("tc_")) return (await firebaseIdentity(token)).uid;
    const record = (await ref("Tokens", token).get()).data();
    if (!record || record.type !== "access" || record.resource !== resource || record.expiresAt.toMillis() <= now()) throw new ApiError(401, "invalid_token", "Reconnect your TravelCrew account");
    const grant = (await db.doc(`assistantOAuthGrants/${record.grant}`).get()).data();
    if (!grant || grant.revoked || grant.expiresAt.toMillis() <= now()) throw new ApiError(401, "invalid_token", "Reconnect your TravelCrew account");
    await active(record.uid, grant.authTime);
    return record.uid;
  }
  async function revoke(token, clientId) {
    if (typeof token !== "string" || token.length > 256) return;
    const record = (await ref("Tokens", token).get()).data();
    if (record && record.clientId === clientId) await db.doc(`assistantOAuthGrants/${record.grant}`).update({revoked: true});
  }
  async function connections(uid) {
    const records = await db.collection("assistantOAuthGrants").where("uid", "==", uid).get();
    return records.docs.filter((d) => !d.data().revoked && d.data().expiresAt.toMillis() > now())
      .map((d) => ({id: d.id, name: d.data().clientName, expires_at: d.data().expiresAt.toDate().toISOString()}));
  }
  async function disconnect(uid, id) {
    if (!/^[A-Za-z0-9_-]{43}$/.test(id)) throw fail();
    const grantRef = db.doc(`assistantOAuthGrants/${id}`);
    await db.runTransaction(async (tx) => {
      const grant = (await tx.get(grantRef)).data();
      if (!grant || grant.uid !== uid) throw new ApiError(404, "not_found", "Connection not found");
      tx.update(grantRef, {revoked: true});
    });
  }
  return {register, authorize, consent, exchange, verify, revoke, firebaseIdentity, connections, disconnect, resource};
}
module.exports = {createOAuth};
