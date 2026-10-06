const express = require("express");
const {z} = require("zod");
const {McpServer} = require("@modelcontextprotocol/sdk/server/mcp.js");
const {StreamableHTTPServerTransport} = require("@modelcontextprotocol/sdk/server/streamableHttp.js");
const {ListToolsRequestSchema} = require("@modelcontextprotocol/sdk/types.js");
const {ApiError, tripSchema, idempotencySchema, createTripService} = require("./assistant-trip");
const {createOAuth} = require("./assistant-oauth");
const {accountPage, tripPage} = require("./assistant-pages");

function createAssistantApp({db, auth, baseUrl, mcpUrl, firebaseConfig, logger = console, now}) {
  const base = new URL(baseUrl);
  if (base.protocol !== "https:" && !["localhost", "127.0.0.1"].includes(base.hostname)) throw new Error("ASSISTANT_BASE_URL requires HTTPS");
  if (base.search || base.hash || base.username || base.password) throw new Error("Invalid ASSISTANT_BASE_URL");
  baseUrl = base.href.replace(/\/$/, "");
  const resourceUrl = new URL(mcpUrl || `${baseUrl}/mcp`);
  if (resourceUrl.origin !== base.origin || resourceUrl.search || resourceUrl.hash || resourceUrl.username || resourceUrl.password) throw new Error("MCP URL must share the assistant origin and have no query or fragment");
  const app = express(); const router = express.Router();
  const oauth = createOAuth(db, auth, baseUrl, now, resourceUrl.href);
  const createTrip = createTripService(db, baseUrl, now);
  const metadataPath = `/.well-known/oauth-protected-resource${resourceUrl.pathname}`;
  const bearer = (req) => /^Bearer ([^\s]+)$/i.exec(req.get("authorization") || "")?.[1];
  app.disable("x-powered-by");
  app.use((req, res, next) => {
    res.set({"Cache-Control": "no-store", "X-Content-Type-Options": "nosniff", "Referrer-Policy": "no-referrer", "X-Frame-Options": "DENY"});
    // Firebase parses bodies before invoking Express. Bound both raw and local requests.
    if (req.rawBody?.length > 131072 || Number(req.get("content-length")) > 131072) return res.status(413).json({error: "payload_too_large"});
    const origin = req.get("origin");
    if (origin && origin !== base.origin) return res.status(403).json({error: "origin_not_allowed"});
    next();
  });
  app.use(express.json({limit: "128kb"}), express.urlencoded({extended: false, limit: "16kb"}));
  const authorizationMetadata = {
    issuer: baseUrl, authorization_endpoint: `${baseUrl}/oauth/authorize`, token_endpoint: `${baseUrl}/oauth/token`,
    registration_endpoint: `${baseUrl}/oauth/register`, revocation_endpoint: `${baseUrl}/oauth/revoke`,
    response_types_supported: ["code"], grant_types_supported: ["authorization_code", "refresh_token"],
    code_challenge_methods_supported: ["S256"], token_endpoint_auth_methods_supported: ["none"],
    revocation_endpoint_auth_methods_supported: ["none"], scopes_supported: ["trips:create"],
    authorization_response_iss_parameter_supported: true,
  };
  const protectedMetadata = {resource: oauth.resource, authorization_servers: [baseUrl], scopes_supported: ["trips:create"], bearer_methods_supported: ["header"], resource_name: "TravelCrew trip creation"};
  app.get([...new Set([metadataPath, "/.well-known/oauth-protected-resource", `/.well-known/oauth-protected-resource${base.pathname.replace(/\/$/, "")}/mcp`])], (req, res) => res.json(protectedMetadata));
  app.get(`/.well-known/oauth-authorization-server${base.pathname.replace(/\/$/, "")}`, (req, res) => res.json(authorizationMetadata));
  router.get("/.well-known/oauth-protected-resource", (req, res) => res.json(protectedMetadata));
  router.get("/.well-known/oauth-authorization-server", (req, res) => res.json(authorizationMetadata));
  router.post("/oauth/register", async (req, res) => res.status(201).json(await oauth.register(req.body)));
  router.get("/oauth/authorize", async (req, res) => {
    const request = await oauth.authorize(req.query);
    res.cookie("tc_consent", request.cookie, {httpOnly: true, secure: base.protocol === "https:", sameSite: "lax", maxAge: 600000, path: `${base.pathname.replace(/\/$/, "")}/oauth/consent`});
    accountPage(res, {baseUrl, firebaseConfig, request});
  });
  router.post("/oauth/consent", async (req, res) => {
    if (req.get("origin") !== base.origin) throw new ApiError(403, "invalid_request", "Open the authorization page again");
    if (typeof req.body?.approve !== "boolean") throw new ApiError(400, "invalid_request", "Choose Allow or Cancel");
    const cookie = /(?:^|;\s*)tc_consent=([^;]+)/.exec(req.get("cookie") || "")?.[1];
    const identity = req.body.approve ? await oauth.firebaseIdentity(bearer(req)) : null;
    const redirect = await oauth.consent(req.body.request_id, cookie, identity, req.body.approve);
    res.json({redirect});
  });
  router.post("/oauth/token", async (req, res) => res.json(await oauth.exchange(req.body || {})));
  router.post("/oauth/revoke", async (req, res) => { await oauth.revoke(req.body?.token, req.body?.client_id); res.json({}); });
  router.get("/connect", (req, res) => accountPage(res, {baseUrl, firebaseConfig}));
  router.get("/connections", async (req, res) => res.json({connections: await oauth.connections((await oauth.firebaseIdentity(bearer(req))).uid)}));
  router.delete("/connections/:id", async (req, res) => {
    await oauth.disconnect((await oauth.firebaseIdentity(bearer(req))).uid, req.params.id); res.json({ok: true});
  });
  router.get("/trips/:id", (req, res) => {
    if (!/^[a-f0-9-]{36}$/.test(req.params.id)) return res.status(404).send("Trip link not found");
    tripPage(res, req.params.id);
  });
  router.get("/openapi.json", (req, res) => res.json({
    openapi: "3.1.0", info: {title: "TravelCrew trip creation", version: "1.0.0"}, servers: [{url: baseUrl}],
    paths: {"/v1/trips": {post: {operationId: "createTrip", summary: "Create a private trip for the connected user",
      security: [{oauth: ["trips:create"]}], parameters: [{in: "header", name: "Idempotency-Key", required: true, schema: z.toJSONSchema(idempotencySchema)}],
      requestBody: {required: true, content: {"application/json": {schema: z.toJSONSchema(tripSchema)}}},
      responses: {201: {description: "Trip created"}, 200: {description: "Existing result returned for a retry"}, 400: {description: "Invalid itinerary"}, 401: {description: "Authentication required"}, 403: {description: "Account unavailable"}, 409: {description: "Idempotency key reused with different input"}, 429: {description: "Daily trip quota reached"}},
    }}}, components: {securitySchemes: {oauth: {type: "oauth2", flows: {authorizationCode: {authorizationUrl: authorizationMetadata.authorization_endpoint, tokenUrl: authorizationMetadata.token_endpoint, scopes: {"trips:create": "Create private trips"}}}}}},
  }));
  router.post("/v1/trips", async (req, res) => {
    const uid = await oauth.verify(bearer(req), true);
    const result = await createTrip(uid, req.body, req.get("idempotency-key"));
    res.status(result.replayed ? 200 : 201).json(result);
  });
  const handleMcp = async (req, res) => {
    const uid = await oauth.verify(bearer(req));
    const server = new McpServer({name: "travelcrew", title: "Travel Crew", version: "1.1.0", websiteUrl: base.origin}, {
      instructions: "Create private Travel Crew trips only when the user asks to save an itinerary. Ask for missing destination, country, and dates. Never invent bookings or paid expenses. Return the trip URL after saving; the user can open it in Travel Crew.",
    });
    const toolConfig = {
      title: "Create a TravelCrew trip", description: "Save a private trip to the connected user's TravelCrew account when requested. Do not invent bookings or record estimated expenses as paid. Generate a unique idempotency_key for each new trip and reuse it unchanged for retries. Return the trip URL to the user.",
      inputSchema: {idempotency_key: idempotencySchema, trip: tripSchema},
      outputSchema: {trip_id: z.string(), url: z.string().url(), app_url: z.string(), is_private: z.literal(true), replayed: z.boolean()},
      _meta: {securitySchemes: [{type: "oauth2", scopes: ["trips:create"]}]},
      annotations: {readOnlyHint: false, destructiveHint: false, idempotentHint: true, openWorldHint: false},
    };
    server.registerTool("create_trip", toolConfig, async ({trip, idempotency_key: key}) => {
      try {
        const result = await createTrip(uid, trip, key);
        return {content: [{type: "text", text: JSON.stringify(result)}], structuredContent: result};
      } catch (error) {
        if (!(error instanceof ApiError)) logger.error("assistant_trip_failed", {code: error.code || "internal"});
        return {isError: true, content: [{type: "text", text: JSON.stringify({error: error instanceof ApiError ? error.code : "internal_error", message: error instanceof ApiError ? error.message : "Trip creation failed. Retry with the same idempotency key."})}]};
      }
    });
    // The SDK version in this project preserves _meta but does not yet expose
    // top-level securitySchemes. Publish both for OpenAI and generic MCP hosts.
    server.server.setRequestHandler(ListToolsRequestSchema, () => ({tools: [{
      ...toolConfig, name: "create_trip", securitySchemes: toolConfig._meta.securitySchemes,
      inputSchema: z.toJSONSchema(z.object(toolConfig.inputSchema)),
      outputSchema: z.toJSONSchema(z.object(toolConfig.outputSchema)),
    }]}));
    const transport = new StreamableHTTPServerTransport({sessionIdGenerator: undefined, enableJsonResponse: true});
    res.on("close", () => { transport.close().catch(() => {}); server.close().catch(() => {}); });
    await server.connect(transport);
    await transport.handleRequest(req, res, req.body);
  };
  app.post(resourceUrl.pathname, handleMcp);
  app.all(resourceUrl.pathname, (req, res) => res.set("Allow", "POST").status(405).json({error: "method_not_allowed"}));
  router.post("/mcp", handleMcp);
  router.all("/mcp", (req, res) => res.set("Allow", "POST").status(405).json({error: "method_not_allowed"}));
  app.use(base.pathname.replace(/\/$/, "") || "/", router);
  app.use((req, res) => res.status(404).json({error: "not_found"}));
  app.use((error, req, res, next) => {
    if (res.headersSent) return next(error);
    const known = error instanceof ApiError;
    const status = known ? error.status : error.type === "entity.too.large" ? 413 : error.type === "entity.parse.failed" ? 400 : 500;
    if (status === 401) res.set("WWW-Authenticate", `Bearer resource_metadata="${base.origin}${metadataPath}", scope="trips:create"`);
    if (status === 429) res.set("Retry-After", "3600");
    if (status === 500) logger.error("assistant_request_failed", {code: error.code || "internal"});
    res.status(status).json({error: known ? error.code : status === 500 ? "internal_error" : "invalid_request", error_description: known ? error.message : "Request could not be processed"});
  });
  return app;
}
module.exports = {createAssistantApp};
