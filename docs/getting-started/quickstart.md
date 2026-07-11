---
title: "Quickstart"
---

Get from zero to a working Stellar wallet with USDC payments in under 10 minutes.

**Requirements:** Node.js 20+ · React 18+ · A publishable key from [dashboard.pollar.xyz](https://dashboard.pollar.xyz)

> SDK requests are rate-limited per API key — plenty of headroom for development. See [API Keys](https://docs.pollar.xyz/docs/getting-started/api-keys).

---

## 1. Install

```bash
npm install @pollar/react
```

This includes `@pollar/core` as a peer dependency. If you are not using React:

```bash
npm install @pollar/core
```

---

## 2. Add `PollarProvider`

Wrap your app root once. Every child component can then call `usePollar()`.

```tsx
import { PollarProvider } from '@pollar/react';

export default function Root() {
  return (
    <PollarProvider client={{ apiKey: process.env.NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY! }}>
      <App />
    </PollarProvider>
  );
}
```

`PollarProvider` already includes `"use client"` internally. Components that call `usePollar()` need `"use client"` because they use React hooks — that is a React requirement, not specific to Pollar.

#### Options

The `client` prop accepts either a `PollarClientConfig` (the provider builds the client for you) or a pre-built `PollarClient` instance.

| Prop       | Type                              | Default | Description                                              |
| ---------- | --------------------------------- | ------- | ------------------------------------------------------- |
| `client`   | `PollarClientConfig \| PollarClient` | —    | **Required.** Client config (`{ apiKey }`) or instance. |
| `appConfig` | `PollarConfig`                   | —       | Local override of the remote dashboard config/styles.   |

See [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react) for the full prop list (`appConfig`, `adapters`, `onStorageDegrade`).

#### Not using React?

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: process.env.NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY!,
  stellarNetwork: 'testnet',
});
```

---

## 3. Login and create a wallet

```tsx
'use client';

import { usePollar } from '@pollar/react';

export function LoginButton() {
  const { isAuthenticated, wallet, login } = usePollar();

  if (isAuthenticated) return <p>✓ Wallet ready — {wallet?.address}</p>;

  return (
    <button onClick={() => login({ provider: 'google' })}>
      Continue with Google
    </button>
  );
}
```

When `login()` is called, Pollar:

1. Authenticates the user via OAuth (Google or GitHub) or email OTP
2. Creates a Stellar G-address on-chain
3. Encrypts the private key with AWS KMS
4. Enables trustlines for all assets configured in your Dashboard (if none configured, no trustlines are set up)
5. Funds the wallet based on your configured [funding mode](https://docs.pollar.xyz/docs/core-concepts/funding-modes)

The user never sees a seed phrase, a wallet address, or a trustline prompt.

---

## 4. Send USDC

```tsx
'use client';

import { usePollar } from '@pollar/react';

export function SendButton() {
  const { runTx } = usePollar();

  return (
    <button
      onClick={() =>
        runTx('payment', {
          destination: 'GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
          amount: '10.00',
          asset: { type: 'credit_alphanum4', code: 'USDC', issuer: 'GA5Z...' },
        })
      }
    >
      Send 10 USDC
    </button>
  );
}
```

`runTx(operation, params)` is the one-shot helper that builds, signs, and submits in a single call (alias of `buildAndSignAndSubmitTx`). For step-by-step control — and to drive the transaction modal UI — use `buildTx()` then `signAndSubmitTx()`; see [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core). For a native XLM payment use `asset: { type: 'native' }`.

Transaction fees are paid from your app's sponsorship wallet configured in the Dashboard. Users pay zero XLM.

---

## 5. Transaction history

```tsx
'use client';

import { usePollar } from '@pollar/react';

import { useEffect } from 'react';

export function History() {
  const { txHistory, getClient } = usePollar();

  // `txHistory` is a state machine; trigger a fetch on the underlying client.
  useEffect(() => {
    getClient().fetchTxHistory({ limit: 20 });
  }, [getClient]);

  if (txHistory.step !== 'loaded') return <p>Loading...</p>;

  return (
    <ul>
      {txHistory.data.records.map((tx) => (
        <li key={tx.id}>
          {tx.summary} · {tx.status}
        </li>
      ))}
    </ul>
  );
}
```

> The simplest path is the built-in modal: call `openTxHistoryModal()` from `usePollar()` and Pollar renders the list for you — no state wiring needed.

---

## Complete example

```tsx
'use client';

import { PollarProvider, usePollar } from '@pollar/react';

function WalletDemo() {
  const { isAuthenticated, wallet, login, runTx, openTxHistoryModal } = usePollar();

  if (!isAuthenticated) {
    return (
      <button onClick={() => login({ provider: 'google' })}>
        Continue with Google
      </button>
    );
  }

  return (
    <div>
      <p>✓ Wallet active — {wallet?.address}</p>
      <button
        onClick={() =>
          runTx('payment', {
            destination: 'GXXX...',
            amount: '5.00',
            asset: { type: 'credit_alphanum4', code: 'USDC', issuer: 'GA5Z...' },
          })
        }
      >
        Send 5 USDC
      </button>
      <button onClick={openTxHistoryModal}>History</button>
    </div>
  );
}

export default function App() {
  return (
    <PollarProvider client={{ apiKey: process.env.NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY! }}>
      <WalletDemo />
    </PollarProvider>
  );
}
```

---

> Both `@pollar/core` and `@pollar/react` ship with full TypeScript types — no `@types/` package needed.
