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
| [Overview](./docs/getting-started/overview)       | What Pollar is and the problem it solves        |
| [API Keys](./docs/getting-started/api-keys)       | Publishable vs secret keys, testnet vs mainnet  |
| [Quickstart](./docs/getting-started/quickstart)   | Install, configure, and send your first payment |
| [Example App](./docs/getting-started/example-app) | Clone and run a full working integration        |

---

## Core Concepts

| <br />                                                          | <br />                                                  |
| --------------------------------------------------------------- | ------------------------------------------------------- |
| [Architecture](./docs/core-concepts/architecture)               | How the SDK, Pollar Server, and Dashboard work together |
| [Funding Modes](./docs/core-concepts/funding-modes)             | Immediate, Deferred, and Manual wallet activation       |
| [Stellar Primitives](./docs/core-concepts/stellar-primitives)   | Fee-bumps, reserves, trustlines, SEP-10, SEP-24         |
| [Security Model](./docs/core-concepts/security-model)           | AWS KMS, Passkeys, BYOK, and MPC                        |
| [Transaction History](./docs/core-concepts/transaction-history) | Two-layer history architecture and pagination           |

---

## SDK Reference

| <br />                                               | <br />                                          |
| ---------------------------------------------------- | ----------------------------------------------- |
| [@pollar/react](./docs/sdk-reference/pollar-react)   | Hooks and pre-built UI components               |
| [@pollar/core](./docs/sdk-reference/pollar-core)     | Full TypeScript client API                      |
| [Pollar Server API](./docs/sdk-reference/server-api) | REST endpoints for backend use                  |
| [Webhooks](./docs/sdk-reference/webhooks)            | Events, HMAC authentication, and retry behavior |
| [Error Codes](./docs/sdk-reference/error-codes)      | All error codes with causes and fixes           |

---

## Operator Guide

| <br />                                                                                 | <br />                                                |
| -------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| [Dashboard Overview](./docs/operator-guide/dashboard-overview)                         | Navigation, get started checklist, testnet vs mainnet |
| [App Settings](./docs/operator-guide/configuration/app-settings)                       | App name, allowed origins, network                    |
| [App Wallets](./docs/operator-guide/configuration/app-wallets)                         | Funding, gas, and distribution wallets                |
| [Funding Mode](./docs/operator-guide/configuration/funding-mode)                       | Immediate, Deferred, and Manual                       |
| [API Keys](./docs/operator-guide/configuration/api-keys)                               | Generate, rotate, and manage keys                     |
| [Domains](./docs/operator-guide/configuration/domains)                                 | Allowed origins for SDK requests                      |
| [Branding & UI](./docs/operator-guide/configuration/branding-ui)                       | Customize the WalletButton modal                      |
| [Webhooks](./docs/operator-guide/configuration/webhooks)                               | Configure event delivery endpoints                    |
| [Alerts](./docs/operator-guide/configuration/alerts)                                   | Low-balance notifications                             |
| [Integrations](./docs/operator-guide/configuration/integrations)                       | SEP-24 fiat ramps and anchors                         |
| [Wallets](./docs/operator-guide/wallet-infrastructure/wallets)                         | Browse and manage user wallets                        |
| [Tokens / Trustlines](./docs/operator-guide/wallet-infrastructure/tokens-trustlines)   | Configure assets for user wallets                     |
| [Gas Sponsorship](./docs/operator-guide/wallet-infrastructure/gas-sponsorship)         | Transaction sponsorship rules                         |
| [Distribution Wallet](./docs/operator-guide/wallet-infrastructure/distribution-wallet) | Configure fund() behavior                             |
| [Users](./docs/operator-guide/user-management/users)                                   | Browse and manage app users                           |
| [Authentication](./docs/operator-guide/user-management/authentication)                 | OAuth providers and email OTP                         |
| [Transactions](./docs/operator-guide/observability/transactions)                       | On-chain transaction log                              |
| [Logs](./docs/operator-guide/observability/logs)                                       | API request and webhook delivery logs                 |

---

## Guides

| <br />                                                   | <br />                                    |
| -------------------------------------------------------- | ----------------------------------------- |
| [Deferred Flow Guide](./docs/guides/deferred-flow-guide) | KYC-gated wallet activation with webhooks |
| [Passkeys Guide](./docs/guides/passkeys-guide)           | Biometric auth with Face ID and Touch ID  |
| [Payments UI](./docs/guides/payments-ui)                 | Send, receive, and history components     |
| [Mainnet Checklist](./docs/guides/mainnet-checklist)     | Everything to verify before going live    |
