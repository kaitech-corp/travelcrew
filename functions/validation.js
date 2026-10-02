const validId = (value) => typeof value === "string" &&
  value.length > 0 && value.length <= 500 && !value.includes("/") &&
  value !== "." && value !== "..";
const normalizeEmails = (emails) => [...new Set(emails
    .filter((email) => typeof email === "string")
    .map((email) => email.trim().toLowerCase())
    .filter((email) => email.length <= 254 &&
      /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)))];
const chunks = (values, size = 500) => {
  const result = [];
  for (let i = 0; i < values.length; i += size) {
    result.push(values.slice(i, i + size));
  }
  return result;
};
const validPhoto = (name, width) => typeof name === "string" &&
  /^places\/[A-Za-z0-9_-]+\/photos\/[A-Za-z0-9_-]+$/.test(name) &&
  name.length <= 4096 && typeof width === "string" && /^\d+$/.test(width) &&
  Number(width) >= 1 && Number(width) <= 4800;
module.exports = {validId, normalizeEmails, chunks, validPhoto};
