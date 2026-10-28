---
title: "Swap"
---

**Dashboard > Treasury > Swap** · Chains: Stellar, Solana (mainnet)

Choose which swap venues your users can use to exchange one asset for another. On Stellar the venues are SDEX, Soroswap and Aquarius; on Solana they are the Jupiter and Titan aggregators, on a mainnet app only. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support).

---

## Enabled venues

Enable one or more venues per chain. **If none are enabled on a chain, the swap UI hides that chain**: `getSwapConfig()` (Stellar) or `getSolanaSwapConfig()` (Solana) returns an empty list. With venues on both chains, the swap modal shows a Network selector.

| Chain | Venues | Who can swap |
|---|---|---|
| Stellar | SDEX, Soroswap, Aquarius | Every wallet except passkey smart wallets |
| Solana | Jupiter, Titan | Co-signed and self-custody wallets (approved on the device) and external wallets (Phantom, Solflare, Backpack). Pollar-managed (custodial) Solana wallets cannot swap |

On Solana, Pollar builds each swap for the user's wallet and refuses a route whose simulation pays the user less than its minimum, so a quote can move a little between the price shown and the swap. A user buys SOL or one of your enabled Solana tokens.

---

## Buy tokens

Extra Stellar tokens your users can swap **into**, on top of your enabled assets. The catalog is curated by the platform; enable the ones you want to expose. On Solana the buy list is SOL plus your enabled Solana tokens.

---

## Sponsorship and billing

Which swaps your app pays the network fee for is set under [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship#swap-sponsorship). A confirmed swap is billed once, as a swap event.

---

## In the SDK

The venues and tokens configured here drive the client SDK:

- `getSwapConfig()` / `getSolanaSwapConfig()` -> enabled venues per chain (empty = no swap there)
- `getSwapTokens()` -> the Stellar buy-token catalog
- `getSwapQuote(params)` / `swap(quote)` -> quote and execute on Stellar
- `getSolanaSwapQuote(params)` / `swapSolana(quote)` -> quote and execute on Solana
- `openSwapModal()` (`@pollar/react`) -> the pre-built swap modal

See [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) and [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react).
