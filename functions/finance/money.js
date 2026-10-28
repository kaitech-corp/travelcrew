"use strict";

const {validId} = require("../validation");

const supportedCurrencies = new Set(Intl.supportedValuesOf("currency"));
const MAX_MINOR = 1_000_000_000_000;
const validUserId = (uid) => validId(uid) && uid.length <= 128 &&
  ![...uid].some((character) => character.charCodeAt(0) < 32 || character.charCodeAt(0) === 127);

function currencyPrecision(code) {
  if (typeof code !== "string" || !/^[A-Z]{3}$/.test(code) ||
      !supportedCurrencies.has(code) || ["XXX", "XTS", "XUA"].includes(code)) {
    throw new RangeError("Unsupported currency.");
  }
  return new Intl.NumberFormat("en", {style: "currency", currency: code})
      .resolvedOptions().maximumFractionDigits;
}

function currencyOptions() {
  return [...supportedCurrencies]
      .filter((code) => !["XXX", "XTS", "XUA"].includes(code))
      .sort()
      .map((code) => ({code, precision: currencyPrecision(code)}));
}

function toMinorUnits(value, currencyCode) {
  const precision = currencyPrecision(currencyCode);
  if (typeof value !== "string" && (typeof value !== "number" || !Number.isFinite(value))) {
    throw new RangeError("Enter a valid amount.");
  }
  const match = /^(0|[1-9][0-9]*)(?:\.([0-9]+))?$/.exec(String(value));
  if (!match || (match[2]?.length ?? 0) > precision) {
    throw new RangeError("Enter a valid amount in the selected currency.");
  }
  const units = BigInt(match[1]) * (10n ** BigInt(precision)) +
      BigInt((match[2] || "").padEnd(precision, "0") || "0");
  if (units < 1n || units > BigInt(MAX_MINOR)) {
    throw new RangeError("Amount is outside the supported range.");
  }
  return Number(units);
}

function equalShares(amountMinor, participants) {
  if (!Number.isSafeInteger(amountMinor) || amountMinor < 1 || amountMinor > MAX_MINOR) {
    throw new RangeError("Invalid amount allocation.");
  }
  if (!Array.isArray(participants) || participants.length < 1 || participants.length > 100 ||
      !participants.every(validUserId)) {
    throw new RangeError("Choose 1 to 100 valid participants.");
  }
  if (new Set(participants).size !== participants.length) {
    throw new RangeError("Duplicate participant.");
  }
  const sorted = [...participants].sort();
  const base = Math.floor(amountMinor / sorted.length);
  const remainder = amountMinor % sorted.length;
  return Object.fromEntries(sorted.map((uid, index) => [uid, base + (index < remainder ? 1 : 0)]));
}

function allocationTotal(allocation) {
  if (allocation === null || typeof allocation !== "object" || Array.isArray(allocation) ||
      Object.keys(allocation).length < 1 || Object.keys(allocation).length > 100) {
    throw new RangeError("Invalid allocation.");
  }
  let sum = 0;
  for (const [uid, amount] of Object.entries(allocation)) {
    if (!validUserId(uid) || !Number.isSafeInteger(amount) || amount < 0 || amount > MAX_MINOR) {
      throw new RangeError("Invalid allocation.");
    }
    sum += amount;
    if (!Number.isSafeInteger(sum) || sum > MAX_MINOR) throw new RangeError("Invalid allocation.");
  }
  return sum;
}

function validateAllocation(expense) {
  if (!expense || !Number.isSafeInteger(expense.amountMinor) ||
      expense.amountMinor < 1 || expense.amountMinor > MAX_MINOR ||
      allocationTotal(expense.payerAmountsMinor) !== expense.amountMinor ||
      allocationTotal(expense.sharesMinor) !== expense.amountMinor) {
    throw new RangeError("Expense allocation must match the total amount.");
  }
  return expense;
}

function balancesFor(expenses, transfers) {
  if (!Array.isArray(expenses) || !Array.isArray(transfers)) {
    throw new TypeError("Expected expense and transfer lists.");
  }
  const balances = new Map();
  const add = (uid, change) => {
    const next = (balances.get(uid) || 0) + change;
    if (!Number.isSafeInteger(next)) throw new RangeError("Balance exceeds supported range.");
    balances.set(uid, next);
  };
  for (const expense of expenses) {
    validateAllocation(expense);
    for (const [uid, amount] of Object.entries(expense.payerAmountsMinor)) add(uid, amount);
    for (const [uid, amount] of Object.entries(expense.sharesMinor)) add(uid, -amount);
  }
  for (const transfer of transfers) {
    if (!validUserId(transfer?.fromUserId) || !validUserId(transfer?.toUserId) ||
        transfer.fromUserId === transfer.toUserId ||
        !Number.isSafeInteger(transfer.amountMinor) || transfer.amountMinor < 1 ||
        transfer.amountMinor > MAX_MINOR ||
        !["pending", "confirmed", "rejected", "cancelled"].includes(transfer.status)) {
      throw new RangeError("Invalid transfer.");
    }
    if (transfer.status === "confirmed") {
      add(transfer.fromUserId, transfer.amountMinor);
      add(transfer.toUserId, -transfer.amountMinor);
    }
  }
  const result = Object.fromEntries([...balances].sort(([a], [b]) => a.localeCompare(b)));
  if (Object.values(result).reduce((sum, amount) => sum + BigInt(amount), 0n) !== 0n) {
    throw new RangeError("Balances do not sum to zero.");
  }
  return result;
}

function suggestedTransfers(balances) {
  if (!balances || typeof balances !== "object" || Array.isArray(balances)) {
    throw new TypeError("Expected balances.");
  }
  const entries = Object.entries(balances);
  if (entries.some(([uid, amount]) => !validUserId(uid) || !Number.isSafeInteger(amount)) ||
      entries.reduce((sum, [, amount]) => sum + BigInt(amount), 0n) !== 0n) {
    throw new RangeError("Invalid balances.");
  }
  const byBalance = (a, b) => b.amount - a.amount || a.uid.localeCompare(b.uid);
  const creditors = entries.filter(([, amount]) => amount > 0)
      .map(([uid, amount]) => ({uid, amount})).sort(byBalance);
  const debtors = entries.filter(([, amount]) => amount < 0)
      .map(([uid, amount]) => ({uid, amount: -amount})).sort(byBalance);
  const result = [];
  let ci = 0;
  let di = 0;
  while (ci < creditors.length && di < debtors.length) {
    const amountMinor = Math.min(creditors[ci].amount, debtors[di].amount);
    result.push({fromUserId: debtors[di].uid, toUserId: creditors[ci].uid, amountMinor});
    creditors[ci].amount -= amountMinor;
    debtors[di].amount -= amountMinor;
    if (creditors[ci].amount === 0) ci++;
    if (debtors[di].amount === 0) di++;
  }
  return result;
}

module.exports = {currencyPrecision, currencyOptions, toMinorUnits, equalShares, validateAllocation,
  balancesFor, suggestedTransfers};
