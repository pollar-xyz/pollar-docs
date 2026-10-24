---
title: "Orders"
---

**Dashboard > Ramps > Orders** · Chains: Stellar, Solana, Polygon

Your app's ramp orders, newest first: the orders your users open with `@pollar/core` 0.12 or later, and the ones your server opens with `/v3/ramps`. Each order runs its legs one at a time; when one stops, the order says at which leg, why, and who resolves it. Orders from SDKs older than 0.12 are under [Transactions](https://docs.pollar.xyz/docs/operator-guide/ramps/transactions).

---

## The list

| Column | Description |
| --- | --- |
| **Created** | When the order was opened |
| **Type** | Buy or Sell, and the provider |
| **State** | For example awaiting payment, processing, completed, failed, refunded |
| **Legs** | One badge per leg (Provider, Swap, Bridge), colored by its status |
| **Needs** | Who has to act when the order stopped (Pollar, your app, your user, the provider), or what it is waiting for (for example a fiat payment or a signature) |

Filter by state: **All**, **awaiting payment**, **processing**, **completed**, **failed**.

---

## Order detail

Click an order to open it. The detail shows the order id (with a copy button), the user, when it was created and last updated, and each leg:

- its kind and path (`USDT on Polygon -> USDC on Polygon`), and its status (for example ACTIVE, AWAITING_ACTION, COMPLETED, HELD, FAILED)
- the amounts in and out, marked **(planned)** until the leg has run
- how it was signed (co-signed, external, self-custody, app custody)
- its on-chain transaction hash, once there is one

### When an order stops

A card says **Stopped at leg N** with the failure code, who resolves it and what to do:

| Who | Typical action |
| --- | --- |
| **Your user** | Quote again and accept the new price, add funds, add the USDC trustline, approve or sign the leg again, finish identity verification, or start a new order |
| **Your app** | Fund the app's gas wallet, or enable the signing mode the route needs (see [Signing](https://docs.pollar.xyz/docs/operator-guide/ramps/signing)) |
| **Pollar** | Contact Pollar with the order id (shown on the card), or wait while Pollar confirms the funds on-chain |
| **The provider** | Wait for the provider |

Temporary failures are retried by Pollar on its own.

When your app may retry, the detail shows **Retry from this leg**. The retry continues the order from the leg that stopped; if the order has moved on in the meantime, the retry is refused and you reload the order.

---

## Related

- [Routes](https://docs.pollar.xyz/docs/operator-guide/ramps/routes): the paths these orders follow
- [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets#rail-wallets): rail wallets that hold funds between two legs
- [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps): how an order runs
