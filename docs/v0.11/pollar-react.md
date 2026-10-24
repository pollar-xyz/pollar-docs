---
title: "@pollar/react"
---

> **@pollar 0.11.x.** This page documents the 0.11 release line, which talks to SDK API v2. The current release is 0.12, documented under [Latest](https://docs.pollar.xyz/docs/sdk-reference/pollar-react). On 0.11.x the ramp methods answer `410 SDK_RAMPS_MOVED_TO_V3`: ramps need 0.12. To move, read the [0.11 -> 0.12 upgrade notes](https://github.com/pollar-xyz/pollar/blob/main/UPGRADE.md).

React hooks and pre-built UI components for Pollar, for Stellar and Solana applications. Built on top of `@pollar/core`.

The modals are multichain: Send, Receive, Wallet balance, Enabled assets and Transaction history carry a network picker on an app with more than one chain, and each scopes its rows to the selected chain (Solana rows link to explorer.solana.com and show fees in lamports). Swap and Earn are Stellar modals. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support).

**Version:** `0.11.5`

```bash
npm install @pollar/react
```

---

## `<PollarProvider>`

Wraps your application root. Required for all hooks and components to work. Internally renders every Pollar modal — login, transaction, send, receive, KYC, ramp, tx history, wallet balance, enabled-assets, swap, earn, sessions, and distribution-rules — so you do not need to mount them manually.

```tsx
import { PollarProvider } from '@pollar/react';

<PollarProvider
  client={{ apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx' }}
>
  <App />
</PollarProvider>
```

**Props:**

| Prop               | Type                                 | Required | Description                                                                                  |
|--------------------|--------------------------------------|----------|----------------------------------------------------------------------------------------------|
| `client`           | `PollarClientConfig \| PollarClient` | Yes      | A `PollarClientConfig` (the provider builds the client) or a pre-built `PollarClient` instance. Locked at first render. |
| `appConfig`        | `PollarConfig`                       | No       | Local override of the remote `/applications/config` (styles, app name). If provided, the remote fetch is skipped. |
| `adapters`         | `PollarAdapters`                     | No       | Transaction-building adapters (e.g. `@pollar/accesly-adapter`), consumed via `createPollarAdapterHook`. This is **not** the wallet-login slot — wallet login providers go on the client's `walletAdapters` config; see [Wallet Adapters](https://docs.pollar.xyz/docs/v0.11/wallet-adapters). |
| `onStorageDegrade` | `OnStorageDegrade`                   | No       | Notified when persistent storage silently degrades to in-memory mode.                        |

