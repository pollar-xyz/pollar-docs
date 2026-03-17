---
title: "Quickstart"
---

Get from zero to a working Stellar wallet with USDC payments in under 10 minutes.

**Requirements:** Node.js 18+ · React 18+ · A publishable key from [dashboard.pollar.xyz](https://dashboard.pollar.xyz)

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
    <PollarProvider publishableKey={process.env.POLLAR_PUBLISHABLE_KEY}>
      <App />
    </PollarProvider>
  );
}
```

`PollarProvider` already includes `"use client"` internally. Components that call `usePollar()` need `"use client"` because they use React hooks — that is a React requirement, not specific to Pollar.

#### Options

| Prop             | Type                           | Default | Description                                |
| ---------------- | ------------------------------ | ------- | ------------------------------------------ |
| `publishableKey` | `string`                       | —       | **Required.** Your Pollar publishable key. |
| `onError`        | `(error: PollarError) => void` | —       | Global error handler.                      |

#### Not using React?

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  publishableKey: process.env.POLLAR_PUBLISHABLE_KEY,
  network: 'testnet',
});
```

---

## 3. Login and create a wallet

```tsx
'use client';

import { usePollar } from '@pollar/react';

export function LoginButton() {
  const { login, wallet, loading } = usePollar();

  if (loading) return <p>Loading...</p>;
  if (wallet) return <p>✓ Wallet ready</p>;

  return (
    <button onClick={() => login({ provider: 'google' })}>
      Continue with Google
    </button>
  );
}
```

When `login()` is called, Pollar:

1. Authenticates the user via OAuth (Google, GitHub, Discord) or email OTP
2. Creates a Stellar G-address on-chain
3. Encrypts the private key with AWS KMS
4. Enables trustlines for all assets configured in your Dashboard (if none configured, no trustlines are set up)
5. Funds the wallet based on your configured [funding mode](../core-concepts/funding-modes)

The user never sees a seed phrase, a wallet address, or a trustline prompt.

---

## 4. Send USDC

```tsx
'use client';

import { usePollar } from '@pollar/react';

export function SendButton() {
  const { sendPayment } = usePollar();

  return (
    <button
      onClick={() =>
        sendPayment({
          to: 'GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
          amount: '10.00',
          asset: 'USDC',
        })
      }
    >
      Send 10 USDC
    </button>
  );
}
```

Transaction fees are paid from your app's sponsorship wallet configured in the Dashboard. Users pay zero XLM.

---

## 5. Transaction history

```tsx
'use client';

import { usePollar } from '@pollar/react';

export function History() {
  const { txHistory, loadingHistory } = usePollar();

  if (loadingHistory) return <p>Loading...</p>;

  return (
    <ul>
      {txHistory.map((tx) => (
        <li key={tx.hash}>
          {tx.type === 'send' ? '↑' : '↓'} {tx.amount} {tx.asset}
        </li>
      ))}
    </ul>
  );
}
```

---

## Complete example

```tsx
'use client';

import { PollarProvider, usePollar } from '@pollar/react';

function WalletDemo() {
  const { login, wallet, sendPayment, txHistory, loading } = usePollar();

  if (loading) return <p>Loading...</p>;

  if (!wallet) {
    return (
      <button onClick={() => login({ provider: 'google' })}>
        Continue with Google
      </button>
    );
  }

  return (
    <div>
      <p>✓ Wallet active</p>
      <button
        onClick={() =>
          sendPayment({ to: 'GXXX...', amount: '5.00', asset: 'USDC' })
        }
      >
        Send 5 USDC
      </button>
      <ul>
        {txHistory.map((tx) => (
          <li key={tx.hash}>
            {tx.amount} {tx.asset} · {tx.type}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default function App() {
  return (
    <PollarProvider publishableKey={process.env.POLLAR_PUBLISHABLE_KEY}>
      <WalletDemo />
    </PollarProvider>
  );
}
```

---

> Both `@pollar/core` and `@pollar/react` ship with full TypeScript types — no `@types/` package needed.
