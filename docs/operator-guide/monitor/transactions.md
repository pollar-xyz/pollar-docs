---
title: "Transactions"
---

**Dashboard → Monitor → Transactions** · Chains: Stellar, Solana, Polygon

A real-time view of all on-chain transactions across your app, on every chain. Each row shows its own chain, fee unit and explorer.

---

## Transaction list

| Column | Description |
|---|---|
| **Tx hash** | The transaction hash, linked to its chain's explorer: stellar.expert, explorer.solana.com, polygonscan |
| **Chain** | Stellar, Solana or Polygon |
| **Type** | `payment`, `activation`, `trustline`, `receive`, ... |
| **Asset** | Asset code (a Stellar asset, an SPL token, an ERC-20) |
| **Amount** | Transaction amount |
| **From / To** | The addresses involved on that chain |
| **Fee** | The network fee in the chain's own unit: stroops / XLM on Stellar, **lamports** on Solana, wei / POL on Polygon, and whether your GAS wallet paid it |
| **Ledger / slot** | Stellar ledger number, Solana slot, Polygon block |
| **Timestamp** | Confirmation time |

Filter by type, asset, date range, or wallet ID. Export as CSV.

---

## Transaction detail

Click any transaction to see the full details, including the raw transaction (the Stellar XDR envelope, or the serialized Solana transaction) and a link to the chain's explorer for on-chain verification.