> To register wallet-login providers (Stellar Wallets Kit, Privy), put them on `client.walletAdapters`, not on this component. See [Wallet Adapters](https://docs.pollar.xyz/docs/v0.11/wallet-adapters).

**`PollarClientConfig`:**

| Option           | Type             | Default                          | Description                                 |
|------------------|------------------|----------------------------------|---------------------------------------------|
| `apiKey`         | `string`         | —                                | **Required.** Your Pollar API key.          |
| `stellarNetwork` | `StellarNetwork` | `'testnet'`                      | Target network: `'testnet'` or `'mainnet'`. |
| `baseUrl`        | `string`         | `'https://sdk.api.pollar.xyz'` (origin only; the SDK appends the API version: `/v3` from 0.12.0, `/v2` in 0.11.x) | Override the Pollar API base URL. |
| `confirmation`   | `'auto' \| 'prompt'` | `'auto'`                     | `'prompt'` shows every signature to the user in `<ConfirmModal>` first. |

Every other `PollarClientConfig` option (`walletAdapters`, `cosignManual`, `loginTimeoutMs`, `storage`, `passkey`, ...) is documented in [`@pollar/core`](https://docs.pollar.xyz/docs/v0.11/pollar-core#pollarclient).

---

## `usePollar()`

The primary hook. Provides access to all Pollar functionality from a single import. Must be used inside `<PollarProvider>`.

```tsx
'use client';
import { usePollar } from '@pollar/react';

function MyComponent() {
  const {
    isAuthenticated,
    verified,
    wallet,
    login,
    logout,
    buildTx,
    signAndSubmitTx,
    signTx,
    submitTx,
    buildAndSignAndSubmitTx,
    runTx,
    tx,
    txHistory,
    network,
    setNetwork,
    walletBalance,
    refreshWalletBalance,
    enabledAssets,
    refreshAssets,
    setTrustline,
    getSwapConfig,
    getSwapTokens,
    getSwapQuote,
    swap,
    getEarnProviders,
    getEarnOpportunities,
    getEarnPosition,
    earnDeposit,
    earnWithdraw,
    getClient,
    openLoginModal,
    openTxModal,
    openKycModal,
    openRampModal,
    openTxHistoryModal,
    openWalletBalanceModal,
    openSendModal,
    openReceiveModal,
    openEnabledAssetsModal,
    openSwapModal,
    openEarnModal,
    openSessionsModal,
    openDistributionRulesModal,
    sessions,
    appConfig,
    styles,
  } = usePollar();
}
```

---

### Authentication

| Property          | Type                                    | Description                                                               |
|-------------------|-----------------------------------------|---------------------------------------------------------------------------|
| `isAuthenticated` | `boolean`                               | Whether the user has an active session. True for a signed-in user with no wallet yet. |
| `verified`        | `boolean`                               | `true` once the server has confirmed the session (login / refresh / resume). `false` while a cold-start session is still optimistic — gate sensitive actions (e.g. signing) on this. |
| `wallet`          | `WalletInfo \| null`                    | The authenticated wallet as a discriminated union over `custody` (`internal` \| `smart` \| `external`), or `null` when unauthenticated. Use `wallet.address` for the on-chain address and `wallet.provider` for the login/wallet provider. |
| `hasWallet`       | `boolean`                               | Whether the user has a wallet on any chain. `false` for an app with [on-demand wallet creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) until `createWallet()` runs. |
| `createWallet`    | `() => Promise<WalletInfo>`             | Creates the user's wallet (On demand apps). See [`pollar.createWallet()`](https://docs.pollar.xyz/docs/v0.11/pollar-core). |
| `login`           | `(options: PollarLoginOptions) => void` | Initiates an authentication flow.                                         |
| `logout`          | `() => void`                            | Signs out the current user and clears the session.                        |

### Wallets per chain

| Property     | Type                | Description                                                                 |
|--------------|---------------------|-----------------------------------------------------------------------------|
| `wallets`    | `WalletInfo[]`      | Every wallet the user holds, one per chain, each with `chain` set. `[]` when logged out. Drives the network pickers; the first one is the default. |
| `wallet`     | `WalletInfo \| null` | The Stellar wallet (see above); `null` after a Solana-only sign-in. Read `wallets` on a multichain app. |

```tsx
const { wallets } = usePollar();
const solana = wallets.find((w) => w.chain === 'SOLANA');
```

See [`useChains()`](#usechains) for the app's chain order and the primary chain, and `walletNotReadyReason(wallet, chain)` for the message to show while a Stellar account is still being created.

### Co-signed wallets and confirmations

| Property           | Type                    | Description                                                                 |
|--------------------|-------------------------|-----------------------------------------------------------------------------|
| `cosign`           | `CosignState`           | `{ pending, lastResolved? }`: requests waiting for this device's vote (Turnkey co-signed wallets). |
| `openCosignModal`  | `() => void`            | Opens the approval prompt of a co-signed wallet. It opens by itself when a request arrives. |
| `confirmations`    | `PendingConfirmation[]` | Signing calls waiting for the user under `confirmation: 'prompt'`; the provider shows the first one in `<ConfirmModal>`. |

Under the default `confirmation: 'auto'` a co-signed wallet behaves like a custodial one from the app's point of view: the device verifies and votes, and `runTx` resolves to `success`. See [Co-signed wallets](https://docs.pollar.xyz/docs/v0.11/pollar-core#co-signed-wallets) in `@pollar/core` and [`useCosign()`](#usecosign) for a custom approval UI.

### App config

| Property       | Type                               | Description                                                                 |
|----------------|------------------------------------|-----------------------------------------------------------------------------|
| `configStatus` | `'loading' \| 'ready' \| 'error'`  | State of the remote `/applications/config` load. `'ready'` at once when `appConfig` is passed. On `'error'` the styles fall back to defaults and the login modal shows a retry. |
| `retryConfig`  | `() => void`                       | Re-run the config fetch after an error. No-op when `appConfig` is passed.   |

**`PollarLoginOptions`:**

| Value                                    | Description                                                       |
|------------------------------------------|-------------------------------------------------------------------|
| `{ provider: 'google' }`                 | Opens Google OAuth flow.                                          |
| `{ provider: 'github' }`                 | Opens GitHub OAuth flow.                                          |
| `{ provider: 'email', email: string }`   | Sends an OTP code to the provided email address.                 |
| `{ provider: WalletType.FREIGHTER }`     | Connects the built-in Freighter wallet (id `'freighter-native'`). |
| `{ provider: WalletType.ALBEDO }`        | Connects the built-in Albedo wallet (id `'albedo-native'`).      |
| `{ provider: '<adapter id>' }`           | Any wallet registered via `walletAdapters` (`'xbull'`, `'lobstr'`, `'privy'`, …). See [Wallet Adapters](https://docs.pollar.xyz/docs/v0.11/wallet-adapters). |

---

### Transactions

| Property                  | Type                                                          | Description                                                              |
|---------------------------|---------------------------------------------------------------|-------------------------------------------------------------------------|
| `tx`                      | `TransactionState`                                            | Current transaction state (reactive).                                   |
| `buildTx`                 | `(operation, params, options?) => Promise<BuildOutcome>`     | Builds an unsigned Stellar transaction.                                |
| `signAndSubmitTx`         | `(unsignedXdr?: string) => Promise<SubmitOutcome>`           | Signs and submits a built transaction (defaults to the current `built` XDR if omitted). |
| `signTx`                  | `(unsignedXdr: string, options?: { skipSponsorship? }) => Promise<SignOutcome>` | Sign without submitting (server-side for a managed wallet, in the adapter for an external one; not available to passkey smart wallets). |
| `submitTx`                | `(signedXdr: string) => Promise<SubmitOutcome>`            | Submits an already-signed XDR.                                         |
| `buildAndSignAndSubmitTx` | `(operation, params, options?) => Promise<SubmitOutcome>`   | One-shot build → sign → submit.                                        |
| `runTx`                   | `(operation, params, options?) => Promise<SubmitOutcome>`   | Alias of `buildAndSignAndSubmitTx`.                                    |
| `sendPayment`             | `(params: SendPaymentParams) => Promise<SubmitOutcome>`     | One-shot payment on any chain: Stellar (`asset`), Solana (`chain: 'SOLANA'`, `mint?`, base units) or Polygon. |
| `openTxModal`             | `() => void`                                                 | Opens the transaction modal programmatically.                          |

The transaction modal opens automatically when `buildTx` is called. See [`@pollar/core`](https://docs.pollar.xyz/docs/v0.11/pollar-core) for `TransactionState` step details and the per-call `BuildOutcome` / `SignOutcome` / `SubmitOutcome` return types.

---

### Network

| Property     | Type                               | Description                           |
|--------------|------------------------------------|---------------------------------------|
| `network`    | `StellarNetwork`                   | Currently active network.             |
| `setNetwork` | `(network: StellarNetwork) => void` | Switches the active Stellar network. |

---

### Wallet Balance

| Property                 | Type                       | Description                                                              |
|--------------------------|----------------------------|--------------------------------------------------------------------------|
| `walletBalance`          | `WalletBalanceState`       | Current wallet balance state (reactive).                                |
| `refreshWalletBalance`   | `() => Promise<void>`      | Refreshes balances for the authenticated wallet. Drives `walletBalance`. |
| `openWalletBalanceModal` | `() => void`               | Opens the wallet balance modal.                                         |

> For an arbitrary public key / network, use `getClient().getWalletBalance(publicKey)` from `@pollar/core`.

---

### Enabled assets & trustlines

| Property                 | Type                                                                          | Description                                                     |
|--------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------|
| `enabledAssets`          | `EnabledAssetsState`                                                          | App-enabled assets paired with the wallet's trustline state.    |
| `refreshAssets`          | `() => Promise<void>`                                                         | Refreshes the enabled-assets state.                             |
| `setTrustline`           | `(asset: { code; issuer }, opts?: { limit?; skipSponsorship? }) => Promise<TrustlineOutcome>` | Establish (omit `limit`) or remove (`limit: '0'`) a trustline. The app sponsors it when the dashboard says so; `skipSponsorship: true` makes the user pay. |
| `openEnabledAssetsModal` | `() => void`                                                                 | Opens the enabled-assets / trustline modal.                     |

---

### Swap

| Property         | Type                                                            | Description                                              |
|------------------|-----------------------------------------------------------------|----------------------------------------------------------|
| `getSwapConfig`  | `() => Promise<SwapVenue[]>`                                    | Venues this app exposes (empty = swap disabled).         |
| `getSwapTokens`  | `() => Promise<SwapToken[]>`                                    | Curated "buy" token catalog.                             |
| `getSwapQuote`   | `(params: SwapQuoteParams) => Promise<SwapQuote[]>`            | Quotes ranked best-first.                                |
| `swap`           | `(quote: SwapQuote, opts?: { autoTrustline? }) => Promise<SubmitOutcome>` | Executes a quote; drives `tx`.                  |
| `openSwapModal`  | `() => void`                                                   | Opens the swap modal.                                    |

---

### Earn

| Property               | Type                                                    | Description                                          |
|------------------------|---------------------------------------------------------|------------------------------------------------------|
| `getEarnProviders`     | `() => Promise<EarnProviderId[]>`                       | Yield providers this app exposes (empty = disabled). |
| `getEarnOpportunities` | `(provider: EarnProviderId) => Promise<EarnOpportunity[]>` | Vaults/pools with live APY.                       |
| `getEarnPosition`      | `(params: EarnPositionParams) => Promise<EarnPosition>` | The wallet's position.                              |
| `earnDeposit`          | `(params: EarnTxParams) => Promise<SubmitOutcome>`      | Deposit into a vault/pool; drives `tx`.             |
| `earnWithdraw`         | `(params: EarnTxParams) => Promise<SubmitOutcome>`      | Withdraw from a vault/pool; drives `tx`.            |
| `openEarnModal`        | `() => void`                                            | Opens the Earn modal.                               |

---

### Transaction History

| Property            | Type             | Description                          |
|---------------------|------------------|--------------------------------------|
| `txHistory`         | `TxHistoryState` | Current tx history state (reactive). |
| `openTxHistoryModal` | `() => void`    | Opens the transaction history modal. |

---

### KYC

| Property       | Type                                                                                  | Description                       |
|----------------|---------------------------------------------------------------------------------------|-----------------------------------|
| `openKycModal` | `(options?: { corridorId?; providerId?; country?; level?; onApproved? }) => void` | Opens the KYC verification modal. |

| Option       | Type         | Default   | Description                                                           |
|--------------|--------------|-----------|-----------------------------------------------------------------------|
| `corridorId` | `string`     | —         | Walk the requirement steps of this ramp route (KYC, forms, registry checks, provider registration). |
| `providerId` | `string`     | —         | Open this KYC option directly instead of listing the choices (the one a ramp's KYC gate names). |
| `country`    | `string`     | `'MX'`    | ISO 3166-1 alpha-2 country code to filter providers.                  |
| `level`      | `KycLevel`   | `'basic'` | Legacy fallback for older backends; named options select their own workflow. |
| `onApproved` | `() => void` | —         | Callback invoked when the KYC verification is successfully approved.  |

Without `corridorId` or `providerId` the modal walks the app's own KYC steps, as configured in the dashboard.

---

### Ramps

| Property         | Type         | Description                        |
|------------------|--------------|------------------------------------|
| `openRampModal`  | `() => void` | Opens the fiat on/off-ramp widget. |

---

### Utilities

| Property    | Type                 | Description                                                            |
|-------------|----------------------|------------------------------------------------------------------------|
| `getClient` | `() => PollarClient` | Returns the underlying `PollarClient` instance for direct API access.  |
| `appConfig` | `PollarConfig`       | Application configuration fetched from the Pollar Dashboard.          |
| `styles`    | `PollarStyles`       | Resolved styles, merging remote config with any local overrides.       |

---

### Modal entry points

All Pollar modals are mounted inside `<PollarProvider>` and controlled programmatically:

| Function                         | Description                             |
|----------------------------------|-----------------------------------------|
| `openLoginModal()`               | Opens the login modal.                  |
| `openTxModal()`                  | Opens the transaction modal.            |
| `openKycModal(options?)`         | Opens the KYC modal.                    |
| `openRampModal()`                | Opens the ramp widget.                  |
| `openTxHistoryModal()`           | Opens the transaction history modal.    |
| `openWalletBalanceModal()`       | Opens the wallet balance modal.         |
| `openSendModal()`                | Opens the send-payment modal.           |
| `openReceiveModal()`             | Opens the receive modal.                |
| `openEnabledAssetsModal()`       | Opens the enabled-assets / trustline modal. |
| `openSwapModal()`                | Opens the swap modal.                   |
| `openEarnModal()`                | Opens the Earn modal.                   |
| `openSessionsModal()`            | Opens the active-sessions modal.        |
| `openDistributionRulesModal()`   | Opens the distribution-rules modal.     |
| `openCardModal()`                | Opens the Cards modal: sign-up, identity verification, issuing, the card and its activity. |
| `openCosignModal()`              | Opens the co-sign approval prompt.      |

---

## Hooks

### `useChains()`

The chains the app serves **and** the user holds a wallet on, in the order configured under [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains). Drive every chain selector from this, not from `wallets` alone: a chain can be enabled before this user is provisioned on it.

```tsx
import { useChains, ChainSelect } from '@pollar/react';

const { chains, primaryChain, primaryAddress, ready } = useChains();
const [chain, setChain] = useState(primaryChain);

if (!ready) return null;
<ChainSelect value={chain} options={chains} onChange={setChain} />
```

| Field            | Type                   | Description                                                                 |
|------------------|------------------------|-----------------------------------------------------------------------------|
| `chains`         | `WalletChain[]`        | `'STELLAR' \| 'SOLANA' \| 'POLYGON'`, in the app's order. `[]` until the config resolves. |
| `primaryChain`   | `WalletChain \| null`  | The app's first configured chain the user holds.                            |
| `primaryAddress` | `string`               | The address on `primaryChain`.                                              |
| `ready`          | `boolean`              | `false` while the config is loading or failed; gate chain UI on it.         |

Helpers exported alongside: `chainsOf(wallets, order?)`, `addressForChain(wallets, chain)`, `resolveChain(chain)` (pre-multichain records are Stellar), and `walletNotReadyReason(wallet, chain)`, which returns the message to show while a Stellar account is `CREATING` or `FAILED`, and `null` on every other chain.

### `useCosign()`

The user's side of a Turnkey co-signed wallet, for an app that renders its own confirmation UI instead of `<CosignModal>`. Subscribes to the client's co-sign store and loads the pending requests once on mount.

| Field          | Type                                                  | Description                                                   |
|----------------|-------------------------------------------------------|---------------------------------------------------------------|
| `pending`      | `CosignRequest[]`                                     | Requests waiting for this device's vote, oldest first.        |
| `lastResolved` | `CosignRequest \| undefined`                          | The last request that reached a final state.                  |
| `loaded`       | `boolean`                                             | Whether the store has been read at least once.                |
| `refresh`      | `() => Promise<void>`                                 | Re-read the pending requests.                                 |
| `verify`       | `(r) => Promise<CosignVerification>`                  | The verification a UI can show before the user decides.       |
| `approve`      | `(r) => Promise<CosignRequest>`                       | Verify against Turnkey and, when it checks out, vote yes.     |
| `reject`       | `(r) => Promise<CosignRequest>`                       | Vote no. Final.                                               |
| `inspectQuorum`| `() => Promise<CosignQuorumReport>`                   | Confirm the wallet is the promised 2-of-2 with this device registered. |
| `devices` / `revokeDevice` | see `@pollar/core`                        | The user's enrolled devices; revoke one (`force` to revoke this one). |

### `createPollarAdapterHook(key)`

Builds a hook over a transaction adapter registered through the `adapters` prop (for example `@pollar/accesly-adapter`): each adapter method becomes `(params) => Promise<SubmitOutcome>` that builds through the adapter and then calls `signAndSubmitTx`.

---

## Components

### `<WalletButton>`

Pre-built button that handles the complete authentication flow. When logged out, opens the login modal. When logged in, shows the wallet address with a dropdown for balance, transaction history, and logout.

Signed in without a wallet, it shows **No wallet** with **Create wallet**, active sessions and logout. For an app whose wallet creation is **Never** it shows **Signed in** without Create wallet.

```tsx
import { WalletButton } from '@pollar/react';

<WalletButton />
```

No props required. Appearance comes from your remote dashboard configuration (or the `appConfig` override passed to `<PollarProvider>`), exposed as `styles` on `usePollar()`. To override colors and corners from your own CSS, see [Theming](https://docs.pollar.xyz/docs/sdk-reference/theming).

---

### `<KycModal>`

Pre-built KYC verification modal. Can be rendered directly when you need more control than `openKycModal()` provides.

```tsx
import { KycModal } from '@pollar/react';

<KycModal
  onClose={() => setOpen(false)}
  country="US"
  level="basic"
  onApproved={() => console.log('KYC approved')}
/>
```

| Prop         | Type         | Default   | Description                                             |
|--------------|--------------|-----------|---------------------------------------------------------|
| `onClose`    | `() => void` | —         | **Required.** Called when the user dismisses the modal. |
| `corridorId` | `string`     | —         | Walk the requirement steps of this ramp route.          |
| `cardProviderId` | `string` | —         | A card provider's steps, in place of a route's.         |
| `providerId` | `string`     | —         | Open this KYC option directly instead of listing the choices. |
| `country`    | `string`     | `'MX'`    | ISO 3166-1 alpha-2 country code to filter providers.    |
| `level`      | `KycLevel`   | `'basic'` | Legacy fallback for older backends.                     |
| `onApproved` | `() => void` | —         | Called when KYC is successfully approved.               |

---

### `<KycStatus>`

A display-only badge for a KYC status value. It fetches nothing: pass the status you read from `getKycStatus()`.

```tsx
import { KycStatus } from '@pollar/react';

<KycStatus status={status} />
```

| Prop        | Type             | Description                                                     |
|-------------|------------------|-----------------------------------------------------------------|
| `status`    | `KycStatus`      | **Required.** `'none'`, `'pending'`, `'approved'`, `'rejected'` or `'expired'`. |
| `label`     | `string`         | Replaces the status label, keeping its color.                   |
| `className` | `string`         |                                                                 |

---

### `<RequirementFormModal>`

One `FORM` requirement step of a ramp route. Renders the form the backend names, prefilled with the user's previous answers, and stores the answers encrypted. `<RampWidget>` opens it by itself; render it directly when you build your own route list from the quote's `requirementsRequired`.

```tsx
import { RequirementFormModal } from '@pollar/react';

<RequirementFormModal
  formId={step.optionId}
  progress={{ position: step.completed + 1, total: step.total }}
  onClose={() => setOpen(false)}
  onSubmitted={() => requote()}
/>
```

| Prop          | Type                                  | Default | Description                                                        |
|---------------|---------------------------------------|---------|--------------------------------------------------------------------|
| `formId`      | `string`                              | —       | **Required.** The `optionId` of the pending `FORM` step.           |
| `progress`    | `{ position: number; total: number }` | —       | Shown as "Step n of total".                                        |
| `onClose`     | `() => void`                          | —       | **Required.** Called when the user dismisses the modal.            |
| `onSubmitted` | `() => void`                          | —       | **Required.** Called once the answers are stored. Quote again.     |

A 422 `KYC_FORM_INVALID_ANSWERS` is shown per field; numbers and dates are checked locally before the request.

---

### `<RegistryCheckModal>`

One `REGISTRY_CHECK` step (SEGIP, the Bolivian civil registry, through Stereum). Shows the user's verified identity prefilled and read-only; only the surname split and the CI complement can be edited. A check the registry did not confirm is held for review and the modal shows that state with nothing to retry.

```tsx
import { RegistryCheckModal } from '@pollar/react';

<RegistryCheckModal
  optionId={step.optionId}
  progress={{ position: step.completed + 1, total: step.total }}
  onClose={() => setOpen(false)}
  onApproved={() => requote()}
/>
```

| Prop         | Type                                  | Default | Description                                                             |
|--------------|---------------------------------------|---------|-------------------------------------------------------------------------|
| `optionId`   | `string`                              | —       | **Required.** The `optionId` of the pending `REGISTRY_CHECK` step.      |
| `progress`   | `{ position: number; total: number }` | —       | Shown as "Step n of total".                                             |
| `onClose`    | `() => void`                          | —       | **Required.** Called when the user dismisses the modal.                 |
| `onApproved` | `() => void`                          | —       | **Required.** Called once the registry confirmed the data. Quote again. |

`prefill.applies === false` (the document is not one the registry checks) shows a notice and only lets the user close. A 409 `KYC_REGISTRY_IDENTITY_REQUIRED` means the KYC step before it is not complete.

---

### `<ProviderRegistrationModal>`

One `PROVIDER_REGISTRATION` step. Lists what the ramp provider receives (identity, form answers, registry validation) and registers the user with it when they consent. A user already registered is passed through at once.

```tsx
import { ProviderRegistrationModal } from '@pollar/react';

<ProviderRegistrationModal
  corridorId={step.corridorId}
  progress={{ position: step.completed + 1, total: step.total }}
  onClose={() => setOpen(false)}
  onRegistered={() => requote()}
/>
```

| Prop           | Type                                  | Default | Description                                                                  |
|----------------|---------------------------------------|---------|------------------------------------------------------------------------------|
| `corridorId`   | `string`                              | —       | The route whose ramp the user registers with. One of `corridorId` / `cardProviderId`. |
| `cardProviderId` | `string`                            | —       | Or the card provider to register with.                                       |
| `progress`     | `{ position: number; total: number }` | —       | Shown as "Step n of total".                                                  |
| `onClose`      | `() => void`                          | —       | **Required.** Called when the user dismisses the modal.                      |
| `onRegistered` | `() => void`                          | —       | **Required.** Called once the user is registered with the provider. Quote again. |

A 409 `KYC_REGISTRATION_STEPS_PENDING` means an earlier step is still open; a 422 `KYC_REGISTRATION_MISSING_DATA` lists the fields the identity or the forms lack.

---

### `<CardModal>`

The Cards flow: provider steps (KYC, forms, registry check, provider registration), the provider's own KYC form with terms, verification polling, issuing, the card face with limit / available / to pay, recent activity, **Reveal** (decrypted on the device, auto-hidden after 30 s) and **Add funds** (from the user's Stellar wallet, shown as "Step n of 4" until credited, or a deposit address for another wallet).

```tsx
import { CardModal } from '@pollar/react';

<CardModal onClose={() => setOpen(false)} />
```

| Prop      | Type         | Description                                              |
|-----------|--------------|----------------------------------------------------------|
| `onClose` | `() => void` | **Required.** A funding in flight keeps advancing after close. |

Headless: the card methods on `PollarClient` ([Cards](https://docs.pollar.xyz/docs/v0.11/pollar-core#cards)).

---

### `<CosignModal>`

The approval prompt of a Turnkey co-signed wallet. It verifies each request against Turnkey before enabling **Approve**, so the user only confirms a transaction the device checked itself. The provider opens it by itself when a request arrives; render it yourself only to control placement.

```tsx
import { CosignModal } from '@pollar/react';

<CosignModal onClose={() => setOpen(false)} />
```

---

### `<RampWidget>`

Pre-built fiat on/off-ramp widget with support for on-ramp (fiat → crypto) and off-ramp (crypto → fiat) flows.

```tsx
import { RampWidget } from '@pollar/react';

<RampWidget onClose={() => setOpen(false)} />
```

| Prop      | Type         | Description                                              |
|-----------|--------------|----------------------------------------------------------|
| `onClose` | `() => void` | **Required.** Called when the user dismisses the widget. |

---

### `<WalletBalanceModal>`

Displays the token balances of the authenticated wallet with a manual refresh option.

```tsx
import { WalletBalanceModal } from '@pollar/react';

<WalletBalanceModal onClose={() => setOpen(false)} />
```

| Prop      | Type         | Description                                             |
|-----------|--------------|---------------------------------------------------------|
| `onClose` | `() => void` | **Required.** Called when the user dismisses the modal. |

---

## Template components

Template components handle rendering only — they receive all data and callbacks as props and contain no internal logic. Use them to build fully custom UI while reusing Pollar's layout and visual structure.

| Component                      | Description                                                  |
|--------------------------------|--------------------------------------------------------------|
| `<WalletButtonTemplate>`          | Wallet button (logged-out / logged-in) presentation.         |
| `<LoginModalTemplate>`            | Login provider selection and email OTP screens.              |
| `<KycModalTemplate>`              | KYC provider selection and verification screens.             |
| `<RampWidgetTemplate>`            | Ramp input, quote selection, and payment instruction screens.|
| `<TransactionModalTemplate>`      | Transaction details, signing, and result screens.            |
| `<TxHistoryModalTemplate>`        | Transaction history list screen.                             |
| `<WalletBalanceModalTemplate>`    | Wallet balance screen.                                       |
| `<EnabledAssetsModalTemplate>`    | Enabled-assets / trustline screen.                          |
| `<SendModalTemplate>`             | Send-payment screen.                                         |
| `<SwapModalTemplate>`             | Swap screen (exports `SwapAssetOption`).                    |
| `<ReceiveModalTemplate>`          | Receive (address / QR) screen.                              |
| `<SessionsModalTemplate>`         | Active-sessions list screen.                                |
| `<CosignModalTemplate>`           | Co-sign approval screen (`CosignModalTemplateProps`: `pending`, `current`, `verification`, `busy`, `onApprove`, `onReject`, ...). |
| `<DistributionRulesModalTemplate>`| Claimable distribution rules screen.                        |

Some template props are required because the live modals need them: `SendModalTemplateProps.onMax` / `onPaste`, `SwapModalTemplateProps.onReverse` / `onMax`, `SessionsModalTemplateProps.revokeError`, `RampWidgetTemplateProps.kycRequired` / `onVerifyRoute`. `WalletButtonTemplateProps` takes `theme`, `accentColor` and an optional `styleOverrides`, like the modal templates. The Send, Receive and WalletButton templates take an optional `notReadyReason` (from `walletNotReadyReason`), and the ramp template an optional `onboardingStatus`.

> Live (non-template) modal components are also exported for direct rendering: `SendModal`, `SwapModal`, `EarnModal`, `CardModal`, `CosignModal`, `ReceiveModal`, `EnabledAssetsModal`, `WalletBalanceModal`, `SessionsModal`, `DistributionRulesModal`, `KycModal`, `RequirementFormModal`, `RegistryCheckModal`, `ProviderRegistrationModal`, plus `KycStatus`, `RouteDisplay`, `ChainSelect` and `TxStatusView`. Each live modal takes `onClose`.
>
> Styling helpers: `buildModalCssVars(theme, accentColor, overrides?, variant?)`, `modalChrome(styles)`, `readableTextOn(background)` and the `ModalStyleOverrides` type (`backgroundColor`, `textColor`, `buttonColor`, `modalBorderRadius`, `buttonBorderRadius`). The CSS variables they feed are listed in [Theming](https://docs.pollar.xyz/docs/sdk-reference/theming). Passkeys: `browserPasskeyCeremony` and `browserPasskeySigner` are the WebAuthn implementations the provider installs on the client.

Import the corresponding `*Props` type for full type safety:

```tsx
import {
  TransactionModalTemplate,
  type TransactionModalTemplateProps,
  WalletBalanceModalTemplate,
  type WalletBalanceModalTemplateProps,
} from '@pollar/react';
```

---

## Types

```typescript
import type {
  PollarConfig,
  PollarStyles,
  LoginButtonProps,
  AuthModalProps,
  KycStep,
  RampStep,
  TransactionModalTemplateProps,
  WalletBalanceModalTemplateProps,
  // re-exported from @pollar/core so you can author custom login providers
  PollarAuthProvider,
  AuthProviderContext,
} from '@pollar/react';
```

Core types such as `WalletInfo`, `TransactionState`, `TxHistoryState`, `EnabledAssetsState`, `WalletBalanceContent`, `SwapQuote`, `EarnOpportunity`, `PollarLoginOptions`, `StellarNetwork`, and `WalletType` are imported directly from `@pollar/core`.