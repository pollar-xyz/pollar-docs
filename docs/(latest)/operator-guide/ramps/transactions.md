---
title: "Transactions"
---

**Dashboard > Ramps > Transactions** · Chains: Stellar, Solana, Polygon

The ramp transactions your users started with SDKs older than 0.12 (SDK API v2). Ramps opened with `@pollar/core` 0.12 or later, or with `/v3/ramps`, are under [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders). On v2, starting a new ramp answers `410 SDK_RAMPS_MOVED_TO_V3`, so this list only follows the transactions already open.

---

## The list

| Column | Description |
| --- | --- |
| **Date** | When the transaction was opened |
| **User** | The user who opened it |
| **Type** | On-ramp or Off-ramp |
| **Provider** | The ramp provider that handled it |
| **Amount** | The fiat amount and currency, and the crypto amount and asset once known |
| **Route** | Country, rail and chain |
| **Tx hash** | The on-chain settlement, once it exists |
| **Status** | `Created`, `Pending`, `Awaiting payment`, `Processing`, `Settling on-chain`, `Completed`, `Failed`, `Refunded`, plus **In review** when Pollar is reviewing it |

Filter by type (**All**, **On-ramp**, **Off-ramp**). The list is paginated.

---

## Related

- [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders): ramp orders from SDK 0.12 and the Server API
- [Providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers): transactions under review by Pollar are also listed there
