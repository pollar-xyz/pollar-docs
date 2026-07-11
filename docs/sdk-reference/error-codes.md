---
title: "Error Codes"
---

Pollar surfaces errors in two places: the **Server / SDK API** (HTTP responses) and the **client SDK** (method outcomes and reactive state). This page documents both, plus the real error codes.

---

## Error model

### Server / SDK API responses

Every API response uses a fixed envelope. Errors are **flat** — there is no `error` wrapper and no `message`/`status` field in the body (the HTTP status code carries the status):

```json
{
  "code": "INSUFFICIENT_FUNDS_FOR_TRUSTLINE",
  "success": false
}
```

Some errors include extra fields (e.g. validation issues):

```json
{
  "code": "VALIDATION_ERROR",
  "success": false,
  "details": { "fieldErrors": { "publicKey": ["Must start with G"] } }
}
```

Successful responses are `{ "content": <data>, "code": "<SUCCESS_CODE>", "success": true }`.

### Client SDK

Most `@pollar/core` methods **do not throw** on operational failures. Instead they:

- Return an **outcome** object — e.g. `buildTx`, `signAndSubmitTx`, `runTx` resolve to `{ status: 'error', details?, resultCode? }` (vs `'built' | 'success' | 'pending'`).
- Drive **reactive state** — `tx.step === 'error'` carries `{ phase, details }`; auth/balance/history states expose `{ step: 'error', message }`.

```typescript
const result = await pollar.runTx('payment', { destination, amount, asset });
if (result.status === 'error') {
  console.error(result.details, result.resultCode);
}
```

The only error that is **thrown** is `PollarFlowError` (exported from `@pollar/core`), raised when a flow method is called out of order (e.g. verifying an OTP code before one was sent). Its `code` is always `'INVALID_FLOW'`:

```typescript
import { PollarFlowError } from '@pollar/core';

try {
  pollar.verifyEmailCode('123456');
} catch (err) {
  if (err instanceof PollarFlowError) {
    // called the wrong step for the current AuthState
  }
}
```

Auth flow error codes (surfaced on the `error` `AuthState`) are exported as `AUTH_ERROR_CODES` (e.g. `SESSION_EXPIRED`, `EMAIL_CODE_INVALID`, `WALLET_AUTH_FAILED`, `PASSKEY_FAILED`).

---

## Auth, API keys & access

| Code                         | Description                                                   | Resolution                                                         |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------ |
| `INVALID_CREDENTIALS`        | Missing or invalid credentials                               | Check the credentials you are sending                              |
| `FORBIDDEN`                  | Authenticated but not allowed to perform this action         | Verify the key type / permissions                                  |
| `API_KEY_NOT_FOUND`          | API key does not exist or was revoked                        | Generate a new key from **Build → API Keys**                       |
| `API_KEY_EXPIRED`            | API key has expired                                          | Rotate the key                                                     |
| `API_KEY_TYPE_NOT_ALLOWED`   | Publishable key used on a secret-key route (or vice versa)   | Use a secret key on the Server API, publishable on the SDK API     |
| `ORIGIN_NOT_ALLOWED`         | Request origin is not in the app's allowed origins           | Add the origin under **Build → Domains**                           |
| `RATE_LIMITED`               | Too many requests                                            | Back off and retry                                                 |

> Keys are network-specific by prefix: `pub_testnet_` / `pub_mainnet_` (publishable) and `sec_testnet_` / `sec_mainnet_` (secret).

---

## Validation & general

| Code                    | Description                                            | Resolution                                          |
| ----------------------- | ----------------------------------------------------- | --------------------------------------------------- |
| `VALIDATION_ERROR`      | Malformed body or failed schema validation            | Check the payload against the API reference         |
| `INVALID_JSON`          | Request body is not valid JSON                        | Send a valid JSON body                              |
| `USER_NOT_FOUND`        | User does not exist in your app                       | Verify the `externalId` / user                      |
| `APPLICATION_NOT_FOUND` | Application not found for the key                     | Verify the API key                                  |
| `INTERNAL_SERVER_ERROR` | Unexpected server error                               | Retry; contact support if it persists               |
| `NOT_IMPLEMENTED`       | Endpoint exists but is not yet wired up               | Feature is on the roadmap                            |

---

## Wallet & funding

| Code                               | Description                                                  | Resolution                                                  |
| ---------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| `WALLET_NOT_FOUND`                 | Public key is not a wallet owned by your app                | Verify the `publicKey`                                      |
| `WALLET_NOT_FUNDED`                | Wallet exists but is not yet funded                         | Activate the wallet before transacting / adding trustlines |
| `WALLET_ALREADY_FUNDED`            | Wallet is already active                                    | Safe to ignore — idempotent activation                     |
| `WALLET_CREATION_FAILED`           | Failed to create the wallet on Stellar                      | Retry — transient Stellar network issue                    |
| `FUND_XLM_FAILED`                  | Funding the XLM reserve failed                              | Check the funding wallet balance, then retry               |
| `FRIENDBOT_NOT_AVAILABLE`          | Testnet Friendbot funding is unavailable                    | Retry shortly                                              |
| `WALLET_ADAPTER_NOT_SUPPORTED`     | Server-side wallet provisioning not supported for BYO custody apps | Provision wallets via your adapter                  |

---

## Trustlines

