const {z} = require("zod");
const {HttpsError} = require("firebase-functions/v2/https");
const {normalize, travelDay} = require("./features");
const {validId} = require("../validation");

const id = z.string().min(1).max(128).regex(/^[A-Za-z0-9_-]+$/);
const tripId = z.string().refine(validId);
const day = z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine((v) => travelDay(v) !== null);
const filtersSchema = z.object({from: day.optional(), to: day.optional(), minDays: z.number().int().min(1).max(365).optional(),
  maxDays: z.number().int().min(1).max(365).optional()}).strict().refine((v) =>
  (!v.from || !v.to || v.from <= v.to) && (!v.minDays || !v.maxDays || v.minDays <= v.maxDays));
const preferencesSchema = z.object({destinations: z.array(z.string().trim().min(1).max(160)).max(10)
    .transform((values) => [...new Set(values.map(normalize))]), filters: filtersSchema.default({})}).strict();
const feedSchema = z.object({pageSize: z.number().int().min(1).max(20).default(20),
  cursor: z.string().max(1024).optional(), filters: filtersSchema.optional()}).strict();
const eventSchema = z.object({eventId: id, sessionId: id, tripId, position: z.number().int().min(0).max(199),
  type: z.enum(["impression", "open", "favorite", "unfavorite"]), occurredAt: z.number().int().optional()}).strict();
const eventsSchema = z.object({events: z.array(z.unknown()).min(1).max(25)}).strict();
const dismissalSchema = z.object({tripId, dismissed: z.boolean(), sessionId: id.optional()}).strict();
function parse(schema, data) {
  const result = schema.safeParse(data ?? {});
  if (!result.success) throw new HttpsError("invalid-argument", "Invalid recommendation request.");
  return result.data;
}
function identity(request) {
  if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Sign in required.");
  return request.auth.uid;
}
module.exports = {id, filtersSchema, preferencesSchema, feedSchema, eventSchema, eventsSchema, dismissalSchema, parse, identity};
