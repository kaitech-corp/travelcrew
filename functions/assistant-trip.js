const {z} = require("zod");
const {createHash, randomUUID} = require("node:crypto");
const {FieldValue} = require("firebase-admin/firestore");
const {notification, inboxRef} = require("./notification-data");
const {currencyPrecision, toMinorUnits, equalShares} = require("./finance/money");

class ApiError extends Error {
  constructor(status, code, message) { super(message); this.status = status; this.code = code; }
}
const text = (max = 200) => z.string().trim().min(1).max(max);
const date = z.string().regex(/^\d{4}-\d{2}-\d{2}$/).refine((v) => {
  const parsed = new Date(`${v}T00:00:00Z`);
  return Number.isFinite(+parsed) && parsed.toISOString().slice(0, 10) === v;
}, "Use a real calendar date in YYYY-MM-DD format");
const datetime = z.iso.datetime({offset: true}).describe("ISO 8601 timestamp in the event location's local time with its UTC offset on that date. Use Z only for a time actually specified in UTC; never label local time as UTC.");
const travelDate = z.union([date, datetime]);
const transportationDate = z.union([date,
  z.iso.datetime({local: true}).refine((value) => !value.endsWith("Z"))]);
const orderedTransportation = (v) => {
  if (!v.departure || !v.arrival) return true;
  if (v.departure.length === 10 && v.arrival.length === 10) return v.arrival >= v.departure;
  // Different endpoints can have an arrival clock earlier than departure.
  return true;
};
const amount = z.number().finite().positive().max(10000000);
const ordered = (start, end) => (v) => !v[start] || !v[end] || +new Date(v[end]) >= +new Date(v[start]);
const orderedTravel = (start, end) => (v) => {
  if (!v[start] || !v[end]) return true;
  // A date alone has no instant. Do not invent midnight UTC when comparing
  // an all-day entry with a timed entry.
  if (!v[start].includes("T") || !v[end].includes("T")) return v[end].slice(0, 10) >= v[start].slice(0, 10);
  return ordered(start, end)(v);
};
const tripSchema = z.object({
  title: text().optional(), destination: text(), country: text(100),
  start_date: date, end_date: date,
  is_private: z.literal(true).default(true).describe("Assistant-created trips are always private; sharing is managed in the app"),
  image_url: z.url({protocol: /^https$/}).max(2048).optional().describe("Optional suggested destination photo: verified direct upload.wikimedia.org Commons raster URL with Public domain or CC0 license. Omit for No image, if not requested, or if you cannot verify a relevant photo. Never invent URLs. Unsupported/unavailable photos do not prevent saving the trip."),
  transportation: z.array(z.object({
    mode: z.enum(["flight", "driving", "rideshare", "taxi", "train", "bus", "scooter", "bicycle", "walking", "ferry", "boat", "other"]),
    departure: transportationDate.optional().describe("Optional date or local clock at the departure location, e.g. 2027-04-10T10:00:00. No UTC offset is needed; do not convert to the phone timezone"),
    arrival: transportationDate.optional().describe("Optional date or local clock at the arrival location, e.g. 2027-04-10T04:00:00. No UTC offset is needed"),
    notes: z.string().trim().max(4000).default(""),
  }).strict().refine(orderedTransportation, "Arrival must follow departure")).max(50).optional()
    .describe("Multiple transportation entries, including getting there and getting around. Use mode, optional departure/arrival, and notes. Put route, provider, driver, service or flight number, and travelers in notes instead of separate fields. Include transportation plans supplied by the user; do not invent bookings. Flights use mode flight."),
  lodging: z.object({
    type: text(80).optional(), name: text(), address: text(500).optional(),
    check_in: travelDate.optional().describe("Calendar date, or property-local timestamp with its offset on the check-in date"),
    check_out: travelDate.optional().describe("Calendar date, or property-local timestamp with its offset on the check-out date"),
    cost_per_night: z.number().finite().min(0).max(10000000).optional(),
    cost_currency: z.string().regex(/^[A-Z]{3}$/).refine((code) => {
      try { currencyPrecision(code); return true; } catch { return false; }
    }, "Use a supported ISO currency code").optional()
      .describe("Property currency for the nightly quote; required when cost_per_night is supplied. This can differ from the trip expense currency"),
  }).strict().refine(orderedTravel("check_in", "check_out"), "Check-out must follow check-in")
      .superRefine((lodging, context) => {
        if (lodging.cost_per_night === undefined) return;
        if (!lodging.cost_currency) {
          context.addIssue({code: "custom", path: ["cost_currency"], message: "Choose the nightly quote currency"});
          return;
        }
        let precision;
        try { precision = currencyPrecision(lodging.cost_currency); } catch { return; }
        const value = String(lodging.cost_per_night);
        const amount = /^(0|[1-9][0-9]*)(?:\.([0-9]+))?$/.exec(value);
        if (!amount || (amount[2]?.length || 0) > precision) {
          context.addIssue({code: "custom", path: ["cost_per_night"],
            message: "Nightly quote exceeds currency precision"});
        }
      }).optional(),
  activities: z.array(z.object({
    title: text(), description: z.string().trim().max(4000).default(""),
    location: text(500).optional(), address: text(500).optional(),
    start_datetime: datetime.optional(), end_datetime: datetime.optional(),
  }).strict().refine(ordered("start_datetime", "end_datetime"), "Activity end must follow start")).max(50).default([]),
  expense_currency: z.string().regex(/^[A-Z]{3}$/).refine((code) => {
    try { currencyPrecision(code); return true; } catch { return false; }
  }, "Use a supported ISO currency code").optional(),
  expenses: z.array(z.object({
    name: text(), amount, date,
    local_datetime: z.iso.datetime({local: true}).refine((value) => !value.endsWith("Z"))
        .optional().describe("Optional clock at the expense location, without a UTC offset"),
    split_type: z.literal("equally").default("equally"),
  }).strict().refine((expense) => !expense.local_datetime ||
    expense.local_datetime.slice(0, 10) === expense.date,
  "Expense local clock must be on its calendar date")).max(50).default([])
      .describe("Only expenses the user explicitly wants recorded, not speculative estimates"),
}).strict().superRefine((trip, context) => {
  if (!trip.expenses.length) return;
  if (!trip.expense_currency) {
    context.addIssue({code: "custom", path: ["expense_currency"],
      message: "Choose one currency for all trip expenses"});
    return;
  }
  for (const [index, expense] of trip.expenses.entries()) {
    try { toMinorUnits(expense.amount, trip.expense_currency); } catch {
      context.addIssue({code: "custom", path: ["expenses", index, "amount"],
        message: "Amount must use the currency's exact minor-unit precision"});
    }
  }
}).refine(ordered("start_date", "end_date"), "Trip end must follow start");
const idempotencySchema = z.string().regex(/^[A-Za-z0-9_-]{16,128}$/);
const hash = (value) => createHash("sha256").update(value).digest("hex");
const canonical = (value) => JSON.stringify(value, function(key, item) {
  return item && typeof item === "object" && !Array.isArray(item) ?
    Object.fromEntries(Object.keys(item).sort().map((k) => [k, item[k]])) : item;
});
const isoDate = (value) => value ? (value.includes("T") ? value : `${value}T00:00:00.000`) : null;

