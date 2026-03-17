---
title: "@pollar/core"
---

Framework-agnostic TypeScript client for Pollar. Use this directly if you are not using React, or to build custom integrations.

```bash
npm install @pollar/core
```

---

## `PollarClient`

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  publishableKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
});
```

**Constructor options:**

| Option | Type | Default | Description |
|---|---|---|---|
| `publishableKey` | `string` | — | **Required.** Your Pollar publishable key. Network is inferred from the key prefix. |
| `onError` | `(error: PollarError) => void` | — | Global error handler. |

---

## Authentication

### `pollar.login(options)`

Initiates an OAuth or email OTP authentication flow.

```typescript
await pollar.login({ provider: 'google' });

// Email OTP
await pollar.login({ provider: 'email', email: 'user@example.com' });
```

| Option | Type | Description |
|---|---|---|
| `provider` | `'google' \| 'github' \| 'discord' \| 'email'` | Auth provider |
| `email` | `string` | Required when `provider` is `'email'` |

---

### `pollar.logout()`

Signs out the current user and clears the session.

```typescript
await pollar.logout();
```

---

### `pollar.getUser()`

Returns the current authenticated user, or `null` if not authenticated.

```typescript
const user = await pollar.getUser();
```

**`PollarUser`:**

| Property | Type | Description |
|---|---|---|
| `id` | `string` | Pollar user ID (`usr_...`) |
| `email` | `string \| null` | User email |
| `name` | `string \| null` | User display name |
| `provider` | `string` | Auth provider used |

---

## Wallet

### `pollar.getWallet()`

Returns the wallet for the current authenticated user.

```typescript
const wallet = await pollar.getWallet();
// { id: 'wal_...', address: 'GXXX...', status: 'active', balances: [...] }
```

**`Wallet`:**

| Property | Type | Description |
|---|---|---|
| `id` | `string` | Pollar wallet ID (`wal_...`) |
| `address` | `string` | Stellar G-address |
| `status` | `'pending' \| 'active'` | `pending` = unfunded (Deferred / Manual mode) |
| `balances` | `Balance[]` | Array of asset balances |

---

### `pollar.fund(options?)`

Requests assets from the app's distribution wallet. Defaults to XLM if no asset is specified.

```typescript
// Fund with XLM (default)
await pollar.fund();

// Fund with a specific asset
await pollar.fund({ asset: 'USDC' });
```

| Option | Type | Default | Description |
|---|---|---|---|
| `asset` | `string` | `'XLM'` | Asset to fund with. Must be configured in Dashboard. |

Throws `FUND_NOT_ENABLED_ON_MAINNET` if called on mainnet without explicit enablement in **Dashboard → Distribution Wallet**.

---

## Payments

### `pollar.sendPayment(options)`

Sends an asset to a Stellar address. The transaction fee is paid from your app's gas wallet.

```typescript
const result = await pollar.sendPayment({
  to: 'GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  amount: '10.00',
  asset: 'USDC',
  memo: 'Invoice #123', // optional
});

console.log(result.txHash);
```

| Option | Type | Required | Description |
|---|---|---|---|
| `to` | `string` | Yes | Recipient Stellar G-address |
| `amount` | `string` | Yes | Decimal string, e.g. `'10.00'` |
| `asset` | `string` | Yes | Asset code, e.g. `'USDC'` |
| `memo` | `string` | No | Transaction memo |

**Returns `PaymentResult`:**

| Property | Type | Description |
|---|---|---|
| `txHash` | `string` | Stellar transaction hash |
| `ledger` | `number` | Ledger number where tx was confirmed |

---

## History

### `pollar.getHistory(options)`

Returns paginated transaction history for the current wallet.

```typescript
const { transactions, nextCursor, hasMore } = await pollar.getHistory({
  limit: 20,
  cursor: undefined,
  type: 'payment',   // optional filter
  asset: 'USDC',     // optional filter
});
```

| Option | Type | Default | Description |
|---|---|---|---|
| `limit` | `number` | `20` | Transactions per page. Max `100`. |
| `cursor` | `string` | — | Pagination cursor from previous response. |
| `type` | `string` | — | Filter: `payment`, `activation`, `trustline`, `receive`. |
| `asset` | `string` | — | Filter by asset code. |
| `from` | `string` | — | ISO 8601 start date. |
| `to` | `string` | — | ISO 8601 end date. |

**`TxRecord`:**

| Property | Type | Description |
|---|---|---|
| `hash` | `string` | Stellar transaction hash |
| `type` | `'payment' \| 'activation' \| 'trustline' \| 'receive'` | Transaction type |
| `asset` | `string` | Asset code |
| `amount` | `string` | Decimal string |
| `from` | `string` | Sender G-address |
| `to` | `string` | Recipient G-address |
| `feeSponsored` | `boolean` | Whether Pollar paid the fee |
| `ledger` | `number` | Stellar ledger number |
| `timestamp` | `string` | ISO 8601 |

---

## Status

### `pollar.status()`

Returns the current status of the Pollar Server connection.

```typescript
const status = await pollar.status();
// { network: 'testnet', healthy: true }
```

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
} from '@pollar/core';
```