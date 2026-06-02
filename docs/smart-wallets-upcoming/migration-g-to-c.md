---
title: "Migrating from G-Addresses to C-Addresses"
---

> 🚧 **Upcoming — not yet available.** Smart wallets (`walletType: 'smart'`) are not implemented in the current SDK yet. This page documents the planned migration path. See the [section overview](./overview) for status.

If you're already onboarding users with Pollar's classic flow (G-addresses), moving to smart
wallets (C-addresses) is a one-line configuration change for the common case. This guide
covers that change, what stays the same, and the edge cases worth knowing about.

## TL;DR

```diff
  const pollar = new PollarClient({
    apiKey: process.env.POLLAR_API_KEY!,
    stellarNetwork: 'testnet',
-   // walletType defaults to 'classic'
+   walletType: 'smart',
  });
```

Your `login()` call, your session handling, and your payment calls keep the same shape.
Pollar absorbs the differences between account types internally.

## What stays the same

- **The SDK surface.** `login()`, the session object, and `pay()` have the same signatures.
- **Key custody.** Keys remain server-side via KMS. Users still never handle seed phrases.
- **Fee sponsorship.** Pollar still pays the user's fees; you don't fund users manually.
- **Your auth providers.** The same social login providers work unchanged.

## What changes

### 1. The address format

A user's `wallet.address` now starts with `C` instead of `G`. If you store or display
addresses, make sure your validation and UI don't assume a `G` prefix.

```typescript
// Before: always G...
// After:  G... (classic) or C... (smart)
const isSmart = wallet.type === 'smart';
```

### 2. The wallet state shape

The session wallet carries a `type` discriminator:

```typescript
type WalletType = 'classic' | 'smart';

interface PollarWallet {
  type: WalletType; // discriminator
  address: string;  // G-address or C-address
  status: 'pending' | 'active';
}
```

Branch on `wallet.type` if any of your code paths depend on account semantics.

### 3. Onboarding produces contract transactions

Classic onboarding creates an account and (optionally) trustlines. Smart onboarding deploys a
contract and extends its TTL. If you surface onboarding progress, the lifecycle states are
different — see the [lifecycle explainer](./c-address-lifecycle.md). The progress event is the
same `walletProgress` event; only the status values differ.

### 4. Assets use the SAC, not trustlines

C-addresses don't use classic trustlines. They hold assets through the **Stellar Asset
Contract (SAC)**. Pollar handles this for you — `pay()` works the same — but if you query
balances directly, you query the SAC rather than account trustlines.

## Coexistence: running both at once

You can run classic and smart users side by side. `walletType` is set per client instance, so
you can migrate a subset of users or offer both:

```typescript
function makeClient(useSmartWallet: boolean) {
  return new PollarClient({
    apiKey: process.env.POLLAR_API_KEY!,
    stellarNetwork: 'testnet',
    walletType: useSmartWallet ? 'smart' : 'classic',
  });
}
```

Existing G-address users are unaffected. There is no in-place "upgrade" of a G-address into a
C-address — they are different account types. New users onboarded with `walletType: 'smart'`
get C-addresses; existing users keep theirs.

## Migration checklist

- [ ] Set `walletType: 'smart'` on the client (for new smart-wallet users)
- [ ] Remove any `G`-prefix assumptions in address validation/UI
- [ ] Handle `wallet.type` wherever account semantics matter
- [ ] If you render onboarding progress, map the new lifecycle states
- [ ] If you read balances directly, switch to SAC balance queries
- [ ] Test the full flow on testnet before enabling for users

## When to stay on G-addresses

Smart wallets add programmable authorization and a smoother fee/rent model, but they aren't
required for every app. If your product only needs classic payments and has no need for
contract-level account logic, the classic flow remains fully supported.

## Next steps

- [C-Address Quickstart](./quickstart-c-address.md)
- [How the C-Address Lifecycle Works](./c-address-lifecycle.md)
