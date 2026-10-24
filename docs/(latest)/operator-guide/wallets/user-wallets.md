---
title: "Wallets"
---

**Dashboard → Wallets → Wallets** · Chains: Stellar, Solana, Polygon

Browse and manage all user wallets created through your app, on every chain it enables. A user has one wallet per enabled chain, so the same user appears once per chain.

---

## Wallet list

The wallet list shows every wallet associated with your app:

| Column | Description |
|---|---|
| **Address** | The wallet's address on its chain, linked to that chain's explorer: stellar.expert for Stellar, Solscan for Solana (devnet on a testnet app), Polygonscan for Polygon (Amoy on testnet) |
| **Network** | Stellar, Solana or Polygon; sortable |
| **User** | Associated user email or ID |
| **Custody** | **Pollar**, **Co-signed** (Turnkey 2-of-2), **External** (the user's own wallet) or **Passkey** (smart wallet); filterable |
| **Status** | **Active** (funded on-chain) or **Not funded**; sortable |
| **Balances** | Current native and token balances |
| **Tokens** | Stellar wallets show their trustlines; Solana and Polygon wallets show how many of the app's enabled tokens the wallet holds |
| **Created** | Creation timestamp |

Filter by status, network or custody, search by user email or address. Expanding a row shows the wallet's assets: trustlines with their state on Stellar, token accounts on Solana, token balances on Polygon.

---

## Funding a wallet manually

In Deferred mode, Stellar wallets start unfunded (**Not funded**). You can fund one from the Dashboard at any time:

1. Find the wallet in the list
2. Click **Fund 2 XLM** next to a **Not funded** wallet
3. The XLM reserve is funded from your funding wallet

The wallet moves to **Active** within ~2 seconds. (This is also the manual fallback for Immediate-mode wallets whose initial funding didn't complete.)

Solana wallets have no reserve to fund: they are topped up from the app's Solana GAS wallet according to the [top-up policy](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship) and receive their starting SOL from [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding).

---

## Wallet detail

Click any wallet to see:

- Full transaction history
- Current balances per asset
- Activation timestamp
- Associated user
- Link to Stellar Expert for on-chain verification