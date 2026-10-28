const {test} = require("node:test");
const assert = require("node:assert/strict");
const {
  currencyPrecision, currencyOptions, toMinorUnits, equalShares, validateAllocation,
  balancesFor, suggestedTransfers,
} = require("../finance/money");

test("currency precision and decimal parsing do not silently round", () => {
  const options = currencyOptions();
  assert.deepEqual(options.find((item) => item.code === "USD"), {code: "USD", precision: 2});
  assert.deepEqual(options.find((item) => item.code === "JPY"), {code: "JPY", precision: 0});
  assert.deepEqual(options.find((item) => item.code === "KWD"), {code: "KWD", precision: 3});
  assert.equal(options.some((item) => item.code === "XXX"), false);
  assert.deepEqual([...options].sort((a, b) => a.code.localeCompare(b.code)), options);
  assert.equal(currencyPrecision("USD"), 2);
  assert.equal(currencyPrecision("JPY"), 0);
  assert.equal(currencyPrecision("KWD"), 3);
  assert.equal(toMinorUnits("0.29", "USD"), 29);
  assert.equal(toMinorUnits(0.29, "USD"), 29);
  assert.equal(toMinorUnits("12", "JPY"), 12);
  assert.equal(toMinorUnits("1.234", "KWD"), 1234);
  for (const input of ["0", "-1", "1.001", "1e3", "NaN", "Infinity", " 1 ", ""] ) {
    assert.throws(() => toMinorUnits(input, "USD"), /amount/i, input);
  }
  for (const code of ["ZZZ", "usd", "USD ", "ABC", ""]) {
    assert.throws(() => currencyPrecision(code), /currency/i, code);
  }
  assert.throws(() => toMinorUnits("999999999999999999", "USD"), /amount/i);
});

test("equal splits distribute every remainder unit by stable participant ID", () => {
  assert.deepEqual(equalShares(100, ["zoe", "amy", "leo"]), {
    amy: 34, leo: 33, zoe: 33,
  });
  assert.deepEqual(equalShares(1, ["b", "a"]), {a: 1, b: 0});
  assert.throws(() => equalShares(100, []), /participant/i);
  assert.throws(() => equalShares(100, ["a", "a"]), /duplicate/i);
});

test("payer contributions and shares are separate exact allocations", () => {
  const expense = {amountMinor: 101, payerAmountsMinor: {amy: 51, zoe: 50},
    sharesMinor: {amy: 34, leo: 34, zoe: 33}};
  assert.doesNotThrow(() => validateAllocation(expense));
  assert.deepEqual(balancesFor([expense], []), {amy: 17, leo: -34, zoe: 17});
  for (const bad of [
    {...expense, payerAmountsMinor: {amy: 100}},
    {...expense, sharesMinor: {amy: 33, leo: 33, zoe: 33}},
    {...expense, sharesMinor: {amy: -1, leo: 69, zoe: 33}},
    {...expense, sharesMinor: {amy: 34.5, leo: 34, zoe: 32.5}},
    {...expense, payerAmountsMinor: {"": 101}},
  ]) assert.throws(() => validateAllocation(bad), /allocation/i);
});

test("only confirmed specific transfers change balances, preserving zero sum", () => {
  const expenses = [{amountMinor: 1001, payerAmountsMinor: {amy: 1001},
    sharesMinor: {amy: 334, leo: 334, zoe: 333}}];
  const transfers = [
    {fromUserId: "leo", toUserId: "amy", amountMinor: 200, status: "confirmed"},
    {fromUserId: "zoe", toUserId: "amy", amountMinor: 333, status: "pending"},
  ];
  const result = balancesFor(expenses, transfers);
  assert.deepEqual(result, {amy: 467, leo: -134, zoe: -333});
  assert.equal(Object.values(result).reduce((a, b) => a + b, 0), 0);
  assert.deepEqual(suggestedTransfers(result), [
    {fromUserId: "zoe", toUserId: "amy", amountMinor: 333},
    {fromUserId: "leo", toUserId: "amy", amountMinor: 134},
  ]);
  assert.throws(() => balancesFor(expenses, [
    {fromUserId: "leo", toUserId: "leo", amountMinor: 1, status: "confirmed"},
  ]), /transfer/i);
});
