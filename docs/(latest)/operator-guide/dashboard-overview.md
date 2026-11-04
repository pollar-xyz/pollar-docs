---
title: "Dashboard Overview"
---

The Pollar Dashboard at [dashboard.pollar.xyz](https://dashboard.pollar.xyz) is the control panel for your app's configuration. Sign in with Google or with a code sent to your email; no wallet required.

Each app you create is isolated, with its own API keys, wallets and configuration. Your account settings (profile, Personal Access Tokens, your own billing) live in the account menu, outside the per-app sidebar.

---

## Getting around

- **App picker**: at the top of the sidebar. Switch to another app, search your apps or create a new one. You stay on the same page when you switch.
- **Search**: at the start of the top bar, or press Cmd+K (Ctrl+K on Windows and Linux). Type the name of a page to go to it.
- **Environment toggle**: at the end of the top bar. It switches between the Test mode app and its live counterpart. See [Test mode vs Live](#testnet-vs-mainnet).
- **Credits card**: at the bottom of the sidebar, only for apps on credits. It shows the credits left and takes you to [Settings > Credits](https://docs.pollar.xyz/docs/operator-guide/settings/credits). Apps that pay with their own wallets do not see it.

---

## Navigation

The per-app sidebar has three single pages and nine groups. Each page below lists the **chains** it applies to: an app enables Stellar, Solana and Polygon independently under [Wallets > Settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#enabled-chains), and the full feature-by-chain matrix is in [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support). Pages marked `upcoming` are gated behind a "coming soon" state.

[Features](https://docs.pollar.xyz/docs/operator-guide/overview/features) decides which groups you see. Cash in and out, Identity checks, Cards and the Savings page show only while they are on.

### Single pages

| Section | What you do here | Chains |
| --- | --- | --- |
| **Home** | API v1 banner, setup progress and transaction metrics | All |
| **Features** | Turn on the areas your app needs, which shows them in the sidebar | All |
| **Get started** | Onboarding checklist (hidden once every step is done) | Stellar-centric steps |

### Users

| Section | What you do here | Chains |
| --- | --- | --- |
| **Accounts** | Browse users with their sign-in providers and every wallet they hold; export CSV; grant signer rotations | All |
| **Sign-in** | How long sessions last. Choosing providers per app is `upcoming` | All |
| **Sign-in look** | Customize the Pollar modals: theme, colors, corners, logo | All |

### Wallets

| Section | What you do here | Chains |
| --- | --- | --- |
| **Settings** | Enabled chains and their order, custody (Pollar in Test mode, Turnkey co-signed or self-custody), when wallets are created, and signature confirmation | All |
| **All wallets** | Every wallet on every chain: status, custody, balances, tokens, rail wallets, manual funding | Stellar, Solana, Polygon |
| **Starting balance** | A Stellar tab (funding wallet, Immediate / Deferred, starting XLM) and a Solana tab (starting SOL) | Stellar, Solana |
| **Sponsored fees** | One tab per enabled chain: Stellar fee bumps and reserves, Solana GAS wallet, top-up policy and transfer sponsorship, Polygon GAS wallet and top-up policy | Stellar, Solana, Polygon |
| **Tokens** | The assets enabled on user wallets: Stellar assets, SPL mints, ERC-20 contracts | Stellar, Solana, Polygon |
| **Transaction rules** | Account merge allowlist, max fee and max operations for custodial signing | Stellar |
| **Signing rules** | Soroban contract and function allowlist for authorization entries | Stellar |
| **Swap** | The swap venues exposed to end users (SDEX, Soroswap, Aquarius; Jupiter and Titan on Live) | Stellar, Solana (Live) |
| **USDC bridge** | Your users moving USDC between their own wallets on different chains | Stellar, Solana, Polygon (Live) |
| **Savings** | The DeFindex vaults and Blend pools exposed to end users | Stellar |
| **Token distribution** | Claimable distribution rules: assets, amounts, rate limits | Stellar |
| **Distribution vault** | The app's distribution wallet and withdrawals to its payout wallet | Stellar |

### Cash in and out

| Section | What you do here | Chains |
| --- | --- | --- |
| **Orders** | Your ramp orders from SDK 0.12 and the Server API, with each leg and who resolves a stop | Stellar, Solana, Polygon |
| **Transactions** | Ramp transactions from SDKs older than 0.12 | Stellar, Solana, Polygon |
| **Routes** | The paths a ramp can take, leg by leg | Stellar, Solana, Polygon |
| **Signing** | Who signs ramp legs, and the app-custody terms | Stellar, Solana, Polygon |
| **Providers** | Enable ramp providers and their corridors, bring your own provider account, KYC per corridor | Stellar, Solana, Polygon (per route) |

### Identity checks

| Section | What you do here | Chains |
| --- | --- | --- |
| **Providers** | The KYC options your app offers, and your own Didit account | All |
| **Verification steps** | The steps your users complete, in order | All |

### Cards

| Section | What you do here | Chains |
| --- | --- | --- |
| **Issued cards** | Your users' cards: identity verification, the card and its credit line | All |
| **Providers** | Enable card providers, set the card label and the redirect URL | All (funding from Stellar or Solana) |

### Pollar Pay

| Section | What you do here | Chains |
| --- | --- | --- |
| **Overview, Branches, Charge, Transactions, Plan** `upcoming` | Pollar Pay for this app | Stellar |

### Developers

| Section | What you do here | Chains |
| --- | --- | --- |
| **API keys** | Create and delete publishable and secret keys, with names, expirations and native-client access | All |
| **Websites** | Allowed origins (CORS) and redirect URIs so the SDK can call Pollar from your app | All |
| **Webhooks** `upcoming` | Configure webhook URLs and view event logs | Stellar |
| **SDK versions** | Which `@pollar/core` builds your users run, and how many live sessions sit on each | All |

### Settings

| Section | What you do here | Chains |
| --- | --- | --- |
| **General** | App name, environment, go-live request and App ID | All |
| **Members** | Invite teammates as Admin, Editor or Viewer; the owner or an admin manages access | All |
| **Credits** | Credit balance, top-up addresses, usage, statements, low-balance alert, prices and history | All |
| **Archive app** (owner or admin) | Archive the app: disables its API keys and SDK access entirely (reversible by unarchiving) | All |

### Monitoring

| Section | What you do here | Chains |
| --- | --- | --- |
| **Transactions** | Outgoing transactions of your app and its users, with their phase, fee and envelopes | Stellar, Solana, Polygon |
| **Logs** | Application logs, live or by date range | All |
| **Alerts** `upcoming` | Low-balance alerts via email or webhook | All |

---

## Get started checklist

New apps show a checklist under [Get started](https://docs.pollar.xyz/docs/operator-guide/overview/get-started):

1. **Configure API keys** (required): a publishable key to connect your SDK
2. **Configure allowed domains** (required): origins the SDK can make requests from
3. **Fund app wallet** (required): the app's Stellar wallet active on-chain with more than 10 XLM
4. **Enable trustlines** (recommended): at least one asset so user wallets can hold more than XLM
5. **Create your first user wallet via SDK** (verification): confirms the integration end to end

---

## Test mode vs Live [#testnet-vs-mainnet]

Each app runs in a single environment, fixed when it is created. Apps start in **Test mode**. Going **Live** is a review: the **owner or an admin** requests it from **Settings > General** or from the **Live** segment of the environment control in the top bar. Once approved, Pollar creates the app's live counterpart in the same project, and the environment control switches between the two apps. API keys, wallets and configuration belong to each app.

The environment is what the API and SDK call `network`. Test mode is what the API and SDK call `testnet`. Live is what they call `mainnet`. The mode decides the cluster on every chain: a Test mode app uses Stellar testnet, Solana **devnet** and Polygon **Amoy**; a live app uses the main networks, which are Stellar public, Solana **mainnet-beta** and Polygon mainnet. Chains themselves are enabled under [Wallets > Settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#enabled-chains).

Start in Test mode. Request to go live when you are ready for production; see the [Go-live checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist) first.
