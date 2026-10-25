---
title: "Upgrade to SDK 0.12"
description: "Move an app on any @pollar release from 0.5 to 0.11 to 0.12 and API v3, one change at a time, with what to search for in your code."
---

This guide takes an app on any `@pollar` release from **0.5.x to 0.11.x** to **0.12**, the release that talks to SDK API v3. It lists every change that can break your build or your app, grouped by topic, with what to search for in your code and what to write instead.

Releases before 0.11.0 call SDK API v1, which is **retired on 2026-11-30**: from then on it answers `410 Gone` and those apps stop signing users in. See [API versions](https://docs.pollar.xyz/docs/sdk-reference/api-versions) for the dates and the rehearsals before them.

---

## 1. Find the release you are on

Look at `@pollar/core` (and `@pollar/react` or `@pollar/react-native`) in your `package.json` or lockfile. **Monitor > SDK versions** in the dashboard lists the builds your users run ([guide](https://docs.pollar.xyz/docs/operator-guide/monitor/sdk-versions)); builds older than 0.11.4 show as not reporting.

Then read the sections marked for every release after yours. A section marked **0.10** applies if you are on 0.9.x or older.

| You are on | Sections that apply |
|---|---|
| 0.5.x | All of them |
| 0.6.x | All except [React context renames](#react-context-renames) |
| 0.7.x | From [Transactions](#transactions) on |
| 0.8.x and 0.9.x | From [Wallet address and type](#wallet-address-and-type) on |
| 0.10.x and 0.11.0 | From [Balances](#balances) on |
| 0.11.1 to 0.11.3 | From [KYC](#kyc) on |
| 0.11.4 and 0.11.5 | From [Ramps](#ramps) on |

---

## 2. Install matching versions

```bash
npm install @pollar/core@latest @pollar/react@latest
# React Native
npm install @pollar/core@latest @pollar/react-native@latest
```

- `@pollar/core`, `@pollar/react` and `@pollar/react-native` must be on the same minor: `@pollar/react@0.12.x` requires `@pollar/core@^0.12`. A caret range on an older line (`^0.11.5`, `^0.5.3`) never reaches 0.12, so edit it by hand.
- `@pollar/react-native` moved from `0.1.x` to the SDK's version line at 0.11.4. A `^0.1.1` range does not pick it up.
- Wallet adapters: install `@pollar/stellar-wallets-kit-adapter@latest` and `@pollar/solana-wallet-standard-adapter@latest` (0.12.0). `@pollar/privy-adapter` and `@pollar/accesly-adapter` have no 0.12 release and do not accept core 0.12.
- From 0.11.3, `@pollar/core` is a peer dependency of `@pollar/react`. npm 7+ installs it for you; with npm 6, Yarn 1 or `--legacy-peer-deps`, list `@pollar/core` in your own dependencies.

---

## 3. What every app notices

These need no code, but you should know about them before you ship.

- **Users sign in again once.** Sessions saved by 0.6.x and older (0.7) and by 0.9.x and older (0.10) are not read by the new release. Each user logs in once after you deploy. Nothing to do on your side.
- **HTTPS is required (0.7).** The SDK binds each session to a key on the device (DPoP), which needs `crypto.subtle` and `crypto.randomUUID`. Browsers expose them on HTTPS and on `localhost` only. In React Native, import `react-native-get-random-values` at the entry of your app.
- **Every signature asks the user first (0.12).** The default signature confirmation is now `'prompt'`: before each signature, `<ConfirmModal>` opens. The app's policy in the dashboard (**Wallet settings > Signature confirmation**) can turn that into a window or turn it off. A headless app must subscribe to `client.onConfirmationRequest()`, or every signature fails with `SDK_CONFIRMATION_UNAVAILABLE`. See [Signature confirmation](#signature-confirmation).
- **`baseUrl` is an origin.** If you pass `baseUrl`, pass only the origin (`https://sdk.api.pollar.xyz`). The SDK appends `/v3` itself; a `baseUrl` ending in `/v1` or `/v2` breaks every request.
- **A wallet can be on its way (0.11.4).** The platform creates the user's Stellar account after login, so the first seconds after a sign-up can answer `SDK_WALLET_NOT_READY`. The built-in components wait for it. See [Wallet provisioning](#wallet-provisioning) if you built your own send or receive screen.

---

## 4. The changes, by topic

Each section names the release that made the change, what to search for, and what to write instead.

### React context renames

**0.6.** Names returned by `usePollar()`:

| Search for | Replace with |
|---|---|
| `transaction` | `tx` |
| `openTransactionModal` | `openTxModal` |
| `config` | `appConfig` |
| `openRampWidget` | `openRampModal` |
| `refreshBalance` | `refreshWalletBalance` |

```tsx
// Before
const { transaction, openTransactionModal, refreshBalance } = usePollar();
// After
const { tx, openTxModal, refreshWalletBalance } = usePollar();
```

`TransactionModal` no longer opens by itself when a transaction starts: call `openTxModal()` where you want it. In `@pollar/react-native` 0.12, `buildTx` opens it for you.

### Session data and user profile

**0.7.** The user's email, names, avatar and providers are no longer in the session or in storage. Read them from the client after login.

Search for: `session.data`, `.data.mail`, `.data.first_name`, `sessionState.data`.

```ts
// Before
const email = authState.session.data.mail;
// After
const email = client.getUserProfile()?.mail;
```

Also in 0.7:

- The session is no longer stored under `pollar:session`. Code that reads `localStorage.getItem('pollar:session')` (for example to get the access token) stops working. Use the SDK's methods instead; there is no supported way to read the token, because it is useless without the device key.
- `logout()` returns a `Promise`. Fire-and-forget calls keep working; `await` it if you need the server-side revocation to finish. `logoutEverywhere()` signs the user out on every device.
- React Native: pass a storage adapter, `createSecureStoreAdapter()` from `@pollar/core/adapters/expo` or `createKeychainAdapter()` from `@pollar/core/adapters/react-native-keychain`. `@pollar/react-native` does this for you.

### Adapter types

**0.7.** Only for apps that use the `adapters` prop of `<PollarProvider>` (`createPollarAdapterHook`). The runtime contract is the same; two types are renamed.

| Search for | Replace with |
|---|---|
| `EscrowFn` | `AdapterFn` |
| `EscrowAdapter` | `PollarAdapter` |

Since 0.7.2 the functions of the hook resolve to a `SubmitOutcome` instead of `void`, so you can read `result.status`.

### Transactions

**0.7.2.** `buildTx` and `signAndSubmitTx` return an outcome instead of `void`. Code that ignores the result keeps working; code that annotated `Promise<void>` does not compile.

```ts
const outcome = await client.signAndSubmitTx(xdr);
if (outcome.status === 'success') {
  /* outcome.hash */
}
```

If you render `TransactionState` yourself, `state.step` has new values (`signed`, `submitting`, `submitted`, `signing-submitting`, `building-signing-submitting`, and in later releases `awaiting_cosign`): add the cases or a `default` branch. `state.external` is gone; check `'buildData' in state` instead. `error` carries a `phase`.

**0.8.** An external wallet's transaction is submitted through Pollar (`/tx/submit`) and can come back as `pending` before it is on the ledger. Treat `pending` as "sent, waiting".

### Provider props

**0.8.** `<PollarProvider>` props:

| Search for | Replace with |
|---|---|
| `config={...}` | `client={...}` (a config object or a `PollarClient`) |
| `styles={...}` | `appConfig={{ styles: {...} }}` |

```tsx
// Before
<PollarProvider config={{ apiKey }} styles={{ theme: 'dark' }}>
// After
<PollarProvider client={{ apiKey }}>
```

Passing `appConfig` (even `{}`) skips the dashboard configuration entirely: your app then ignores the branding, login methods and chains set in the dashboard. Leave it out unless you mean that. In 0.12 the dashboard's Branding no longer overrides your own CSS: a `--pollar-*` variable you set on a Pollar root wins. See [Theming](https://docs.pollar.xyz/docs/sdk-reference/theming).

### Wallet address and type

**0.9 and 0.10.** One `wallet` object replaces the separate fields.

| Search for | Replace with |
|---|---|
| `usePollar().walletAddress` | `usePollar().wallet?.address` |
| `usePollar().walletType` | `usePollar().wallet?.custody` (`'internal'`, `'smart'` or `'external'`), and `wallet?.provider` for the external wallet's id |
| `session.wallet.publicKey` | `session.wallet.address` |
| `=== 'custodial'` | `=== 'internal'` |

```tsx
// Before
const { walletAddress } = usePollar();
// After
const { wallet } = usePollar();
const address = wallet?.address;
```

From 0.11.4 a signed-in user can have no wallet yet, when the app creates wallets on demand: `wallet` is `null` until `createWallet()`. Check `hasWallet` before you read the address.

### External wallets

**0.10.** External wallets are an array of adapters. Freighter and Albedo are always registered.

| Search for | Replace with |
|---|---|
| `walletAdapter:` | `walletAdapters: [...]` |
| `stellarWalletsKit(` | `stellarWalletsKitAdapters(` |
| `loginWallet(id)` | `login({ provider: id })` |
| `ui={{ renderWallets` | remove it: the login modal lists every adapter |
| `@pollar/stellar-wallets-kit-adapter/picker` | remove it |

```tsx
import { Networks } from '@creit.tech/stellar-wallets-kit';
import { stellarWalletsKitAdapters } from '@pollar/stellar-wallets-kit-adapter';

<PollarProvider
  client={{
    apiKey,
    walletAdapters: stellarWalletsKitAdapters({ network: Networks.PUBLIC }),
  }}
>
```

`network` is required by `stellarWalletsKitAdapters` (0.8).

**Your own adapter.** `connect()` resolves `{ address }` only (0.9), and the adapter needs `meta: { label }` for its login button (0.10). `signTransaction` is optional on the interface since 0.11, because Solana adapters do not have it; guard the call if you use an adapter directly. See [Build Your Own Wallet Adapter](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter).

### Balances

**0.11 and 0.11.1.** Balances cover every chain the app enabled.

- `WalletBalanceRecord.balance` and `available` are `string | null`. `null` means the chain could not be read, not zero: show a dash, never `0`.
- Each record has a `chain` (`'STELLAR'`, `'POLYGON'`, `'SOLANA'`) and `decimals`. Format each amount with its own `decimals` instead of assuming 7.
- `type` can be `'token'`: an exhaustive `switch` needs that case.

```ts
// Before
const n = parseFloat(record.balance);
// After
const n = record.balance === null ? null : parseFloat(record.balance);
```

### Trustlines

**0.11.1.** `setTrustline(asset, { sponsored: true })` no longer compiles. The app's configuration decides who pays; drop the option. `{ skipSponsorship: true }` makes the user pay.

### KYC

**0.11.4.**

- `pollKycStatus()` also returns `'pending'` (held for review: stop polling) and `'expired'`. Use `pollKycDecision()` for the review reason.
- `KycStatus` includes `'expired'`.
- `getKycStatus`, `getKycProviders` and `startKyc` throw `PollarApiError`. Read `isPollarApiError(err) && err.code`.

### Wallet provisioning

**0.11.4.** Only if you built your own send or receive screen.

```ts
import { isWalletNotReady } from '@pollar/core';

if (client.getWallet()?.provisioning === 'CREATING') {
  // show "preparing your account"
}

const outcome = await client.signAndSubmitTx(xdr);
if (isWalletNotReady(outcome)) {
  // wait for onWalletStateChange, do not retry in a loop
}

client.onWalletStateChange((provisioning) => {
  if (provisioning === 'READY') enableSending();
});
```

`WalletProvisioning` includes `'NONE'` for a user without a wallet.

### Ramps

**0.12.** A ramp is an order of one or more legs that Pollar runs server-side. The old ramp methods are removed, and `/v1` and `/v2` answer `410` to any call that starts a ramp.

| Search for | Replace with |
|---|---|
| `getRampsQuote(query)` | `quoteRamp({ direction, fiat, asset, amount: { value, denomination } })` |
| `getRampCountries()` | `rampCountries((await client.getRampRoutes(direction)).routes)` |
| `createOnRamp` / `createOffRamp` | `createRampOrder({ quoteId, payee })` |
| `getRampTransaction` / `pollRampTransaction` | `getRampOrder(id)` / `pollRampOrder(id, { onUpdate, signal })` |
| `nextAction` | `order.pendingAction` (`FIAT_PAYMENT`, `SIGNATURE`, `COSIGN_APPROVAL`, `KYC`) |
| `signRampAction(txId, snapshot)` | `signRampLeg(orderId, actionId)` |
| quote `requiredFields` | `rampQuoteFields(quote)`, answered as `payee` |

If you use `<RampWidget>` (or `openRampModal()`), there is nothing to change. A custom `RampWidgetTemplate` takes the order and the quotes instead of the 0.11 transaction fields. See [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps).

### Signature confirmation

**0.12.** Every signing call waits for the user unless the app's policy says otherwise. With `<PollarProvider>` mounted, `<ConfirmModal>` handles it. A headless app answers each request:

```ts
client.onConfirmationRequest((pending) => {
  // every confirmation still waiting for an answer
  for (const request of pending) {
    showMyPrompt(request, { onYes: () => request.confirm(), onNo: () => request.reject() });
  }
});
```

`confirmation: 'auto'` in code applies only when the dashboard policy is also `AUTO`: the stricter of the two wins. A ramp leg always asks.

### Co-signed wallets

**0.11.5 and 0.12.** Only for apps whose wallets are co-signed with Turnkey. The provider opens `<CosignModal>`, `<RecoveryModal>` and `<CustodyMigrationModal>` when needed. Code that drives the verification itself reads `proposal` from `client.cosign.verify(request)` instead of `turnkeyPayload`, and `cosignGroupOf`, `cosignStepKeyOf`, `stepInGroup` and `CosignGroup` are removed. See [Co-signed wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets).

### Templates

Only for apps that mount a `*Template` component themselves instead of the built-in modals. Templates gained props across 0.11 and 0.12 (chain pickers, provisioning, ramp orders, the wallet button's `theme` / `accentColor` / `styleOverrides`). After upgrading, the TypeScript compiler lists every missing prop; the [React reference](https://docs.pollar.xyz/docs/sdk-reference/pollar-react) documents each one.

---

## 5. If you call the API without the SDK

A backend, proxy or test mock that calls `https://sdk.api.pollar.xyz` directly:

- Change the path prefix to `/v3`. v3 serves the same requests and answers as v2, ramps excepted.
- A proxy allow-list, a CORS rule or a mock that matches `/v1/...` or `/v2/...` must match `/v3/...`. If you run sdk-api behind your own proxy, allow the `x-pollar-sdk` request header (0.11.4).
- Sessions created by 0.7 and later are bound to the device key: requests carry `Authorization: DPoP <token>` and a `DPoP` proof header. Do not reuse a user's token from your backend; use the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) with a SECRET key instead.

---

## 6. Check the upgrade

1. **Build.** Run your type check (`tsc --noEmit`) and fix what it reports. Most changes in this guide surface there.
2. **Sign in** with each method your app offers (email, Google, a wallet, a passkey).
3. **Send a transaction** and confirm it in `<ConfirmModal>` (or your own prompt).
4. **Open each Pollar screen** your app uses: balance, send, receive, history, ramps.
5. **Deploy**, then confirm on **Monitor > SDK versions** that no live session remains on a build below 0.11.0, and that the v1 banner on **Home** is gone.

Release notes for every version are in the [CHANGELOG](https://github.com/pollar-xyz/pollar/blob/main/CHANGELOG.md).