function createTripService(db, baseUrl, now = () => Date.now(), preparePhoto) {
  return async function createTrip(uid, input, key) {
    if (!uid || uid.includes("/")) throw new ApiError(401, "unauthorized", "Sign in required");
    if (!idempotencySchema.safeParse(key).success) throw new ApiError(400, "invalid_idempotency_key", "Supply an Idempotency-Key of 16–128 letters, digits, underscores or hyphens");
    const parsed = tripSchema.safeParse(input);
    if (!parsed.success) throw new ApiError(400, "invalid_trip", parsed.error.issues.map((e) => `${e.path.join(".")}: ${e.message}`).join("; "));
    const data = parsed.data;
    const fingerprint = hash(canonical(data));
    const receipt = db.doc(`assistantRequests/${hash(`${uid}:${key}`)}`);
    const tripId = randomUUID();
    const tripRef = db.doc(`trips/${tripId}`);
    const time = now();
    const quotaRef = db.doc(`assistantQuotas/${hash(`${uid}:${Math.floor(time / 86400000)}`)}`);
    // All external I/O happens before the transaction. A retry uses its original
    // receipt; preparation never modifies a trip or runs after its creation.
    let photo;
    if (data.image_url && !(await receipt.get()).exists) {
      try { photo = await preparePhoto?.(uid, data.image_url); } catch { /* Cover is optional. */ }
    }
    return db.runTransaction(async (tx) => {
      const [account, safety, prior, quota] = await Promise.all([
        tx.get(db.doc(`users/${uid}`)), tx.get(db.doc(`safetyAccounts/${uid}`)), tx.get(receipt), tx.get(quotaRef),
      ]);
      if (!account.exists || account.data().isDeleted || safety.data()?.restricted) throw new ApiError(403, "account_unavailable", "An active TravelCrew account is required");
      if (prior.exists) {
        if (prior.data().fingerprint !== fingerprint) throw new ApiError(409, "idempotency_conflict", "This key was already used for a different trip; use a new key for a new request");
        return {...prior.data().result, replayed: true};
      }
      if ((quota.data()?.count || 0) >= 30) throw new ApiError(429, "quota_exceeded", "Daily assistant trip limit reached; try again tomorrow");
      const l = data.lodging || {};
      const displayName = typeof account.data().displayName === "string" ? account.data().displayName : "";
      const trip = {
        id: tripId, createdBy: uid, title: data.title || data.destination, destination: data.destination, country: data.country,
        tripStartDate: isoDate(data.start_date), tripEndDate: isoDate(data.end_date), startDate: isoDate(data.start_date), endDate: data.end_date,
        tripStatus: "upcoming", daysToGo: Math.ceil((+new Date(`${data.start_date}T00:00:00Z`) - time) / 86400000),
        isPrivate: true, isShared: false, joinedUsers: [], invitedUsers: [], images: photo?.status === "ready" ? [photo.url] : [],
        latitude: 0, longitude: 0, continent: "", favouriteCount: 0, tripBudget: 0, tripLocation: data.destination,
        lodgingType: l.type || null, hotelName: l.name || null, hotelAddress: l.address || null,
        checkInDate: isoDate(l.check_in), checkOutDate: isoDate(l.check_out),
        expensePerNight: l.cost_per_night ?? null,
        lodgingCurrencyCode: l.cost_per_night === undefined ? null : l.cost_currency,
        source: "assistant", createdAt: FieldValue.serverTimestamp(),
      };
      if (data.expenses.length) {
        trip.financeCurrency = data.expense_currency;
        trip.financePrecision = currencyPrecision(data.expense_currency);
        trip.financeSchemaVersion = 2;
      }
      if (photo?.status === "ready") trip.imageCredits = {[photo.url]: photo.credit};
      tx.create(tripRef, trip);
      tx.create(tripRef.collection("members").doc(uid), {userId: uid, role: "creator", status: "active", joinedAt: FieldValue.serverTimestamp()});
      tx.create(db.doc(`users/${uid}/tripMemberships/${tripId}`), {tripId, role: "creator", status: "active", joinedAt: FieldValue.serverTimestamp()});
      for (const [index, item] of data.activities.entries()) {
        const id = `activity_${index}`;
        tx.create(tripRef.collection("activities").doc(id), {
          id, tripId, createdBy: uid, title: item.title, description: item.description, location: [item.location, item.address].filter(Boolean).join(" — "),
          startDateTime: item.start_datetime || null, endDateTime: item.end_datetime || null, likesCount: 0, likedBy: [], isDeleted: false, contentRevision: 1,
        });
      }
      for (const [index, item] of data.expenses.entries()) {
        const id = `expense_${index}`;
        const amountMinor = toMinorUnits(item.amount, data.expense_currency);
        tx.create(tripRef.collection("financeExpenses").doc(id), {
          id, tripId, createdBy: uid, name: item.name, date: item.date,
          localDateTime: item.local_datetime || null,
          amountMinor, currencyCode: data.expense_currency,
          currencyPrecision: trip.financePrecision, splitType: "equally",
          payerAmountsMinor: {[uid]: amountMinor}, sharesMinor: equalShares(amountMinor, [uid]),
          financeSchemaVersion: 2, revision: 1, isDeleted: false,
          createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
        });
      }
      for (const [index, item] of (data.transportation || []).entries()) {
        const id = `transport_${index}`;
        tx.create(tripRef.collection("transportation").doc(id), {
          id, tripId, userId: uid, displayName, mode: item.mode,
          departure: item.departure || null, arrival: item.arrival || null,
          notes: item.notes, revision: 1, isDeleted: false,
        });
      }
      const noteId = `assistant_${tripId}`;
      tx.create(inboxRef(db, uid, noteId), {...notification(noteId, "system", uid, "trip_created", tripId,
        "Your trip is ready", `${trip.title} was added to your private trips.`, true), notificationType: "Trip"});
      const result = {trip_id: tripId, url: `${baseUrl}/trips/${tripId}`, app_url: `travelcrew://trips/${tripId}`, is_private: true};
      if (data.image_url) result.cover_status = photo?.status === "ready" ? "ready" : "unavailable";
      tx.create(receipt, {uid, fingerprint, result, createdAt: FieldValue.serverTimestamp()});
      tx.set(quotaRef, {count: (quota.data()?.count || 0) + 1, expiresAt: new Date(time + 2 * 86400000)});
      return {...result, replayed: false};
    });
  };
}
module.exports = {ApiError, tripSchema, idempotencySchema, createTripService, hash};
