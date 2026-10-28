---
title: "@pollar/core"
---

Framework-agnostic TypeScript client for Pollar, for Stellar, Solana and Polygon applications. Use this package directly if you are not using React, or to build custom integrations on top of the Pollar platform.

The client is multichain: a session carries one wallet per chain the app enables (`getWallets()`), balances and history are per chain, and `sendPayment()` takes a `chain`. The transaction builder (`buildTx` / `signTx` / `submitTx`) works on Stellar XDR; on Solana and Polygon use `sendPayment()`. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support) for the full matrix.

**Version:** `0.12.0`. It talks to SDK API v3. The 0.11.x release line is documented at [@pollar/core 0.11](https://docs.pollar.xyz/docs/v0.11/pollar-core).

`@pollar/core`, `@pollar/react` and `@pollar/react-native` must run matching versions: the 0.12.0 UI packages require `@pollar/core@^0.12.0`.

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
| `apiKey`         | `string`         | -                                | **Required.** Your Pollar publishable key.                                 |
| `stellarNetwork` | `StellarNetwork` | `'testnet'`                      | Target Stellar network: `'testnet'` or `'mainnet'`.                        |
| `baseUrl`        | `string`         | `'https://sdk.api.pollar.xyz'`   | Override the Pollar API base URL. Pass the origin only: the SDK appends `/v3`. Useful for self-hosted deployments. |
| `confirmation`   | `'auto' \| 'prompt' \| { window: { seconds, maxUsd } }` | unset: the app's dashboard setting, which defaults to `'prompt'` | How a signing call treats the user, whatever the wallet's custody. Set, the stricter of this and the dashboard setting applies. A ramp leg always asks. See [Confirmation policy](#confirmation-policy). |
| `cosignManual`   | `boolean`        | `false`                          | Keep the raw `cosign_pending` outcome instead of letting the SDK settle co-sign requests: your app drives `client.cosign` itself. |
| `cosignKeyManager` | `KeyManager`   | a second key manager under the `cosign` storage namespace | Where the device key of a Turnkey wallet lives. Pass your own to hold it in hardware-backed storage. |
| `recoveryPasskey` | `RecoveryPasskeyCeremony` | injected by `@pollar/react` | The passkey ceremonies wallet recovery uses (`create` / `get`). Without one, the passkey methods of `client.cosign.recovery` are unavailable. See [Wallet recovery](#wallet-recovery). |
| `loginTimeoutMs` | `number`         | `45000`                          | Timeout of the final `POST /auth/login`, where the server mints the tokens and resolves the wallet. Every other request uses `requestTimeoutMs`. |
| `locale`         | `string`         | unset: the browser or device language | Language of the SDK modals, as a BCP 47 tag (`'es'`, `'pt-BR'`, `'en'`), typically your app's current language. A language pinned in the dashboard (**Build > Branding > Language**) wins over it. The modals have English, Spanish and Portuguese; another tag is skipped. Read it back with `pollar.getLocale()`. |

**Text in the user's language.** The functions that write user-facing text take a trailing optional language, `'en'` by default: `transactionErrorMessage(code, details, language)`, `cosignRefusalMessage`, `appUnavailableMessage`, `authErrorMessage(code, language)` (the text of a backend auth error code), and every ramp text (`rampLegTitle`, `rampStepTitle`, `rampStepStatusText`, `rampNextApproval`, `rampFieldError`, `rampResolutionText`, `rampOrderResolutionText`, `rampRequirementCopy`, `rampTrustlineErrorText`, `rampNoRouteText`, `describeRampAction`, `rampWalletStep`, `rampLegNote`). `resolveLanguage({ dashboard, code, device })` picks the language the way the modals do, and `languageFromTag('pt-BR')` maps a tag to `'pt'`.

> Additional options are supported for non-web runtimes and advanced use: `storage`, `keyManager`, `walletAdapters` (array, see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters)), `requestTimeoutMs` (default `10000`), `submitTimeoutMs` (default `30000`), `retry`, `deviceLabel`, `visibilityProvider`, `openAuthUrl`, `oauthRedirectUri`, `passkey`, `passkeySign`, `logLevel`, `logger`, `onStorageDegrade`, and `maxIdleMs`. See the `PollarClientConfig` type for the full list. React Native apps inject a `storage` adapter and an `openAuthUrl` for OAuth; see [@pollar/react-native](https://docs.pollar.xyz/docs/sdk-reference/pollar-react-native).

---

## Authentication

Pollar's built-in authentication providers are Google OAuth, GitHub OAuth, Email OTP, and external Stellar wallets (Freighter and Albedo are auto-registered). You can register more wallet providers (every Stellar Wallets Kit wallet, or Solana wallets through the Wallet Standard) with the `walletAdapters` config option; see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters). A fifth path, passkey **Smart Wallet** login, is covered under Smart Wallets. All flows update `AuthState`, which can be observed via `onAuthStateChange`.

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

// Built-in external wallets: provider is the wallet id
pollar.login({ provider: WalletType.FREIGHTER }); // 'freighter-native'
pollar.login({ provider: WalletType.ALBEDO });    // 'albedo-native'

// Any wallet registered via `walletAdapters`: provider is that adapter's id
pollar.login({ provider: 'xbull' });  // Stellar Wallets Kit
```

The `provider` for a wallet is the adapter's `type`. Built-in Freighter/Albedo
use the `WalletType` enum (`'freighter-native'` / `'albedo-native'`); wallets
added through [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters)
use their own ids (`'xbull'`, `'lobstr'`, ...).

| Option     | Type                                                     | Description                                     |
|------------|----------------------------------------------------------|-------------------------------------------------|
| `provider` | `'google' \| 'github' \| 'email' \| (string & {})`      | Authentication provider, or a registered wallet adapter's id. |
| `email`    | `string`                                                 | Required when `provider` is `'email'`.          |

---

### Email OTP: step-by-step flow

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

### `pollar.createWallet(options?)`

Creates the signed-in user's wallet, for apps whose wallet creation is **On demand**, or whose custody mode leaves the choice to the user (`USER_CHOICE`: no wallet is created at login). The wallet is created on every chain the app serves and funded per the app's funding mode. Updates the session and notifies `onAuthStateChange` and `onWalletStateChange` subscribers. Idempotent: a user who already has a wallet gets it back.

```typescript
const wallet = await pollar.createWallet();
console.log(wallet.address);

// An app that leaves custody to the user passes their choice
await pollar.createWallet({ custody: 'SELF_CUSTODY' }); // or 'COSIGNED'
```

| Option | Type | Description |
|---|---|---|
| `custody` | `'COSIGNED' \| 'SELF_CUSTODY'` | The Turnkey custody the user picked: co-signed (2-of-2 with Pollar's approver) or self-custody (the user alone). Ignored when the app sets the custody itself |

A Turnkey wallet uses this device's key as its first credential, and it needs a recovery method before it signs (see [Wallet recovery](#wallet-recovery)).

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

Builds an unsigned Stellar transaction on the server. Transitions `TransactionState` through `building` -> `built` (or `error`).

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

Signs a single Soroban `SorobanAuthorizationEntry`: the user's authorization on its own, without a transaction envelope. Use it when your own contract is the transaction source (it sponsors the gas and submits), and all it needs from the user is consent to the invocation.

For **external wallets** the adapter signs the entry directly. For **custodial wallets** Pollar signs server-side, and only if every contract and function in the entry's invocation tree is allowlisted for your app under **Wallets -> [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy)**. That allowlist is what keeps the custodial signer from being usable as a signing oracle, so an unconfigured app signs nothing. **Co-signed wallets** pass the same checks, then the user's device votes: it recomputes the entry's hash itself before approving, and the call resolves once the vote is in. With `cosignManual` it resolves to `{ status: 'cosign_pending', request }` instead, for your app to vote through `pollar.cosign`. **Passkey smart accounts** (C-address sessions) are not supported by this method in the current build: they sign auth entries through their passkey ceremony, which this call does not run, so it resolves to `{ status: 'error' }` rather than signing with the wrong key.

`validUntilLedger` is the absolute ledger the signature expires at; compute it from the network's latest ledger. Your app's validity window caps how far ahead it may be (120 ledgers by default, 300 at most).

```typescript
const result = await pollar.signAuthEntry(entryXdr, { validUntilLedger: latestLedger + 100 });

if (result.status === 'signed') {
  await myBackend.settle(result.signedAuthEntry);
} else {
  console.error(result.details); // e.g. SOROBAN_AUTH_FUNCTION_NOT_ALLOWED
}
```

Resolves to `{ status: 'signed'; signedAuthEntry: string }`, `{ status: 'cosign_pending'; request }` (co-signed wallet, manual voting) or `{ status: 'error'; code?: string; details?: string }`. Like the other transaction methods, it does not throw on a denial. The denial codes are listed under [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes).

A library that signs auth entries itself (stellar-sdk's contract client, x402's `ExactStellarScheme`) takes `pollar.stellar.authEntrySigner()` instead: a SEP-43 signer whose every signature goes through this method. See [Pay for APIs with x402](https://docs.pollar.xyz/docs/guides/x402-payments).

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
| `awaiting_cosign`             | A Turnkey wallet: the request (`request: CosignRequest`) waits for this device's vote. Once the user confirmed the signature, the SDK verifies and proposes it; under `cosignManual` your app does. |
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
| `limit`  | `number` | `20`    | Number of records to return, 1 to 50.                              |
| `offset` | `number` | `0`     | Offset for pagination (history uses offset-based paging).          |
| `chain`  | `'STELLAR' \| 'POLYGON' \| 'SOLANA'` | - | Only this chain's records. Omit for all chains. |

> Only transactions submitted through Pollar appear here. A record reads `PENDING` immediately after build and updates to `SUCCESS` or `FAILED` once submitted. Each record exposes `id`, `hash`, `chain`, `network`, `status`, `operation`, `summary`, `details`, `fee` (`{ amount, unit }`, with `unit` naming what the amount is in, for example `XLM`), `resultCode`, and `createdAt`.

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
| `corridorId`     | `string` | -         | Scope to a ramp route's steps.                   |
| `cardProviderId` | `string` | -         | Scope to a card provider's steps.                |

**`KycStatus` values:** `'none'` · `'pending'` · `'approved'` · `'rejected'` · `'expired'`

**`KycLevel` values:** `'basic'` · `'intermediate'` · `'enhanced'`

---

### Requirement steps

An app, a ramp route or a card provider can require an ordered list of steps before the user proceeds. Steps are all required, in order (AND); the `optionIds` inside a step are alternatives (OR): the step is satisfied when any accepted option is. Step types: `KYC`, `FORM`, `REGISTRY_CHECK` (an identity registry such as SEGIP), `PROVIDER_REGISTRATION` (sign the user up with the ramp or card provider from the verified identity and form answers). `@pollar/react` walks them from `<KycModal>`, `<RampWidget>` and `<CardModal>`; the headless surface:

| Method | Description |
|---|---|
| `getAppRequirements()` -> `{ steps, next, completed, total }` | The app's own steps and the user's progress. `next` is the open step (`type`, `optionId`, `status`, `reviewReason?`) or `null` |
| `getRequirementForm(formId)` -> `RequirementForm` | A form asked by a `FORM` step: `fields` (`text`, `textarea`, `number`, `date`, `select`, `multiselect`, `checkbox`, `email`, `phone`, with `label.en` / `label.es`, `required`, `options`, `validation`), the user's previous `answers`, and the `missing` keys |
| `submitRequirementForm(formId, answers)` -> `{ formId, version, missing }` | Stores the answers encrypted. Invalid ones fail with `KYC_FORM_INVALID_ANSWERS` and `body.errors: { key, code }[]` |
| `getRegistryCheck(optionId)` / `submitRegistryCheck(optionId, { surname1, surname2?, complementNumber? })` | A `REGISTRY_CHECK` step: the prefilled identity (only the surname split and the document complement are editable) and its `status` / `rejectedFields` |
| `getProviderRegistration(corridorId)` / `submitProviderRegistration(corridorId)` | Whether the user is registered with the route's ramp provider, whether they can be now, what is shared, and the user's consent to register |

A route held back by one of these steps comes back in the quote's `rejected` list with the step as `requirement` (see [`quoteRamp`](#pollarquoterampbody)); complete it and quote again.

---

## Ramps

A ramp is an **order** of one or more **legs** that Pollar runs server-side: the provider leg (fiat in or out), plus a swap or a bridge when the asset the user wants is not the one the provider delivers. A route ends only on a chain the app enables; a leg that runs on another chain uses a rail wallet the order sets up. The concepts are in [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps); this section is the client surface. `@pollar/react` wraps it in `<RampWidget>`.

The flow:

1. `getRampRoutes(direction)` lists the fiat and asset pairs the app can ramp between.
2. `quoteRamp(...)` quotes every route for a pair, leg by leg, best first. Routes that cannot run come back in `rejected`, each with why.
3. `createRampOrder({ quoteId, payee })` turns the quote the user picked into an order and runs its first leg.
4. `pollRampOrder(id, ...)` follows the order. Whenever it waits on the user, `order.pendingAction` says for what: pay the fiat side, sign a leg, approve a co-signed step, or complete a verification.

### `pollar.getRampRoutes(direction)`

The fiat and asset pairs the app can ramp between in a direction (`'ONRAMP'` or `'OFFRAMP'`), each with the leg kinds of its shortest path. Nothing is quoted.

```typescript
const { routes } = await pollar.getRampRoutes('ONRAMP');
// routes: { fiat: { currency, rail, country }, asset: { code, identifier, chain }, legs: ('PROVIDER_ONRAMP' | 'SWAP' | 'BRIDGE' | ...)[] }[]
const countries = rampCountries(routes); // { country, fiats }[] for a country picker
```

`fiat.rail` is one of `SPEI`, `PIX`, `PSE`, `ACH`, `BREB`, `QR`, `BANK_TRANSFER`, `CASH`, `CARD`, `HOSTED`. `HOSTED` means the user picks the payment method inside the provider's own flow, so there are no payment details before its page opens. `rampRailLabel(rail, { language: 'es', provider })` gives the text to show. `asset.chain` is a `RampChain`: `STELLAR`, `POLYGON` or `SOLANA`.

---

### `pollar.quoteRamp(body)`

Quotes every route between the fiat and the asset, leg by leg, best first. Waits up to 30 seconds for the providers.

```typescript
const { quotes, rejected } = await pollar.quoteRamp({
  direction: 'ONRAMP',
  fiat: { currency: 'MXN', rail: 'SPEI', country: 'MX' },
  asset: { code: 'USDC', identifier: null, chain: 'STELLAR' },
  amount: { value: '1000', denomination: 'in' }, // 'in': what the user pays; 'out': what they receive
});
```

Each quote carries `quoteId`, `expiresAt`, `amountIn`, `amountOut` (an estimate until the last leg reports what arrived), `etaSeconds` and its `legs`. Each leg names its `kind` (`PROVIDER_ONRAMP`, `PROVIDER_OFFRAMP`, `SWAP`, `BRIDGE`), `from` / `to`, amounts, `providerFees`, the `wallet` it uses and the `requiredFields` the user fills in. `rampQuoteFields(quote)` collects those fields across the legs (`key`, `label`, `type`, `options`, `pattern`, `hint`); `rampFieldValid(field, value)` and `rampFieldError(field, value)` check a filled-in value.

Each entry of `rejected` is a route that was planned and dropped, with its `legs`, a `failure` (`code`, `resolutionAction`, `detail`) and, when a verification step holds it back, a `requirement` (`type`: `KYC`, `FORM`, `REGISTRY_CHECK` or `PROVIDER_REGISTRATION`, its `optionId` and `status`). The helpers turn a rejection into something the user can act on:

| Helper | Returns |
|---|---|
| `rampRequirementCopy(requirement)` | `{ message, action }`: the text and the button for the verification step; `action` is `null` while the step is under review or rejected |
| `rampWalletStep(rejection)` | The wallet step the route waits on (`create_wallet`, `set_up_wallet` on the chain in `failure.detail`, `migrate_custody`, `set_up_recovery`) with its button label, or `null`. Run it with `pollar.runRampWalletStep(step, custody?)` |
| `rampTrustlineAsset(rejection)` | `{ code, issuer }` of the asset the Stellar wallet must trust for this route, or `null`. Add it with `setTrustline` and quote again |
| `rampNoRouteText(rejected)` | When no route is left: the fix every rejected route shares, or a change of amount |
| `rampResolutionText(failure)` | What the user can do about a failure's `resolutionAction` |

With no route at all, `quoteRamp` throws a `PollarApiError` with code `SDK_RAMPS_NO_ROUTE`, and `body.rejected` holds the same list.

---

### `pollar.createRampOrder(body)`

Turns the quote the user accepted into an order and runs its first leg, so the answer already carries the first `pendingAction`. `payee` holds a value for each of the quote's required fields, by `key`. The same quote always answers the same order.

```typescript
const order = await pollar.createRampOrder({
  quoteId: quote.quoteId,
  // An Abroad payout to Brazil: the quote's requiredFields name these keys.
  payee: { pixKeyType: 'EMAIL', bankAccount: 'ana@example.com' },
});
```

A payee the provider would refuse throws `VALIDATION_ERROR` with the reason in `body.message`, before anything moves. An expired quote throws `SDK_RAMPS_QUOTE_EXPIRED`: quote again.

---

### The order

`RampOrder` carries `id`, `direction`, `state` (`created`, `awaiting_payment`, `processing`, `settling_onchain`, `completed`, `failed`, `refunded`; the last three are final), `legs`, `pendingAction`, `failure` and `nextPollAfter` (when to read it again; `null` once it no longer moves).

Each leg has its `kind`, `status`, planned and actual amounts, `onchainTxHash`, `fundsLocation` (where its funds sit while it waits), `etaSeconds`, `startedAt`, a `failure`, and the `steps` of a swap or bridge leg (`approve`, `swap`, `burn`, `attestation`, `mint`, each `pending`, `awaiting_approval`, `confirming` or `done`).

`pendingAction` is what the order waits on:

| `kind` | The user | Client call |
|---|---|---|
| `FIAT_PAYMENT` | Pays the fiat side. `instructions` is a QR (its code already rendered in `scannable`), bank coordinates, or a `hosted` page | `checkRampOrder(id)` when the user says they paid |
| `SIGNATURE` | Signs a leg with their own wallet. Carries `chain`, `payload` (`encoding`, `value`), `summary` and `expiresAt` | `signRampLeg(orderId, actionId)` from an explicit user action |
| `COSIGN_APPROVAL` | Approves a co-signed step, like any co-sign request (`cosignRequestId`) | `pollar.cosign.approve(...)`, or `<CosignModal>` |
| `KYC` | Completes a verification step with the provider (`steps`, `url`) | The requirement flow, then the order moves on |
| `NONE` | Nothing; the order is working | - |

UI helpers for an order:

| Helper | Returns |
|---|---|
| `describeRampAction(order)` | The pending action as a screen shows it: `title`, `canSign`, `canApprove`, `scannable`, `details`, `link` / `linkLabel`, `note`, `codeMissing`, `paymentClosed`, `expiresAt` |
| `rampOrderReceive(order)` | `{ amount, unit, estimated }`: what the user receives |
| `rampOrderStopped(order)` / `isRampOrderSettled(order)` | Whether the order no longer moves on its own / is final |
| `rampOrderResolutionText(order)` | The text for the order's failure |
| `rampLegTitle(leg)`, `rampLegStatus(leg)`, `rampLegNote(leg)`, `rampLegTimeLeft(leg)` | A leg's title, `'pending' \| 'active' \| 'done' \| 'failed'`, a note for an accepted substitute, and its seconds left |
| `rampStepTitle(step, leg)`, `rampStepStatusText(step)`, `rampNextApproval(order)` | A chain step's title and status, and the approval that comes next |

---

### Following an order

| Method | Description |
|---|---|
| `getRampOrder(id)` -> `Promise<RampOrder>` | One read |
| `pollRampOrder(id, { onUpdate?, onError?, until?, signal? })` -> `Promise<RampOrder>` | Reads at the pace the server suggests until the order settles, or `until(order)` holds. A failed read goes to `onError` and is read again (1 second, doubling up to 60); only an order that no longer exists ends it, with `SDK_RAMPS_TX_NOT_FOUND` |
| `listRampOrders({ pending?, open?, state?, since?, limit?, cursor? })` -> `Promise<RampOrdersPage>` | The user's orders, newest first. `pending: 'true'` keeps the ones waiting on the user; `open: 'true'` every one not final yet, which is what a client resumes |
| `checkRampOrder(id)` -> `Promise<RampOrder>` | Asks the provider about the fiat payment now instead of at the next recheck (at most once every 10 seconds per order) |
| `retryRampOrder(id)` -> `Promise<RampOrder>` | Runs a held order again from where it stopped, when the user is the one who resolves it |

```typescript
const controller = new AbortController();
const final = await pollar.pollRampOrder(order.id, {
  signal: controller.signal,
  onUpdate: (o) => render(describeRampAction(o)),
  until: (o) => o.pendingAction?.kind === 'SIGNATURE' || isRampOrderSettled(o),
});
```

---

### Signing a leg

Core has no built-in ramp signer. Register one per chain and payload encoding, `STELLAR`/`xdr` included; an unregistered pair fails before signing. The handler validates the payload against the wallet it authorizes (account, chain, network), signs it and returns it signed without broadcasting.

```typescript
import { assertRampStellarSigner } from '@pollar/core';

const removeSigner = pollar.registerRampSigningHandler('STELLAR', 'xdr', async (action) => {
  assertRampStellarSigner(action, myStellarAddress); // every operation must spend from this account
  return myWallet.signXdr(action.payload.value);
});

// From the user's Authorize button only:
await pollar.signRampLeg(order.id, order.pendingAction.actionId);
```

`signRampLeg` reads the order again and signs only if the pending action is still the one the user saw (`actionId`) and has not expired. A ramp leg always asks the user for confirmation, whatever the [confirmation policy](#confirmation-policy). Polling an order never signs. `<RampWidget>` lends the connected wallet as the Stellar and Solana signer while the user authorizes, unless the app registered its own.

---

### Wallet steps

A route can wait on the user's wallet. `runRampWalletStep(step, custody?)` runs the step `rampWalletStep` returned and resolves to `{ recoveryRequired }`: true when the Turnkey wallet it leaves needs a recovery method before it signs. `set_up_recovery` does nothing itself; open the recovery flow, then quote again.

| Method | Description |
|---|---|
| `runRampWalletStep(step, custody?)` | `create_wallet` -> `createWallet`, `set_up_wallet` -> `setUpRampWallet`, `migrate_custody` -> `cosign.migrateWallets` |
| `setUpRampWallet(chain, custody?)` -> `Promise<RampWalletSetup>` | A Turnkey wallet on a chain the route passes through (`POLYGON` or `SOLANA`), with this device as its first credential. It signs once `recoveryConfigured` |

---

### Ramp errors

`quoteRamp`, `createRampOrder` and the order calls throw `PollarApiError`. `body` keeps every field the API sent.

| `code` | When |
|---|---|
| `SDK_RAMPS_NO_ROUTE` (422) | No route for the pair and amount; `body.rejected` says why each dropped |
| `SDK_RAMPS_QUOTE_EXPIRED` (400) / `SDK_RAMPS_QUOTE_NOT_FOUND` (404) | Quote again |
| `VALIDATION_ERROR` (400) | A payee the provider would refuse; the reason is in `body.message` |
| `SDK_RAMPS_ACTION_STALE` (409) | The action changed before it was answered: read the order again |
| `SDK_RAMPS_NOTHING_TO_RETRY` (409) | `retryRampOrder` on an order that is not held on the user |
| `SDK_RAMPS_WALLET_NOT_READY` (422) | The wallet's account is not on-chain yet: approve the new account first |
| `SDK_RAMPS_TX_NOT_FOUND` (404) | The order does not exist for this user |
| `SDK_CREDITS_INSUFFICIENT` / `SDK_BILLING_OVERDUE` (402) | The app is on credits and cannot cover the route's fees. Show `appUnavailableMessage(error)`; the app's owner fixes it |

The full list is in [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes).

---

## App Config

### `pollar.getAppConfig()`

Returns the application configuration associated with your API key, as configured in the Pollar Dashboard.

```typescript
const config = await pollar.getAppConfig();
```

---

## One-shot transactions

For build -> sign -> submit in a single call, use `runTx` (an alias of
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

`getTxStatus(hash)` resolves to `{ hash, status: 'PENDING' | 'SUCCESS' | 'FAILED', resultCode?, operationCodes?, message?, ledger? }`. A Stellar transaction that failed on its operations lists each operation's result code in `operationCodes` (for example `paymentNoDestination`), and a failed transaction's state and outcome carry the matching `code` (`TX_DESTINATION_NOT_FOUND`). `transactionErrorMessage(code, details)` turns it into text for the user.

### `pollar.signSolanaTransaction(base64)`

Signs a serialized Solana transaction with the user's own connected Solana wallet and returns it signed, without broadcasting it. The wallet shows the transaction and the user approves it there; Pollar adds no prompt of its own. Base64 in and out. Throws when the session has no external Solana wallet that can sign.

```typescript
const signed = await pollar.signSolanaTransaction(unsignedBase64);
```

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
| `'SOLANA'` | Integer base units (lamports, or the mint's smallest unit) | `mint?` (omit for SOL) | Managed and co-signed: one call to `/tx/build-sign-submit`. External (SIWS): Pollar builds, the wallet signs via `signSolanaTransaction`, Pollar submits |
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

- `pollar.getEnabledAssetsState()`: current state snapshot.
- `pollar.refreshAssets()`: refresh the enabled-assets state machine.
- `pollar.onEnabledAssetsStateChange(cb)`: subscribe; returns an unsubscribe fn.
- `pollar.setTrustline(asset, opts?)`: establish (omit `limit`) or remove
  (`limit: '0'`) a trustline. The app covers the reserve and the fee whenever
  the dashboard sponsors trustlines; pass `{ skipSponsorship: true }` to make
  the user's wallet pay instead. Returns a `TrustlineOutcome`.

```typescript
await pollar.setTrustline({ code: 'USDC', issuer: 'GABC...' });
```

---

## Swap

Multi-venue asset swaps (SDEX / AMM). Empty `getSwapConfig()` means swap is
disabled for the app: hide the UI.

- `pollar.getSwapConfig()` -> `Promise<SwapVenue[]>`: venues this app exposes.
- `pollar.getSwapTokens()` -> `Promise<SwapToken[]>`: curated "buy" token catalog.
- `pollar.getSwapQuote(params)` -> `Promise<SwapQuote[]>`: quotes ranked best-first.
- `pollar.swap(quote, opts?)` -> `Promise<SubmitOutcome>`: execute a quote
  (establishes the buy-asset trustline first when needed). Drives `TransactionState`.

### Swap on Solana

Jupiter and Titan, on a mainnet app only. Amounts are integer base units of each
mint; SOL is swapped as wrapped SOL (`So11111111111111111111111111111111111111112`).

- `pollar.getSolanaSwapConfig()` -> `Promise<SolanaSwapVenue[]>`: the Solana venues
  this app exposes (`'jupiter'`, `'titan'`); empty means no swap on Solana.
- `pollar.getSolanaSwapQuote({ inputMint, outputMint, amount, provider?, slippageBps? })`
  -> `Promise<SolanaSwapQuote[]>`: quotes for the user's Solana wallet, best output
  first. Each has `provider`, `inAmount`, `outAmount`, `minOut`, `priceImpactPct`
  (null when the venue does not report it) and `route.hops`. A quote carries no
  transaction.
- `pollar.swapSolana(quote, { slippageBps? })` -> `Promise<SubmitOutcome>`: asks the
  user to confirm, then has Pollar build the quoted route for the user's wallet.
  The route is fetched again, so the amounts can move a little from the quote, and
  Pollar refuses one whose simulation pays the user less than its minimum. A
  co-signed or self-custody wallet approves it on the device; an external wallet
  (Phantom, Solflare, Backpack) signs it in the wallet. A Pollar-managed (custodial)
  Solana wallet cannot swap. Drives `TransactionState`.

```ts
const SOL = 'So11111111111111111111111111111111111111112';
const USDC = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

const [best] = await pollar.getSolanaSwapQuote({ inputMint: SOL, outputMint: USDC, amount: '100000000' }); // 0.1 SOL
if (best) await pollar.swapSolana(best);
```

---

## Earn

Yield vaults (DeFindex) and lending pools (Blend). Empty `getEarnProviders()`
means Earn is disabled: hide the UI.

- `pollar.getEarnProviders()` -> `Promise<EarnProviderId[]>`.
- `pollar.getEarnOpportunities(provider)` -> `Promise<EarnOpportunity[]>`: vaults/pools with live APY.
- `pollar.getEarnPosition(params)` -> `Promise<EarnPosition>`: the wallet's position.
- `pollar.earnDeposit(params)` -> `Promise<SubmitOutcome>`.
- `pollar.earnWithdraw(params)` -> `Promise<SubmitOutcome>`.

---

## Token distribution

- `pollar.listDistributionRules()` -> `Promise<DistributionRule[]>`: claimable rules for the app.
- `pollar.claimDistributionRule(body)` -> claims a rule for the authenticated user.

---

## Sessions

Manage the authenticated user's active sessions (devices).

- `pollar.listSessions()` -> `Promise<SessionInfo[]>`.
- `pollar.getSessionsState()` / `pollar.fetchSessions()` / `pollar.onSessionsStateChange(cb)`: the sessions state machine.
- `pollar.revokeSession(familyId)`: revoke one session.
- `pollar.logout({ everywhere: true })` or `pollar.logoutEverywhere()`: sign out everywhere.

---

## Smart Wallets (passkey)

Passkey-backed Soroban **C-address** login. Requires a `passkey` ceremony in
`PollarClientConfig` (`@pollar/react` supplies one via `@simplewebauthn/browser`;
browser-only for now).

- `pollar.loginSmartWallet()`: log in with an existing passkey wallet.
- `pollar.createSmartWallet()`: create + deploy a new passkey C-address.

See [Smart Wallets](https://docs.pollar.xyz/docs/smart-wallets/overview) for the full flow.

---

## Stellar SEP proofs

Ownership proofs signed by the user's Stellar wallet, custodial or external:

- `pollar.stellar.sep53.signMessage(message)` -> `{ status: 'signed', signature, signerAddress, scheme: 'sep53' }` or `{ status: 'error', code?, details? }`. SEP-53 message signing.
- `pollar.stellar.sep10.sign({ challengeXdr, homeDomains?, webAuthDomain? })` -> `{ status: 'signed', signedXdr, signerAddress }` or an error. Signs a SEP-10 web-auth challenge from your own anchor.
- `pollar.stellar.authEntrySigner({ validUntilLedger? })` -> a SEP-43 signer `{ address, signAuthEntry(authEntry, opts?) }` over the user's wallet, for stellar-sdk's contract client and x402. Given a Soroban authorization preimage it returns the raw signature, as stellar-sdk expects; given an entry, the signed entry, which needs the `validUntilLedger` option (a function returning the absolute ledger the signature expires at). It throws on a refusal or a pending co-sign vote. See [Pay for APIs with x402](https://docs.pollar.xyz/docs/guides/x402-payments).

---

## Lifecycle and wallet readiness

| Method | Description |
|---|---|
| `pollar.ready()` -> `Promise<void>` | Resolves once the keypair and the stored session are restored. Await it before reading `getAuthState()` on a cold start |
| `pollar.destroy()` | Detaches the cross-tab storage listener and aborts any in-flight login |
| `pollar.refresh()` | Refreshes the access token; concurrent calls are coalesced |
| `pollar.refreshWalletState()` -> `Promise<WalletProvisioning \| null>` | Asks the server where the Stellar account stands: `'READY'`, `'CREATING'`, `'FAILED'` or `'NONE'`. Never throws |
| `pollar.onWalletStateChange(cb)` | Subscribe to that readiness; replays the current value, then emits on change |
| `isWalletNotReady(errorOrOutcome)` / `WALLET_NOT_READY_CODE` | `true` when a failure is "the wallet is still being prepared" (`SDK_WALLET_NOT_READY`), whether thrown or returned as an outcome. Retry once the state is `READY` |
| `pollar.getUserProfile()` -> `PollarUserProfile \| null` | Email, names, avatar and linked providers. Held in memory only, never persisted |
| `pollar.providerAction(provider, action, payload?)` | A named secondary step on a registered auth provider (the email provider's `sendCode` / `verifyCode`) |
| `pollar.setPasskeyDefaults({ passkey?, passkeySign? })` | Fill in the passkey ceremony and signer when they were not configured at construction (`@pollar/react` does this) |
| `pollar.getNetworkState()` | `{ step: 'idle' }` or `{ step: 'connected', network }` |
| `pollar.getWalletType()` -> `WalletId \| null` | The provider the session was opened with |
| `pollar.listWalletAdapters()` -> `{ id, meta, chain }[]` | The registered adapters, Freighter and Albedo first, each with its `chain` |
| `pollar.getWalletAdapter(id)` | One registered adapter instance |
| `pollar.getLogger()` | The client's level-gated logger |

---

## Confirmation policy

Every signing call can ask the user first, whatever the wallet's custody: custodial, Turnkey (co-signed or self-custody) or external. Two settings decide it:

- **The app's dashboard setting**, under [Wallets > Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings): always ask (`PROMPT`, the default), ask and then sign for a window (`WINDOW`, 5 minutes and 50 USD by default), or never ask (`AUTO`).
- **`confirmation` in `PollarClientConfig`**: `'prompt'`, `'auto'` or `{ window: { seconds, maxUsd } }`.

With `confirmation` unset, the SDK follows the dashboard. Set, the stricter of the two applies (`'prompt'` over a window over `'auto'`; between two windows, the shorter time and the lower total), so `'auto'` in code skips the prompt only when the dashboard says `AUTO` too.

| Policy | What the user sees |
|---|---|
| `'prompt'` | Every signature is shown first and waits for the user. An external wallet then shows its own popup |
| `{ window: { seconds, maxUsd } }` | A confirmed signature opens a window of `seconds`. Inside it, the next signatures sign without asking while their USD total stays within `maxUsd`. Only a payment the SDK builds itself (`sendPayment`, `runTx('payment', ...)`) has a value it can read; any other signature (a raw `signTx`, a swap, a contract call) always asks, and so does an asset with no price. The window closes on logout |
| `'auto'` | No prompt. A Turnkey wallet still votes through the device; an external wallet still shows its own popup |

A ramp leg always asks, whatever the policy.

`@pollar/react` renders the prompt (`<ConfirmModal>`). A headless app subscribes with `onConfirmationRequest` and answers each `PendingConfirmation` with `confirm()` or `reject()`. While nothing is subscribed, a signing call that has to ask fails with `SDK_CONFIRMATION_UNAVAILABLE` instead of signing unasked; a declined one fails with `SDK_CONFIRMATION_DECLINED`.

```typescript
pollar.onConfirmationRequest((pending) => {
  for (const c of pending) {
    // c.kind: 'sign' | 'sign_and_send' | 'build_sign_submit'; c.network; c.operation; c.details
    showDialog(c).then((ok) => (ok ? c.confirm() : c.reject()));
  }
});
```

- `pollar.getPendingConfirmations()` -> `PendingConfirmation[]`.
- `pollar.onConfirmationRequest(cb)`: subscribe; replays the current list.

---

## Turnkey wallets

An app whose [wallet custody](https://docs.pollar.xyz/docs/operator-guide/wallets/settings) is a Turnkey mode gives each user a wallet in their own Turnkey sub-organization:

- **Co-signed** (`COSIGNED`): a 2-of-2 quorum of this device's key and Pollar's approver key. Every signature needs both votes, on Stellar, Solana and Polygon.
- **Self-custody** (`SELF_CUSTODY`): the user alone, at threshold 1. Only the user's credentials sign.

The concepts are in [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets); this section is the client surface.

The device key is a second P-256 key kept under the `cosign` namespace of the client's storage (`cosignKeyManager` to hold it elsewhere, for example hardware-backed). Logout does not reset it, so the user's vote survives signing out. `login()` and `createWallet()` send its public key, which becomes the user's credential in the sub-organization.

### How a co-signed request is approved

A signing call on a co-signed wallet answers with a co-sign request. Nothing on the wallet is approved without the user, its setup included: account creation, a trustline, an account on a new chain. Each transaction is its own request, ramp steps included. With the provider mounted, `<CosignModal>` opens for each one; a headless app approves through `pollar.cosign.approve(request)` from a user action.

When the user approves, the device:

1. Asks Pollar to **rebuild** a refreshable request (a Solana blockhash lasts about a minute, a Stellar sequence a few), under the same request id.
2. **Verifies** the unsigned payload the request carries, never its summary:

   | Chain | Check |
   |---|---|
   | Stellar | The transaction hash, recomputed from the unsigned envelope, must be what the request asks to sign |
   | Solana | The transaction is read: a transfer must match the destination, amount and mint it states, a CCTP `deposit_for_burn` is decoded (amount, signing account, destination domain and recipient), and a fee above custody's 0.001 SOL cap is refused |
   | Polygon | The unsigned EIP-1559 transaction is decoded: chain id, and only a POL / ERC-20 transfer, `approve`, Uniswap V3 `exactInputSingle` or CCTP V2 `depositForBurn` with the stated destination, value and calldata |
   | Account derivation | Wallet id and parameters |

3. **Proposes** the Turnkey activity it built from the values it checked, stamped with the device key. Pollar's approver votes second.

A mismatch throws `SDK_COSIGN_VERIFICATION_FAILED` and nothing is sent. A vote gets 60 seconds; if the connection drops meanwhile, the client reads the request back and reports it as it stands. When Turnkey refuses the request, the error is `SDK_COSIGN_TURNKEY_REJECTED`; `cosignRefusalMessage(error)` gives the text with Turnkey's own reason.

Until the wallet has a recovery method, everything except its setup (account creation, trustlines) is refused with `SDK_WALLET_RECOVERY_REQUIRED` (409). See [Wallet recovery](#wallet-recovery).

### `pollar.cosign`

The raw surface, for an app that drives the flow itself (`cosignManual: true`) or renders its own approval UI:

| Method | Description |
|---|---|
| `pending()` -> `Promise<CosignRequest[]>` | The requests waiting for the user |
| `get(id, { sync? })` | One request; `sync` re-reads the activity from Turnkey first |
| `refresh(request \| id)` | Rebuild the request right before the vote; same id. A request the client composed itself (`refreshable: false`) comes back as is |
| `verify(request)` -> `Promise<CosignVerification>` | The check above, without proposing. `{ ok: true, localHash, proposal }` (the Turnkey request `approve` submits) or `{ ok: false, reason }` |
| `approve(request \| id)` | Vote yes: refreshes, verifies, then relays the proposal. Always verifies. Resolves with the request after both votes: approved and signed (and submitted, for intents that submit), or still pending |
| `settle(request)` | Read a proposed request back until Turnkey settles it. Still pending after a few reads, it is returned as is |
| `reject(request \| id)` | Vote no. Final: closes the request on the server. The request is read first, and only one still pending is cancelled |
| `cancel(id)` | Close the request as rejected. Final |
| `relay(path, body, { requestId? })` | Stamp a Turnkey request with the device key and have sdk-api forward it unchanged |
| `inspectQuorum({ report? })` -> `Promise<CosignQuorumReport>` | Reads the sub-organization back with the device key and reports whether it is the quorum the custody promises: two root users at threshold 2 (co-signed) or the user alone at threshold 1 (self-custody), with this device registered. Run once after the wallet is created, before the first deposit |
| `switchCustody(to)` -> `Promise<CosignQuorumReport>` | Move the wallet between `'COSIGNED'` and `'SELF_CUSTODY'`. Each step is checked on the device before it is stamped; a switch that stops halfway resumes on the next call. Throws `SDK_COSIGN_CUSTODY_SWITCH_NOT_ALLOWED` for an app that does not let its users choose, `SDK_COSIGN_CUSTODY_SWITCH_PENDING` while a co-sign request waits |
| `devices()` -> `Promise<CosignDevicesContent>` | The user's enrolled devices, the custody and the quorum state |
| `revokeDevice(deviceId, { force? })` | Revoke one of the user's devices. Revoking the key this device signs with locks it out, so it is refused unless `force` |

- `pollar.getCosignState()` -> `{ pending: CosignRequest[]; lastResolved?: CosignRequest }`.
- `pollar.onCosignStateChange(cb)`: subscribe; replays the current value.

With `cosignManual: true`, a signing call on a co-signed wallet returns `{ status: 'cosign_pending', request, buildData? }` and `TransactionState` sits on `awaiting_cosign` until your app approves through `pollar.cosign.approve()`.

`recognizedSetupRequest(request)` tells a setup request (account creation, a trustline, an account on a new chain) apart, for an app that labels it. `transactionErrorMessage(code, details)` gives user-facing text for a failed transaction or approval.

### Wallet recovery

A Turnkey wallet needs a way back in that does not depend on this device. The user adds it directly with Turnkey: Pollar never sets a recovery method or confirms one. `client.cosign.recovery` is the surface; `<RecoveryModal>` in `@pollar/react` and `@pollar/react-native` is the UI. See [Passkeys and wallet recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide).

| Method | Description |
|---|---|
| `status()` -> `Promise<RecoveryState>` | `required`, `configured`, the confirmed `email`, the `passkeys` and the `devices` |
| `addPasskey({ name? })` / `removePasskey(authenticatorId)` | Register or remove a passkey (synced by the platform, iCloud or Google). Needs a `recoveryPasskey` ceremony; `passkeyAvailable` says whether one is set |
| `startEmail(email)` / `confirmEmail(code)` | Email a code to confirm an address, then confirm it. The code goes encrypted to Turnkey, never through Pollar |
| `requestDeviceEnrollment(label?)` -> `{ id, expiresAt }` | On a new device: ask an enrolled device to add this one |
| `approveDevice(enrollmentId)` / `rejectDevice(enrollmentId)` | On an enrolled device: answer that request |
| `recoverWithPasskey()` | On a device that lost access: a passkey adds this device's key |
| `startEmailRecovery()` / `recoverWithEmailCode(code)` | On a device that lost access: the confirmed email receives a code that adds this device's key |
| `exportWallet()` -> `Promise<string>` | The recovery phrase, decrypted on this device. Whoever holds it controls every account of the wallet |

The passkey ceremony comes from the platform layer: `PollarClientConfig.recoveryPasskey`, also accepted by `setPasskeyDefaults` (`@pollar/react` installs `browserRecoveryPasskey`).

### Custody migration

When the app's wallets live in Turnkey and the user still has wallets Pollar custodies, the device moves them:

| Method | Description |
|---|---|
| `cosign.custodyMigration()` -> `Promise<CustodyMigrationState>` | Whether a move is `required`, the target `toCustody`, whether the user picks it (`choice`), and each wallet's `status`, `addressChanges` and `newAddress` |
| `cosign.migrateWallet(custody?, { chain? })` | Move one wallet. Stellar keeps its address; Solana and Polygon move every token and the native balance to the user's Turnkey account on that chain, a new address |
| `cosign.migrateWallets(custody?)` | Move every wallet that still has to, Stellar first |

`custody` is the user's pick when the app leaves it to them. A move throws `SDK_CUSTODY_MIGRATION_BLOCKED`, with `body.reasons`, while something still points at the old wallet (an open ramp order, a transaction in flight). Like any new Turnkey wallet, the moved one needs a recovery method before it signs. `<CustodyMigrationModal>` in `@pollar/react` runs this after login.

---

## Cards

An app that enables a card provider in [Cards -> Providers](https://docs.pollar.xyz/docs/operator-guide/cards/providers) offers its users a virtual card funded from their wallet. `@pollar/react` wraps the whole flow in `<CardModal>`; the methods below are the headless surface. The card number is decrypted on the device, never on a Pollar server.

Every method takes an optional `{ cardProviderId }`, needed only when the app enables more than one provider.

| Method | Description |
|---|---|
| `getCardProviders()` -> `Promise<CardProvider[]>` | The providers this app enables. An empty array means Cards is off: hide the UI |
| `getCardRequirements(params?)` -> `Promise<CardRequirements>` | The platform steps the provider needs (`KYC`, `FORM`, `REGISTRY_CHECK`, `PROVIDER_REGISTRATION`) and where the user stands (`next`, `completed`, `total`) |
| `getCardProviderRegistration(cardProviderId)` / `submitCardProviderRegistration(cardProviderId)` | Whether the user is registered with the provider, what is shared, and the user's consent to sign up from the verified identity and form answers |
| `getCardHolder(params?)` -> `Promise<CardHolder \| null>` | The holder, `null` before `createCardHolder` |
| `createCardHolder(params?)` | Creates the holder; `firstName`, `lastName`, `email` default to the session profile |
| `submitCardKyc({ termsAccepted, kyc })` -> `Promise<CardHolder>` | The provider's own KYC form (`CardKycInput`); `termsAccepted` must be `true`. The returned holder carries `verificationLink` while `kycStatus` is `PENDING` / `NEEDS_ACTION` / `IN_REVIEW` |
| `getCardOccupations(params?)` | The occupation codes `CardKycInput.occupation` accepts |
| `getCards(params?)` -> `Promise<CardInfo[]>` | The user's cards; never includes card numbers |
| `issueCard({ nickname?, limit? })` -> `Promise<CardInfo>` | Issue a virtual card. Needs an approved KYC |
| `getCardBalance(params?)` -> `Promise<CardBalance \| null>` | Credit limit, spending power and balance due, read live from the provider |
| `getCardTransactions({ cardId?, limit?, offset? })` -> `Promise<CardTransactionsPage>` | Newest first |
| `fundCard({ amount })` -> `Promise<CardFundingOutcome>` | Moves USDC from the user's **Stellar** wallet to the card's collateral. A custodial wallet pays at once; an external wallet is asked to sign, and `{ status: 'cancelled' }` means it declined. The returned `CardFunding` then advances on its own: `CREATED -> BURNED -> ATTESTED -> MINTED -> CREDITED`, or `FAILED` with `error` |
| `getCardFunding(fundingId)` / `listCardFundings(params?)` | Follow a funding, or list them newest first |
| `getCardDepositAddresses(params?)` | One deposit address per network, for funding from another wallet |
| `revealCardSecrets(cardId, params?)` -> `Promise<CardSecrets>` | PAN and CVC, decrypted on this device with a one-shot key the server never sees. Show them and drop them; never store or log the result |

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

## Errors and messages

Transaction methods (`signTx`, `runTx`, `sendPayment`, `setTrustline`, ...) return an outcome with `status: 'error'` and a `code` instead of throwing. Calls that read or create resources (KYC, `createWallet`, ramps, cards, requirement steps) throw a `PollarApiError`: `code` is the stable machine-readable code, `details` the server's reason when it sends one, and `body` the whole error payload. A request that hangs past its timeout rejects with a `PollarNetworkError` (`code: 'SDK_NETWORK_TIMEOUT'`).

Match on `code`, with the exported guards:

```typescript
import { isPollarApiError, isPollarNetworkError, appUnavailableMessage } from '@pollar/core';

try {
  await pollar.createRampOrder({ quoteId, payee });
} catch (err) {
  const unavailable = appUnavailableMessage(err); // 402: the app is out of credits or has an overdue bill
  if (unavailable) return showError(unavailable);
  if (isPollarApiError(err) && err.code === 'VALIDATION_ERROR') return showError(String(err.body.message));
  if (isPollarNetworkError(err)) return showError('Network timeout, try again');
  throw err;
}
```

| Helper | Returns |
|---|---|
| `appUnavailableMessage(error)` | The text for an error the user cannot fix and the app's owner must: `SDK_CREDITS_INSUFFICIENT` or `SDK_BILLING_OVERDUE` (402). `null` for any other error. The SDK also logs one console warning for the developer |
| `cosignRefusalMessage(error)` | The text for `SDK_COSIGN_TURNKEY_REJECTED`, with Turnkey's own reason; `null` for any other error |
| `transactionErrorMessage(code, details)` | User-facing text for a failed transaction or approval, on-chain result codes included |
| `toBaseUnits(amount, decimals)` / `fromBaseUnits(base, decimals)` | Convert between a decimal string and integer base units (`'1.5'` with 9 decimals is `'1500000000'`). `toBaseUnits` throws on a malformed amount or on more fractional digits than the asset has |
| `POLLAR_CORE_VERSION` | The installed `@pollar/core` version |

Every code is listed in [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes).

---

## Server-side ramp adapters

`@pollar/core/ramps` is a separate entry point for a ramp provider adapter registered with Pollar and run server-side, not for apps. It exports `defineRampAdapter`, `defineRampAdapterRegistration`, `RampAdapterError`, `isRampAdapterError` and the `RampAdapter*` types. The contract is version 2 (`RAMP_ADAPTER_CONTRACT_VERSION`); a registration without `contractVersion` is treated as version 1.

```typescript
import { defineRampAdapter, defineRampAdapterRegistration } from '@pollar/core/ramps';
```

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
  WalletInfo,
  WalletProvisioning,
  SendPaymentParams,
  SubmitOutcome,
  SignOutcome,
  TrustlineOutcome,
  PollarUserProfile,
  // KYC and requirement steps
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
  ProviderRegistration,
  // ramps
  RampDirection,
  RampRoutesResponse,
  RampRoute,
  RampFiat,
  RampAsset,
  RampQuoteRequest,
  RampQuotesResponse,
  RampQuote,
  RampQuoteLeg,
  RampField,
  RampQuoteRejection,
  RampQuoteRequirement,
  RampOrderRequest,
  RampOrder,
  RampOrderLeg,
  RampOrderLegStep,
  RampOrderState,
  RampOrdersQuery,
  RampOrdersPage,
  RampPendingAction,
  RampSignatureAction,
  RampFiatInstructions,
  RampScannable,
  RampFailure,
  RampWalletSetup,
  RampSigningHandler,
  RampWalletStep,
  // swap, earn, distribution, sessions
  SwapVenue,
  SwapToken,
  SwapQuote,
  SwapQuoteParams,
  EarnProviderId,
  EarnOpportunity,
  EarnPosition,
  DistributionRule,
  SessionInfo,
  // confirmations and Turnkey wallets
  ConfirmationPolicy,
  ConfirmationRequest,
  PendingConfirmation,
  CosignRequest,
  CosignState,
  CosignVerification,
  CosignProposal,
  CosignCustody,
  CosignQuorumReport,
  CosignDevicesContent,
  RecoveryState,
  RecoveryPasskeyCeremony,
  CustodyMigrationState,
  CustodyMigrationChain,
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

import { WalletType, RampChain, PollarApiError, PollarNetworkError } from '@pollar/core';
```

`RampChain` is both a type and a runtime constant (`RampChain.STELLAR`, `RampChain.POLYGON`, `RampChain.SOLANA`).
