---
title: "Transactions"
---

**Dashboard → Ramps → Transactions** · Chains: Stellar, Solana, Polygon

Every ramp order your users opened, on-ramp and off-ramp, with its provider, status and settlement chain. Use it to answer "where is this user's money" without opening the provider's own console.

---

## The list

| Column | Description |
| --- | --- |
| **Provider** | The ramp provider that handles the order (Bridge, Etherfuse, Stereum, PagFinance, Abroad, Anclap) |
| **User** | Email or name of the user who opened the order |
| **Direction** | On-ramp (fiat in, crypto out) or Off-ramp |
| **Status** | `Created`, `Pending`, `Awaiting payment`, `Processing`, `Settling on-chain`, `Completed`, `Failed`, `Refunded` |
| **Amount** | Fiat amount and currency, and the crypto amount and asset once known |
| **Country / Rail** | The fiat corridor and payment rail (Pix, SPEI, bank transfer, QR) |
| **Fee** | The provider's fee in its currency |
| **Chain** | The chain the order settles on: Stellar, Solana or Polygon |
| **Tx hash** | The on-chain settlement, linked to the chain's explorer once it exists |
| **Wallet** | The user wallet credited or debited |
| **Created** | When the order was opened |

Filter by direction (**All**, **On-ramp**, **Off-ramp**). Orders flagged **reconciliation required** need a look from Pollar's side; they stay visible here so you know the user is waiting.

---

## Related

- [Ramp providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers): which providers and corridors are enabled
- [Rail wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/rail-wallets): funds parked on an intermediate chain between two steps of a ramp
- [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support): which providers settle on Solana
