---
title: "@pollar/core"
---

Framework-agnostic TypeScript client for Pollar, for Stellar and Solana applications. Use this package directly if you are not using React, or to build custom integrations on top of the Pollar platform.

The client is multichain: a session carries one wallet per chain the app enables (`getWallets()`), balances and history are per chain, and `sendPayment()` takes a `chain`. The transaction builder (`buildTx` / `signTx` / `submitTx`) works on Stellar XDR; on Solana use `sendPayment()`. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support) for the full matrix.

**Version:** `0.11.5`

```bash
npm install @pollar/core
```

---

## `PollarClient`

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
});
```

**Constructor options:**

| Option           | Type             | Default                          | Description                                                                |
|------------------|------------------|----------------------------------|----------------------------------------------------------------------------|
| `apiKey`         | `string`         | —                                | **Required.** Your Pollar publishable key.                                 |
| `stellarNetwork` | `StellarNetwork` | `'testnet'`                      | Target Stellar network: `'testnet'` or `'mainnet'`.                        |
| `baseUrl`        | `string`         | `'https://sdk.api.pollar.xyz'`   | Override the Pollar API base URL. The SDK appends `/v2` to it. Useful for self-hosted deployments. |
| `confirmation`   | `'auto' \| 'prompt'` | `'auto'`                     | Confirmation policy. `'auto'`: the SDK settles every signature itself (for a co-signed wallet the device verifies the request against Turnkey and votes on its own). `'prompt'`: every signature is shown to the user first, whatever the custody. See [Co-signed wallets](#co-signed-wallets). |
| `cosignManual`   | `boolean`        | `false`                          | Keep the raw `cosign_pending` outcome instead of letting the SDK settle co-sign requests: your app drives `client.cosign` itself. |
| `cosignKeyManager` | `KeyManager`   | —                                | Where the device key of a co-signed wallet lives; defaults to the client's `keyManager`. |
| `loginTimeoutMs` | `number`         | `45000`                          | How long `login()` waits for an OAuth / wallet round-trip before failing. |

> Additional options are supported for non-web runtimes and advanced use: `storage`, `keyManager`, `walletAdapters` (array — see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters)), `requestTimeoutMs` (default `10000`), `submitTimeoutMs` (default `30000`), `retry`, `deviceLabel`, `visibilityProvider`, `openAuthUrl`, `oauthRedirectUri`, `passkey`, `passkeySign`, `logLevel`, `logger`, `onStorageDegrade`, and `maxIdleMs`. See the `PollarClientConfig` type for the full list (React Native consumers must inject a `storage` adapter, and provide `openAuthUrl` for OAuth).

---

## Authentication

Pollar's built-in authentication providers are Google OAuth, GitHub OAuth, Email OTP, and external Stellar wallets (Freighter and Albedo are auto-registered). You can register more wallet providers — every Stellar Wallets Kit wallet, or Privy embedded wallets — through the `walletAdapters` config option; see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters). A fifth path, passkey **Smart Wallet** login, is covered under Smart Wallets. All flows update `AuthState`, which can be observed via `onAuthStateChange`.

---

### `pollar.login(options)`

Unified entry point for starting an authentication flow. For email, this initiates the session and sends the OTP code in a single call. For wallet providers, it connects and authenticates the wallet.

```typescript
import { WalletType } from '@pollar/core';

// OAuth providers
pollar.login({ provider: 'google' });
pollar.login({ provider: 'github' });

// Email OTP (sends code automatically)
pollar.login({ provider: 'email', email: 'user@example.com' });

// Built-in external wallets — provider is the wallet id
pollar.login({ provider: WalletType.FREIGHTER }); // 'freighter-native'
pollar.login({ provider: WalletType.ALBEDO });    // 'albedo-native'

// Any wallet registered via `walletAdapters` — provider is that adapter's id
pollar.login({ provider: 'xbull' });  // Stellar Wallets Kit
pollar.login({ provider: 'privy' });  // Privy embedded wallet
```

The `provider` for a wallet is the adapter's `type`. Built-in Freighter/Albedo
use the `WalletType` enum (`'freighter-native'` / `'albedo-native'`); wallets
added through [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters)
use their own ids (`'xbull'`, `'lobstr'`, `'privy'`, …).

| Option     | Type                                                     | Description                                     |
|------------|----------------------------------------------------------|-------------------------------------------------|
| `provider` | `'google' \| 'github' \| 'email' \| (string & {})`      | Authentication provider, or a registered wallet adapter's id. |
| `email`    | `string`                                                 | Required when `provider` is `'email'`.          |

---

### Email OTP — step-by-step flow

For use cases that require manual control over each step of the email OTP flow (e.g. custom UI), the following methods are available individually:

#### `pollar.beginEmailLogin()`

Initializes a new email session. Transitions `AuthState` to `entering_email`.

```typescript
pollar.beginEmailLogin();
```

#### `pollar.sendEmailCode(email)`

Sends the OTP code to the provided email address. Must be called when `AuthState.step === 'entering_email'`.

```typescript
pollar.sendEmailCode('user@example.com');
```

#### `pollar.verifyEmailCode(code)`

Verifies the OTP code entered by the user and completes authentication. Must be called when `AuthState.step === 'entering_code'`.

```typescript
pollar.verifyEmailCode('123456');
```

---

### `pollar.cancelLogin()`

Cancels any in-progress authentication flow and resets `AuthState` to `idle`.

```typescript
pollar.cancelLogin();
```

---

### `pollar.logout()`

Signs out the current user, clears the session from storage, and resets all client state.

```typescript
pollar.logout();
```

---

### `pollar.getAuthState()`

Returns the current authentication state synchronously.

```typescript
const state = pollar.getAuthState();

if (state.step === 'authenticated') {
  console.log(state.session);
}
```

---

### `pollar.onAuthStateChange(callback)`

Subscribes to authentication state changes. The callback is invoked immediately with the current state, and on every subsequent change. Returns an unsubscribe function.

```typescript
const unsubscribe = pollar.onAuthStateChange((state) => {
  if (state.step === 'authenticated') {
    console.log('Logged in:', state.session);
  }
});

