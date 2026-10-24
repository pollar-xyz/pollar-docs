---
title: "MCP Gateway"
---

The **Pollar MCP Gateway** lets AI agents and other programmatic clients read and manage your Pollar applications over the [Model Context Protocol](https://modelcontextprotocol.io) (MCP). It is a curated, scoped surface in front of the Pollar API, built for tools like Claude Code, Claude Desktop, Cursor, and any MCP-capable client.

**Endpoint:** `https://mcp.api.pollar.xyz/mcp` (Streamable HTTP)

**Authentication:** a **Personal Access Token** (`pat_...`) sent as `Authorization: Bearer pat_...`. The token's scopes decide what the agent can do; a request without a token is rejected.

---

## Get a Personal Access Token

Personal Access Tokens (PATs) are **account-level** credentials: they belong to you, not to a single app, and can cover all of your apps or a chosen subset.

1. In the dashboard, open **Personal Access Tokens** in the account sidebar (the one you see outside an app, next to **Account** and **Billing**).
2. Click **Create token** and give it a **name**.
3. Pick its **scopes** (see below), or toggle **Full access** for all scopes.
4. (Optional) Restrict it to **specific applications**. Left unrestricted, it covers every app you own.
5. (Optional) Set an **expiry date**.
6. Copy the token (`pat_...`) immediately: it is shown only once.

Revoke a token anytime from the same screen; any client using it loses access immediately.

### Scopes

A token grants `resource:action` permissions. A tool fails with `403 PAT_INSUFFICIENT_SCOPE` if the token lacks the scope it needs, and the error names the scope to grant. Grant the **least** a client requires: a read-only research agent only needs the `:read` scopes; a provisioning agent needs the matching `:write` scopes.

| Scope | Grants |
|---|---|
| `applications:read` / `:write` | Read apps, their metrics, credits, usage, statements and deposit addresses; create apps; edit allowed domains and redirect URIs |
| `api_keys:read` / `:write` | List API keys; create and revoke keys |
| `wallets:read` / `:write` | Read wallets and balances; fund testnet wallets |
| `assets:read` / `:write` | Read assets; enable assets |
| `transactions:read` | Read transaction history |
| `users:read` | Read SDK end-users |
| `distribution:read` / `:write` | Read distribution rules and the distribution vault; create rules |
| `branches:read` / `:write`, `members:read` / `:write` | Dashboard features with no MCP tool |

> Selecting **Full access** (`*`) grants every scope.

---

## Tools

Each tool maps to a Pollar API operation and requires the matching scope on your token.

### Read

| Tool | Arguments | Returns | Scope |
|---|---|---|---|
| `whoami` | none | The developer account the token belongs to and the applications in scope. Call it first | none (the app list needs `applications:read`) |
| `list_applications` | none | Applications the token can access | `applications:read` |
| `get_application` | `id` | App detail (network, auth settings, wallets summary) | `applications:read` |
| `get_application_wallets` | `id` | App and end-user wallets | `wallets:read` |
| `get_wallet_balances` | `id`, `publicKey` | On-chain balances for a wallet | `wallets:read` |
| `get_application_transactions` | `id`, `limit?`, `offset?` | Transaction history (paginated) | `transactions:read` |
| `get_application_users` | `id`, `limit?`, `offset?` | SDK end-users (paginated) | `users:read` |
| `get_application_metrics` | `id`, `range?` (`7d`, `14d`, `30d`; default `14d`), `network?`, `tz?` | Transaction counts and time series; `tz` buckets by the developer's local day (default UTC) | `applications:read` |
| `get_application_credits` | `id`, `since?`, `limit?` (1 to 200, default 50) | Credit balance (100 credits = 1 USD): paid, promo, overdraft, available, and the latest movements, charges negative with the event behind each | `applications:read` |
| `get_application_usage` | `id`, `from?`, `to?` | Use per billable event in a period (default the last 30 days): count and credits, with the total | `applications:read` |
| `get_application_statements` | `id` | A postpaid app's monthly statements: amount billed, unpaid, due date, status (`ISSUED`, `PAID`, `OVERDUE`, `VOID`) | `applications:read` |
| `get_application_deposit_addresses` | `id` | Where the app tops up its credits: an address per chain and the stablecoins each accepts | `applications:read` |
| `get_distribution_vault` | `id` | The distribution vault: address, balances and latest withdrawals | `distribution:read` |
| `list_api_keys` | `id` | The app's keys, metadata only (never the key itself) | `api_keys:read` |
| `list_distribution_rules` | `id` | The app's token distribution rules | `distribution:read` |
| `list_application_assets` | `id` | The assets enabled on the app | `applications:read` |

There is no tool that withdraws from the distribution vault: a withdrawal needs the owner's dashboard session.

### Write

| Tool | Arguments | Scope |
|---|---|---|
| `create_application` | `name` (3 to 100 characters) | `applications:write` |
| `create_api_key` | `id`, `name`, `type?` (`PUBLISHABLE` default, or `SECRET`), `allow_native_clients?`, `expires_at?` | `api_keys:write` |
| `enable_asset` | `id`, `code`, `issuer`, `name` | `assets:write` |
| `create_distribution_rule` | `id`, `assetId`, `name`, `amountPerUser`, `maxClaims`, `period`, `globalCap?`, `validFrom?`, `validUntil?`, `enabled?` | `distribution:write` |
| `fund_testnet_wallet` | `id`, `publicKey` | `wallets:write` |

`create_api_key` returns the full key once. `fund_testnet_wallet` tops up a wallet through the Stellar **testnet** friendbot, typically the app's global (or funding) wallet; get the public key from `get_application_wallets` first. It has no effect on mainnet apps.

### Edit

| Tool | Arguments | Scope |
|---|---|---|
| `update_application_domains` | `id`, `allowed_origins` | `applications:write` |
| `update_application_redirect_uris` | `id`, `allowed_redirect_uris` | `applications:write` |
| `revoke_api_key` | `id`, `keyId` (from `list_api_keys`) | `api_keys:write` |

`update_application_domains` **replaces** the app's entire allowed-origins (CORS) list, so pass the full set you want to keep, not just additions.

`update_application_redirect_uris` does the same for the OAuth redirect allowlist. The two lists are independent: a callback host only needs to be a redirect URI, not an origin. An empty redirect list refuses every OAuth login of the app with `APPLICATION_HAS_NO_REDIRECT_URIS`.

`revoke_api_key` cannot be undone: SDK clients using the key stop working, and a new key is issued with `create_api_key`.

### Helpers

These combine several reads (and, where noted, a conditional write) into one answer.

| Tool | Arguments | Does |
|---|---|---|
| `get_application_wallet_by_role` | `id`, `role?` | Resolve a wallet by role (GLOBAL / FUNDING / GAS / DISTRIBUTION) and report whether it is funded |
| `ensure_wallet_funded` | `id`, `role?` | Fund the role's wallet via the testnet friendbot **only if** it is not already funded (mainnet wallets are reported, not funded) |
| `check_application_readiness` | `id` | Evaluate the dashboard "Get started" config steps (API keys, domains, OAuth redirect URIs, app-wallet funding, trustlines) and report whether the app is ready to use. A step shows `done: null` when the token lacks the scope to read it |

`role` defaults to `GLOBAL`; use `FUNDING` / `GAS` / `DISTRIBUTION` once an app has split wallets. "Funded" means the wallet's account exists on Stellar; for exact balances call `get_wallet_balances`.

---

## Resources and prompts

Clients that read MCP resources can load:

| URI | Content |
|---|---|
| `pollar://applications` | The applications the token can access (JSON) |
| `pollar://applications/{id}` | One application's detail record (JSON) |

And two prompts:

| Prompt | Arguments | Does |
|---|---|---|
| `onboard_application` | `name?` | Creates an application and walks it through every "Get started" step to ready |
| `audit_application` | `application_id` | Audits an application's readiness, wallets, API keys, enabled assets and recent activity |

---

## REST reads

The same token also reads a few endpoints over plain HTTP, with `Authorization: Bearer pat_...`:

```
GET https://mcp.api.pollar.xyz/v1/applications
GET https://mcp.api.pollar.xyz/v1/applications/{id}
GET https://mcp.api.pollar.xyz/v1/applications/{id}/wallets
GET https://mcp.api.pollar.xyz/v1/applications/{id}/wallets/{publicKey}/balances
GET https://mcp.api.pollar.xyz/v1/applications/{id}/transactions
GET https://mcp.api.pollar.xyz/v1/applications/{id}/users
```

The token's scopes apply the same way as for the tools.

---

## Confirmation behavior

Clients that support MCP tool annotations use them to decide when to prompt:

- **Reads and creates run automatically** (including `fund_testnet_wallet` and `ensure_wallet_funded`, which are harmless idempotent testnet top-ups).
- **Edits that overwrite or remove existing state** (`update_application_domains`, `update_application_redirect_uris` and `revoke_api_key`) **prompt for confirmation** before running.

---

## Connect a client

Replace `pat_...` with your token in every example.

**Claude Code**

```bash
claude mcp add --transport http pollar https://mcp.api.pollar.xyz/mcp --header "Authorization: Bearer pat_..."

claude mcp get pollar   # verify it was installed
```

**Claude Desktop / Cursor / Windsurf / Cline**: add a `mcpServers` entry (config files: Claude Desktop `claude_desktop_config.json`, Cursor `~/.cursor/mcp.json`, Windsurf `~/.codeium/windsurf/mcp_config.json`):

```json
{
  "mcpServers": {
    "pollar": {
      "type": "http",
      "url": "https://mcp.api.pollar.xyz/mcp",
      "headers": { "Authorization": "Bearer pat_..." }
    }
  }
}
```

**VS Code (GitHub Copilot)**: add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "pollar": {
      "type": "http",
      "url": "https://mcp.api.pollar.xyz/mcp",
      "headers": { "Authorization": "Bearer pat_..." }
    }
  }
}
```

**Clients that only support stdio**: bridge to the HTTP endpoint with `mcp-remote`:

```json
{
  "mcpServers": {
    "pollar": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.api.pollar.xyz/mcp", "--header", "Authorization: Bearer pat_..."]
    }
  }
}
```

After editing the config, restart the client. Once connected it should list the Pollar tools (`list_applications`, `get_application`, ...).

---

## Example prompts

With the gateway connected, you can ask an agent things like:

- *"List my Pollar apps and tell me which ones are ready to use."* -> `list_applications` + `check_application_readiness`
- *"Fund the testnet global wallet for app `...` if it isn't funded yet."* -> `ensure_wallet_funded`
- *"Add `https://staging.myapp.com` to app `...`'s allowed domains."* -> `update_application_domains` (the client confirms first)
- *"Let app `...`'s OAuth login redirect back to `https://api.myapp.com/oauth/callback`."* -> `update_application_redirect_uris` (the client confirms first)
- *"Create a publishable API key for app `...`."* -> `create_api_key`
- *"How many credits does app `...` have left, and what used them this month?"* -> `get_application_credits` + `get_application_usage`

---

## Security

- A PAT is as sensitive as a password: never commit it to version control; store it in your client's secret config.
- Grant the minimum scopes a client needs, and restrict the token to specific apps when possible.
- Set an expiry for short-lived or shared tokens, and revoke any token you suspect is exposed from **Personal Access Tokens** in the dashboard.
