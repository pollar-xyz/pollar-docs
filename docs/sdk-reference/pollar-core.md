---
title: "@pollar/core"
---

Framework-agnostic TypeScript client for Pollar. Use this package directly if you are not using React, or to build custom integrations on top of the Pollar platform.

**Version:** `0.10.1`

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
| `baseUrl`        | `string`         | `'https://sdk.api.pollar.xyz'`   | Override the Pollar API base URL. The SDK appends `/v1` to it. Useful for self-hosted deployments. |

> Additional options are supported for non-web runtimes and advanced use: `storage`, `keyManager`, `walletAdapters` (array — see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters)), `requestTimeoutMs` (default `10000`), `submitTimeoutMs` (default `30000`), `retry`, `deviceLabel`, `visibilityProvider`, `openAuthUrl`, `oauthRedirectUri`, `passkey`, `logLevel`, `logger`, `onStorageDegrade`, and `maxIdleMs`. See the `PollarClientConfig` type for the full list (React Native consumers must inject a `storage` adapter, and provide `openAuthUrl` for OAuth).

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

For **external wallets** the adapter signs the entry directly. For **custodial wallets** Pollar signs server-side, and only if every contract and function in the entry's invocation tree is allowlisted for your app under **Treasury → [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/treasury/auth-policy)**. That allowlist is what keeps the custodial signer from being usable as a signing oracle, so an unconfigured app signs nothing. **Passkey smart accounts** (C-address sessions) are not supported by this method in the current build: they sign auth entries through their passkey ceremony, which this call does not run, so it resolves to `{ status: 'error' }` rather than signing with the wrong key.

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
| `submitted`                   | Accepted by Horizon; awaiting ledger confirmation. `hash` is set.   |
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

Fetches paginated transaction history for the authenticated wallet.

```typescript
await pollar.fetchTxHistory({
  limit: 20,
  offset: 0,
});
```

| Option   | Type     | Default | Description                                                        |
|----------|----------|---------|--------------------------------------------------------------------|
| `limit`  | `number` | —       | Number of records to return.                                       |
| `offset` | `number` | `0`     | Offset for pagination (history uses offset-based paging).          |

> Only transactions submitted through Pollar appear here. A record reads `PENDING` immediately after build and updates to `SUCCESS` or `FAILED` once submitted. Each record exposes `id`, `hash`, `network`, `status`, `operation`, `summary`, `feeXlm`, `resultCode`, and `createdAt`.

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

Pollar provides a KYC (Know Your Customer) flow that integrates with third-party identity verification providers.

### `pollar.getKycProviders(country)`

Returns the list of available KYC providers for the given country code.

```typescript
const providers = await pollar.getKycProviders('US');
```

---

### `pollar.getKycStatus(providerId?)`

Returns the current KYC status for the authenticated user. Optionally scoped to a specific provider. Resolves to an object — read `.status` for the value.

```typescript
const { status, level, providerId, expiresAt } = await pollar.getKycStatus();
// status: 'none' | 'pending' | 'approved' | 'rejected'
```

---

### `pollar.startKyc(body)`

Initiates a KYC verification session with the specified provider.

```typescript
const session = await pollar.startKyc({
  providerId: 'provider_id',
  level: 'basic',
  redirectUrl: 'https://yourapp.com/kyc/callback',
});
```

---

### `pollar.resolveKyc(providerId, level?)`

Resolves the outcome of a completed KYC session.

```typescript
await pollar.resolveKyc('provider_id', 'basic');
```

---

### `pollar.pollKycStatus(providerId, opts?)`

Polls the KYC status until it reaches a terminal state (`approved` or `rejected`), or until the timeout is exceeded.

```typescript
const finalStatus = await pollar.pollKycStatus('provider_id', {
  intervalMs: 2000,
  timeoutMs: 60000,
});
```

| Option       | Type     | Description                               |
|--------------|----------|-------------------------------------------|
| `intervalMs` | `number` | Polling interval in milliseconds.         |
| `timeoutMs`  | `number` | Maximum wait time before throwing.        |

**`KycStatus` values:** `'none'` · `'pending'` · `'approved'` · `'rejected'`

**`KycLevel` values:** `'basic'` · `'intermediate'` · `'enhanced'`

---

## Ramps

Pollar supports on-ramp (fiat → crypto) and off-ramp (crypto → fiat) flows through integrated third-party providers.

### `pollar.getRampsQuote(query)`

Returns available quotes for a ramp operation.

```typescript
const quotes = await pollar.getRampsQuote({
  direction: 'onramp',
  fiatCurrency: 'USD',
  cryptoAsset: 'USDC',
  amount: '100',
});
```

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

