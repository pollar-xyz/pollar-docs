---
title: "Routes"
---

**Dashboard > Ramps > Routes** · Chains: Stellar, Solana, Polygon

Where your users' ramps can go right now, leg by leg. Routes come from the providers and corridors you enabled under [Providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers), and end only on the chains your app enables.

---

## Reading a route

Pick **Buy (on-ramp)** or **Sell (off-ramp)**. Each card is one fiat currency and one token on a chain (for example BOB to USDC on Stellar) and shows:

- the **preferred** path and its number of legs. For example: BOB paid by bank QR, a provider leg (Stereum) to USDT on Polygon, a swap to USDC on Polygon, then a bridge to USDC on Stellar
- the **fallback** paths, used when the preferred one cannot be quoted

A leg is one of three kinds:

| Leg | What it does |
| --- | --- |
| **provider** | The ramp provider takes fiat and delivers a token (Buy), or takes a token and pays out fiat (Sell) |
| **swap** | Exchanges one token for another on the same chain |
| **bridge** | Moves a token to another chain (Circle CCTP for USDC) |

The fewest legs win; the others are fallbacks. The number of legs per route is capped (shown at the bottom of the page, 4 by default).

Each leg is priced and timed when your user asks for a quote, so the page shows paths, not prices.

If no route is listed, enable a ramp provider under [Providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers); its routes show up as soon as it is on.

---

## Related

- [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps): orders, legs and who signs each one
- [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders): the orders that ran on these routes
- [Signing](https://docs.pollar.xyz/docs/operator-guide/ramps/signing): a route that needs a signing mode your app does not have is not offered
