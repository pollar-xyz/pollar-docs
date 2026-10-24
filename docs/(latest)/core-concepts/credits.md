---
title: "Credits and Billing Models"
description: "How an app pays for the chain: with its own operator wallets, or with credits that Pollar's pool charges."
---

Running wallets costs money on-chain: account reserves, network fees, starting balances. An app pays for them under one of two **billing models**:

| | Own wallets (`LEGACY_WALLETS`) | Credits (`CREDITS`) |
| --- | --- | --- |
| Who pays fees, reserves and starting balances | The app's operator wallets (funding, gas, distribution), which Pollar signs for | Pollar's own wallets (the pool), which charge the app in credits |
| What the app keeps funded | XLM, SOL or POL in its wallets | A credit balance |
| Distribution claims pay from | The distribution (or global) wallet | The app's distribution vault |

**Billing > Credits** in the dashboard says which model the app is on. An app still on its own wallets sees "This app still pays with its own wallets": nothing is charged in credits yet, and any gift or bonus Pollar adds waits there until the app moves. Pollar moves an app to credits.

---

## Credits

**100 credits = 1 USD.** Credits belong to one app and one network: a testnet app's credits never cross to its mainnet pair. Testnet charges the same prices as mainnet, paid with testnet USDC.

| Balance | What it is |
| --- | --- |
| **Paid** | Top-ups. Transferable to another app. |
| **Promo** | Gifts and bonuses from Pollar. Spent first; not refundable. |
| **Margin** | How far below zero Pollar lets the app go. |
| **Available** | What the app can spend now. |

Every billable event (a wallet, a sponsored reserve or fee, a co-signed signature, a KYC check, a ramp leg, and so on) has a price in the app's price list, shown on **Billing > Credits > Prices**. An event with no price counts at 0.

### Topping up

Each app has deposit addresses on several chains. Send **USDC or USDT** to one of them; the balance updates once the deposit confirms. Read them in the dashboard, with `GET /v3/billing/deposit-addresses` on the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api), or from the MCP gateway.

### When credits run out

A paid flow answers **402 `SDK_CREDITS_INSUFFICIENT`** when the available credits do not cover it. The SDK shows the user a generic message pointing to the app's support (`appUnavailableMessage(error)` gives the text) and logs one warning for the developer. A flow the pool would pay for during login or session resume is skipped rather than refused.

Set a low-balance alert on **Billing > Credits**: Pollar emails you once when the available credits drop below the amount, and again only after they went back above it.

### Postpaid apps

A postpaid app is billed once a month for what it used. Each statement has a due date; while one is overdue, new paid flows answer **402 `SDK_BILLING_OVERDUE`**. A deposit pays the oldest open statement first.

---

## Distribution vault

On an app on credits, token distribution claims pay from the app's **distribution vault**: a Pollar-held balance per app. Pollar's pool pays the claim's network fee. The owner or an admin withdraws from the vault on **Billing > Distribution vault**, from the dashboard only, and always to the payout address Pollar has on file for the app: a withdrawal cannot name a destination, and no API key or token can start one. The Server API and the MCP gateway read the vault but cannot move it.

---

## Reading billing from code

| Surface | What it reads |
| --- | --- |
| Server API `/v3/billing` (SECRET key) | `credits`, `usage`, `statements`, `deposit-addresses`, `distribution-vault`. Read-only |
| MCP gateway | `get_application_credits`, `get_application_usage`, `get_application_statements`, `get_application_deposit_addresses`, `get_distribution_vault`. Read-only |
| SDK | `402` answers on paid flows, and `appUnavailableMessage` |

See [Credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits) and [Distribution vault](https://docs.pollar.xyz/docs/operator-guide/billing/distribution-vault) in the Operator Guide for the screens.