// Later:
unsubscribe();
```

**`AuthState` steps:**

| Step                    | Description                                              |
|-------------------------|----------------------------------------------------------|
| `idle`                  | No active session or flow.                               |
| `creating_session`      | Creating a client session on the server.                 |
| `entering_email`        | Waiting for the user to provide their email address.     |
| `sending_email`         | Sending the OTP code to the user's email.                |
| `entering_code`         | Waiting for the user to enter the OTP code.              |
| `verifying_email_code`  | Verifying the submitted OTP code.                        |
| `opening_oauth`           | Opening the OAuth provider window.                       |
| `connecting_wallet`       | Connecting to the external wallet extension.             |
| `signing_wallet_challenge`| The wallet is counter-signing the SEP-10 challenge.      |
| `wallet_not_installed`    | The requested wallet extension is not installed.         |
| `authenticating_wallet`   | Authenticating with the connected wallet.                |
| `creating_passkey`        | Running the passkey (Smart Wallet) device ceremony.      |
| `deploying_smart_account` | Deploying the passkey C-address on-chain (new users).    |
| `authenticating`          | Finalizing authentication with the Pollar server.        |
| `authenticated`           | User is authenticated. `session` and `verified` are set. |
| `error`                   | An error occurred. `message` and `errorCode` are set.    |

---

## Wallet

### `pollar.getWallet()`

The signed-in user's Stellar wallet as a `WalletInfo`, or `null` when there is no session or the user has no Stellar wallet (an app with [on-demand wallet creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation), or a user who signed in with a Solana wallet).

```typescript
const wallet = pollar.getWallet();
console.log(wallet?.address, wallet?.custody);
```

---

### `pollar.getWallets()`

Every wallet the user holds, one per chain, each with its `chain`. `[]` when there is no session or no wallet.

---

### `pollar.hasWallet()`

Whether the signed-in user has a wallet on any chain.

```typescript
if (!pollar.hasWallet()) {
  // offer to create it, or hide wallet features
}
```

---

### `pollar.createWallet()`

Creates the signed-in user's wallet, for apps whose wallet creation is **On demand**. The wallet is created on every chain the app serves and funded per the app's funding mode. Updates the session and notifies `onAuthStateChange` and `onWalletStateChange` subscribers. Idempotent: a user who already has a wallet gets it back.

```typescript
const wallet = await pollar.createWallet();
console.log(wallet.address);
```

Throws a `PollarApiError`:

| `code` | When |
| ------ | ---- |
| `SDK_WALLET_PROVISIONING_DISABLED` | The app's wallet creation is **Never** |
| `SDK_WALLET_PROVISIONING_UNSUPPORTED` | The user signed in with their own wallet or a passkey |

---

### `isWalletRequired(errorOrOutcome)`

True when a returned outcome or thrown error is `SDK_WALLET_REQUIRED`: the user has no wallet yet. Exported from `@pollar/core` with `WALLET_REQUIRED_CODE`.

```typescript
import { isWalletRequired } from '@pollar/core';

const signed = await pollar.signTx(unsignedXdr);
if (isWalletRequired(signed)) {
  await pollar.createWallet();
}
```

---

## Network

### `pollar.getNetwork()`

Returns the currently active Stellar network.

```typescript
const network = pollar.getNetwork(); // 'testnet' | 'mainnet'
```

---

### `pollar.setNetwork(network)`

Switches the active Stellar network.

```typescript
pollar.setNetwork('mainnet');
```

---

### `pollar.onNetworkStateChange(callback)`

Subscribes to network state changes. Returns an unsubscribe function.

```typescript
const unsubscribe = pollar.onNetworkStateChange((state) => {
  if (state.step === 'connected') {
    console.log('Network:', state.network);
  }
});
```

---

## Transactions

Pollar handles transaction building and signing through a state machine. Use `onTransactionStateChange` to observe progress in your UI.

### `pollar.buildTx(operation, params, options?)`

Builds an unsigned Stellar transaction on the server. Transitions `TransactionState` through `building` → `built` (or `error`).

```typescript
await pollar.buildTx('payment', {
  destination: 'GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  amount: '10.00',
  asset: { type: 'credit_alphanum4', code: 'USDC', issuer: 'GABC...' },
});
```

| Parameter   | Type              | Description                              |
|-------------|-------------------|------------------------------------------|
| `operation` | `string`          | Stellar operation type (e.g. `payment`). |
| `params`    | `object`          | Operation-specific parameters.           |
| `options`   | `object`          | Optional build-time overrides.           |

---

### `pollar.signAndSubmitTx(unsignedXdr)`

Signs and submits a previously built transaction. For custodial wallets (social/email login), signing is performed server-side. For external wallets (Freighter/Albedo), signing is performed client-side and submitted directly to Horizon.

Must be called when `TransactionState.step === 'built'`.

```typescript
const state = pollar.getTransactionState();

if (state?.step === 'built') {
  await pollar.signAndSubmitTx(state.buildData.unsignedXdr);
}
```

---

### `pollar.signAuthEntry(entryXdr, { validUntilLedger })`

Signs a single Soroban `SorobanAuthorizationEntry` — the user's authorization on its own, without a transaction envelope. Use it when your own contract is the transaction source (it sponsors the gas and submits), and all it needs from the user is consent to the invocation.

For **external wallets** the adapter signs the entry directly. For **custodial wallets** Pollar signs server-side, and only if every contract and function in the entry's invocation tree is allowlisted for your app under **Wallets → [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy)**. That allowlist is what keeps the custodial signer from being usable as a signing oracle, so an unconfigured app signs nothing. **Passkey smart accounts** (C-address sessions) are not supported by this method in the current build: they sign auth entries through their passkey ceremony, which this call does not run, so it resolves to `{ status: 'error' }` rather than signing with the wrong key.

`validUntilLedger` is the absolute ledger the signature expires at — compute it from the network's latest ledger. Your app's validity window caps how far ahead it may be (120 ledgers by default, 300 at most).

```typescript
const result = await pollar.signAuthEntry(entryXdr, { validUntilLedger: latestLedger + 100 });

if (result.status === 'signed') {
  await myBackend.settle(result.signedAuthEntry);
} else {
  console.error(result.details); // e.g. SOROBAN_AUTH_FUNCTION_NOT_ALLOWED
}
```

Resolves to `{ status: 'signed'; signedAuthEntry: string }` or `{ status: 'error'; details?: string }` — like the other transaction methods, it does not throw on a denial. The denial codes are listed under [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes).

---

### `pollar.getTransactionState()`

Returns the current transaction state synchronously, or `null` if no transaction is in progress.

```typescript
const state = pollar.getTransactionState();
```

---

### `pollar.onTransactionStateChange(callback)`

Subscribes to transaction state changes. Returns an unsubscribe function.

```typescript
const unsubscribe = pollar.onTransactionStateChange((state) => {
  if (state.step === 'success') {
    console.log('Transaction hash:', state.hash);
  }
});
```

**`TransactionState` steps:**

| Step                          | Description                                                          |
|-------------------------------|---------------------------------------------------------------------|
| `idle`                        | No transaction in progress.                                         |
| `building`                    | Building the transaction on the server.                             |
| `built`                       | Transaction built. `buildData.unsignedXdr` is available.            |
| `signing`                     | Signing the built transaction.                                      |
| `signed`                      | Signed. `signedXdr` is available.                                   |
| `submitting`                  | Submitting the signed transaction.                                  |
| `signing-submitting`          | Custodial atomic sign+submit (server swallows the boundary).        |
| `building-signing-submitting` | Custodial atomic build+sign+submit (`runTx` / `buildAndSignAndSubmitTx`). |
| `awaiting_cosign`             | A co-signed wallet: the request (`request: CosignRequest`) waits for the device's vote. Under `confirmation: 'auto'` the SDK settles it and moves on; under `'prompt'` or `cosignManual` your app does. |
| `submitted`                   | Accepted by the network; awaiting ledger confirmation. `hash` is set.   |
| `success`                     | Transaction confirmed. `hash` is available.                         |
| `error`                       | Transaction failed. Carries `phase`, and optionally `code` / `message` / `details`. |

---

## Wallet Balance

### `pollar.refreshBalance()`

Fetches the current balances for the **authenticated** wallet and drives the wallet-balance state machine (takes no arguments).

```typescript
await pollar.refreshBalance();
```

---

### `pollar.getWalletBalance(publicKey, network?)`

Fetches balances for an **arbitrary** public key without touching the balance state machine. Returns the balance content directly.

```typescript
const { balances } = await pollar.getWalletBalance('GXXX...');
```

---

### `pollar.getWalletBalanceState()`

Returns the current wallet balance state synchronously.

```typescript
const state = pollar.getWalletBalanceState();

