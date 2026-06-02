---
title: "Smart Wallets (C-Addresses)"
---

> 🚧 **Upcoming — not yet available.** Smart wallets are on the Pollar roadmap. The `walletType: 'smart'` option, the `pollar.pay()` call, and the `walletProgress` lifecycle events described in this section are **not implemented in the current SDK yet**. These pages document the planned design so you can prepare your integration. The classic flow (G-addresses) documented elsewhere is the supported path today.

**Smart wallets** let you onboard users to a Stellar **smart contract account** — a *C-address* — instead of a classic ed25519 account (a *G-address*). The account's authorization logic lives in a Soroban contract rather than in a fixed signature scheme, which unlocks programmable authorization and a smoother fee/rent model.

The promise is that adopting them is a **configuration choice, not a rewrite**: the same `login()` call, the same session object, and the same payment API. You opt in with a single client option:

```typescript
const pollar = new PollarClient({
  apiKey: process.env.POLLAR_API_KEY!,
  stellarNetwork: 'testnet',
  walletType: 'smart', // ← opt into C-addresses (default is 'classic')
});
```

## In this section

| <br />                                                          | <br />                                                       |
| --------------------------------------------------------------- | ------------------------------------------------------------ |
| [C-Address Quickstart](./quickstart-c-address)                  | Social login through to a payment-ready smart wallet         |
| [Migrating from G-Addresses](./migration-g-to-c)                | What changes (and what doesn't) when you switch account types |
| [How the C-Address Lifecycle Works](./c-address-lifecycle)      | Deploy, rent/TTL, the SAC, and auth-entry signing under the hood |

## How it differs from classic accounts at a glance

| Aspect           | G-address (classic, available today) | C-address (smart wallet, upcoming) |
| ---------------- | ------------------------------------ | ---------------------------------- |
| Identifier       | Starts with `G`                      | Starts with `C`                    |
| Authorization    | Native ed25519 signature             | `__check_auth` in the contract     |
| Creation         | `createAccount` operation            | `InvokeHostFunction` (contract deploy) |
| Holding an asset | `changeTrust` trustline              | SAC balance (no classic trustline) |
| Keeping it alive | XLM reserve (one-time)               | Storage rent + TTL (recurring)     |

See [How the C-Address Lifecycle Works](./c-address-lifecycle) for the full breakdown.
