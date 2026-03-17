---
title: "Error Codes"
---

All errors from the Pollar SDK and Server follow a consistent structure.

---

## Error structure

**SDK (`PollarError`):**

```typescript
{
  code: 'INSUFFICIENT_FUNDING_BALANCE',
  message: 'The funding wallet does not have enough XLM to activate this wallet.',
  status: 402,
  meta?: { ... }
}
```

**Server (REST API):**

```json
{
  "error": {
    "code": "INSUFFICIENT_FUNDING_BALANCE",
    "message": "The funding wallet does not have enough XLM to activate this wallet.",
    "status": 402
  }
}
```

---

## Authentication

| Code                   | Status | Description                                  | Resolution                                                                                      |
| ---------------------- | ------ | -------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `UNAUTHORIZED`         | 401    | Missing or invalid API key                   | Check that you are passing the correct publishable or secret key                                |
| `KEY_NETWORK_MISMATCH` | 401    | Key prefix does not match the target network | Use `pub_testnet_` / `sec_testnet_` for testnet and `pub_mainnet_` / `sec_mainnet_` for mainnet |
| `KEY_REVOKED`          | 401    | API key has been revoked                     | Generate a new key from **Dashboard → API Keys**                                                |
| `SESSION_EXPIRED`      | 401    | User session has expired                     | Call `login()` again                                                                            |

---

## Wallet

| Code                     | Status | Description                          | Resolution                                        |
| ------------------------ | ------ | ------------------------------------ | ------------------------------------------------- |
| `WALLET_NOT_FOUND`       | 404    | Wallet ID does not exist in your app | Verify the `walletId`                             |
| `WALLET_ALREADY_ACTIVE`  | 409    | Wallet is already active             | Safe to ignore — idempotent activation            |
| `WALLET_PENDING`         | 422    | Wallet exists but is not yet funded  | Activate the wallet before attempting to transact |
| `WALLET_CREATION_FAILED` | 500    | Failed to create wallet on Stellar   | Retry — transient Stellar network issue           |

---

## Funding & Sponsorship

| Code                                | Status | Description                                                             | Resolution                                                                 |
| ----------------------------------- | ------ | ----------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `INSUFFICIENT_FUNDING_BALANCE`      | 402    | Funding wallet does not have enough XLM to cover the activation reserve | Top up your funding wallet from **Dashboard → Sponsorship Budget**         |
| `INSUFFICIENT_GAS_BALANCE`          | 402    | Gas wallet does not have enough XLM to pay transaction fees             | Top up your gas wallet from **Dashboard → Sponsorship Budget**             |
| `INSUFFICIENT_DISTRIBUTION_BALANCE` | 402    | Distribution wallet does not have enough of the requested asset         | Top up your distribution wallet from **Dashboard → Distribution Wallet**   |
| `FUND_NOT_ENABLED_ON_MAINNET`       | 403    | `fund()` was called on mainnet without explicit enablement              | Enable from **Dashboard → Distribution Wallet → Allow fund() on mainnet**  |
| `FUND_ASSET_NOT_CONFIGURED`         | 422    | The requested asset is not configured for distribution                  | Add the asset from **Dashboard → Distribution Wallet → Configured assets** |
| `FUND_RATE_LIMIT_EXCEEDED`          | 429    | User has exceeded the configured funding rate limit                     | Configured in **Dashboard → Distribution Wallet → Rate limits**            |

---

## Payments

| Code                        | Status | Description                                                 | Resolution                                                    |
| --------------------------- | ------ | ----------------------------------------------------------- | ------------------------------------------------------------- |
| `INVALID_DESTINATION`       | 400    | Recipient G-address is invalid or does not exist on Stellar | Verify the destination address                                |
| `INVALID_AMOUNT`            | 400    | Amount is not a valid decimal string or is zero or negative | Use a positive decimal string, e.g. `'10.00'`                 |
| `ASSET_NOT_SUPPORTED`       | 422    | Asset is not in the app's approved assets list              | Add the asset from **Dashboard → Settings → Approved assets** |
| `INSUFFICIENT_USER_BALANCE` | 422    | User wallet does not have enough of the asset               | Check `wallet.balances` before sending                        |
| `NO_TRUSTLINE`              | 422    | Recipient does not have a trustline for the asset           | Cannot send to an account without a trustline for this asset  |
| `TRANSACTION_FAILED`        | 500    | Transaction was rejected by Stellar                         | Check the `meta` field for the Stellar result code            |
| `FEE_BUMP_FAILED`           | 500    | Fee-bump signing failed                                     | Retry — contact support if it persists                        |

---

## Trustlines

| Code                        | Status | Description                             | Resolution                      |
| --------------------------- | ------ | --------------------------------------- | ------------------------------- |
| `TRUSTLINE_ALREADY_EXISTS`  | 409    | Trustline for this asset already exists | Safe to ignore                  |
| `TRUSTLINE_CREATION_FAILED` | 500    | Failed to create trustline on Stellar   | Retry — transient network issue |

---

## Stellar Network

| Code                  | Status | Description                                            | Resolution                                                                           |
| --------------------- | ------ | ------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| `STELLAR_UNAVAILABLE` | 503    | Stellar network is unreachable                         | Pollar retries automatically. Check [status.stellar.org](https://status.stellar.org) |
| `STELLAR_TIMEOUT`     | 504    | Transaction submitted but not confirmed within timeout | Check Stellar Explorer with the `txHash` — the transaction may have landed           |
| `LEDGER_FULL`         | 503    | Ledger is full — surge pricing in effect               | Pollar retries with a higher fee automatically                                       |

---

## Server

| Code              | Status | Description                                       | Resolution                                                                     |
| ----------------- | ------ | ------------------------------------------------- | ------------------------------------------------------------------------------ |
| `INVALID_REQUEST` | 400    | Malformed request body or missing required fields | Check the request payload against the API reference                            |
| `NOT_FOUND`       | 404    | Endpoint or resource does not exist               | Verify the URL and resource ID                                                 |
| `RATE_LIMITED`    | 429    | Too many requests                                 | Back off and retry. Testnet keys are limited to 1,000 req/day                  |
| `INTERNAL_ERROR`  | 500    | Unexpected server error                           | Retry. If it persists, contact support with the request ID from `X-Request-Id` |

---

## Handling errors in the SDK

```typescript
import { PollarError } from '@pollar/core';

try {
  await pollar.sendPayment({ to: 'GXXX...', amount: '10.00', asset: 'USDC' });
} catch (err) {
  if (err instanceof PollarError) {
    switch (err.code) {
      case 'INSUFFICIENT_USER_BALANCE':
        // show balance error to user
        break;
      case 'STELLAR_UNAVAILABLE':
        // show retry UI
        break;
      default:
        console.error(err.code, err.message);
    }
  }
}
```

Using the global error handler:

```tsx
<PollarProvider
  publishableKey="pub_testnet_..."
  onError={(err) => {
    console.error(`[Pollar] ${err.code}: ${err.message}`);
  }}
>
  <App />
</PollarProvider>
```
