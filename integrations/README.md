# Travel Crew assistant integrations

Connect to **https://travelcrew.app/mcp** using Streamable HTTP and OAuth.
The only tool is `create_trip`, which saves a private itinerary in the connected
Travel Crew account. It supports activities, supplied flight/lodging details,
and explicitly requested expenses. It returns an HTTPS link to open the trip.
It does not book travel or read/edit existing trips. Manage or disconnect access
at **https://travelcrew.app/assistant/connect**.

## ChatGPT custom connection

Use the account/workspace's custom MCP or developer-mode connection interface:

1. Add a remote MCP connection named **Travel Crew** with URL
   `https://travelcrew.app/mcp` and **OAuth** authentication.
2. Use dynamic client registration; no client secret is needed. The server
   advertises authorization, token, and registration endpoints automatically.
3. Sign in with an existing Travel Crew account and select **Allow trip creation**.
4. Ask: “Save a private Tokyo, Japan trip for April 10–12, 2027 in Travel Crew.”
5. Follow the returned link or open **My Trips** in Travel Crew.

Availability and administration of custom connections depend on the host account.
Follow the current [OpenAI connection/testing guide](https://developers.openai.com/plugins/deploy/connect-chatgpt)
and [authentication contract](https://developers.openai.com/plugins/build/auth).
The implementation uses public-client OAuth, S256 PKCE, the `trips:create` scope,
and exact resource `https://travelcrew.app/mcp`. Never paste Firebase credentials
or a service-account key into an AI client.

## OpenAI plugin package and submission

`travelcrew-plugin/` contains the portable manifest, remote MCP declaration,
existing Travel Crew logo, five positive review scenarios, and three negative
scenarios. No skill or embedded chat UI is required for this tool-only plugin.

Build a ZIP from the repository root:

```sh
python3 integrations/package_plugin.py
```

The output is `build/integrations/travelcrew-plugin-1.0.0.zip`. Upload it in the
[OpenAI Plugins portal](https://platform.openai.com/plugins), select the verified
publisher, connect the declared MCP server, and scan its tool. The package
contains no credentials. A valid package is not a platform approval.

Complete these account-specific submission steps before requesting review:

- Verify the publisher identity and domain in the portal. The website supports
  the exact challenge token via server environment variable
  `OPENAI_APPS_CHALLENGE`, returned as plain text at
  `https://travelcrew.app/.well-known/openai-apps-challenge`. The token must come
  from the portal; do not invent or overwrite an existing verification token.
- Supply dedicated reviewer account credentials privately in the portal, with
  an active Travel Crew profile and no interactive MFA requirement. Do not use
  a customer's account or include credentials in the ZIP.
- Run all eight manifest scenarios inside the target AI client and record their
  results. Backend validation tests do not prove the model asks clarifying
  questions or declines unsupported requests correctly.
- Record a walkthrough and supply its accessible URL in review details or
  `extensions.com.openai.review.demo_recording_url`, then rebuild the ZIP.
- Confirm category, publisher, support/legal links, intended countries, and
  required attestations. Submit for review, and publish only after approval.

These requirements follow the [official submission guide](https://developers.openai.com/plugins/deploy/submission).
This repository does not claim the plugin has been submitted or approved.

## Gemini CLI

Merge this entry into your existing Gemini CLI `mcpServers` settings, preserving
other configured servers:

```json
{
  "mcpServers": {
    "travelcrew": {
      "httpUrl": "https://travelcrew.app/mcp",
      "trust": false
    }
  }
}
```

The same configuration is included in `gemini/gemini-extension.json` for extension
packaging. In Gemini CLI, use `/mcp auth travelcrew`, finish browser sign-in and
consent, then inspect `/mcp` and try the sample prompt above. Keep tool-call
confirmation enabled. The callback must reach a local browser/loopback listener.
Travel Crew returns the `iss` parameter required by Gemini's issuer validation.
See [Gemini CLI MCP configuration and OAuth](https://geminicli.com/docs/tools/mcp-server/).

This is a Gemini **CLI** integration. It does not assert that consumer Gemini
chat accepts arbitrary MCP plugins or that a Gemini marketplace submission has
been made. Gemini Enterprise uses a separate connector and administrative setup;
do not configure a confidential-client flow against this public-client-only
authorization server without checking that product's requirements.

## Other compatible MCP clients

Use the same HTTPS URL with Streamable HTTP. Clients must support OAuth discovery,
dynamic registration, public-client authorization-code flow with S256 PKCE, and
the resource indicator. The server supports stateless POST requests; GET returns
405 because no separate SSE stream is provided. An unauthenticated POST returns
401 with a protected-resource metadata challenge, which is expected.

| Setting | Value |
| --- | --- |
| MCP URL/resource | `https://travelcrew.app/mcp` |
| OAuth issuer | `https://travelcrew.app/assistant` |
| Protected resource metadata | `https://travelcrew.app/.well-known/oauth-protected-resource/mcp` |
| Authorization metadata | `https://travelcrew.app/.well-known/oauth-authorization-server/assistant` |
| Scope | `trips:create` |
| Client authentication | `none` (public client, PKCE required) |
| Account management | `https://travelcrew.app/assistant/connect` |

Generate a new idempotency key for each new trip. On uncertain network failures,
retry the same itinerary with the same key so only one trip is created.

## Verification status

On October 7, 2026, the public `/mcp` endpoint returned the expected 401 challenge.
The backend deployed October 3 is reachable through the Cloud Run website;
all six OAuth/quota TTL policies were confirmed active October 5. October 3
checks passed for 12 assistant schema/integration cases, browser email sign-in,
consent, callback, app link and disconnect through the website proxy, eight
website tests, website browser checks, and Flutter connection/link tests.

Authenticated production qualification, actual ChatGPT/Gemini host interaction,
and native-device opening remain to be recorded. Run the explicit live check:

```sh
node functions/test-browser/assistant.live.cjs --live
```

It creates and cleans up a temporary production test account and private trips.
It uses the real Firebase browser SDK and official MCP client. It does not
submit a plugin or run the model-level review prompts. Pending suggested-photo
source changes are a separate rollout; see the [backend runbook](../functions/ASSISTANT.md).
