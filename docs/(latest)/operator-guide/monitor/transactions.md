---
title: "Transactions"
---

**Dashboard > Monitor > Transactions** · Chains: Stellar, Solana, Polygon

The outgoing transactions originated by your app and its users, on every chain.

---

## Transaction list

| Column | Description |
|---|---|
| **Hash** | The transaction hash, with a link to its chain's explorer |
| **Operation** | What the transaction does: `payment`, `create_account`, `change_trust`, `path_payment_strict_send` or `invoke_contract`, with a summary |
| **User** | The user who originated it |
| **Wallet** | The wallet that signed it, with a link to it in [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets) |
| **Blockchain** | Stellar, Solana or Polygon |
| **Status** | The transaction's phase: `BUILDING`, `BUILT`, `SIGNING`, `SIGNED`, `SUBMITTING`, `SUBMITTED`, `SUCCESS` or `FAILED` (with the phase it failed at) |
| **Fee** | The network fee with its unit, as the chain reports it |
| **Date** | When it was recorded |

Filter by **Status** and **Operation**, and search by hash or public key. **Live** keeps the list updating as new transactions arrive.

---

## Transaction details

Click a transaction to open its details:

- for a contract call: the contract, method or host function, and the arguments
- the error, and the contract error when there is one
- the transaction envelopes (unsigned and signed XDR), with copy buttons
- the raw details as JSON