if (state.step === 'loaded') {
  console.log(state.data.balances);
}
```

---

### `pollar.onWalletBalanceStateChange(callback)`

Subscribes to wallet balance state changes. Returns an unsubscribe function.

```typescript
const unsubscribe = pollar.onWalletBalanceStateChange((state) => {
  if (state.step === 'loaded') {
    console.log(state.data.balances);
  }
});
```

---

## Transaction History

### `pollar.fetchTxHistory(params?)`

Fetches paginated transaction history for the authenticated user, across every chain the app enables unless you filter by `chain`.

```typescript
await pollar.fetchTxHistory({
  limit: 20,
  offset: 0,
  chain: 'SOLANA',
});
```

| Option   | Type     | Default | Description                                                        |
|----------|----------|---------|--------------------------------------------------------------------|
| `limit`  | `number` | —       | Number of records to return.                                       |
| `offset` | `number` | `0`     | Offset for pagination (history uses offset-based paging).          |
| `chain`  | `'STELLAR' \| 'POLYGON' \| 'SOLANA'` | — | Only this chain's records. Omit for all chains. |

> Only transactions submitted through Pollar appear here. A record reads `PENDING` immediately after build and updates to `SUCCESS` or `FAILED` once submitted. Each record exposes `id`, `hash`, `chain`, `network`, `status`, `operation`, `summary`, `details`, `fee` (`{ amount, unit }`: stroops on Stellar, lamports on Solana, wei on Polygon), `resultCode`, and `createdAt`.

---

### `pollar.getTxHistoryState()`

Returns the current transaction history state synchronously.

```typescript
const state = pollar.getTxHistoryState();

if (state.step === 'loaded') {
  console.log(state.data.records);
}
```

---

### `pollar.onTxHistoryStateChange(callback)`

Subscribes to transaction history state changes. Returns an unsubscribe function.

```typescript
const unsubscribe = pollar.onTxHistoryStateChange((state) => {
  if (state.step === 'loaded') {
    console.log(state.data.records);
  }
});
```

---

## KYC

Pollar provides a KYC (Know Your Customer) flow that integrates with third-party identity verification providers. Every method takes optional `corridorId` / `cardProviderId` arguments: with one of them, the read or the session is scoped to that ramp route's or card provider's steps instead of the app's own.

### `pollar.getKycProviders(country, corridorId?, cardProviderId?)`

Returns the KYC providers available for the given country code. With `corridorId`, only the one option the route asks for (or none).

```typescript
const { providers } = await pollar.getKycProviders('MX');
// providers: { id, name, flow: 'iframe' | 'form' | 'redirect', levels: KycLevel[] }[]
```

---

### `pollar.getKycStatus(providerId?, corridorId?, cardProviderId?)`

The current KYC status for the authenticated user. `status` is what gates the user; `decisionStatus` and `reviewReason` say why a `pending` is pending; `pendingStep` names the requirement step still open.

```typescript
const { status, decisionStatus, reviewReason, level, providerId, expiresAt, pendingStep } =
  await pollar.getKycStatus();
