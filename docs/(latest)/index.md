---
title: "Pollar Documentation"
---

**Pollar** is the onboarding-to-payment infrastructure layer for consumer apps on **Stellar and Solana**. The full stack from social login to USDC payments — without exposing users to blockchain complexity. One login gives each user a wallet on every chain your app enables; Solana is fully supported for sign-in, managed and co-signed wallets, SOL and SPL payments with sponsored fees, history and fiat ramps. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support).

- [dashboard.pollar.xyz](https://dashboard.pollar.xyz) — Create an app and get your API keys

- [github.com/pollar-xyz/pollar](https://github.com/pollar-xyz/pollar) — Open source SDK

- [Telegram](https://t.me/+R76f1BarXSUxMTQx) — Pollar community

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
| [Security Model](https://docs.pollar.xyz/docs/core-concepts/security-model)           | AWS KMS, Passkeys, BYOK, and MPC                        |
| [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets)     | Turnkey 2-of-2 on Stellar, Solana and Polygon           |
| [Transaction History](https://docs.pollar.xyz/docs/core-concepts/transaction-history) | Two-layer history architecture and pagination           |

---

## SDK Reference

| <br />                                               | <br />                                          |
| ---------------------------------------------------- | ----------------------------------------------- |
| [@pollar/react](https://docs.pollar.xyz/docs/sdk-reference/pollar-react)   | Hooks and pre-built UI components               |
| [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)     | Full TypeScript client API                      |
| [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters) | External + embedded wallet login (Stellar Wallets Kit, Solana Wallet Standard, Privy) |
| [Pollar Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) | REST endpoints for backend use                  |
| [Webhooks](https://docs.pollar.xyz/docs/sdk-reference/webhooks)            | Events, HMAC authentication, and retry behavior |
| [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes)      | All error codes with causes and fixes           |
| [MCP Gateway](https://docs.pollar.xyz/docs/sdk-reference/mcp-gateway)      | MCP / AI-agent access via Personal Access Tokens |

---

## Operator Guide

The sections below mirror the Dashboard sidebar: **Overview · Build · Users · Wallets · Ramps · Cards · Treasury · Integrations · Monitor · Danger Zone**. Start with the [Dashboard Overview](https://docs.pollar.xyz/docs/operator-guide/dashboard-overview), which also lists the chains each page applies to.

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
| [Members](https://docs.pollar.xyz/docs/operator-guide/build/members)     | Team access (owner only)              |

**Users**

| <br /> | <br /> |
| ------ | ------ |
| [Accounts](https://docs.pollar.xyz/docs/operator-guide/users/accounts)   | Browse and manage app users           |

**Wallets**

| <br /> | <br /> |
| ------ | ------ |
| [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets)                   | User wallets on every chain           |
| [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings)               | Custody (Pollar / co-signed) and creation timing |
| [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding)        | Stellar funding wallet, starting XLM and SOL |
| [Funding Mode](https://docs.pollar.xyz/docs/operator-guide/wallets/funding-mode)              | Immediate and Deferred (Stellar)      |
| [Rail wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/rail-wallets)              | Wallets on chains the app does not show |
| [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains)                          | Enable Stellar, Solana, Polygon       |
| [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship)                | Who pays the fee, per chain           |
| [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines)  | Stellar assets, SPL mints, ERC-20s    |
| [Transaction Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/transaction-policy)  | Restrict sensitive Stellar operations |
| [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy)                | Soroban authorization allowlist       |

**Ramps**

| <br /> | <br /> |
| ------ | ------ |
| [Providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers)       | Fiat on/off-ramp providers and corridors |
| [Transactions](https://docs.pollar.xyz/docs/operator-guide/ramps/transactions) | Every ramp order and its settlement chain |

**Cards**

| <br /> | <br /> |
| ------ | ------ |
| [Providers](https://docs.pollar.xyz/docs/operator-guide/cards/providers)       | Card providers, label and redirect URL |
| [Card holders](https://docs.pollar.xyz/docs/operator-guide/cards/card-holders) | Your users' cards                     |

**Treasury**

| <br /> | <br /> |
| ------ | ------ |
| [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap)                             | Swap venues exposed to users (Stellar) |
| [Earn](https://docs.pollar.xyz/docs/operator-guide/treasury/earn)                             | Yield providers (DeFindex, Blend)     |
| [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution) | Claimable distribution rules          |

**Integrations**

| <br /> | <br /> |
| ------ | ------ |
| [Authentication](https://docs.pollar.xyz/docs/operator-guide/integrations/authentication) | OAuth providers and email OTP (upcoming) |
| [KYC](https://docs.pollar.xyz/docs/operator-guide/integrations/kyc)                        | Identity-verification providers (upcoming) |
| [Pollar Pay](https://docs.pollar.xyz/docs/operator-guide/integrations/pollar-pay)          | Pollar Pay integration (upcoming)     |

**Monitor**

| <br /> | <br /> |
| ------ | ------ |
| [Transactions](https://docs.pollar.xyz/docs/operator-guide/monitor/transactions) | On-chain transactions, per chain      |
| [Logs](https://docs.pollar.xyz/docs/operator-guide/monitor/logs)                 | API request and delivery logs         |
| [SDK versions](https://docs.pollar.xyz/docs/operator-guide/monitor/sdk-versions) | Which SDK builds your users run       |
| [Alerts](https://docs.pollar.xyz/docs/operator-guide/monitor/alerts)             | Low-balance notifications (upcoming)  |

**Danger Zone**

| <br /> | <br /> |
| ------ | ------ |
| [Archive app](https://docs.pollar.xyz/docs/operator-guide/danger-zone/archive-app) | Archive / unarchive the app (owner only) |

---

## Guides

| <br />                                                   | <br />                                    |
| -------------------------------------------------------- | ----------------------------------------- |
| [Deferred Flow Guide](https://docs.pollar.xyz/docs/guides/deferred-flow-guide) | KYC-gated wallet activation with webhooks |
| [Passkeys Guide](https://docs.pollar.xyz/docs/guides/passkeys-guide)           | Biometric auth with Face ID and Touch ID  |
| [Payments UI](https://docs.pollar.xyz/docs/guides/payments-ui)                 | Send, receive, and history components, on Stellar and Solana |
| [Swaps](https://docs.pollar.xyz/docs/guides/swaps-guide)                       | Asset swaps: pre-built modal or headless  |
| [Custom Wallet Adapter](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter) | Bring your own signer                 |
| [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist)     | Everything to verify before going live    |
