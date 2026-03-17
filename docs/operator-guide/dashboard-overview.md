---
title: "Dashboard Overview"
---

The Pollar Dashboard at [dashboard.pollar.xyz](https://dashboard.pollar.xyz) is the control panel for your app's configuration. Sign in with Google or email OTP — no Stellar wallet required.

Each app you create is isolated with its own API keys, wallets, and configuration. You can switch between apps and networks (Testnet / Mainnet) from the top navigation bar.

---

## Navigation

### Configuration

| Section           | What you do here                                                                |
| ----------------- | ------------------------------------------------------------------------------- |
| **App Settings**  | App name, allowed domains (CORS), and general configuration                     |
| **App Wallets**   | View and fund your operator wallets (funding, gas, distribution)                |
| **Funding Mode**  | Select Immediate, Deferred, or Manual wallet activation                         |
| **API Keys**      | Generate and manage publishable and secret keys                                 |
| **Domains**       | Configure allowed origins so the SDK can make requests from your app            |
| **Branding & UI** | Customize the `WalletButton` modal — colors, logo, and supported auth providers |
| **Webhooks**      | Configure inbound webhook URLs and view event logs                              |
| **Alerts**        | Set up low-balance alerts via email or webhook                                  |
| **Integrations**  | Enable SEP-24 fiat ramps and configure anchors                                  |

### Wallet Infrastructure

| Section                 | What you do here                                                              |
| ----------------------- | ----------------------------------------------------------------------------- |
| **Wallets**             | Browse and manage user wallets — view status, balances, and activate manually |
| **Tokens / Trustlines** | Configure which assets are automatically enabled on new user wallets          |
| **Gas Sponsorship**     | Set rules for which transaction types are sponsored and per-user limits       |
| **Distribution Wallet** | Configure `fund()` — assets, amounts, and rate limits                         |

### User Management

| Section            | What you do here                                      |
| ------------------ | ----------------------------------------------------- |
| **Users**          | Browse users, view wallet status, and manage accounts |
| **Authentication** | Configure supported OAuth providers and email OTP     |

### Observability

| Section          | What you do here                                       |
| ---------------- | ------------------------------------------------------ |
| **Transactions** | View all on-chain transactions across your app         |
| **Logs**         | API request logs, errors, and webhook delivery history |

---

## Get started checklist

When you create a new app, the Dashboard shows a checklist of required steps before you can go live:

1. **Configure API keys** — generate a publishable key to connect your SDK
2. **Configure domains** — add allowed origins so the SDK can make requests
3. **App wallet created and funded** — your funding wallet must be active on Stellar with enough XLM to cover wallet creation
4. **Enable trustlines** — configure at least one asset so user wallets can hold it
5. **Install the SDK and create your first wallet** — confirms the integration is working end-to-end

---

## Testnet vs Mainnet

Every app has independent Testnet and Mainnet environments. Switch between them from the network selector in the top navigation bar. API keys, wallets, and configuration are completely separate between environments.

Start on Testnet — it's free and resets periodically. Move to Mainnet when you're ready for production. See [Mainnet Checklist](../guides/mainnet-checklist) before switching.
