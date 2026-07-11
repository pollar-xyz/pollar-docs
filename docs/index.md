---
title: "Pollar Documentation"
---

**Pollar** is the onboarding-to-payment infrastructure layer for consumer apps on Stellar. The full stack from social login to USDC payments — without exposing users to blockchain complexity.

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
| [Funding Modes](https://docs.pollar.xyz/docs/core-concepts/funding-modes)             | Immediate and Deferred wallet activation                |
| [Stellar Primitives](https://docs.pollar.xyz/docs/core-concepts/stellar-primitives)   | Fee-bumps, reserves, trustlines, SEP-10, SEP-24         |
| [Security Model](https://docs.pollar.xyz/docs/core-concepts/security-model)           | AWS KMS, Passkeys, BYOK, and MPC                        |
| [Transaction History](https://docs.pollar.xyz/docs/core-concepts/transaction-history) | Two-layer history architecture and pagination           |

---

## SDK Reference

| <br />                                               | <br />                                          |
| ---------------------------------------------------- | ----------------------------------------------- |
| [@pollar/react](https://docs.pollar.xyz/docs/sdk-reference/pollar-react)   | Hooks and pre-built UI components               |
| [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)     | Full TypeScript client API                      |
| [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters) | External + embedded wallet login (Stellar Wallets Kit, Privy) |
| [Pollar Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) | REST endpoints for backend use                  |
| [Webhooks](https://docs.pollar.xyz/docs/sdk-reference/webhooks)            | Events, HMAC authentication, and retry behavior |
| [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes)      | All error codes with causes and fixes           |
| [MCP Gateway](https://docs.pollar.xyz/docs/sdk-reference/mcp-gateway)      | MCP / AI-agent access via Personal Access Tokens |

---

## Operator Guide

The sections below mirror the Dashboard sidebar: **Overview · Build · Users · Treasury · Integrations · Monitor · Danger Zone**. Start with the [Dashboard Overview](https://docs.pollar.xyz/docs/operator-guide/dashboard-overview).

**Overview**

| <br /> | <br /> |
| ------ | ------ |
| [Home](https://docs.pollar.xyz/docs/operator-guide/overview/home)                 | Your app at a glance                  |
| [Get started](https://docs.pollar.xyz/docs/operator-guide/overview/get-started)   | Onboarding checklist                  |

**Build**

| <br /> | <br /> |
| ------ | ------ |
| [Settings](https://docs.pollar.xyz/docs/operator-guide/build/settings)   | App name and general configuration    |
| [API Keys](https://docs.pollar.xyz/docs/operator-guide/build/api-keys)   | Generate and manage keys              |
| [Domains](https://docs.pollar.xyz/docs/operator-guide/build/domains)     | Allowed origins for SDK requests      |
| [Webhooks](https://docs.pollar.xyz/docs/operator-guide/build/webhooks)   | Event delivery endpoints (upcoming)   |
| [Branding](https://docs.pollar.xyz/docs/operator-guide/build/branding)   | Customize the Pollar modals           |
| [Members](https://docs.pollar.xyz/docs/operator-guide/build/members)     | Team access (owner only)              |

**Users**

| <br /> | <br /> |
| ------ | ------ |
| [Accounts](https://docs.pollar.xyz/docs/operator-guide/users/accounts)   | Browse and manage app users           |
| [Wallets](https://docs.pollar.xyz/docs/operator-guide/users/wallets)     | Browse and manage user wallets        |

**Treasury**

| <br /> | <br /> |
| ------ | ------ |
| [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/treasury/tokens-trustlines) | Configure assets for user wallets |
| [Funding Mode](https://docs.pollar.xyz/docs/operator-guide/treasury/funding-mode)             | Immediate and Deferred (set on Account Funding) |
| [Account Funding](https://docs.pollar.xyz/docs/operator-guide/treasury/account-funding)       | Your funding (reserve) wallet     |
| [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/treasury/sponsorship)               | Transaction fee sponsorship       |
| [Transaction Policy](https://docs.pollar.xyz/docs/operator-guide/treasury/transaction-policy) | Restrict sensitive operations (account merge, max fee) |
| [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/treasury/auth-policy)               | Soroban authorization allowlist   |
| [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap)                             | Swap venues exposed to users      |
| [Earn](https://docs.pollar.xyz/docs/operator-guide/treasury/earn)                             | Yield providers (DeFindex, Blend) |
| [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution) | Claimable distribution rules      |

**Integrations**

| <br /> | <br /> |
| ------ | ------ |
| [Authentication](https://docs.pollar.xyz/docs/operator-guide/integrations/authentication) | OAuth providers and email OTP (upcoming) |
| [KYC](https://docs.pollar.xyz/docs/operator-guide/integrations/kyc)                        | Identity-verification providers (upcoming) |
| [Ramps](https://docs.pollar.xyz/docs/operator-guide/integrations/ramps)                    | Fiat on/off-ramp providers        |
| [Pollar Pay](https://docs.pollar.xyz/docs/operator-guide/integrations/pollar-pay)          | Pollar Pay integration            |

**Monitor**

| <br /> | <br /> |
| ------ | ------ |
| [Transactions](https://docs.pollar.xyz/docs/operator-guide/monitor/transactions) | On-chain transaction log             |
| [Logs](https://docs.pollar.xyz/docs/operator-guide/monitor/logs)                 | API request and delivery logs        |
| [Alerts](https://docs.pollar.xyz/docs/operator-guide/monitor/alerts)             | Low-balance notifications (upcoming) |

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
| [Payments UI](https://docs.pollar.xyz/docs/guides/payments-ui)                 | Send, receive, and history components     |
| [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist)     | Everything to verify before going live    |
