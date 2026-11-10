---
title: "Transactions"
---

**Dashboard > Cash in and out > Transactions** · Chains: Stellar, Solana, Polygon

The ramp transactions your users started with SDKs older than 0.12 (SDK API v2). Ramps opened with `@pollar/core` 0.12 or later, or with `/v3/ramps`, are under [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders). On v2, starting a new ramp answers `410 SDK_RAMPS_MOVED_TO_V3`, so this list only follows the transactions already open.

Ramps that Pollar is reviewing are listed at the top of the page.

---

## Transactions under review by Pollar

Ramps that could not be settled automatically and that Pollar is reviewing. Each shows its transaction ID, the method (for example Buy, Bolivia, QR), the amounts and the date it went into review. No action is needed from you: Pollar resolves them and the entry updates once it is resolved. Share the transaction ID with your user if they ask. The section is hidden while there are none.

---

## The list

| Column | Description |
| --- | --- |
| **Date** | When the transaction was opened |
| **User** | The user who opened it |
| **Type** | On-ramp or Off-ramp |
| **Method** | The country and the payment method, for example Bolivia, QR |
| **Amount** | The fiat amount and currency, and the crypto amount and asset once known |
| **Network** | The chain |
| **Tx hash** | The on-chain settlement, once it exists |
| **Status** | `Created`, `Pending`, `Awaiting payment`, `Processing`, `Settling on-chain`, `Completed`, `Failed`, `Refunded`, plus **In review** when Pollar is reviewing it |

Filter by type (**All**, **On-ramp**, **Off-ramp**). The list is paginated.

---

## Related

- [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders): ramp orders from SDK 0.12 and the Server API
- [Countries and methods](https://docs.pollar.xyz/docs/operator-guide/ramps/methods): the countries and payment methods your users can use
