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
