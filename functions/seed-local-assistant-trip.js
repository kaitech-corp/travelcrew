"use strict";

// Local simulator fixture only. Creates one assistant/MCP-shaped private trip
// for the seeded owner through the real creation transaction so the native
// app-link and reload journey can be exercised against local emulators.
const {initializeApp, deleteApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {createTripService} = require("./assistant-trip");

const projectId = "universal-code-135522";
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
if (!/^(localhost|127\.0\.0\.1):[0-9]{2,5}$/.test(firestoreHost || "") ||
    (process.env.GCLOUD_PROJECT && process.env.GCLOUD_PROJECT !== projectId)) {
  throw new Error("Set FIRESTORE_EMULATOR_HOST to a loopback emulator before seeding.");
}

const itinerary = {
  title: "Kyoto spring",
  destination: "Kyoto",
  country: "Japan",
  start_date: "2027-05-01",
  end_date: "2027-05-04",
  lodging: {name: "Ryokan by the river", check_in: "2027-05-01", check_out: "2027-05-04",
    cost_per_night: 18000, cost_currency: "JPY"},
  activities: [
    {title: "Fushimi Inari at dawn", start_datetime: "2027-05-02T06:00:00+09:00",
      end_datetime: "2027-05-02T08:00:00+09:00", location: "Fushimi Inari Taisha"},
    {title: "Kaiseki dinner", start_datetime: "2027-05-03T19:00:00+09:00",
      end_datetime: "2027-05-03T21:00:00+09:00"},
  ],
  transportation: [
    {mode: "flight", departure: "2027-05-01T10:15:00", arrival: "2027-05-02T14:05:00",
      notes: "Example Air 12, Los Angeles to Osaka Kansai."},
    {mode: "train", arrival: "2027-05-02T16:30:00", notes: "Haruka express to Kyoto Station."},
  ],
  expense_currency: "JPY",
  expenses: [{name: "Rail passes", amount: 128000, date: "2027-05-02",
    local_datetime: "2027-05-02T15:10:00"}],
};

async function main() {
  const app = initializeApp({projectId});
  try {
    const db = getFirestore(app, "travel-crew-db-2");
    const createTrip = createTripService(db, "http://127.0.0.1:5001/assistant");
    const key = `local_sim_${Date.now()}_journey`;
    const result = await createTrip("e2e_owner", itinerary, key);
    const replay = await createTrip("e2e_owner", itinerary, key);
    if (replay.trip_id !== result.trip_id || replay.replayed !== true) {
      throw new Error("Idempotent replay did not return the original trip.");
    }
    process.stdout.write(`${JSON.stringify({trip_id: result.trip_id, replayed_ok: true})}\n`);
  } finally {
    await deleteApp(app);
  }
}

main().catch((error) => {
  process.stderr.write(`${error.message}\n`);
  process.exitCode = 1;
});
