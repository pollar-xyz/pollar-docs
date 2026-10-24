---
title: "Pollar Documentation"
---

**Pollar** is the onboarding-to-payment infrastructure layer for consumer apps on **Stellar, Solana and Polygon**: the full stack from social login to USDC payments, without exposing users to blockchain complexity. One login gives each user a wallet on every chain your app enables; Solana is fully supported for sign-in, managed, co-signed and self-custody wallets, SOL and SPL payments with sponsored fees, and history. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support).

These pages document `@pollar/*` **0.12**, SDK API v3 and Server API v3. The reference for `@pollar/*` 0.11 and Server API v1 is under **SDK 0.11 / Server API v1** in the version selector.

- [dashboard.pollar.xyz](https://dashboard.pollar.xyz): Create an app and get your API keys

- [github.com/pollar-xyz/pollar](https://github.com/pollar-xyz/pollar): Open source SDK

- [Telegram](https://t.me/+R76f1BarXSUxMTQx): Pollar community

## Getting Started

| <br />                                            | <br />                                          |
| ------------------------------------------------- | ----------------------------------------------- |
| [Overview](https://docs.pollar.xyz/docs/getting-started/overview)       | What Pollar is and the problem it solves        |
| [API Keys](https://docs.pollar.xyz/docs/getting-started/api-keys)       | Publishable vs secret keys, testnet vs mainnet  |
| [Quickstart](https://docs.pollar.xyz/docs/getting-started/quickstart)   | Install, configure, and send your first payment |
| [Example App](https://docs.pollar.xyz/docs/getting-started/example-app) | Clone and run a full working integration        |

---

## Core Concepts

| <br />                                                          | <br />                                                  |
| --------------------------------------------------------------- | ------------------------------------------------------- |
| [Architecture](https://docs.pollar.xyz/docs/core-concepts/architecture)               | How the SDK, Pollar Server, and Dashboard work together |
| [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support)             | What works on Stellar, Solana and Polygon, feature by feature |
| [Funding Modes](https://docs.pollar.xyz/docs/core-concepts/funding-modes)             | Immediate and Deferred wallet activation                |
| [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation)         | At login, on demand, or never                           |
| [Stellar Primitives](https://docs.pollar.xyz/docs/core-concepts/stellar-primitives)   | Fee-bumps, reserves, trustlines, SEP-10, SEP-24         |
| [Security Model](https://docs.pollar.xyz/docs/core-concepts/security-model)           | Who holds each key, encryption at rest, signing policy  |
| [Co-signed and Self-custody Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) | Turnkey wallets, approvals and recovery on Stellar, Solana and Polygon |
| [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps)                             | Fiat on/off-ramps as orders of provider, swap and bridge legs |
| [Credits and Billing Models](https://docs.pollar.xyz/docs/core-concepts/credits)      | Paying for the chain with your own wallets or with credits |
| [Transaction History](https://docs.pollar.xyz/docs/core-concepts/transaction-history) | Where history comes from, and pagination                |

---

## SDK Reference

| <br />                                               | <br />                                          |
| ---------------------------------------------------- | ----------------------------------------------- |
| [@pollar/react](https://docs.pollar.xyz/docs/sdk-reference/pollar-react)   | Hooks and pre-built UI components               |
| [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)     | Full TypeScript client API                      |
| [@pollar/react-native](https://docs.pollar.xyz/docs/sdk-reference/pollar-react-native) | Provider, hooks and modals for React Native |
| [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters) | External wallet login (Stellar Wallets Kit, Solana Wallet Standard) |
| [Pollar Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) | REST endpoints for backend use (v3)             |
| [API Versions](https://docs.pollar.xyz/docs/sdk-reference/api-versions)    | Which API version each SDK uses, and the v1 retirement |
| [Webhooks](https://docs.pollar.xyz/docs/sdk-reference/webhooks)            | Outbound event delivery (upcoming)              |
| [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes)      | All error codes with causes and fixes           |
| [MCP Gateway](https://docs.pollar.xyz/docs/sdk-reference/mcp-gateway)      | MCP / AI-agent access via Personal Access Tokens |

---

## Operator Guide

The sections below mirror the Dashboard sidebar: **Overview, Build, Users, Wallets, Ramps, Cards, Treasury, Integrations, Monitor, Billing, Danger Zone**. Start with the [Dashboard Overview](https://docs.pollar.xyz/docs/operator-guide/dashboard-overview), which also lists the chains each page applies to.

**Overview**

| <br /> | <br /> |
| ------ | ------ |
| [Home](https://docs.pollar.xyz/docs/operator-guide/overview/home)                 | Your app at a glance                  |
| [Get started](https://docs.pollar.xyz/docs/operator-guide/overview/get-started)   | Onboarding checklist                  |

**Build**

| <br /> | <br /> |
| ------ | ------ |
| [Settings](https://docs.pollar.xyz/docs/operator-guide/build/settings)   | App name, network and token lifetimes |
| [API Keys](https://docs.pollar.xyz/docs/operator-guide/build/api-keys)   | Generate and manage keys              |
| [Domains](https://docs.pollar.xyz/docs/operator-guide/build/domains)     | Allowed origins and redirect URIs     |
| [Webhooks](https://docs.pollar.xyz/docs/operator-guide/build/webhooks)   | Event delivery endpoints (upcoming)   |
| [Branding](https://docs.pollar.xyz/docs/operator-guide/build/branding)   | Customize the Pollar modals           |
| [Members](https://docs.pollar.xyz/docs/operator-guide/build/members)     | Team access and roles (owner or admin manage) |

**Users**

| <br /> | <br /> |
| ------ | ------ |
| [Accounts](https://docs.pollar.xyz/docs/operator-guide/users/accounts)   | Browse and manage app users           |

**Wallets**

| <br /> | <br /> |
| ------ | ------ |
| [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings)               | Enabled chains, custody, creation timing, signature confirmation |
| [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets)                   | User wallets on every chain, rail wallets included |
| [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding)        | Funding wallet, funding mode, starting XLM, SOL and POL |
| [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship)                | Who pays the fee, per chain           |
| [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines)  | Stellar assets, SPL mints, ERC-20s    |
| [Transaction Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/transaction-policy)  | Restrict sensitive Stellar operations |
| [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy)                | Soroban authorization allowlist       |

**Ramps**

| <br /> | <br /> |
| ------ | ------ |
| [Providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers)       | Fiat on/off-ramp providers and corridors |
| [Routes](https://docs.pollar.xyz/docs/operator-guide/ramps/routes)             | The paths a ramp can take, leg by leg |
| [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders)             | Ramp orders and what each one needs   |
| [Signing](https://docs.pollar.xyz/docs/operator-guide/ramps/signing)           | How ramp legs are signed              |
| [Transactions](https://docs.pollar.xyz/docs/operator-guide/ramps/transactions) | Ramps from SDKs older than 0.12       |

**Cards**

| <br /> | <br /> |
| ------ | ------ |
| [Providers](https://docs.pollar.xyz/docs/operator-guide/cards/providers)       | Card providers, label and redirect URL |
| [Card holders](https://docs.pollar.xyz/docs/operator-guide/cards/card-holders) | Your users' cards                     |

**Treasury**

| <br /> | <br /> |
| ------ | ------ |
| [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap)                             | Swap venues exposed to users (Stellar) |
| [Earn](https://docs.pollar.xyz/docs/operator-guide/treasury/earn)                             | Yield vaults and pools (DeFindex, Blend) |
| [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution) | Claimable distribution rules          |

**Integrations**

| <br /> | <br /> |
| ------ | ------ |
| [Authentication](https://docs.pollar.xyz/docs/operator-guide/integrations/authentication) | OAuth providers and email OTP (upcoming) |
| [KYC](https://docs.pollar.xyz/docs/operator-guide/integrations/kyc)                        | Identity verification and verification steps |
| [Pollar Pay](https://docs.pollar.xyz/docs/operator-guide/integrations/pollar-pay)          | Pollar Pay integration (upcoming)     |

**Monitor**

| <br /> | <br /> |
| ------ | ------ |
| [Transactions](https://docs.pollar.xyz/docs/operator-guide/monitor/transactions) | On-chain transactions, per chain      |
| [Logs](https://docs.pollar.xyz/docs/operator-guide/monitor/logs)                 | Application logs, live or by date     |
| [SDK versions](https://docs.pollar.xyz/docs/operator-guide/monitor/sdk-versions) | Which SDK builds your users run       |
| [Alerts](https://docs.pollar.xyz/docs/operator-guide/monitor/alerts)             | Low-balance notifications (upcoming)  |

**Billing**

| <br /> | <br /> |
| ------ | ------ |
| [Credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits)                       | Credit balance, top-up addresses, usage and statements |
| [Distribution vault](https://docs.pollar.xyz/docs/operator-guide/billing/distribution-vault) | The vault distribution claims pay from, and withdrawals |

**Danger Zone**

| <br /> | <br /> |
| ------ | ------ |
| [Archive app](https://docs.pollar.xyz/docs/operator-guide/danger-zone/archive-app) | Archive / unarchive the app (owner or admin) |

---

## Guides

| <br />                                                   | <br />                                    |
| -------------------------------------------------------- | ----------------------------------------- |
| [Deferred Flow Guide](https://docs.pollar.xyz/docs/guides/deferred-flow-guide) | KYC-gated wallet activation from your backend |
| [Passkeys and Wallet Recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide) | Recovery methods for co-signed and self-custody wallets |
| [Payments UI](https://docs.pollar.xyz/docs/guides/payments-ui)                 | Send, receive, and history components, on Stellar and Solana |
| [Swaps](https://docs.pollar.xyz/docs/guides/swaps-guide)                       | Asset swaps: pre-built modal or headless  |
| [Custom Wallet Adapter](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter) | Bring your own signer                 |
| [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist)     | Everything to verify before going live    |
