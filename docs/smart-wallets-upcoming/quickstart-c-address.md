---
title: "C-Address Quickstart"
---

> 🚧 **Upcoming — not yet available.** The `walletType: 'smart'` option, `pollar.pay()`, and the `walletProgress` events below are not implemented in the current SDK yet. This page documents the planned flow. See the [section overview](./overview) for status.

This guide takes you from zero to a **payment-ready smart wallet** on Stellar. The user signs
in with a social provider and Pollar handles the rest: deploying the contract account
(C-address), sponsoring fees, and reaching a state where the wallet can send and receive
assets. The user never sees a seed phrase or manages a private key.

> **Already using Pollar with G-addresses?** See the [Migration Guide](./migration-g-to-c.md).
> For how the lifecycle works under the hood, see the [C-Address Lifecycle](./c-address-lifecycle.md).

## What you'll build

A login flow that ends with a deployed C-address, verifiable on Stellar Expert.

## 1. Install

```bash
npm install @pollar/core
```

## 2. Initialize the client

The only difference from classic onboarding is `walletType: 'smart'`. Everything else stays
the same. Both `testnet` and `mainnet` are supported; this guide uses `testnet`.

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: process.env.POLLAR_API_KEY!,
  stellarNetwork: 'testnet',
  walletType: 'smart', // ← opt into C-addresses
});
```

If you omit `walletType`, the client defaults to `'classic'` (G-addresses) and behaves
exactly as before. Smart wallets are fully opt-in.

## 3. Log the user in

`login()` runs the full lifecycle: authenticate, deploy the contract, sponsor fees, and
settle into `payment_ready`. Keys are managed server-side via KMS.

```typescript
const session = await pollar.login({ provider: 'google' });

console.log(session.wallet);
// {
//   type: 'smart',
//   address: 'C...',        // the C-address
//   status: 'active',       // 'active' once payment_ready
// }
```

## 4. (Optional) Follow the lifecycle in your UI

To show progress, subscribe to lifecycle events. Each transition gives you the status and any
transaction hashes produced.

```typescript
pollar.on('walletProgress', (event) => {
  // event.status: 'deploying' | 'deployed' | 'sponsoring' | 'sponsored' | 'payment_ready'
  // event.contractId: the C-address (from 'deployed' onward)
  // event.txs: [{ label, hash }]  — verifiable on Stellar Expert
  render(event);
});
```

The lifecycle states, in order:

| Status          | Meaning                                             |
|-----------------|-----------------------------------------------------|
| `deploying`     | Deploy transaction submitted, awaiting confirmation |
| `deployed`      | Contract is on-chain; the C-address now exists      |
| `sponsoring`    | Pollar is paying storage rent and extending the TTL |
| `sponsored`     | Rent covered, TTL extended                          |
| `payment_ready` | Wallet can send and receive assets                  |

## 5. Verify on-chain

Every transaction is real and permanent on-chain. Build a verification link from the
C-address or any tx hash:

```typescript
const contractUrl = `https://testnet.stellar.expert/contract/${session.wallet.address}`;
```

## 6. Send a payment

Once the wallet is `payment_ready`, send assets. Pollar builds the contract invocation, signs
the auth entries with the user's KMS-managed key, and sponsors the fee.

```typescript
await pollar.pay({
  to: 'CDESTINATION...', // G-address or C-address
  asset: { code: 'USDC', issuer: 'GA5ZSE...' },
  amount: '10.00',
});
```

## Full example

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: process.env.POLLAR_API_KEY!,
  stellarNetwork: 'testnet',
  walletType: 'smart',
});

pollar.on('walletProgress', (e) => console.log(e.status, e.contractId));

const { wallet } = await pollar.login({ provider: 'google' });
console.log('Smart wallet ready:', wallet.address);
```

## Live demo

A deployed reference implementation of this flow runs at
[demo.pollar.xyz/c-address](https://demo.pollar.xyz/c-address) — social login through to a
payment-ready C-address, with live Stellar Expert links for every transaction.

## Next steps

- [Migrating from G-addresses](./migration-g-to-c.md)
- [How the C-address lifecycle works](./c-address-lifecycle.md)
