---
title: "@pollar/react"
---

React hooks and pre-built UI components for Pollar. Built on top of `@pollar/core`.

```bash
npm install @pollar/react
```

---

## `usePollar()`

The primary hook. Returns a single object with namespaced access to all Pollar functionality. Use this if you prefer working with one import.

```tsx
'use client';
import { usePollar } from '@pollar/react';

function MyComponent() {
  const { auth, wallet, payments, history } = usePollar();

  // Auth
  const { login, logout, user, loading } = auth;

  // Wallet
  const { wallet: walletData, fund } = wallet;

  // Payments
  const { sendPayment } = payments;

  // History
  const { txHistory, loadingHistory, fetchMoreHistory, hasMore } = history;
}
```

Each namespace returns exactly what the corresponding individual hook returns. See the individual hooks below for the full API of each.

---

## Individual hooks

### `usePollarAuth()`

```tsx
'use client';
import { usePollarAuth } from '@pollar/react';

const { login, logout, user, loading } = usePollarAuth();
```

| Property | Type | Description |
|---|---|---|
| `login` | `(options: LoginOptions) => Promise<void>` | Initiates OAuth or email OTP flow |
| `logout` | `() => Promise<void>` | Signs out the current user |
| `user` | `PollarUser \| null` | Authenticated user object |
| `loading` | `boolean` | Auth state is being resolved |

**`LoginOptions`:**

| Property | Type | Description |
|---|---|---|
| `provider` | `'google' \| 'github' \| 'discord' \| 'email'` | Auth provider |
| `email` | `string` | Required when `provider` is `'email'` (triggers OTP flow) |

---

### `usePollarWallet()`

```tsx
'use client';
import { usePollarWallet } from '@pollar/react';

const { wallet, fund, loading } = usePollarWallet();
```

| Property | Type | Description |
|---|---|---|
| `wallet` | `Wallet \| null` | Current user's wallet |
| `fund` | `(options?: FundOptions) => Promise<void>` | Requests assets from the distribution wallet. Defaults to XLM. |
| `loading` | `boolean` | Wallet state is being resolved |

> Wallet activation in Deferred mode is triggered from your backend via `POST /wallets/activate` — not from the client. See [Deferred Flow Guide](../guides/deferred-flow-guide) for the full setup.

**`Wallet`:**

| Property | Type | Description |
|---|---|---|
| `id` | `string` | Pollar wallet ID (`wal_...`) |
| `address` | `string` | Stellar G-address |
| `status` | `'pending' \| 'active'` | `pending` = unfunded (Deferred mode) |
| `balances` | `Balance[]` | Array of asset balances |

**`FundOptions`:**

| Property | Type | Default | Description |
|---|---|---|---|
| `asset` | `string` | `'XLM'` | Asset to fund with. Must be configured in Dashboard. Throws if asset is not configured or distribution wallet has insufficient balance. |

---

### `usePollarPayments()`

```tsx
'use client';
import { usePollarPayments } from '@pollar/react';

const { sendPayment } = usePollarPayments();
```

| Property | Type | Description |
|---|---|---|
| `sendPayment` | `(options: PaymentOptions) => Promise<PaymentResult>` | Sends an asset to a Stellar address |

**`PaymentOptions`:**

| Property | Type | Required | Description |
|---|---|---|---|
| `to` | `string` | Yes | Recipient Stellar G-address |
| `amount` | `string` | Yes | Decimal string, e.g. `'10.00'` |
| `asset` | `string` | Yes | Asset code, e.g. `'USDC'` |
| `memo` | `string` | No | Transaction memo |

**`PaymentResult`:**

| Property | Type | Description |
|---|---|---|
| `txHash` | `string` | Stellar transaction hash |
| `ledger` | `number` | Ledger number where tx was confirmed |

---

### `usePollarHistory()`

```tsx
'use client';
import { usePollarHistory } from '@pollar/react';

const { txHistory, loadingHistory, fetchMoreHistory, hasMore } = usePollarHistory();
```

| Property | Type | Description |
|---|---|---|
| `txHistory` | `TxRecord[]` | Array of transaction records |
| `loadingHistory` | `boolean` | History is being fetched |
| `fetchMoreHistory` | `() => Promise<void>` | Loads the next page |
| `hasMore` | `boolean` | More pages available |

---

## Components

### `<PollarProvider>`

Wraps your app root. Required for all hooks to work.

```tsx
import { PollarProvider } from '@pollar/react';

<PollarProvider publishableKey="pub_testnet_...">
  <App />
</PollarProvider>
```

| Prop | Type | Default | Description |
|---|---|---|---|
| `publishableKey` | `string` | — | **Required.** Your Pollar publishable key. |
| `onError` | `(error: PollarError) => void` | — | Global error handler. |

---

### `<WalletButton>`

Pre-built button that handles the complete login flow. Opens a modal with Google, GitHub, Discord, and email OTP options.

```tsx
import { WalletButton } from '@pollar/react';

<WalletButton />
```

When logged out, opens the login modal. When logged in, shows a wallet summary with address and balance.

The button and modal styles are customizable from **Dashboard → Configuration → Branding & UI** — no code changes needed.

---

### `<SendPayment>` `coming soon`

Embeddable send flow with asset selector, address input, and amount field.

### `<ReceivePayment>` `coming soon`

QR code and shareable payment link for the current wallet. SEP-7 support included when available.

### `<PaymentHistory>` `coming soon`

Paginated transaction history list, embeddable in any layout.

### `<AssetBalance>` `coming soon`

Displays the balance of a specific asset for the current wallet.

### `<FundButton>` `coming soon`

Testnet funding button that calls `fund()` — requests assets from the distribution wallet.

### `<PasskeySetup>` `coming soon`

Biometric authentication setup — moves the private key from KMS to the device Secure Enclave.

### `<FiatRamp>` `coming soon`

Embeddable SEP-24 deposit and withdrawal modal.

---

## Types

```typescript
import type {
  Wallet,
  Balance,
  TxRecord,
  PaymentOptions,
  PaymentResult,
  FundOptions,
  LoginOptions,
  PollarUser,
  PollarError,
  UsePollarReturn,
} from '@pollar/react';
```