// status: 'none' | 'pending' | 'approved' | 'rejected' | 'expired'
// decisionStatus: 'pending' | 'manual_review' | 'approved' | 'rejected' | 'expired'
```

---

### `pollar.startKyc(body)`

Starts a KYC session with a provider. An `iframe` / `redirect` provider answers `kycUrl`; a `form` provider answers the `fields` to render.

```typescript
const session = await pollar.startKyc({
  providerId: 'provider_id',
  level: 'basic',
  country: 'MX',
  corridorId,       // optional: the ramp route this KYC is for
  idempotencyKey,   // optional: the same key on a retry reuses the session
});
// session: { sessionId, kycUrl?, fields? }
```

---

### `pollar.resolveKyc(providerId, level?, country?, corridorId?, idempotencyKey?, cardProviderId?)`

Checks the status and returns early when already approved; otherwise starts a session. Resolves to `{ alreadyApproved: boolean }` plus the `startKyc` response when a session was opened. `SDK_KYC_ALREADY_APPROVED` from the server is mapped to `{ alreadyApproved: true }`.

```typescript
const result = await pollar.resolveKyc('provider_id', 'basic', 'MX');
if (!result.alreadyApproved && result.kycUrl) window.open(result.kycUrl);
```

---

### `pollar.pollKycDecision(providerId, opts?)` / `pollar.pollKycStatus(providerId, opts?)`

Polls until the decision settles: `approved`, `rejected`, `expired`, **or `pending` held for manual review**. `pollKycDecision` resolves with the full status object; `pollKycStatus` reduces it to the `KycStatus` value. Both throw `'KYC polling timed out'` past `timeoutMs`.

```typescript
const status = await pollar.pollKycStatus('provider_id', { intervalMs: 3000, timeoutMs: 300_000 });
```

| Option           | Type     | Default   | Description                                      |
|------------------|----------|-----------|--------------------------------------------------|
| `intervalMs`     | `number` | `3000`    | Polling interval in milliseconds.                |
| `timeoutMs`      | `number` | `300000`  | Maximum wait time before throwing.               |
| `corridorId`     | `string` | —         | Scope to a ramp route's steps.                   |
| `cardProviderId` | `string` | —         | Scope to a card provider's steps.                |

**`KycStatus` values:** `'none'` · `'pending'` · `'approved'` · `'rejected'` · `'expired'`

**`KycLevel` values:** `'basic'` · `'intermediate'` · `'enhanced'`

---

### Requirement steps

An app, a ramp route or a card provider can require an ordered list of steps before the user proceeds. Steps are all required, in order (AND); the `optionIds` inside a step are alternatives (OR): the step is satisfied when any accepted option is. Step types: `KYC`, `FORM`, `REGISTRY_CHECK` (an identity registry such as SEGIP), `PROVIDER_REGISTRATION` (sign the user up with the ramp or card provider from the verified identity and form answers). `@pollar/react` walks them from `<KycModal>`, `<RampWidget>` and `<CardModal>`; the headless surface:

| Method | Description |
|---|---|
| `getAppRequirements()` → `{ steps, next, completed, total }` | The app's own steps and the user's progress. `next` is the open step (`type`, `optionId`, `status`, `reviewReason?`) or `null` |
| `getRequirementForm(formId)` → `RequirementForm` | A form asked by a `FORM` step: `fields` (`text`, `textarea`, `number`, `date`, `select`, `multiselect`, `checkbox`, `email`, `phone`, with `label.en` / `label.es`, `required`, `options`, `validation`), the user's previous `answers`, and the `missing` keys |
| `submitRequirementForm(formId, answers)` → `{ formId, version, missing }` | Stores the answers encrypted. Invalid ones fail with `KYC_FORM_INVALID_ANSWERS` and `body.errors: { key, code }[]` |
| `getRegistryCheck(optionId)` / `submitRegistryCheck(optionId, { surname1, surname2?, complementNumber? })` | A `REGISTRY_CHECK` step: the prefilled identity (only the surname split and the document complement are editable) and its `status` / `rejectedFields` |
| `getProviderRegistration(corridorId)` / `submitProviderRegistration(corridorId)` | Whether the user is registered with the route's ramp provider, whether they can be now, what is shared, and the user's consent to register |

A ramp quote reports the first open step of each route in `requirementsRequired` (see [`getRampsQuote`](#pollargetrampsquotequery)); complete it and quote again.

---

## Ramps

The registered-adapter details in this section are checked against SDK source
`0.12.0-rc.1` and backend revision
[`2c7a5dc`](https://github.com/pollar-xyz/pollar-platform/commit/2c7a5dc1975e0dcc61dd846bf0c8e48dff8ca0e5).
This source snapshot does not establish which npm version or API revision your
deployment runs; confirm both before depending on optional fields.

Pollar supports on-ramp (fiat → crypto) and off-ramp (crypto → fiat) flows through integrated third-party providers. A ramp settles on the chain its route names (`chain` on the responses): Stellar, Solana or Polygon.

Provider code and supported chain identifiers do not establish availability in
your deployment. Application configuration, network, wallets, credentials and
settlement verification gates determine which routes can be offered. Existing
[KYC and requirement steps](#requirement-steps) remain part of eligibility.

### `pollar.getRampsQuote(query)`

Returns the quotes for a ramp, sorted by recommendation: the first item is the best option.

```typescript
const { quotes, requirementsRequired, unavailable } = await pollar.getRampsQuote({
  direction: 'onramp',
  country: 'BR',
  currency: 'BRL',
  amount: 100,
});
```

| Query field          | Type                                   | Description                                                   |
|----------------------|----------------------------------------|---------------------------------------------------------------|
| `direction`          | `'onramp' \| 'offramp'`                | **Required.**                                                 |
| `country`            | `string`                               | **Required.** ISO 3166-1 alpha-2.                             |
| `currency`           | `string`                               | **Required.** The fiat currency.                              |
| `amount`             | `number`                               | **Required.** In `amountDenomination`.                        |
| `amountDenomination` | `'fiat' \| 'crypto'`                   | What `amount` is in. Default fiat.                            |
| `amountExact`        | `string`                               | The exact decimal string when `amount` would lose precision.  |
| `chain`              | `'STELLAR' \| 'POLYGON' \| 'SOLANA'`   | Only routes that settle on this chain.                        |
| `routeId`            | `string`                               | Re-quote one route.                                           |

The response:

| Field                  | Description                                                                                       |
|------------------------|---------------------------------------------------------------------------------------------------|
| `quotes`               | `RampQuote[]`: `quoteId`, `provider`, `rail` (`SPEI`, `PIX`, `PSE`, `ACH`, `BREB`, `QR`), `protocol` (`SEP-24` / `REST`), `fee`, `rate`, `estimatedTime`, `recommended`, `requiredFields` (the contact / bank fields to collect), and the amounts below |
| `requirementsRequired` | Routes not quoted because a requirement step is still open: `{ corridorId, type, optionId, status, position, completed, total }`. Complete the step (see [Requirement steps](#requirement-steps)) and quote again |
| `unavailable`          | Providers that could not quote, with a `code`                                                     |

Each quote carries the bounds of the **route** and, separately, what applies to
**this user**:

| Field               | Meaning                                                                 |
| ------------------- | ----------------------------------------------------------------------- |
| `minAmount` / `maxAmount` | What the route will serve. Same for every user.                   |
| `fiatAmount`        | The fiat this quote actually settles — **not always what you asked for**. Display this one. |
| `cryptoAmount`      | The crypto the wallet will be **debited** on an off-ramp. `null` on an on-ramp. Fund the wallet with at least this — see below. |
| `availableAmount`   | The fiat this user's wallet balance covers on an off-ramp. `null` when there is no answer to give: an on-ramp, a provider without its own FX rate, or a balance Pollar cannot read. `null` never means zero — your app may hold the balance elsewhere and fund the wallet before the user signs. |
| `expiresAt`         | When the quote stops being accepted. **This is the deadline to count down.** |
| `providerExpiresAt` | When the underlying provider's own quote dies, or `null`. Informational — see below. |
| `route` / `terms`   | Optional registered-adapter route and exact accepted terms. `terms` carries decimal-string `fiatAmount`, `cryptoAmount`, `feeAmount` and their currencies plus `assetCode`, nullable `assetIssuer` and `assetChain`. |

Use exact `terms` when present. Their crypto total describes the credit on an
on-ramp and the debit on an off-ramp; the compatibility numeric `cryptoAmount`
remains null on deposits. Do not reconstruct totals from `rate` or convert exact
strings through floating-point arithmetic. `terms.feeAmount` is a disclosed
component already included in the totals; do not add it again. `amountExact` is an additive input
for registered adapters; it does not make legacy providers exact-decimal APIs.

#### Quote expiry: count down `expiresAt`, not `providerExpiresAt`

A Pollar quote is accepted for **15 minutes**. Past `expiresAt`, starting a ramp
with that `quoteId` fails with `SDK_RAMPS_QUOTE_EXPIRED` and you request a new
one.

Providers can run on shorter clocks; `providerExpiresAt` reports their validity
when available. It does not replace the public `expiresAt` countdown. Registered
adapters can use an unexpired firm offer or refresh it before dispatch. The
default policy requires unchanged exact totals; a change outside the route's
authorized policy returns `SDK_RAMPS_QUOTE_CHANGED`. Request a fresh quote and
show its terms for user acceptance before starting again. A reserved operation
is replayed from saved terms rather than repriced.

Legacy providers retain their own refresh behavior. Do not assume that an
expired provider quote will always be refreshed without a visible price change.

#### The amount you asked for is not always the amount quoted

Providers that price by the crypto side land *near* your figure rather than on
it. Ask to receive 12 BOB from Stereum and the quote settles **12.13**. That is
the number it will really pay, and it is what `fiatAmount` reports — show it,
because the user will see 12.13 arrive in their bank.

It also matters for arithmetic: `rate` is published against `fiatAmount`, so
dividing *your* requested figure by it gives a different answer.

```ts
// 12 / 10.734513274336285  ->  1.1178…  ->  1.12   ✗ a cent short
// 12.13 / 10.734513274336285  ->  1.13          ✓ what will be charged
```

Which is why you should not divide at all — read `cryptoAmount`.

#### Funding an off-ramp: use `cryptoAmount`

An off-ramp is paid from the wallet, so the required crypto has to be there
before payment. Use exact `terms.cryptoAmount` when present, otherwise the
compatibility `cryptoAmount`, to display the quoted debit. Transaction fees and
chain-specific prerequisites still apply; the asset amount alone does not
guarantee that a wallet can submit the payment.

Do not derive it by dividing the fiat amount by `rate`. `rate` is published
against an amount already rounded to the cent, so the division cannot recover
the charge and can land you a cent short; the ramp then fails with
`SDK_RAMPS_INSUFFICIENT_BALANCE`.

Some legacy providers refresh with a fixed crypto amount and a changing fiat
payout. That behavior is provider-specific; registered adapters enforce their
saved terms and declared refresh policy. Read the returned transaction terms
and status rather than assuming a universal pricing or settlement guarantee.

---

### `pollar.createOnRamp(body)`

Creates an on-ramp transaction (fiat → crypto).

```typescript
const onramp = await pollar.createOnRamp({ ... });
console.log(onramp.depositInstructions);
// { txId, provider, status, kycUrl?, pendingSignature?, depositInstructions }
```

---

### `pollar.createOffRamp(body)`

Creates an off-ramp transaction (crypto → fiat).

```typescript
const offramp = await pollar.createOffRamp({ ... });
```

---

#### Retrying a start that timed out

The backend can replay an already persisted transaction when a sequential
`createOnRamp` / `createOffRamp` call repeats its `quoteId`, returning current
state. Retain the original body and quote ID when recovering a lost response;
do not create a new quote to retry an unknown payment outcome. If you have the
`txId`, read `getRampTransaction(txId)` first.

Ramp starts have a 30-second SDK request budget, distinct from the general
10-second default. A timeout can happen after the server committed and does
not prove that an order or payment failed. `reconciliationRequired` means the
existing transfer needs review; do not submit a second transfer.

The complete cross-provider atomic retry contract remains pending.
There is no supported ramp `Idempotency-Key` header in this revision; existing
quote replay is not a universal guarantee that every provider's ambiguous
write can be retried. Follow the returned action or request operator review
when the outcome cannot be established.

---

### `pollar.getRampTransaction(txId)`

Returns the current state of a ramp transaction by ID.

```typescript
const tx = await pollar.getRampTransaction('tx_id');
console.log(tx.status);
```

`status` stays `pending`, `processing`, `completed` or `failed`. Enrolled
transactions can additionally return `lifecycleState`: `created`,
`awaiting_payment`, `processing`, `settling_onchain`, `completed`, `failed` or
`refunded`. Refunds project to compatibility `failed`; legacy rows may have no
lifecycle. `reconciliationRequired` is separate from either state field.

Optional `milestones` describe verified receipt/payment observations. A raw
`txHash`, provider success response or intermediary bridge hash alone does not
prove end-to-end completion.

### Registered-adapter actions

`getRampRoutes()` returns eligible routes and their capabilities for the
authenticated application and user. It can return an empty list when no
registered integration satisfies configuration and verification gates; legacy
providers can still be available through the quote flow. The chain enum is
`STELLAR`, `POLYGON` or `SOLANA`, distinct from `mainnet` / `testnet`.

```typescript
const { routes } = await pollar.getRampRoutes();
// Populate choices from routes; do not assume a provider or direction is enabled.

