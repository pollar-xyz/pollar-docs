---
title: "Dashboard Overview"
---

The Pollar Dashboard at [dashboard.pollar.xyz](https://dashboard.pollar.xyz) is the control panel for your app's configuration. Sign in with Google or with a code sent to your email; no wallet required.

Each app you create is isolated, with its own API keys, wallets and configuration. Switch between apps from the top navigation bar. Your account settings (profile, Personal Access Tokens, your own billing) live in the account menu, outside the per-app sidebar.

---

## Navigation

The per-app sidebar has eleven groups. Each page below lists the **chains** it applies to: an app enables Stellar, Solana and Polygon independently under [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#enabled-chains), and the full feature-by-chain matrix is in [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support). Pages marked `upcoming` are gated behind a "coming soon" state.

### Overview

| Section | What you do here | Chains |
| --- | --- | --- |
| **Home** | API v1 banner, setup progress and transaction metrics | All |
| **Get started** | Onboarding checklist (hidden once every step is done) | Stellar-centric steps |

### Build

| Section | What you do here | Chains |
| --- | --- | --- |
| **Settings** | App name, network, mainnet access request and auth token lifetimes | All |
| **API Keys** | Create and delete publishable and secret keys, with names, expirations and native-client access | All |
| **Domains** | Allowed origins (CORS) and redirect URIs so the SDK can call Pollar from your app | All |
| **Webhooks** `upcoming` | Configure webhook URLs and view event logs | Stellar |
| **Branding** | Customize the Pollar modals: theme, colors, corners, logo | All |
| **Members** | Invite teammates as Admin, Editor or Viewer; the owner or an admin manages access | All |

### Users

| Section | What you do here | Chains |
| --- | --- | --- |
| **Accounts** | Browse users with their sign-in providers and every wallet they hold; export CSV; grant signer rotations | All |

### Wallets

| Section | What you do here | Chains |
| --- | --- | --- |
| **Wallet settings** | Enabled chains and their order, custody (Pollar on testnet, Turnkey co-signed or self-custody), when wallets are created, and signature confirmation | All |
| **Wallets** | Every wallet on every chain: status, custody, balances, tokens, rail wallets, manual funding | Stellar, Solana, Polygon |
| **Account Funding** | A Stellar tab (funding wallet, Immediate / Deferred, starting XLM) and a Solana tab (starting SOL) | Stellar, Solana |
| **Sponsorship** | One tab per enabled chain: Stellar fee bumps and reserves, Solana GAS wallet, top-up policy and transfer sponsorship, Polygon GAS wallet and top-up policy | Stellar, Solana, Polygon |
| **Tokens & Trustlines** | The assets enabled on user wallets: Stellar assets, SPL mints, ERC-20 contracts | Stellar, Solana, Polygon |
| **Transaction Policy** | Account merge allowlist, max fee and max operations for custodial signing | Stellar |
| **Auth Policy** | Soroban contract and function allowlist for authorization entries | Stellar |

### Ramps

| Section | What you do here | Chains |
| --- | --- | --- |
| **Providers** | Enable ramp providers and their corridors, bring your own provider account, KYC per corridor | Stellar, Solana, Polygon (per route) |
| **Routes** | The paths a ramp can take, leg by leg | Stellar, Solana, Polygon |
| **Orders** | Your ramp orders from SDK 0.12 and the Server API, with each leg and who resolves a stop | Stellar, Solana, Polygon |
| **Signing** | Who signs ramp legs, and the app-custody terms | Stellar, Solana, Polygon |
| **Transactions** | Ramp transactions from SDKs older than 0.12 | Stellar, Solana, Polygon |

### Cards

| Section | What you do here | Chains |
| --- | --- | --- |
| **Providers** | Enable card providers, set the card label and the redirect URL | All (funding from Stellar) |
| **Card holders** | Your users' cards: identity verification, the card and its credit line | All |

### Treasury

| Section | What you do here | Chains |
| --- | --- | --- |
| **Swap** | The swap venues exposed to end users (SDEX, Soroswap, Aquarius) | Stellar |
| **Earn** | The DeFindex vaults and Blend pools exposed to end users | Stellar |
| **Token Distribution** | Claimable distribution rules: assets, amounts, rate limits | Stellar |

### Integrations

| Section | What you do here | Chains |
| --- | --- | --- |
| **Authentication** `upcoming` | Configure supported OAuth providers and email OTP | All |
| **KYC** | Identity verification: enabled KYC options, verification steps, your own Didit account | All |
| **Pollar Pay** `upcoming` | Pollar Pay integration | Stellar |

### Monitor

| Section | What you do here | Chains |
| --- | --- | --- |
| **Transactions** | Outgoing transactions of your app and its users, with their phase, fee and envelopes | Stellar, Solana, Polygon |
| **Logs** | Application logs, live or by date range | All |
| **SDK versions** | Which `@pollar/core` builds your users run, and how many live sessions sit on each | All |
| **Alerts** `upcoming` | Low-balance alerts via email or webhook | All |

### Billing

| Section | What you do here | Chains |
| --- | --- | --- |
| **Credits** | Credit balance, top-up addresses, usage, statements, low-balance alert, prices and history | All |
| **Distribution vault** | The app's distribution wallet and withdrawals to its payout wallet | Stellar |

### Danger Zone

| Section | What you do here | Chains |
| --- | --- | --- |
| **Archive app** (owner or admin) | Archive the app: disables its API keys and SDK access entirely (reversible by unarchiving) | All |

---

## Get started checklist

New apps show a checklist under [Get started](https://docs.pollar.xyz/docs/operator-guide/overview/get-started):

1. **Configure API keys** (required): a publishable key to connect your SDK
2. **Configure allowed domains** (required): origins the SDK can make requests from
3. **Fund app wallet** (required): the app's Stellar wallet active on-chain with more than 10 XLM
4. **Enable trustlines** (recommended): at least one asset so user wallets can hold more than XLM
5. **Create your first user wallet via SDK** (verification): confirms the integration end to end

---

## Testnet vs Mainnet

Each app targets a single network, fixed when it is created. Apps start on **Testnet**. **Mainnet** access is a review: the **owner or an admin** requests it from **Build > Settings** or from the **MainNet** segment of the network control in the top bar. Once approved, Pollar creates the app's mainnet counterpart in the same project, and the network control switches between the two apps. API keys, wallets and configuration belong to each app.

The network decides the cluster on every chain: a testnet app is Stellar testnet, Solana **devnet** and Polygon **Amoy**; a mainnet app is Stellar public, Solana **mainnet-beta** and Polygon mainnet. Chains themselves are enabled under [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#enabled-chains).

Start on Testnet. Request Mainnet when you are ready for production; see the [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist) first.
