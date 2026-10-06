const {execFileSync} = require("node:child_process");
async function main() {
  const token = execFileSync("gcloud", ["auth", "print-access-token"], {encoding: "utf8"}).trim();
  const endpoint = "https://identitytoolkit.googleapis.com/admin/v2/projects/universal-code-135522/config";
  const headers = {Authorization: `Bearer ${token}`, "Content-Type": "application/json", "X-Goog-User-Project": "universal-code-135522"};
  const response = await fetch(endpoint, {headers});
  if (!response.ok) throw new Error(`Firebase Auth config read failed: ${response.status} ${(await response.json()).error?.message}`);
  const config = await response.json();
  const authorizedDomains = config.authorizedDomains || [];
  if (!authorizedDomains.includes("travelcrew.app") && process.argv.includes("--configure")) {
    const updated = await fetch(`${endpoint}?updateMask=authorizedDomains`, {method: "PATCH", headers, body: JSON.stringify({authorizedDomains: [...authorizedDomains, "travelcrew.app"]})});
    if (!updated.ok) throw new Error(`Firebase Auth domain update failed: ${updated.status}`);
    console.log("Added travelcrew.app to authorized domains, preserving all existing domains.");
  } else console.log(`travelcrew.app authorized: ${authorizedDomains.includes("travelcrew.app")}`);
  console.log(`Email/password enabled: ${config.signIn?.email?.enabled === true && config.signIn?.email?.passwordRequired === true}`);
  for (const provider of ["google.com", "apple.com"]) {
    const result = await fetch(`https://identitytoolkit.googleapis.com/admin/v2/projects/universal-code-135522/defaultSupportedIdpConfigs/${provider}`, {headers});
    console.log(`${provider} enabled: ${result.ok ? (await result.json()).enabled === true : "not configured"}`);
  }
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
