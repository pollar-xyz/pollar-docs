---
title: "Credits"
---

**Dashboard > Billing > Credits** · Chains: all (top-ups on several chains)

What Pollar charges this app for: wallets, sponsored reserves and fees, co-signing and the other paid features. **100 credits = 1 USD.** Credits belong to the app's network and never cross to the other one: a testnet app and its mainnet counterpart have separate balances. How billing works is explained in [Credits](https://docs.pollar.xyz/docs/core-concepts/credits).

---

## Apps on credits and apps on their own wallets

An app pays in one of two ways:

| Model | Who pays the on-chain costs |
| --- | --- |
| **Credits** | Pollar's pool pays reserves, fees, starting balances and top-ups, and charges the app's credits. |
| **Own wallets** | The app's funding and gas wallets pay, as described in [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding) and [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship). Nothing is charged in credits. |

An app on its own wallets sees the banner **This app still pays with its own wallets**. Any gift or bonus Pollar adds still shows on this page and is spent once the app moves to credits. Moving an app to credits is done by Pollar.

---

## Balance

| Card | What it is |
| --- | --- |
| **Available** | What the app can spend now, in credits and in USD |
| **Paid** | Top-ups. Transferable to another app |
| **Promo** | Gifts and bonuses. Spent first; not refundable |
| **Margin** | How far below zero the app can go |

Two banners can appear above the cards:

- **This app is below zero**: paid features keep working within the margin Pollar gave the app; once it runs out, they answer `402` until you top up.
- **A statement is overdue** (postpaid apps): new paid flows answer `402` until it is paid. A deposit pays the oldest open statement first.

In the SDK and the APIs these refusals are `402 SDK_CREDITS_INSUFFICIENT` and `402 SDK_BILLING_OVERDUE`.

---

## Top up

Send a stablecoin to the app's address on any of the chains listed; each address has a copy button. On mainnet each address takes USDC, and the Polygon and Solana ones also take USDT; on testnet every address takes Circle's test USDC only. The balance updates once the deposit confirms; 1 USD buys 100 credits, and only the official contracts are credited. Testnet charges the same prices as mainnet. See [Credits](https://docs.pollar.xyz/docs/core-concepts/credits) for the full table. The same addresses are available from the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) and the [MCP Gateway](https://docs.pollar.xyz/docs/sdk-reference/mcp-gateway).

---

## Usage and statements

- **Last 30 days**: what the app used, per billable event, with the count and the credits of each, and the total in credits and USD. An event with no price counts at 0.
- **Statements** (postpaid apps only): what the app used is billed once a month and due by the date on each statement. Each statement shows its period, usage, payments, due date, the credits still open and its status (open, paid, overdue).

---

## Low-balance alert

Pollar emails you once when the available credits drop below the amount you set, and again only after they went back above it. Set **Alert below (credits)** and **Send to** (comma-separated emails; empty sends it to the app owner), then **Save**. Members with write access can change it.

---

## Prices

What each operation costs the app in credits. A rule in the app's own contract (marked **your contract**) wins over the general price; an operation with no price is **free**.

---

## History

Every movement of the balance: date, type (**Charge**, **Top-up**, **Courtesy**, **Gift**, **Adjustment**, **Refund**, **Invoice payment**, **Transfer**), the event or reason, and the credits.
