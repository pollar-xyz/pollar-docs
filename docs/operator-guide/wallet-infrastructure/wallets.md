---
title: "Wallets"
---

**Dashboard → Wallet Infrastructure → Wallets**

Browse and manage all user wallets created through your app.

---

## Wallet list

The wallet list shows every wallet associated with your app:

| Column | Description |
|---|---|
| **Wallet ID** | Pollar wallet ID (`wal_...`) |
| **G-address** | Stellar address — links to Stellar Expert |
| **User** | Associated user email or ID |
| **Status** | `pending` or `active` |
| **Balances** | Current asset balances |
| **Created** | Creation timestamp |

Filter by status, search by user email or wallet ID.

---

## Activating a wallet manually

In Deferred or Manual mode, wallets start with `pending` status. To activate from the Dashboard:

1. Find the wallet in the list
2. Click **Activate**
3. Confirm — the XLM reserve is funded from your funding wallet

The wallet moves to `active` status within ~2 seconds.

---

## Wallet detail

Click any wallet to see:

- Full transaction history
- Current balances per asset
- Activation timestamp
- Associated user
- Link to Stellar Expert for on-chain verification