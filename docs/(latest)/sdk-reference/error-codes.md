---
title: "Error Codes"
---

Pollar surfaces errors in two places: the **Server / SDK API** (HTTP responses) and the **client SDK** (method outcomes, thrown errors and reactive state). This page documents both, plus the error codes, for `@pollar/core` 0.12 and API v3. For 0.11.x, see the [0.11 reference](https://docs.pollar.xyz/docs/v0.11/error-codes).

---

## Error model

### Server / SDK API responses

Every API response uses a fixed envelope. Errors are **flat**: there is no `error` wrapper and no `status` field in the body (the HTTP status code carries the status):

```json
{
  "code": "INSUFFICIENT_FUNDS_FOR_TRUSTLINE",
  "success": false
}
```

Some errors include extra fields: validation issues in `details`, a human-readable `message` (a ramp payee the provider would refuse, an API version that is retired), or the data the error is about (`rejected` on a ramp quote with no route, `reasons` on a blocked custody migration):

```json
{
  "code": "VALIDATION_ERROR",
  "success": false,
  "details": { "fieldErrors": { "publicKey": ["Must start with G"] } }
}
```

Successful responses are `{ "content": <data>, "code": "<SUCCESS_CODE>", "success": true }`.

### Client SDK

The transaction methods of `@pollar/core` **do not throw** on operational failures. Instead they:

- Return an **outcome** object: `buildTx`, `signAndSubmitTx`, `runTx`, `sendPayment` resolve to `{ status: 'error', code?, details?, resultCode?, message? }` (vs `'built' | 'success' | 'pending' | 'cosign_pending'`).
- Drive **reactive state**: `tx.step === 'error'` carries `{ phase, details }`; auth/balance/history states expose `{ step: 'error', message }`.

```typescript
const result = await pollar.runTx('payment', { destination, amount, asset });
if (result.status === 'error') {
  console.error(result.code, result.details, result.resultCode);
}
```

Other methods (wallet creation, KYC, requirements, cards, ramps, co-sign and recovery) **throw** when the API refuses. Three kinds of error are thrown; check them by `code` or with the exported guards:

| Error | `code` | When |
| --- | --- | --- |
| `PollarApiError` | the API's code (e.g. `SDK_RAMPS_NO_ROUTE`) | The API answered with an error body. `body` keeps every field the server sent; `details` is set when the body had one. Guard: `isPollarApiError(err)` |
| `PollarNetworkError` | `'SDK_NETWORK_TIMEOUT'` | The request timed out on the client (`requestTimeoutMs`) before the server answered. Guard: `isPollarNetworkError(err)` |
| Flow error | `'INVALID_FLOW'` | A flow method was called out of order (e.g. verifying an OTP code before one was sent). Check `err.code === 'INVALID_FLOW'` |

```typescript
import { isPollarApiError, isPollarNetworkError } from '@pollar/core';

try {
  await pollar.createWallet();
} catch (err) {
  if (isPollarApiError(err) && err.code === 'SDK_WALLET_PROVISIONING_DISABLED') {
    // the app creates no wallets
  } else if (isPollarNetworkError(err)) {
    // retry later
  }
}
```

Auth flow error codes (surfaced on the `error` `AuthState`) are exported as `AUTH_ERROR_CODES` (e.g. `SESSION_EXPIRED`, `EMAIL_CODE_INVALID`, `WALLET_AUTH_FAILED`, `PASSKEY_FAILED`).

### Text to show the user

`@pollar/core` exports the messages its own UI shows, so a custom UI phrases errors the same way:

- `transactionErrorMessage(code, details?)`: the text for a transaction failure, from the code or the on-chain result code.
- `appUnavailableMessage(err)`: the text for `SDK_CREDITS_INSUFFICIENT` / `SDK_BILLING_OVERDUE`, an error the user cannot fix and the app must; `null` for any other error.
- `cosignRefusalMessage(err)`: the text for `SDK_COSIGN_TURNKEY_REJECTED`, with the wallet provider's own reason when it gave one; `null` for any other error.

---

## Auth, API keys & access

| Code                         | Description                                                   | Resolution                                                         |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------ |
| `INVALID_CREDENTIALS`        | Missing or invalid credentials                               | Check the credentials you are sending                              |
| `FORBIDDEN`                  | Authenticated but not allowed to perform this action         | Verify the key type / permissions                                  |
| `API_KEY_NOT_FOUND`          | API key does not exist or was revoked                        | Generate a new key from **Build > API Keys**                       |
| `API_KEY_EXPIRED`            | API key has expired                                          | Rotate the key                                                     |
| `API_KEY_TYPE_NOT_ALLOWED`   | Publishable key used on a secret-key route (or vice versa)   | Use a secret key on the Server API, publishable on the SDK API     |
| `ORIGIN_NOT_ALLOWED`         | Request origin is not in the app's allowed origins           | Add the origin under **Build > Domains**                           |
| `REDIRECT_URI_NOT_ALLOWED`   | OAuth `redirect_uri` is not in the app's allowed redirect URIs | Add its origin under **Build > Domains**                          |
| `APPLICATION_HAS_NO_REDIRECT_URIS` | The app has no allowed redirect URI registered, so no OAuth login can start | Register the callback under **Build > Domains**              |
| `RATE_LIMITED`               | Too many requests                                            | Back off and retry                                                 |
| `API_VERSION_SUNSET` (410)   | The request used a retired API version (SDK API v1). The body carries `message`, `sunsetAt` and `migrationGuide` | Upgrade the SDK; see [API versions](https://docs.pollar.xyz/docs/sdk-reference/api-versions) |

> Keys are network-specific by prefix: `pub_testnet_` / `pub_mainnet_` (publishable) and `sec_testnet_` / `sec_mainnet_` (secret).

---

## Credits

Apps on credits pay Pollar per use (see [Credits](https://docs.pollar.xyz/docs/core-concepts/credits)). A paid call is refused before anything moves when the app cannot pay:

| Code                               | Description                                                  | Resolution                                                  |
| ---------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| `SDK_CREDITS_INSUFFICIENT` (402)   | The app's credit balance does not cover the call             | The app owner tops up credits in the dashboard. Show `appUnavailableMessage(err)` to the user |
| `SDK_BILLING_OVERDUE` (402)        | A postpaid statement of the app is overdue                    | The app owner pays the statement                            |

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
| `WALLET_ALREADY_FUNDED`            | Wallet is already active                                    | Safe to ignore: activation is idempotent                   |
| `WALLET_CREATION_FAILED`           | Failed to create the wallet on Stellar                      | Retry: transient Stellar network issue                     |
| `FUND_XLM_FAILED`                  | Funding the XLM reserve failed                              | Check the funding wallet balance, then retry               |
| `FRIENDBOT_NOT_AVAILABLE`          | Testnet Friendbot funding is unavailable                    | Retry shortly                                              |
| `WALLET_ADAPTER_NOT_SUPPORTED`     | Server-side wallet provisioning not supported for BYO custody apps | Provision wallets via your adapter                  |
| `SDK_WALLET_NOT_READY` (409)       | The wallet's Stellar account is still being created         | Retry in a few seconds; `walletNotReadyReason()` gives the text to show |
| `SDK_WALLET_REQUIRED` (409)        | The user has no wallet yet (app with on-demand or no wallet creation) | Call `createWallet()`, or hide the feature. See [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) |
| `SDK_WALLET_PROVISIONING_DISABLED` (403) | The app's wallet creation is set to Never           | Change it in the dashboard, or do not offer wallet features |
| `SDK_WALLET_PROVISIONING_UNSUPPORTED` (409) | The user signed in with their own wallet or a passkey; there is no wallet to create | Use the wallet the user signed in with |
| `SDK_USER_WALLET_MISMATCH` (409)   | The address does not belong to this user                     | Use the session's own wallet                                |

---

## Co-signed and self-custody wallets (Turnkey)

Apps whose wallets live in Turnkey (see [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets)). A signing call that needs the user's vote is not an error: it answers **202 `SDK_COSIGN_PENDING`** and the SDK reports `status: 'cosign_pending'`.

| Code                               | Description                                                  | Resolution                                                  |
| ---------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| `SDK_UPGRADE_REQUIRED` (409)       | The app creates Turnkey wallets and this SDK did not send the device key | Upgrade `@pollar/core` to 0.12.0 or later |
| `SDK_COSIGN_NOT_CONFIGURED` (503)  | Co-signing is not available on the app's network           | Contact Pollar                                              |
| `SDK_COSIGN_REQUEST_NOT_FOUND` (404) | No request with that id or fingerprint belongs to this user | Refresh `pollar.cosign.pending()`                        |
| `SDK_COSIGN_REQUEST_NOT_PENDING` (409) | The request already reached a final state (approved, rejected, expired) | Read it with `?sync=1` to see the outcome       |
| `SDK_COSIGN_DEVICE_NOT_ENROLLED` (403) | The key that stamped the vote is not one of the user's devices | Approve this device from an enrolled one, or recover it with a passkey or email code |
| `SDK_COSIGN_PROPOSAL_MISMATCH` (409) | The Turnkey request the device proposed does not match the transaction Pollar holds | Refresh the request and approve again |
| `SDK_COSIGN_TURNKEY_REJECTED` (502) | Turnkey refused the request; `body.message` carries its reason | Show `cosignRefusalMessage(err)`; retry in a moment |
| `SDK_COSIGN_UPSTREAM_ERROR` (502)  | Turnkey or the co-signing service failed                    | Retry; the request stays pending until its 24 hour window closes |
| `SDK_COSIGN_USER_REQUIRED` (409)   | A server-side call tried to sign for a Turnkey wallet; only the user's device can vote | Run the operation from the SDK |
| `SDK_COSIGN_CUSTODY_SWITCH_NOT_ALLOWED` (403) | The app does not let the user move the wallet between co-signed and self-custody | Nothing to do on the client |
| `SDK_COSIGN_CUSTODY_SWITCH_PENDING` (409) | Requests are still pending on the wallet | Finish or reject them, then switch |
| `SDK_COSIGN_CUSTODY_STEP_MISMATCH` (409) | The custody step sent is not the one the server expects next | Read the next step again and resend |
| `SDK_WALLET_RECOVERY_REQUIRED` (409) | The Turnkey wallet has no recovery method; it signs nothing but its own setup and on-ramps until it has one | Open the recovery flow (`openRecoveryModal()`); see [Passkeys and wallet recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide) |
| `SDK_CUSTODY_MIGRATION_NOT_AVAILABLE` (409) | The wallet has nothing to move to Turnkey | Nothing to do |
| `SDK_CUSTODY_MIGRATION_BLOCKED` (409) | Something still points at the old wallet; `body.reasons` lists what | Wait for what is pending, then move |
| `SDK_COSIGN_VERIFICATION_FAILED`   | SDK only: the payload differs from the one shown; the device rejected the request | Report it to Pollar with the verification report |
| `SDK_COSIGN_NO_SIGNATURE`          | SDK only: an approved request carries no signature          | Retry the operation                                         |
| `SDK_COSIGN_PASSKEY_UNAVAILABLE`   | SDK only: a recovery passkey method ran with no passkey ceremony on the client | Pass `recoveryPasskey` (React Native), or hide the passkey options |

---

## Signature confirmation

SDK only. Every signing call passes the app's confirmation policy first (see [Signature confirmation](https://docs.pollar.xyz/docs/sdk-reference/pollar-react#signature-confirmation)).

| Code                               | Description                                                  | Resolution                                                  |
| ---------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| `SDK_CONFIRMATION_DECLINED`        | The user declined the prompt                                 | Nothing was signed; the user can retry                     |
| `SDK_CONFIRMATION_UNAVAILABLE`     | The policy asks the user and nothing renders the prompt      | Mount `PollarProvider`, or subscribe with `onConfirmationRequest` |

---

## Trustlines

| Code                               | Description                                              | Resolution                                       |
| ---------------------------------- | ------------------------------------------------------- | ------------------------------------------------ |
| `TRUSTLINE_FAILED`                 | Failed to create/remove a trustline on Stellar          | Retry: transient network issue                   |
| `INSUFFICIENT_FUNDS_FOR_TRUSTLINE` | Not enough XLM to cover the trustline reserve (0.5 XLM) | Top up the funding wallet                         |
| `TRUSTLINE_HAS_BALANCE`            | Cannot remove a trustline that still holds a balance    | Move the balance to zero first                   |
| `NO_DEFAULT_TRUSTLINES`            | No default assets are configured for the app            | Configure assets under **Wallets > Tokens & Trustlines** |

---

## Signer rotation

| Code | Description | Resolution |
| --- | --- | --- |
| `SIGNER_ROTATION_NOT_ENABLED` (403) | The app does not sponsor signer rotations | Turn on **Sponsor signer rotations** and **Include external wallets** under **Wallets > Sponsorship** |
| `SIGNER_ROTATION_NOT_GRANTED` (403) | The user holds no unspent rotation grant, or already used it | Grant one from **Users > Accounts** or with `POST /v3/wallets/{publicKey}/signer-rotation` |
| `SIGNER_ROTATION_PENDING` (409) | A sponsored rotation built for this user can still be submitted | Submit it, or wait until its `expiresAt` passes |
| `SIGNER_ROTATION_INVALID` (422) | The wallet is custodial or not created yet, or the requested change is not allowed | Read `details`; see [the rotation rules](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter#rotate-the-wallet-signer) |

---

## Transactions

| Code                       | Description                                              | Resolution                                          |
| -------------------------- | ------------------------------------------------------- | --------------------------------------------------- |
| `SDK_TX_BUILD_ERROR`       | The transaction could not be built                      | Check operation params (destination, amount, asset) |
| `TX_UNSUPPORTED_OPERATION` (400) | Operation type is not supported                   | Use a supported operation (e.g. `payment`)          |
| `TX_OP_MALFORMED` (400)    | Invalid operation parameters                            | Fix the parameters                                  |
| `TX_INVALID_SIGNED_XDR` (400) | The signed XDR is malformed                          | Re-sign from the built XDR                          |
| `TX_SIGN_FAILED` (502)     | Signing failed on Pollar's side                         | Retry; for external wallets, re-approve in the wallet |
| `TX_SUBMIT_FAILED` (422)   | The network rejected the transaction                    | Inspect `resultCode` on the outcome                 |
| `TX_SUBMIT_UNCONFIRMED` (504) | The network did not answer in time; nothing rejected the transaction | Check its status before retrying     |
| `TX_BAD_SEQUENCE` (409)    | Sequence number race                                    | Safe to retry                                       |
| `TX_IDEMPOTENCY_CONFLICT` (409) | A conflicting submission is already in flight      | Wait and check transaction status                   |
| `TX_FEE_LIMIT_EXCEEDED` (422) | The fee is above the app's limit                     | Check the app's transaction policy                  |

When the network refuses a transaction for a known reason, the code names it (all 422):

| Code | Meaning |
| --- | --- |
| `TX_INSUFFICIENT_BALANCE` | The wallet does not hold enough of the asset |
| `TX_INSUFFICIENT_FEE` | The fee is too low for the network |
| `TX_LOW_RESERVE` | The account would go below its minimum reserve |
| `TX_TOO_MANY_SUBENTRIES` | The account holds too many trustlines, offers or signers |
| `TX_DESTINATION_NOT_FOUND` | The destination account does not exist |
| `TX_NO_TRUSTLINE` | The destination (or source) has no trustline for the asset |
| `TX_NO_ISSUER` | The asset's issuer does not exist |
| `TX_NOT_AUTHORIZED` | The issuer has not authorized the account for the asset |
| `TX_LINE_FULL` | The destination's trustline limit is reached |
| `TX_CONTRACT_FAILED` | A contract call failed |
| `TX_TOO_LATE` | The transaction's time bounds passed |
| `TX_SOURCE_NOT_FOUND` | The source account does not exist on the ledger |
| `TX_BAD_AUTH` | Signatures are missing or wrong |

`transactionErrorMessage(code, details)` returns the text the SDK's own modals show for each.

---

## Soroban auth entries

Returned by `POST /tx/sign-auth-entry` (`pollar.signAuthEntry()`) when the app's allowlist refuses to authorize an entry, and by the dashboard/Server API when a row is saved. Configured under **Wallets > [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy)**.

Every denial here also carries `applicationId` and `applicationName`: the app the decision was made against, which is the app your API key resolves to, not necessarily the one open in the dashboard.

```json
{
  "code": "SOROBAN_AUTH_NO_POLICY",
  "success": false,
  "message": "no Soroban auth-entry allowlist is configured for this application",
  "applicationId": "cm...",
  "applicationName": "Acme Checkout"
}
```

| Code                                | Description                                                        | Fix                                                             |
| ----------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------- |
| `SOROBAN_AUTH_NO_POLICY`            | The app has no enabled allowlist rows                              | Add a row, or check `applicationName` against the app you configured |
| `SOROBAN_AUTH_CONTRACT_NOT_ALLOWED` | A contract in the invocation tree is not allowlisted               | Add it; sub-invocations each need their own row                 |
| `SOROBAN_AUTH_FUNCTION_NOT_ALLOWED` | The contract is allowlisted, the invoked function is not           | Names match exactly: `Transfer` is not `transfer`               |
| `SOROBAN_AUTH_ADDRESS_MISMATCH`     | The entry authorizes an address other than the caller's wallet     | Build the entry for the session's own address                   |
| `SOROBAN_AUTH_ENTRY_INVALID`        | Not a valid `SorobanAuthorizationEntry`, or not address-credentials | Send the entry itself: a `HashIDPreimage` is a different type   |
| `SOROBAN_AUTH_EXPIRATION_TOO_LONG`  | `validUntilLedger` is in the past or beyond the app's window       | Recompute from the latest ledger; the ceiling is 300 ledgers     |
| `SOROBAN_AUTH_SIGN_FAILED`          | The entry passed the allowlist but signing failed                  | Retry: this one is on Pollar's side                             |

Saving an allowlist row (dashboard or Server API) can also answer:

| Code                                          | Description                                                          |
| --------------------------------------------- | -------------------------------------------------------------------- |
| `CONTRACT_FUNCTION_UNKNOWN`                   | The row names a function the contract does not expose. `message` names which |
| `CONTRACT_NOT_FOUND`                          | The contract is not deployed on this app's network                   |
| `CONTRACT_INTROSPECTION_FAILED`               | Pollar could not read the contract (RPC unreachable)                 |
| `SOROBAN_AUTH_WILDCARD_REQUIRES_ANY_FUNCTION` | The "any contract" row may only carry the "any function" wildcard    |

---

## Swaps

| Code                          | Description                                    | Resolution                         |
| ----------------------------- | --------------------------------------------- | ---------------------------------- |
| `SDK_SWAP_NO_ROUTE` (422)     | No venue can fill the swap for this pair and amount | Change the amount or the pair |
| `SDK_SWAP_QUOTE_ERROR` (502)  | A venue failed to quote                        | Retry in a moment                  |

---

## Distribution

| Code                                  | Description                                          | Resolution                                                |
| ------------------------------------- | --------------------------------------------------- | --------------------------------------------------------- |
| `DISTRIBUTION_RULE_NOT_FOUND`         | The distribution rule does not exist                | Verify the rule id                                        |
| `DISTRIBUTION_ASSET_NOT_ENABLED`      | The asset is not enabled for distribution           | Enable it under **Treasury > Token Distribution**         |
| `DISTRIBUTION_RULE_DISABLED`          | The rule is disabled                                | Enable the rule                                           |
| `DISTRIBUTION_RULE_EXPIRED`           | The rule's validity window has ended                | None                                                      |
| `DISTRIBUTION_RULE_EXHAUSTED`         | The rule's total allocation is used up              | None                                                      |
| `DISTRIBUTION_RATE_LIMIT_EXCEEDED`    | The user exceeded the rule's claim rate limit       | Configured per rule in **Treasury > Token Distribution**  |
| `DISTRIBUTION_NO_DISTRIBUTION_WALLET` | No distribution wallet is configured                | Configure one under **Treasury > Token Distribution**     |

---

## KYC

| Code                            | Description                                  |
| ------------------------------- | -------------------------------------------- |
| `SDK_KYC_PROVIDER_NOT_FOUND` (404) | KYC provider not found                    |
| `SDK_KYC_PROVIDER_NOT_ENABLED` (404) | KYC provider not enabled for the app    |
| `SDK_KYC_SESSION_EXPIRED` (410) | KYC session expired                          |
| `SDK_KYC_VERIFICATION_NOT_FOUND` (404) | KYC verification not found            |
| `SDK_KYC_ALREADY_APPROVED` (409) | The user is already verified for this option |
| `SDK_KYC_UNDER_REVIEW` (409)    | A verification is waiting for a person; a new one is refused meanwhile |

---

## Ramps

Ramps run on `/v3/ramps` (see [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps)).

| Code                                  | Description                                  | Resolution |
| ------------------------------------- | -------------------------------------------- | --- |
| `SDK_RAMPS_NO_ROUTE` (422)            | No route can serve the quote; `rejected` lists each route with why it was dropped | Show `rampNoRouteText(rejected)`, or the fix a rejected route offers (verify, trustline, wallet step) |
| `SDK_RAMPS_QUOTE_NOT_FOUND` (404)     | The quote does not exist or belongs to another user | Quote again |
| `SDK_RAMPS_QUOTE_EXPIRED` (400)       | The quote expired                            | Quote again |
| `VALIDATION_ERROR` (400)              | A `payee` field is missing or the provider would refuse it; the reason is in `message`. Nothing moved | Fix the field |
| `VALIDATION_ERROR` (409)              | The order request does not match the quote   | Create the order from the quote as returned |
| `SDK_RAMPS_WALLET_NOT_READY` (422)    | The route needs the user's wallet on another chain and it waits for the user's approval | Approve the co-sign request; the order is retried once it is approved |
| `SDK_RAMPS_ACTION_STALE` (409)        | The pending action changed since it was read, or the leg is busy | Read the order again and act on its current `pendingAction` |
| `SDK_RAMPS_NOTHING_TO_RETRY` (409)    | The order has no failure the user can retry  | Read the order; quote again if it says so |
| `SDK_RAMPS_ORDER_NOT_CANCELLABLE` (409) | The order is past the point it can be cancelled | None |
| `SDK_RAMPS_TX_NOT_FOUND` (404)        | No order with that id belongs to this user   | Verify the id |
| `SDK_RAMPS_MOVED_TO_V3` (410)         | A ramp call reached `/v1` or `/v2`. `message` names the SDK release to upgrade to | Upgrade `@pollar/core` to 0.12.0 or later |

---

## Cards

| Code | Description |
| --- | --- |
| `SDK_CARDS_PROVIDER_NOT_FOUND` (404) / `SDK_CARDS_HOLDER_NOT_FOUND` (404) / `SDK_CARDS_CARD_NOT_FOUND` (404) / `SDK_CARDS_FUNDING_NOT_FOUND` (404) | The provider, card holder, card or funding does not exist for this user |
| `SDK_CARDS_PROVIDER_NOT_CONFIGURED` (422) | The card provider has no usable configuration for this app |
| `SDK_CARDS_TERMS_NOT_ACCEPTED` (400) | The provider's terms were not accepted |
| `SDK_CARDS_KYC_ALREADY_SUBMITTED` (409) / `SDK_CARDS_KYC_NOT_APPROVED` (409) | The provider's KYC is already submitted, or not approved yet |
| `SDK_CARDS_REQUIREMENT_REQUIRED` (409) | A provider step (KYC, form, registration) is still open |
| `SDK_CARDS_PROVIDER_USER_TAKEN` (409) | The provider already holds this person under another account |
| `SDK_CARDS_PROVIDER_REJECTED` (422) / `SDK_CARDS_IP_NOT_SUPPORTED` (422) / `SDK_CARDS_OPERATION_UNSUPPORTED` (422) | The provider refused the request, the user's region, or the operation |
| `SDK_CARDS_FUNDING_UNAVAILABLE` (422) / `SDK_CARDS_FUNDING_WALLET_NOT_READY` (422) / `SDK_CARDS_FUNDING_INVALID_STATE` (409) | Funding is not possible now, the wallet is not ready, or the funding is not in a state for this action |
| `SDK_CARDS_PROVIDER_ERROR` (502) | The provider failed upstream; retry in a moment |

---

## Session, DPoP & passkeys

End-user session and token errors (sdk-api). These are handled by the SDK's auth flow; surface to users as "please sign in again".

| Code                                            | Description                                  |
| ----------------------------------------------- | -------------------------------------------- |
| `SDK_AUTH_INVALID_TOKEN` / `SDK_AUTH_TOKEN_EXPIRED` | Access token invalid or expired          |
| `SDK_AUTH_DPOP_REQUIRED` / `SDK_AUTH_DPOP_INVALID` / `SDK_AUTH_DPOP_USE_NONCE` | DPoP proof required / invalid / needs nonce |
| `SDK_REFRESH_TOKEN_INVALID` / `_EXPIRED` / `_REUSED` | Refresh token invalid, expired, or reused |
| `PASSKEY_CHALLENGE_MISSING` / `PASSKEY_VERIFICATION_FAILED` / `PASSKEY_DEPLOY_FAILED` | Passkey ceremony errors (smart wallets) |

> This is not the full enum: the server defines additional internal codes (hub-api admin, Pollar Pay, wallet services). The codes above are the ones an SDK or Server API integrator is most likely to encounter.

---

## Handling errors in the SDK

```typescript
import { appUnavailableMessage, isPollarApiError, transactionErrorMessage } from '@pollar/core';

// Transaction failures come back as outcomes: no try/catch needed.
const result = await pollar.runTx('payment', { destination, amount, asset });
if (result.status === 'error') {
  if (result.code === 'SDK_CONFIRMATION_DECLINED') return; // the user said no
  showError(appUnavailableMessage(result) ?? transactionErrorMessage(result.code, result.details));
}

// Methods that call the API directly throw.
try {
  const quotes = await pollar.quoteRamp(request);
} catch (err) {
  if (isPollarApiError(err) && err.code === 'SDK_RAMPS_NO_ROUTE') {
    // err.body.rejected lists every route and why it was dropped
  }
}

// Calling a flow step out of order throws an error with code 'INVALID_FLOW'.
try {
  pollar.verifyEmailCode('123456');
} catch (err) {
  if ((err as { code?: string }).code === 'INVALID_FLOW') {
    // wrong step for the current AuthState
  }
}
```

To observe transaction failures reactively, subscribe to `onTransactionStateChange` and inspect `state.phase` / `state.details` when `state.step === 'error'`.
