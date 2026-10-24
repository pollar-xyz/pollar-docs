---
title: "Dashboard Overview"
---

The Pollar Dashboard at [dashboard.pollar.xyz](https://dashboard.pollar.xyz) is the control panel for your app's configuration. Sign in with Google; no wallet required.

Each app you create is isolated with its own API keys, wallets, and configuration. You can switch between apps from the top navigation bar.

---

## Navigation

The per-app sidebar is organized into ten groups. Each page below lists the **chains** it applies to: an app enables Stellar, Solana and Polygon independently under [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains), and the full feature-by-chain matrix is in [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support). Pages marked `upcoming` are gated behind a "coming soon" state.

### Overview

| Section | What you do here | Chains |
| --- | --- | --- |
| **Home** | Per-app landing with key status at a glance | All |
| **Get started** | Onboarding checklist (hidden once you're set up) | Stellar-centric steps |

### Build

| Section | What you do here | Chains |
| --- | --- | --- |
| **Settings** | App name, network (testnet / mainnet) and auth token lifetimes | All |
| **API Keys** | Generate and manage publishable and secret keys | All |
| **Domains** | Allowed origins (CORS) and redirect URIs so the SDK can call Pollar from your app | All |
| **Webhooks** `upcoming` | Configure inbound webhook URLs and view event logs | Stellar |
| **Branding** | Customize the Pollar modals: theme, accent color, logo | All |
| **Members** | View team members; the owner manages access | All |

### Users

| Section | What you do here | Chains |
| --- | --- | --- |
| **Accounts** | Browse users, view login history, custody badges, and manage accounts | All |

### Wallets

| Section | What you do here | Chains |
| --- | --- | --- |
| **Wallets** | Browse user wallets on every chain: status, custody, balances, tokens, explorer links | Stellar, Solana, Polygon |
| **Wallet settings** | Who holds the keys (Pollar or Turnkey co-signed) and when wallets are created | All |
| **Account Funding** | A Stellar tab (funding wallet, Immediate / Deferred, starting XLM) and a Solana tab (GAS wallet, starting SOL) | Stellar, Solana |
| **Rail wallets** | Users' wallets on chains the app does not show, left behind by a ramp or a disabled chain | Stellar, Solana, Polygon |
| **Chains** | Enable chains, order the default, create the per-chain GAS wallet | Stellar, Solana, Polygon |
| **Sponsorship** | One tab per enabled chain: Stellar fee bumps and reserves, Solana fee payer and top-up policy, Polygon gas policy | Stellar, Solana, Polygon |
| **Tokens & Trustlines** | The assets enabled on user wallets: Stellar assets, SPL mints, ERC-20 contracts | Stellar, Solana, Polygon |
| **Transaction Policy** | Account merge allowlist, max fee and max operations for custodial signing | Stellar |
| **Auth Policy** | Soroban contract and function allowlist for authorization entries | Stellar |

### Ramps

| Section | What you do here | Chains |
| --- | --- | --- |
| **Providers** | Enable fiat on/off-ramp providers and their corridors | Stellar, Solana, Polygon (per provider) |
| **Transactions** | Every ramp order of your app with its status, rail and settlement chain | Stellar, Solana, Polygon |

### Cards

| Section | What you do here | Chains |
| --- | --- | --- |
| **Providers** | Enable card providers, set the card label and the redirect URL | All (funding from Stellar) |
| **Card holders** | Your users' cards: identity verification, the card and its credit line | All |

### Treasury

| Section | What you do here | Chains |
| --- | --- | --- |
| **Swap** | The swap venues exposed to end-users (SDEX, Soroswap, Aquarius) | Stellar |
| **Earn** | The yield providers exposed to end-users (DeFindex, Blend) | Stellar |
| **Token Distribution** | Claimable distribution rules: assets, amounts, rate limits | Stellar |

### Integrations

| Section | What you do here | Chains |
| --- | --- | --- |
| **Authentication** `upcoming` | Configure supported OAuth providers and email OTP | All |
| **KYC** `upcoming` | Configure identity-verification providers | All |
| **Pollar Pay** `upcoming` | Pollar Pay integration | Stellar |

### Monitor

| Section | What you do here | Chains |
| --- | --- | --- |
| **Transactions** | On-chain transactions across your app, each with its chain, fee unit and explorer | Stellar, Solana, Polygon |
| **Logs** | API request logs, errors, and delivery history | All |
| **SDK versions** | Which `@pollar/core` builds your users run, and how many live sessions sit on each | All |
| **Alerts** `upcoming` | Low-balance alerts via email or webhook | All |

### Danger Zone

| Section | What you do here | Chains |
| --- | --- | --- |
| **Archive app** (owner only) | Archive the app: disables its API keys and SDK access entirely (reversible by unarchiving) | All |

---

## Get started checklist

When you create a new app, the Dashboard shows a checklist of required steps before you can go live:

1. **Configure API keys**: generate a publishable key to connect your SDK
2. **Configure domains**: add allowed origins so the SDK can make requests
3. **App wallet created and funded**: your funding wallet must be active on Stellar with enough XLM to cover wallet creation. On Solana the equivalent is the Solana GAS wallet under [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains)
4. **Enable tokens**: configure at least one asset so user wallets can hold it
5. **Install the SDK and create your first wallet**: confirms the integration is working end-to-end

---

## Testnet vs Mainnet

Each app targets a single network. Apps start on **Testnet**; moving to **Mainnet** is a gated request/approval flow (via the network control in the top bar), not a free toggle. API keys, wallets, and configuration are scoped to the app's network.

The network decides the cluster on every chain: a testnet app is Stellar testnet, Solana **devnet** and Polygon **Amoy**; a mainnet app is Stellar public, Solana **mainnet-beta** and Polygon mainnet. Chains themselves are enabled separately under [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains).

Start on Testnet; it's free and resets periodically. Request Mainnet when you're ready for production. See [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist) before switching.
