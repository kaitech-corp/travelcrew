const {test} = require("node:test");
const assert = require("node:assert/strict");
const {tripSchema} = require("../assistant-trip");
const valid = {destination: "Tokyo", country: "Japan", start_date: "2027-04-10", end_date: "2027-04-12"};
test("itinerary validation rejects invented dates, privilege fields and invalid nested records", () => {
  const invalid = [
    {start_date: "2027-02-30"}, {end_date: "2027-04-01"}, {createdBy: "someone-else"}, {is_private: false},
    {image_url: "javascript:alert(1)"}, {destination: "   "}, {joinedUsers: ["other"]},
    {activities: Array(51).fill({title: "Activity"})},
    {activities: [{title: "Activity", start_datetime: "2027-04-10T10:00:00"}]},
    {activities: [{title: "Activity", start_datetime: "2027-04-10T11:00:00Z", end_datetime: "2027-04-10T10:00:00Z"}]},
    {expenses: [{name: "Hotel", amount: -1, date: "2027-04-10"}]},
    {expenses: [{name: "Hotel", amount: Infinity, date: "2027-04-10"}]},
    {expenses: [{name: "Hotel", amount: 2, date: "2027-04-10", paidByUsers: ["other"]}]},
    {lodging: {name: "Hotel", check_in: "2027-04-12", check_out: "2027-04-10"}},
    {airline: {departure_date: "2027-04-12", arrival_date: "2027-04-10"}},
  ];
  for (const patch of invalid) assert.equal(tripSchema.safeParse({...valid, ...patch}).success, false, JSON.stringify(patch));
  assert.equal(tripSchema.parse(valid).is_private, true);
  assert.equal(tripSchema.safeParse({...valid, activities: [{title: "Museum", start_datetime: "2027-04-10T11:00:00+09:00"}]}).success, true);
});

test("travel timestamps use airport/property offsets and compare actual instants", () => {
  const trip = {...valid,
    airline: {departure_date: "2027-04-10T10:00:00+09:00", arrival_date: "2027-04-10T04:00:00-07:00"},
    lodging: {name: "Hotel", check_in: "2027-04-10T15:00:00+09:00", check_out: "2027-04-12T11:00:00+09:00"},
  };
  assert.equal(tripSchema.safeParse(trip).success, true);
  assert.equal(tripSchema.safeParse({...trip, lodging: {name: "Hotel", check_in: "2027-04-10T15:00:00-07:00", check_out: "2027-04-10"}}).success, true);
  assert.equal(tripSchema.safeParse({...trip, airline: {departure_date: "2027-04-10T10:00:00+09:00", arrival_date: "2027-04-10T09:00:00+09:00"}}).success, false);
  assert.equal(tripSchema.safeParse({...trip, airline: {departure_date: "2027-04-10T10:00:00"}}).success, false);
  assert.equal(tripSchema.safeParse({...trip, lodging: {name: "Hotel", check_in: "2027-04-10T15:00:00"}}).success, false);
});

test("creation stores supplied travel offsets unchanged and keeps all-day dates floating", async () => {
  const {createTripService} = require("../assistant-trip");
  const records = new Map([["users/owner", {}]]);
  const doc = (path) => ({path,
    get: async () => ({exists: records.has(path), data: () => records.get(path)}),
    collection: (name) => collection(`${path}/${name}`),
  });
  const collection = (path) => ({doc: (id) => doc(`${path}/${id}`)});
  const db = {doc, collection, runTransaction: (fn) => fn({
    get: (ref) => ref.get(), create: (ref, data) => records.set(ref.path, data),
    set: (ref, data) => records.set(ref.path, data),
  })};
  const input = {...valid,
    airline: {departure_date: "2027-04-10T10:00:00+09:00", arrival_date: "2027-04-10T04:00:00-07:00"},
    lodging: {name: "Hotel", check_in: "2027-04-10T15:00:00+09:00", check_out: "2027-04-12"},
  };
  const result = await createTripService(db, "https://travelcrew.app")("owner", input, "timezone-regression-test");
  const saved = records.get(`trips/${result.trip_id}`);
  assert.equal(saved.departureDate, input.airline.departure_date);
  assert.equal(saved.arrivalDate, input.airline.arrival_date);
  assert.equal(saved.checkInDate, input.lodging.check_in);
  assert.equal(saved.checkOutDate, "2027-04-12T00:00:00.000");
  assert.equal(saved.tripStartDate, "2027-04-10T00:00:00.000");
  assert.equal(records.get(`trips/${result.trip_id}/flights/owner`).arrivalDate, input.airline.arrival_date);
});

test("transportation accepts optional schedules, all modes, and rejects forged or invalid input", () => {
  for (const mode of ["flight", "driving", "rideshare", "taxi", "train", "bus", "scooter", "bicycle", "walking", "ferry", "boat", "other"]) {
    assert.equal(tripSchema.safeParse({...valid, transportation: [{mode}]}).success, true);
  }
  for (const transportation of [
    [{mode: "spaceship"}], [{mode: "driving", userId: "someone-else"}],
    [{mode: "train", departure: "2027-04-10T10:00:00"}],
    [{mode: "bus", departure: "2027-04-12", arrival: "2027-04-10"}],
    [{mode: "bus", travelers: Array(51).fill("Name")}], Array(51).fill({mode: "walking"}),
  ]) assert.equal(tripSchema.safeParse({...valid, transportation}).success, false);
});

test("MCP saves mixed transportation and retains flights for existing clients", async () => {
  const {createTripService} = require("../assistant-trip");
  const records = new Map([["users/owner", {displayName: "Randy"}]]);
  const doc = (path) => ({path, get: async () => ({exists: records.has(path), data: () => records.get(path)}), collection: (name) => collection(`${path}/${name}`)});
  const collection = (path) => ({doc: (id) => doc(`${path}/${id}`)});
  const db = {doc, collection, runTransaction: (fn) => fn({get: (ref) => ref.get(), create: (ref, data) => records.set(ref.path, data), set: (ref, data) => records.set(ref.path, data)})};
  const input = {...valid, airline: {flight_number: "OLD123"}, transportation: [
    {mode: "flight", provider: "Airline", service_number: "NEW456", departure: "2027-04-10T10:00:00+09:00", arrival: "2027-04-10T04:00:00-07:00"},
    {mode: "rideshare", provider: "Uber", travelers: ["Randy"], origin: "Airport", destination: "Hotel"},
    {mode: "scooter", title: "Scooter rental"},
  ]};
  const create = createTripService(db, "https://travelcrew.app");
  const result = await create("owner", input, "transportation-regression");
  const prefix = `trips/${result.trip_id}`;
  assert.equal(records.get(`${prefix}/flights/owner`).flightNumber, "OLD123");
  for (const path of ["flights/owner", "flights/transport_0", "transportation/transport_1", "transportation/transport_2"]) {
    assert.equal(records.get(`${prefix}/${path}`).displayName, "Randy");
  }
  assert.equal(records.get(`${prefix}/flights/transport_0`).flightNumber, "NEW456");
  assert.equal(records.get(`${prefix}/flights/transport_0`).arrivalDate, input.transportation[0].arrival);
  assert.deepEqual(records.get(`${prefix}/transportation/transport_1`).travelerNames, ["Randy"]);
  assert.equal(records.get(`${prefix}/transportation/transport_2`).departure, null);
  const count = records.size;
  assert.equal((await create("owner", input, "transportation-regression")).replayed, true);
  assert.equal(records.size, count);
});
