---
title: "Earn"
---

**Dashboard > Treasury > Earn** · Chains: Stellar

Let your users deposit into yield vaults (DeFindex) and lending pools (Blend), signing with their Pollar wallet. **If nothing is enabled, the Earn UI is hidden for your users.** DeFindex and Blend settle on Stellar, so Earn applies to the user's Stellar wallet; see [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support).

---

## Vaults & pools

The **Vaults & pools** card lists the individual DeFindex vaults and Blend pools available on your app's network. Turn on the ones you want your users to see; all are off by default. Only the enabled vaults and pools are offered in the SDK.

## DeFindex API key

Optional per-app key. Without one, DeFindex uses the platform key. The key is stored encrypted, server side only; **Save key**, **Update key** and **Remove key** manage it.

---

## In the SDK

The vaults and pools enabled here drive the client SDK:

- `getEarnProviders()` -> enabled providers (empty = Earn disabled)
- `getEarnOpportunities(provider)` -> vaults/pools with live APY
- `getEarnPosition(params)` -> the wallet's position
- `earnDeposit(params)` / `earnWithdraw(params)` -> move funds
- `openEarnModal()` (`@pollar/react`) -> the pre-built Earn modal

See [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) and [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react).
