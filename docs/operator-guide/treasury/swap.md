---
title: "Swap"
---

**Dashboard → Treasury → Swap**

Choose which swap venues your users can use to exchange one asset for another.

---

## Enabled venues

Enable one or more DEX / AMM venues. **If none are enabled, the swap UI is hidden for your users** — `getSwapConfig()` returns an empty list and the SDK hides the swap surface.

---

## Buy tokens

Extra tokens your users can swap **into**, on top of your enabled assets. The catalog is curated by the platform; enable the ones you want to expose.

---

## In the SDK

The venues and tokens configured here drive the client SDK:

- `getSwapConfig()` → enabled venues (empty = swap disabled)
- `getSwapTokens()` → the buy-token catalog
- `getSwapQuote(params)` / `swap(quote)` → quote and execute
- `openSwapModal()` (`@pollar/react`) → the pre-built swap modal

See [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) and [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react).