#### Quote expiry: count down `expiresAt`, not `providerExpiresAt`

A Pollar quote is accepted for **15 minutes**. Past `expiresAt`, starting a ramp
with that `quoteId` fails with `SDK_RAMPS_QUOTE_EXPIRED` and you request a new
one.

Providers run on much shorter clocks — Stereum's own quote lasts about a minute,
Etherfuse's about two — and `providerExpiresAt` reports that when the provider
publishes it. **You do not have to beat it.** When you start the ramp, Pollar
re-quotes the provider under the same parameters as the quote you were shown,
and confirms the order against that fresh quote. A provider quote going stale
while your user fills in a bank form is absorbed server-side and never reaches
you.

That matters most on off-ramps, where the form asks for an account number, a
bank, a holder name and a document: nobody completes it inside a provider's
one-minute window, and they do not have to.

`providerExpiresAt` is there for transparency — showing which provider clock is
running, or logging it — not as something to enforce.

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

An off-ramp is paid from the wallet, so the crypto has to be there before you
start it. `cryptoAmount` is that figure, and it is **fixed at quote time**: the
order charges exactly it, so moving precisely this much into the wallet is
always enough. If your app holds the balance elsewhere — a lending position, a
vault, a savings product — this is the number to withdraw.

Do not derive it by dividing the fiat amount by `rate`. `rate` is published
against an amount already rounded to the cent, so the division cannot recover
the charge and can land you a cent short; the ramp then fails with
`SDK_RAMPS_INSUFFICIENT_BALANCE`.

The trade-off that buys you a fixed charge: the **payout** absorbs rate movement
instead. Between the quote and the order, Pollar re-quotes the provider for the
same crypto amount, so the fiat that arrives can differ slightly from the figure
you displayed. Read the settled amounts back from the ramp transaction rather
than assuming the quote's.

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

`createOnRamp` / `createOffRamp` are safe to retry with the same `quoteId`. A
quote is consumed once, so a repeat does not open a second order or charge
twice: it answers with the transaction the first call already produced, carrying
its current `status` and `stellarTxHash`.

That matters because a timeout is not a failure. The SDK abandons a request
after 10 seconds by default, and a dropped connection can cut the answer after
the server has committed — on an off-ramp, after the crypto has left the wallet.
Treating that as a failed withdrawal is wrong, and there is no other way to find
the transaction, because its id came back in the answer you never received.

```ts
// On a network error, ask again with the same quoteId rather than giving up.
try {
  return await pollar.createOffRamp(body);
} catch (e) {
  if (isNetworkError(e)) return await pollar.createOffRamp(body); // replays, never duplicates
  throw e;
}
```

A genuine first failure still fails: nothing was created, so the retry runs the
start for real.

---

### `pollar.getRampTransaction(txId)`

Returns the current state of a ramp transaction by ID.

```typescript
const tx = await pollar.getRampTransaction('tx_id');
console.log(tx.status);
```

---

### `pollar.pollRampTransaction(txId, opts?)`

Polls a ramp transaction until it reaches a terminal status.

```typescript
const finalStatus = await pollar.pollRampTransaction('tx_id', {
  intervalMs: 3000,
  timeoutMs: 120000,
});
```

| Option       | Type     | Description                        |
|--------------|----------|------------------------------------|
| `intervalMs` | `number` | Polling interval in milliseconds.  |
| `timeoutMs`  | `number` | Maximum wait time before throwing. |

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

Lower-level building blocks are also available: `signTx(unsignedXdr)` (external
wallets only), `submitTx(signedXdr)`, `getTxStatus(hash)`, `createAccount()`, and
`resetTransactionState()`.

---

## Enabled assets & trustlines

The app's dashboard-enabled assets paired with the authenticated wallet's
on-chain trustline state.

- `pollar.getEnabledAssetsState()` — current state snapshot.
- `pollar.refreshAssets()` — refresh the enabled-assets state machine.
- `pollar.onEnabledAssetsStateChange(cb)` — subscribe; returns an unsubscribe fn.
- `pollar.setTrustline(asset, opts?)` — establish (omit `limit`) or remove
  (`limit: '0'`) a trustline. Pass `{ sponsored: true }` so the app covers the
  reserve + fee when eligible; otherwise the user's wallet pays. Returns a
  `TrustlineOutcome`.

```typescript
await pollar.setTrustline({ code: 'USDC', issuer: 'GABC...' }, { sponsored: true });
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
  KycLevel,
  KycStatus,
  KycFlow,
  KycProvider,
  KycStartBody,
  KycStartResponse,
  RampsQuoteQuery,
  RampQuote,
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
  PollarFlowError,
} from '@pollar/core';

import { WalletType } from '@pollar/core';
```