// Call from the user's explicit Continue action for a saved user_ready step.
async function continueAfterUserConfirmation(txId: string) {
  const current = await pollar.getRampTransaction(txId);
  if (current.nextAction?.kind !== 'user_ready' ||
      current.transactionVersion === undefined || current.reconciliationRequired) {
    return current;
  }
  return pollar.continueRamp(txId, {
    actionId: current.nextAction.actionId,
    transactionVersion: current.transactionVersion,
  });
}
```

Render the saved `nextAction`; `describeRampAction(snapshot)` supplies a shared
UI interpretation, and `mergeRampSnapshot(previous, incoming)` prevents older
versions replacing newer progress. Continuations bind to both `actionId` and
`transactionVersion`; refresh status when an action is stale. Information steps
can supply `fields` to `continueRamp`; signed steps supply `signedPayload`.

For a `sign_transaction` step, `signRampAction(txId, snapshot)` refreshes the
action, invokes a registered signing handler and continues the workflow. Every
chain/encoding pair needs `registerRampSigningHandler(chain, encoding, handler)`,
including `STELLAR` / `xdr`. The handler must validate the payload, account,
chain and network, then return the signed payload without broadcasting it.
Signing and continuation require user interaction; polling and restoration
must never trigger them automatically. Existing legacy signature helpers below
remain supported.

---

### `pollar.pollRampTransaction(txId, opts?)`

Polls a ramp transaction until it reaches a terminal status.

```typescript
const finalStatus = await pollar.pollRampTransaction('tx_id', {
  intervalMs: 3000,
  timeoutMs: 120000,
});
```

| Option       | Type     | Default  | Description                        |
|--------------|----------|----------|------------------------------------|
| `intervalMs` | `number` | `5000`   | Polling interval in milliseconds.  |
| `timeoutMs`  | `number` | `600000` | Maximum wait time before throwing. |

---

### More ramp methods

| Method | Description |
|---|---|
| `getRampCountries()` → `{ countries: { code, currency }[] }` | The countries (and fiat currency) the app's enabled ramp providers serve on its network. Drive the country picker from this |
| `getRampTransaction(txId)` | One ramp: `status`, `direction`, `amount`, `currency`, `chain`, `txHash`, `depositInstructions`, `pendingSignature`, `fundsInTransit`, `updatedAt` |
| `retryRampTransaction(txId)` | Run the pending step of a ramp whose funds are in transit now, instead of at the next pass |
| `completeWithdraw(txId)` | Complete an off-ramp once the anchor's KYC is done: builds, signs and submits the withdraw payment |
| `submitRampSignature(txId, { signedXdr, action })` | Resume a ramp from an **external** wallet after the client signed the `pendingSignature` XDR (`action`: `'sep10'` or `'withdraw_payment'`) |
| `getRampLiquidity(rail)` → `{ rail, liquidity, available, message? }` | Live liquidity on a payout rail (`'PIX'`, `'BREB'`). `available: false` means the rail cannot be served right now |
| `getRampKycStatus()` → `{ provider, hasApproved, status }` | Poll after an off-ramp answered `kycRequired: true`; once `hasApproved`, request a fresh quote |
| `decodePixQr(qrCode)` → `{ decoded }` | Decode a Pix "copia e cola" payload to show the payee before an off-ramp. `decoded: null` is a stale code. Pass the original payload as `bankDetails.qrCode` on `createOffRamp` |

The on/off-ramp responses also carry `onboardingStatus` (`'kyc'` / `'endorsement'` / `'awaiting_provider'`) while the provider is still onboarding the user, `kycUrl` / `tosUrl` to send them to, and `depositInstructions` (a scannable Pix / Stellar / URL payload plus copyable fields) on an on-ramp.

---

## App Config

### `pollar.getAppConfig()`

Returns the application configuration associated with your API key, as configured in the Pollar Dashboard.

```typescript
const config = await pollar.getAppConfig();
```

---

## One-shot transactions

For build → sign → submit in a single call, use `runTx` (an alias of
`buildAndSignAndSubmitTx`). Both drive the same `TransactionState` machine as the
split calls and resolve to a `SubmitOutcome` (`{ status: 'success' | 'pending' | 'error', … }`).

```typescript
const outcome = await pollar.runTx('payment', {
  destination: 'GXXX...',
  amount: '10.00',
  asset: { type: 'credit_alphanum4', code: 'USDC', issuer: 'GABC...' },
});
if (outcome.status === 'error') console.error(outcome.details, outcome.resultCode);
```

Lower-level building blocks are also available: `signTx(unsignedXdr, { skipSponsorship? })`
(a managed wallet signs server-side, an external wallet in its adapter; only passkey
smart wallets cannot use it), `submitTx(signedXdr)`, `getTxStatus(hash)`,
`createAccount()`, and `resetTransactionState()`.

### `pollar.sendPayment(params)`

One entry point for a payment on any chain. `SendPaymentParams` is a per-chain
union; the Stellar member routes through `buildAndSignAndSubmitTx` (so external
adapters and passkey wallets keep the split flow), the Solana and Polygon members
are a single server-side call for a managed wallet.

```typescript
// Stellar: decimal amount and an asset
await pollar.sendPayment({ destination: 'G...', amount: '1.5', asset: { type: 'native' } });

