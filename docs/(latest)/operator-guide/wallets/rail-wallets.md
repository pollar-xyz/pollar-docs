---
title: "Rail wallets"
---

**Dashboard → Wallets → Rail wallets** · Chains: Stellar, Solana, Polygon

Your users' wallets on chains this app does not show. A wallet lands here in two ways:

- a **ramp settled through it**: Stereum, for example, delivers on the user's Polygon wallet before the funds are bridged to Stellar or Solana, so an app that serves only Stellar still has Polygon wallets for its users;
- the app **switched the chain off** after the wallets existed (see [Disabling a chain](https://docs.pollar.xyz/docs/operator-guide/wallets/chains#disabling-a-chain)).

They belong to the user. Nothing in the app shows them, so money left there between two steps of a ramp surfaces on this page and nowhere else.

---

## The list

| Column | Description |
| --- | --- |
| **Address** | The wallet's address, with a link to its explorer on its own chain (stellar.expert, solscan, polygonscan) |
| **Chain** | Stellar, Solana or Polygon |
| **User** | The user's email or SDK user id |
| **Balances** | Native and token balances read live from the chain |
| **Created** | Creation timestamp |

Filter with **Only wallets with a balance** to see what is actually stranded. The page shows the 500 most recent rail wallets.

---

## Related

- [Ramp transactions](https://docs.pollar.xyz/docs/operator-guide/ramps/transactions): the ramp orders that moved funds through these wallets
- [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains): re-enabling a chain brings its wallets back into the app
