---
title: "Quickstart"
---

Get from zero to a working wallet with USDC payments in under 10 minutes. The steps below use Stellar; a Solana app follows the same steps with Solana enabled under **Wallets > Wallet settings > Enabled chains** ([Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings)) and `sendPayment({ chain: 'SOLANA', ... })` for the payment (see [Payments UI](https://docs.pollar.xyz/docs/guides/payments-ui#on-solana)).

**Requirements:** Node.js 20+ · React 18+ · A publishable key from [dashboard.pollar.xyz](https://dashboard.pollar.xyz)

> SDK requests are rate-limited per API key, with plenty of headroom for development. See [API Keys](https://docs.pollar.xyz/docs/getting-started/api-keys).

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

`PollarProvider` already includes `"use client"` internally. Components that call `usePollar()` need `"use client"` because they use React hooks; that is a React requirement, not specific to Pollar.

#### Options

The `client` prop accepts either a `PollarClientConfig` (the provider builds the client for you) or a pre-built `PollarClient` instance.

| Prop       | Type                              | Default | Description                                              |
| ---------- | --------------------------------- | ------- | ------------------------------------------------------- |
| `client`   | `PollarClientConfig \| PollarClient` | -    | **Required.** Client config (`{ apiKey }`) or instance. |
| `appConfig` | `PollarConfig`                   | -       | Local **replacement** of the remote dashboard config: passing it skips the `/applications/config` fetch and nothing is merged in. Leave it out to keep branding, login methods and chains in sync with the dashboard. |

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

  if (!isAuthenticated) {
    return (
      <button onClick={() => login({ provider: 'google' })}>
        Continue with Google
      </button>
    );
  }

  if (!wallet) return <p>Signed in, creating your wallet...</p>;
  return <p>✓ Wallet ready: {wallet.address}</p>;
}
```

When `login()` is called, Pollar:

1. Authenticates the user via OAuth (Google or GitHub) or email OTP and opens the session
2. Creates a wallet on every chain the app enables (a Stellar G-address, a Solana address, ...). On testnet it is a Pollar-managed wallet whose key Pollar's wallet service keeps encrypted at rest; on mainnet it is a [co-signed or self-custody](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) Turnkey wallet whose key only the user's device can use
3. In the background, activates the Stellar account on-chain, enables trustlines for the assets configured in your Dashboard, and funds it per your [funding mode](https://docs.pollar.xyz/docs/core-concepts/funding-modes); on Solana, sends the starting SOL you configured

`isAuthenticated` turns true at step 1. `wallet` is `null` until the wallet exists, and on an app with [on-demand wallet creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) it stays `null` until you call `createWallet()`. A payment sent while the Stellar account is still being activated returns `SDK_WALLET_NOT_READY`; retry once `wallet.provisioning` is `READY`.

The user never sees a seed phrase. On a Pollar-managed wallet there is no trustline prompt either; on a Turnkey wallet the user approves the account creation and each trustline, and adds a recovery method (a passkey, an email code or another device) before the wallet signs anything else. See [Passkeys and wallet recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide).

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

`runTx(operation, params)` is the one-shot helper that builds, signs, and submits in a single call (alias of `buildAndSignAndSubmitTx`). For step-by-step control, and to drive the transaction modal UI, use `buildTx()` then `signAndSubmitTx()`; see [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core). For a native XLM payment use `asset: { type: 'native' }`.

Before signing, the SDK shows the transaction in `<ConfirmModal>` and waits for the user: that is the default policy, set per app under **Wallets > Wallet settings > Signature confirmation** (always ask, ask once for a window, or never ask). Transaction fees are paid from your app's gas wallet, or from Pollar's pool on an [app on credits](https://docs.pollar.xyz/docs/core-concepts/credits). Users pay zero XLM.

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

> The simplest path is the built-in modal: call `openTxHistoryModal()` from `usePollar()` and Pollar renders the list for you, with no state wiring.

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

  if (!wallet) return <p>Creating your wallet...</p>;

  return (
    <div>
      <p>✓ Wallet active: {wallet.address}</p>
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

> Both `@pollar/core` and `@pollar/react` ship with full TypeScript types; no `@types/` package needed.
