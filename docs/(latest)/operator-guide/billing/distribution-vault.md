---
title: "Distribution vault"
---

**Dashboard > Billing > Distribution vault** · Chains: Stellar

The app's own wallet for the assets it distributes to users through [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution). What is in it belongs to the app. Pollar's pool pays the network fee of every withdrawal.

---

## The vault

The page shows the vault's Stellar address (with a copy button) and its balances, read from the network. Fund it by sending assets to that address. If the app has no vault on Stellar, the page says so.

---

## Withdraw

**Withdraw** sends an asset from the vault to the app's **payout wallet**:

1. Choose the **Asset** and enter the **Amount**.
2. Click **Withdraw**. The withdrawal is checked before it is sent (the payout wallet exists and holds the asset's trustline, and the vault holds the amount).

Rules:

- **Only the owner or an admin** can withdraw, from their dashboard session. There is no withdrawal with a SECRET key, a Personal Access Token, the Server API or the MCP Gateway.
- **The destination is always the payout wallet** Pollar set for the app. A withdrawal cannot name another address. Until Pollar has set it, withdrawals are not open; contact Pollar to set it.
- **Withdrawals are for apps on [credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits).** An app on its own wallets sees "Withdrawals are not open for this app"; contact Pollar to move it to credits.

---

## Withdrawals

Every withdrawal is listed from the moment it is asked for, with its asset, amount, destination, transaction hash and status (pending, confirmed or failed, with the reason).
