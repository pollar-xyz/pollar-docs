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
| **Status** | Compatibility status: `pending`, `processing`, `completed` or `failed`; enrolled transactions also expose the lifecycle described below |
| **Amount** | Fiat amount and currency, and the crypto amount and asset once known |
| **Country / Rail** | The fiat corridor and payment rail (Pix, SPEI, bank transfer, QR) |
| **Fee** | The provider's fee in its currency |
| **Chain** | The chain the order settles on: Stellar, Solana or Polygon |
| **Tx hash** | The on-chain settlement, linked to the chain's explorer once it exists |
| **Wallet** | The user wallet credited or debited |
| **Created** | When the order was opened |

Filter by direction (**All**, **On-ramp**, **Off-ramp**). Orders flagged **reconciliation required** need a look from Pollar's side; they stay visible here so you know the user is waiting.

The API's optional `lifecycleState` has seven states: `created`,
`awaiting_payment`, `processing`, `settling_onchain`, `completed`, `failed` and
`refunded`. It is separate from the four-value compatibility `status`;
`refunded` projects to `failed` there. Legacy records may have no lifecycle.
`reconciliationRequired` is a separate flag, not an additional state. A reported
transaction hash or provider success alone does not prove final settlement;
intermediary bridge hashes must be distinguished from the customer payment.

---

## Related

- [Ramp providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers): which providers and corridors are enabled
- [Rail wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/rail-wallets): funds parked on an intermediate chain between two steps of a ramp
- [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support): which providers settle on Solana
