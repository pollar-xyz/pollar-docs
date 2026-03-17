---
title: "Distribution Wallet"
---

**Dashboard → Wallet Infrastructure → Distribution Wallet**

Controls the behavior of `fund()` — the SDK method that sends assets from your app's distribution wallet to a user wallet.

---

## Configured assets

Add the assets you want to distribute via `fund()`. Only listed assets can be requested — calling `fund({ asset: 'USDC' })` with an unconfigured asset throws `FUND_ASSET_NOT_CONFIGURED`.

For each asset, configure:

| Setting | Description |
|---|---|
| **Amount per call** | How much is sent each time `fund()` is called |
| **Daily limit** | Maximum a single wallet can receive per day |
| **Weekly limit** | Maximum a single wallet can receive per week |
| **Monthly limit** | Maximum a single wallet can receive per month |

---

## Default asset

`fund()` called without arguments sends XLM. XLM is always available as a default — no configuration required.

```typescript
await fund();            // sends XLM
await fund({ asset: 'USDC' }); // sends USDC if configured
```

---

## Mainnet

`fund()` is disabled on mainnet by default. Enable it explicitly by toggling **Allow fund() on mainnet** in this section.

Calling `fund()` on mainnet without this setting enabled throws `FUND_NOT_ENABLED_ON_MAINNET`.

---

## Funding the distribution wallet

Send assets directly to the distribution wallet's G-address or use the **Fund wallet** button in [App Wallets](../configuration/app-wallets.md).