// Solana: integer base units. Omit `mint` for native SOL (lamports)...
await pollar.sendPayment({ chain: 'SOLANA', destination: '7xKX...', amount: '1500000000' });

// ...or pass the SPL mint and its smallest unit (USDC has 6 decimals)
await pollar.sendPayment({
  chain: 'SOLANA',
  destination: '7xKX...',
  amount: '2500000',
  mint: 'EPjFWdd5AufqSSqeM3qQw8xJXpY4zFrPyLKS3jcKBVMy',
});
```

| `chain` | `amount` | Asset field | Signing |
|---|---|---|---|
| `'STELLAR'` (default) | Decimal string | `asset` | Managed: Pollar signs. External / passkey: the adapter signs |
| `'SOLANA'` | Integer base units (lamports, or the mint's smallest unit) | `mint?` (omit for SOL) | Managed and co-signed: one call to `/v2/tx/build-sign-submit`. External (SIWS): Pollar builds, the wallet signs via `signSolanaTransaction`, Pollar submits |
| `'POLYGON'` | Integer base units (wei, or the token's smallest unit) | `mint?` (the ERC-20 contract) | Managed and co-signed; an external Polygon wallet is refused |

On Solana, when the token is marked **sponsor transfers** in the dashboard, the
app's GAS wallet is the fee payer and the recipient's associated token account is
created in the same transaction. Sending an SPL token the sender does not hold yet
fails with `TX_NO_TRUSTLINE`. The result is the same `SubmitOutcome` as `runTx`,
with the Solana signature in `hash`.

---

## Enabled assets & trustlines

The app's dashboard-enabled assets paired with the authenticated wallet's
on-chain trustline state.

- `pollar.getEnabledAssetsState()` — current state snapshot.
- `pollar.refreshAssets()` — refresh the enabled-assets state machine.
- `pollar.onEnabledAssetsStateChange(cb)` — subscribe; returns an unsubscribe fn.
- `pollar.setTrustline(asset, opts?)` — establish (omit `limit`) or remove
  (`limit: '0'`) a trustline. The app covers the reserve and the fee whenever
  the dashboard sponsors trustlines; pass `{ skipSponsorship: true }` to make
  the user's wallet pay instead. Returns a `TrustlineOutcome`.

```typescript
await pollar.setTrustline({ code: 'USDC', issuer: 'GABC...' });
```

---

## Swap

Multi-venue asset swaps (SDEX / AMM). Empty `getSwapConfig()` means swap is
disabled for the app — hide the UI.

- `pollar.getSwapConfig()` → `Promise<SwapVenue[]>` — venues this app exposes.
- `pollar.getSwapTokens()` → `Promise<SwapToken[]>` — curated "buy" token catalog.
- `pollar.getSwapQuote(params)` → `Promise<SwapQuote[]>` — quotes ranked best-first.
- `pollar.swap(quote, opts?)` → `Promise<SubmitOutcome>` — execute a quote
  (establishes the buy-asset trustline first when needed). Drives `TransactionState`.

---

## Earn

Yield vaults (DeFindex) and lending pools (Blend). Empty `getEarnProviders()`
means Earn is disabled — hide the UI.

- `pollar.getEarnProviders()` → `Promise<EarnProviderId[]>`.
- `pollar.getEarnOpportunities(provider)` → `Promise<EarnOpportunity[]>` — vaults/pools with live APY.
- `pollar.getEarnPosition(params)` → `Promise<EarnPosition>` — the wallet's position.
- `pollar.earnDeposit(params)` → `Promise<SubmitOutcome>`.
- `pollar.earnWithdraw(params)` → `Promise<SubmitOutcome>`.

---

## Token distribution

- `pollar.listDistributionRules()` → `Promise<DistributionRule[]>` — claimable rules for the app.
- `pollar.claimDistributionRule(body)` → claims a rule for the authenticated user.

---

## Sessions

Manage the authenticated user's active sessions (devices).

- `pollar.listSessions()` → `Promise<SessionInfo[]>`.
- `pollar.getSessionsState()` / `pollar.fetchSessions()` / `pollar.onSessionsStateChange(cb)` — the sessions state machine.
- `pollar.revokeSession(familyId)` — revoke one session.
- `pollar.logout({ everywhere: true })` or `pollar.logoutEverywhere()` — sign out everywhere.

---

## Smart Wallets (passkey)

Passkey-backed Soroban **C-address** login. Requires a `passkey` ceremony in
`PollarClientConfig` (`@pollar/react` supplies one via `@simplewebauthn/browser`;
browser-only for now).

- `pollar.loginSmartWallet()` — log in with an existing passkey wallet.
- `pollar.createSmartWallet()` — create + deploy a new passkey C-address.

See [Smart Wallets](https://docs.pollar.xyz/docs/smart-wallets/overview) for the full flow.

---

## Stellar SEP proofs

Ownership proofs signed by the user's Stellar wallet, custodial or external:

- `pollar.stellar.sep53.signMessage(message)` → `{ status: 'signed', signature, signerAddress, scheme: 'sep53' }` or `{ status: 'error', code?, details? }`. SEP-53 message signing.
- `pollar.stellar.sep10.sign({ challengeXdr, homeDomains?, webAuthDomain? })` → `{ status: 'signed', signedXdr, signerAddress }` or an error. Signs a SEP-10 web-auth challenge from your own anchor.

---

## Lifecycle and wallet readiness

| Method | Description |
|---|---|
| `pollar.ready()` → `Promise<void>` | Resolves once the keypair and the stored session are restored. Await it before reading `getAuthState()` on a cold start |
| `pollar.destroy()` | Detaches the cross-tab storage listener and aborts any in-flight login |
| `pollar.refresh()` | Refreshes the access token; concurrent calls are coalesced |
| `pollar.refreshWalletState()` → `Promise<WalletProvisioning \| null>` | Asks the server where the Stellar account stands: `'READY'`, `'CREATING'`, `'FAILED'` or `'NONE'`. Never throws |
| `pollar.onWalletStateChange(cb)` | Subscribe to that readiness; replays the current value, then emits on change |
| `isWalletNotReady(errorOrOutcome)` / `WALLET_NOT_READY_CODE` | `true` when a failure is "the wallet is still being prepared" (`SDK_WALLET_NOT_READY`), whether thrown or returned as an outcome. Retry once the state is `READY` |
| `pollar.getUserProfile()` → `PollarUserProfile \| null` | Email, names, avatar and linked providers. Held in memory only, never persisted |
| `pollar.providerAction(provider, action, payload?)` | A named secondary step on a registered auth provider (the email provider's `sendCode` / `verifyCode`) |
| `pollar.setPasskeyDefaults({ passkey?, passkeySign? })` | Fill in the passkey ceremony and signer when they were not configured at construction (`@pollar/react` does this) |
| `pollar.getNetworkState()` | `{ step: 'idle' }` or `{ step: 'connected', network }` |
| `pollar.getWalletType()` → `WalletId \| null` | The provider the session was opened with |
| `pollar.listWalletAdapters()` → `{ id, meta, chain }[]` | The registered adapters, Freighter and Albedo first, each with its `chain` |
| `pollar.getWalletAdapter(id)` | One registered adapter instance |
| `pollar.getLogger()` | The client's level-gated logger |

---

## Co-signed wallets

A mainnet app whose dashboard sets [wallet custody](https://docs.pollar.xyz/docs/operator-guide/wallets/settings) to **Co-signed with Turnkey** gives each user a 2-of-2 quorum: this device's key plus Pollar's approver key. Every signature needs both votes, on Stellar, Solana and Polygon. The concepts are in [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets); this section is the client surface.

The device key is a second P-256 key kept under the `cosign` namespace of the client's storage (`cosignKeyManager` to hold it elsewhere, for example hardware-backed). Logout does not reset it, so the user's vote survives signing out. `login()` and `createWallet()` send its public key, which becomes the user's half of the quorum: a user on an SDK older than 0.11.5 cannot create a co-signed wallet.

### Confirmation policy

`confirmation` in `PollarClientConfig` decides how much the user sees, whatever the custody:

| Policy | Custodial wallet | Co-signed wallet | External wallet |
|---|---|---|---|
| `'auto'` (default) | Signs on the server, no prompt | The device verifies the request against Turnkey and votes on its own; `signTx` returns `signed`, `runTx` returns `success`, exactly as for a custodial wallet | Only the wallet's own popup |
| `'prompt'` | Shows the transaction first, then signs | Shows it first, then verifies and votes | Shows it first, then the wallet's popup |

Under `'prompt'`, `@pollar/react` renders the prompt (`<ConfirmModal>`); a headless app subscribes with `onConfirmationRequest` and answers each `PendingConfirmation` with `confirm()` or `reject()`. While nothing is subscribed, a signing call fails with `SDK_CONFIRMATION_UNAVAILABLE` rather than signing unasked.

```typescript
pollar.onConfirmationRequest((pending) => {
  for (const c of pending) {
    // c.kind: 'sign' | 'sign_and_send' | 'build_sign_submit'; c.network; c.operation; c.details
    showDialog(c).then((ok) => (ok ? c.confirm() : c.reject()));
  }
});
```

- `pollar.getPendingConfirmations()` → `PendingConfirmation[]`.
- `pollar.onConfirmationRequest(cb)` — subscribe; replays the current list.

### What the device verifies

Before voting, the device asks Pollar to **rebuild** a refreshable request (a Solana blockhash lasts about a minute, a Stellar sequence a few), then reads Turnkey's copy of the activity with its own key and compares:

| Chain | Check |
|---|---|
| Stellar | The transaction hash, recomputed from the unsigned envelope |
| Solana | A CCTP `deposit_for_burn` is decoded on the device (amount, signing account, destination domain and recipient, fee and rent payer); anything the reader cannot decode is compared byte for byte |
| Polygon | The unsigned EIP-1559 transaction is decoded: chain id, and only a POL / ERC-20 transfer, `approve`, Uniswap V3 `exactInputSingle` or CCTP V2 `depositForBurn` with the stated destination, value and calldata |
| Account derivation | Wallet id and parameters |

A mismatch throws `SDK_COSIGN_VERIFICATION_FAILED` and nothing is sent. Setup requests Pollar opens on its own (account creation, a trustline, an account on a new chain) are approved without a prompt only when the device decodes them field by field and they name this wallet; anything else lands in the pending list. Requests that belong to an **approval group** (a ramp's swap and bridge, for example) are shown once with all their steps; after the user approves the first, the device votes the rest on its own, still verifying each.

### `pollar.cosign`

The raw surface, for an app that drives the flow itself (`cosignManual: true`) or renders its own approval UI:

| Method | Description |
|---|---|
| `pending()` → `Promise<CosignRequest[]>` | The requests waiting for this device's vote |
| `get(id, { sync? })` | One request; `sync` re-reads the activity from Turnkey first |
| `verify(request)` → `Promise<CosignVerification>` | The check above, without voting. `{ ok: true, localHash, turnkeyPayload }` or `{ ok: false, reason }` |
| `approve(request \| id, { verify? })` | Vote yes. Verifies first unless told not to. Resolves with the request after the vote: approved and signed (and submitted, for intents that submit), or still pending |
| `reject(request \| id)` | Vote no. Final |
| `cancel(id)` | Withdraw Pollar's vote: the activity is rejected in Turnkey. Final |
| `refresh(request \| id)` | Rebuild the request right before the vote; same id, new Turnkey activity |
| `inspectQuorum({ report? })` → `Promise<CosignQuorumReport>` | Reads the sub-organization back and reports whether it is the promised quorum: two root users, threshold 2, this device registered. Run once after the wallet is created, before the first deposit |
| `devices()` → `Promise<CosignDevicesContent>` | The user's enrolled devices and the quorum state |
| `revokeDevice(deviceId, { force? })` | Revoke one of the user's devices. Revoking the key this device signs with locks it out, so it is refused unless `force` |

- `pollar.getCosignState()` → `{ pending: CosignRequest[]; lastResolved?: CosignRequest }`.
- `pollar.onCosignStateChange(cb)` — subscribe; replays the current value.

With `cosignManual: true`, a signing call on a co-signed wallet returns `{ status: 'cosign_pending', request, buildData? }` and `TransactionState` sits on `awaiting_cosign` until your app approves through `pollar.cosign.approve()`.

Helpers: `cosignGroupOf(request)` → `CosignGroup | null`, `cosignStepKeyOf(request)`, `stepInGroup(group, stepKey)`, and `transactionErrorMessage(code, details)` for user-facing text of a failed transaction or approval.

---

## Cards

An app that enables a card provider in [Cards → Providers](https://docs.pollar.xyz/docs/operator-guide/cards/providers) offers its users a virtual card funded from their wallet. `@pollar/react` wraps the whole flow in `<CardModal>`; the methods below are the headless surface. The card number is decrypted on the device, never on a Pollar server.

Every method takes an optional `{ cardProviderId }`, needed only when the app enables more than one provider.

| Method | Description |
|---|---|
| `getCardProviders()` → `Promise<CardProvider[]>` | The providers this app enables. An empty array means Cards is off: hide the UI |
| `getCardRequirements(params?)` → `Promise<CardRequirements>` | The platform steps the provider needs (`KYC`, `FORM`, `REGISTRY_CHECK`, `PROVIDER_REGISTRATION`) and where the user stands (`next`, `completed`, `total`) |
| `getCardProviderRegistration(cardProviderId)` / `submitCardProviderRegistration(cardProviderId)` | Whether the user is registered with the provider, what is shared, and the user's consent to sign up from the verified identity and form answers |
| `getCardHolder(params?)` → `Promise<CardHolder \| null>` | The holder, `null` before `createCardHolder` |
| `createCardHolder(params?)` | Creates the holder; `firstName`, `lastName`, `email` default to the session profile |
| `submitCardKyc({ termsAccepted, kyc })` → `Promise<CardHolder>` | The provider's own KYC form (`CardKycInput`); `termsAccepted` must be `true`. The returned holder carries `verificationLink` while `kycStatus` is `PENDING` / `NEEDS_ACTION` / `IN_REVIEW` |
| `getCardOccupations(params?)` | The occupation codes `CardKycInput.occupation` accepts |
| `getCards(params?)` → `Promise<CardInfo[]>` | The user's cards; never includes card numbers |
| `issueCard({ nickname?, limit? })` → `Promise<CardInfo>` | Issue a virtual card. Needs an approved KYC |
| `getCardBalance(params?)` → `Promise<CardBalance \| null>` | Credit limit, spending power and balance due, read live from the provider |
| `getCardTransactions({ cardId?, limit?, offset? })` → `Promise<CardTransactionsPage>` | Newest first |
| `fundCard({ amount })` → `Promise<CardFundingOutcome>` | Moves USDC from the user's **Stellar** wallet to the card's collateral. A custodial wallet pays at once; an external wallet is asked to sign, and `{ status: 'cancelled' }` means it declined. The returned `CardFunding` then advances on its own: `CREATED → BURNED → ATTESTED → MINTED → CREDITED`, or `FAILED` with `error` |
| `getCardFunding(fundingId)` / `listCardFundings(params?)` | Follow a funding, or list them newest first |
| `getCardDepositAddresses(params?)` | One deposit address per network, for funding from another wallet |
| `revealCardSecrets(cardId, params?)` → `Promise<CardSecrets>` | PAN and CVC, decrypted on this device with a one-shot key the server never sees. Show them and drop them; never store or log the result |

```typescript
const [provider] = await pollar.getCardProviders();
if (!provider) return; // Cards is off for this app

