---
title: "App Wallets"
---

**Dashboard → Configuration → App Wallets**

App Wallets are the Stellar accounts that Pollar uses to cover costs on behalf of your users. Each wallet has a distinct role.

---

## The three wallets

| Wallet                  | Role                                                         | Charged when               |
| ----------------------- | ------------------------------------------------------------ | -------------------------- |
| **Funding wallet**      | Covers the XLM reserve required to activate new user wallets | Once per wallet activation |
| **Gas wallet**          | Pays transaction fees for all on-chain operations            | Every transaction          |
| **Distribution wallet** | Sends assets to users via `fund()`                           | Every `fund()` call        |

By default a single wallet is created when you create your app and covers all three roles. You can configure separate wallets for each role as your app scales.

---

## Funding a wallet

### Option 1 — Send directly to the G-address

Copy the wallet's Stellar G-address and send XLM or assets from any Stellar wallet or exchange.

### Option 2 — Fund from the Dashboard

Click **Fund wallet** in the Dashboard, connect your Stellar wallet, and send funds with a single click.

---

## Recommended minimum balances

| Wallet              | Recommended minimum                                       |
| ------------------- | --------------------------------------------------------- |
| Funding wallet      | 50 XLM (\~25 wallet activations with 2 assets each)       |
| Gas wallet          | 10 XLM                                                    |
| Distribution wallet | Depends on configured assets and expected `fund()` volume |

Configure low-balance alerts in [Alerts](./alerts.md) so you are notified before running out of funds.

---

## XLM reserve cost per wallet activation

The cost to activate a user wallet depends on how many assets are configured in [Tokens / Trustlines](../wallet-infrastructure/tokens-trustlines):

`1 XLM + (number of configured assets × 0.5 XLM)`

| Assets configured    | Reserve required |
| -------------------- | ---------------- |
| 0                    | 1 XLM            |
| 1 (e.g. USDC)        | 1.5 XLM          |
| 2 (e.g. USDC + EURC) | 2 XLM            |
| 3                    | 2.5 XLM          |

Pollar does not charge extra — the full amount is consumed from your funding wallet.

> References: [Minimum Balance](https://developers.stellar.org/docs/learn/fundamentals/lumens#minimum-balance) · [Trustlines](https://developers.stellar.org/docs/learn/fundamentals/stellar-data-structures/accounts#trustlines)