| Code                               | Description                                              | Resolution                                       |
| ---------------------------------- | ------------------------------------------------------- | ------------------------------------------------ |
| `TRUSTLINE_FAILED`                 | Failed to create/remove a trustline on Stellar          | Retry — transient network issue                  |
| `INSUFFICIENT_FUNDS_FOR_TRUSTLINE` | Not enough XLM to cover the trustline reserve (0.5 XLM) | Top up the funding wallet                         |
| `TRUSTLINE_HAS_BALANCE`            | Cannot remove a trustline that still holds a balance    | Move the balance to zero first                   |
| `NO_DEFAULT_TRUSTLINES`            | No default assets are configured for the app            | Configure assets under **Treasury → Tokens & Trustlines** |

---

## Transactions

| Code                       | Description                                              | Resolution                                          |
| -------------------------- | ------------------------------------------------------- | --------------------------------------------------- |
| `SDK_TX_BUILD_ERROR`       | The transaction could not be built                      | Check operation params (destination, amount, asset) |
| `TX_UNSUPPORTED_OPERATION` | Operation type is not supported                         | Use a supported operation (e.g. `payment`)          |
| `TX_INVALID_SIGNED_XDR`    | The signed XDR is malformed                             | Re-sign from the built XDR                          |
| `TX_SIGN_FAILED`           | Signing failed                                          | Retry; for external wallets, re-approve in the wallet |
| `TX_SUBMIT_FAILED`         | Stellar rejected the transaction                        | Inspect `resultCode` on the outcome                 |
| `TX_IDEMPOTENCY_CONFLICT`  | A conflicting submission is already in flight           | Wait and check transaction status                   |

---

## Distribution

| Code                                  | Description                                          | Resolution                                                |
| ------------------------------------- | --------------------------------------------------- | --------------------------------------------------------- |
| `DISTRIBUTION_RULE_NOT_FOUND`         | The distribution rule does not exist                | Verify the rule id                                        |
| `DISTRIBUTION_ASSET_NOT_ENABLED`      | The asset is not enabled for distribution           | Enable it under **Treasury → Token Distribution**         |
| `DISTRIBUTION_RULE_DISABLED`          | The rule is disabled                                | Enable the rule                                           |
| `DISTRIBUTION_RULE_EXPIRED`           | The rule's validity window has ended                | —                                                         |
| `DISTRIBUTION_RULE_EXHAUSTED`         | The rule's total allocation is used up              | —                                                         |
| `DISTRIBUTION_RATE_LIMIT_EXCEEDED`    | The user exceeded the rule's claim rate limit       | Configured per rule in **Treasury → Token Distribution**  |
| `DISTRIBUTION_NO_DISTRIBUTION_WALLET` | No distribution wallet is configured                | Configure one under **Treasury → Token Distribution**     |

---

## KYC & Ramps

| Code                            | Description                                  |
| ------------------------------- | -------------------------------------------- |
| `SDK_KYC_PROVIDER_NOT_FOUND`    | KYC provider not found                       |
| `SDK_KYC_PROVIDER_NOT_ENABLED`  | KYC provider not enabled for the app         |
| `SDK_KYC_SESSION_EXPIRED`       | KYC session expired                          |
| `SDK_KYC_VERIFICATION_NOT_FOUND`| KYC verification not found                   |
| `SDK_RAMPS_PROVIDER_NOT_FOUND`  | Ramp provider not found                      |
| `SDK_RAMPS_QUOTE_NOT_FOUND`     | Ramp quote not found                         |
| `SDK_RAMPS_QUOTE_EXPIRED`       | Ramp quote expired — request a new one       |
| `SDK_RAMPS_TX_NOT_FOUND`        | Ramp transaction not found                   |

---

## Session, DPoP & passkeys

End-user session and token errors (sdk-api). These are handled by the SDK's auth flow; surface to users as "please sign in again".

| Code                                            | Description                                  |
| ----------------------------------------------- | -------------------------------------------- |
| `SDK_AUTH_INVALID_TOKEN` / `SDK_AUTH_TOKEN_EXPIRED` | Access token invalid or expired          |
| `SDK_AUTH_DPOP_REQUIRED` / `SDK_AUTH_DPOP_INVALID` / `SDK_AUTH_DPOP_USE_NONCE` | DPoP proof required / invalid / needs nonce |
| `SDK_REFRESH_TOKEN_INVALID` / `_EXPIRED` / `_REUSED` | Refresh token invalid, expired, or reused |
| `PASSKEY_CHALLENGE_MISSING` / `PASSKEY_VERIFICATION_FAILED` / `PASSKEY_DEPLOY_FAILED` | Passkey ceremony errors |

> This is not the full enum — the server defines additional internal codes (hub-api admin, Pollar Pay, authentik, wallet-adapter). The codes above are the ones an SDK or Server API integrator is most likely to encounter.

---

## Handling errors in the SDK

```typescript
import { PollarFlowError } from '@pollar/core';

// Operational failures come back as outcomes — no try/catch needed.
const result = await pollar.runTx('payment', { destination, amount, asset });
if (result.status === 'error') {
  switch (result.resultCode) {
    case 'tx_insufficient_balance':
      // not enough of the asset
      break;
    default:
      console.error(result.details);
  }
}

// Misuse of the flow API throws.
try {
  pollar.sendEmailCode('user@example.com');
} catch (err) {
  if (err instanceof PollarFlowError) {
    // wrong step for the current AuthState
  }
}
```

To observe transaction failures reactively, subscribe to `onTransactionStateChange` and inspect `state.phase` / `state.details` when `state.step === 'error'`.