let holder = await pollar.getCardHolder();
if (!holder) holder = await pollar.createCardHolder();
if (holder.kycStatus === 'NOT_STARTED') {
  holder = await pollar.submitCardKyc({ termsAccepted: true, kyc: form });
  // send the user to holder.verificationLink, poll getCardHolder() until APPROVED
}

const card = (await pollar.getCards())[0] ?? (await pollar.issueCard({ nickname: 'Travel' }));
const funding = await pollar.fundCard({ amount: '25' });
const { pan, cvc } = await pollar.revealCardSecrets(card.id);
```

Errors are `PollarApiError`s: `SDK_CARDS_PROVIDER_ERROR` (the provider is down), `SDK_CARDS_IP_NOT_SUPPORTED`, `SDK_CARDS_PROVIDER_USER_TAKEN` (the email is already registered through another app), and `SDK_CARDS_REQUIREMENT_REQUIRED` (409: a platform step is still open; the body names `requirementType` and `optionId`).

Types: `CardProvider`, `CardHolder`, `CardKycStatus`, `CardKycInput`, `CardInfo`, `CardStatus`, `CardBalance`, `CardTransaction`, `CardFunding`, `CardFundingStatus`, `CardFundingOutcome`, `CardSecrets`, `CardRequirements`, `CardRequirementStep`.

---

## Types

```typescript
import type {
  PollarClientConfig,
  PollarLoginOptions,
  AuthState,
  AuthErrorCode,
  NetworkState,
  TransactionState,
  TxBuildBody,
  TxBuildContent,
  TxHistoryState,
  TxHistoryParams,
  TxHistoryRecord,
  WalletBalanceState,
  WalletBalanceRecord,
  WalletChain,
  WalletProvisioning,
  SendPaymentParams,
  SubmitOutcome,
  SignOutcome,
  KycLevel,
  KycStatus,
  KycDecisionStatus,
  KycStatusContent,
  KycFlow,
  KycProvider,
  KycStartBody,
  KycStartResponse,
  AppRequirements,
  RequirementForm,
  RequirementFormAnswers,
  RegistryCheck,
  RampsQuoteQuery,
  RampQuote,
  RampQuoteRequirement,
  RampsQuoteResponse,
  RampsOnrampBody,
  RampsOnrampResponse,
  RampsOfframpBody,
  RampsOfframpResponse,
  RampsTransactionResponse,
  RampTxStatus,
  RampDirection,
  SwapVenue,
  SwapToken,
  SwapQuote,
  SwapQuoteParams,
  EarnProviderId,
  EarnOpportunity,
  EarnPosition,
  SessionInfo,
  DistributionRule,
  WalletInfo,
  PollarUserProfile,
  PollarFlowError,
  // co-signed wallets and confirmations
  CosignRequest,
  CosignState,
  CosignVerification,
  CosignQuorumReport,
  ConfirmationRequest,
  PendingConfirmation,
  // cards
  CardProvider,
  CardHolder,
  CardKycInput,
  CardInfo,
  CardBalance,
  CardTransaction,
  CardFunding,
  CardFundingOutcome,
  CardSecrets,
  CardRequirements,
  // Stellar SEP proofs
  StellarMessageProof,
  Sep10SignParams,
  Sep10Proof,
} from '@pollar/core';

import { WalletType } from '@pollar/core';
```
