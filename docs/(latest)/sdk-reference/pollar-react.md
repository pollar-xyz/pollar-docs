---
title: "@pollar/react"
---

React hooks and pre-built UI components for Pollar, for Stellar and Solana applications. Built on top of `@pollar/core`.

The modals are multichain: Send, Receive, Wallet balance, Enabled assets and Transaction history carry a network picker on an app with more than one chain, and each scopes its rows to the selected chain (Solana rows link to explorer.solana.com and show fees in lamports). Swap offers Stellar and, on a mainnet app with Jupiter or Titan enabled, Solana, with a Network selector when the app has both. Earn is a Stellar modal. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support).

**Version:** `0.12.0`. It requires `@pollar/core@^0.12.0` and talks to SDK API v3. For 0.11.x, see the [0.11 reference](https://docs.pollar.xyz/docs/v0.11/pollar-react).

```bash
npm install @pollar/react @pollar/core
```

---

## `<PollarProvider>`

Wraps your application root. Required for all hooks and components to work. It renders every Pollar modal itself, so you do not mount them: login, transaction, send, receive, KYC, ramp, transaction history, wallet balance, enabled assets, swap, earn, cards, sessions, distribution rules, co-sign approval, signature confirmation, wallet recovery and custody migration.

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
| `appConfig`        | `PollarConfig`                       | No       | Local replacement for the remote `/applications/config` (styles, app name, chains). If provided, the remote fetch is skipped and nothing is merged with the server's answer. |
| `adapters`         | `PollarAdapters`                     | No       | Transaction-building adapters, consumed via `createPollarAdapterHook`. This is **not** the wallet-login slot: wallet login providers go on the client's `walletAdapters` config; see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters). |
| `onStorageDegrade` | `OnStorageDegrade`                   | No       | Notified when persistent storage silently degrades to in-memory mode.                        |

> To register wallet-login providers (Stellar Wallets Kit, Solana Wallet Standard), put them on `client.walletAdapters`, not on this component. See [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters).

**`PollarClientConfig`:**

| Option           | Type             | Default                          | Description                                 |
|------------------|------------------|----------------------------------|---------------------------------------------|
| `apiKey`         | `string`         | none                             | **Required.** Your Pollar publishable key.  |
| `stellarNetwork` | `StellarNetwork` | `'testnet'`                      | Target network: `'testnet'` or `'mainnet'`. |
| `baseUrl`        | `string`         | `'https://sdk.api.pollar.xyz'`   | Override the Pollar API origin. Pass the origin only: the SDK appends `/v3`. |
| `confirmation`   | `'prompt' \| 'auto' \| { window: { seconds, maxUsd } }` | unset: the app's dashboard setting, which defaults to `'prompt'` | How a signing call treats the user. See [Signature confirmation](#signature-confirmation). |
| `locale`         | `string`         | unset: the browser language      | Language of the modals, as a BCP 47 tag. See [Language](#language). |

Every other `PollarClientConfig` option (`walletAdapters`, `cosignManual`, `recoveryPasskey`, `loginTimeoutMs`, `storage`, `passkey`, ...) is documented in [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core).

### Signature confirmation

By default every signing call waits for the user: the provider shows the transaction in `<ConfirmModal>` and signs only when the user confirms, whatever the wallet's custody.

The app's policy is set in the dashboard, under **Wallets > Wallet settings > Signature confirmation** ([guide](https://docs.pollar.xyz/docs/operator-guide/wallets/settings)): always ask, ask once and then sign for a window (5 minutes and 50 USD by default), or never ask. With `confirmation` unset the SDK follows the dashboard. When you set it, the stricter of the two applies: `'auto'` in code skips the prompt only if the dashboard says never ask too.

- Inside a window, a signature signs without asking while the USD total of the window stays within `maxUsd`. Only a payment the SDK builds itself (`sendPayment`, `runTx('payment', ...)`) has a value it can read; any other signature (a raw `signTx`, a swap, a contract call) asks, and so does an asset with no price. The window closes on logout.
- A ramp leg always asks, whatever the policy.
- A declined prompt ends the call with `SDK_CONFIRMATION_DECLINED`; nothing was signed.

### Language

Every modal is in English, Spanish and Portuguese. The provider picks the language once, in this order:

1. The language pinned in the dashboard, **Build > Branding > Language** ([guide](https://docs.pollar.xyz/docs/operator-guide/build/branding)). With **User's device language** (the default) nothing is pinned.
2. The `language` prop of a modal that takes one (`<RampWidget>`, `<KycModal>`, `<RequirementFormModal>`, `<RegistryCheckModal>`, `<ProviderRegistrationModal>`).
3. The client's `locale`.
4. The browser language.

English when none of them is a language the modals have. To keep the modals in your app's language, pass it as `locale`:

```tsx
<PollarProvider client={{ apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx', locale: i18n.language }}>
```

`locale` is read when the client is built; the dashboard setting arrives with `/applications/config` on each mount.

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
    wallets,
    hasWallet,
    createWallet,
    login,
    logout,
    buildTx,
    signAndSubmitTx,
    signTx,
    submitTx,
    buildAndSignAndSubmitTx,
    runTx,
    sendPayment,
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
    cosign,
    confirmations,
    recovery,
    recoveryLocked,
    custodyMigration,
    getClient,
    openLoginModal,
    openTxModal,
    openKycModal,
    openRampModal,
    openRecoveryModal,
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
| `verified`        | `boolean`                               | `true` once the server has confirmed the session (login / refresh / resume). `false` while a cold-start session is still optimistic: gate sensitive actions (e.g. signing) on this. |
| `wallet`          | `WalletInfo \| null`                    | The authenticated wallet as a discriminated union over `custody` (`internal` \| `smart` \| `external`), or `null` when unauthenticated. Use `wallet.address` for the on-chain address and `wallet.provider` for the login/wallet provider. |
| `hasWallet`       | `boolean`                               | Whether the user has a wallet on any chain. `false` for an app with [on-demand wallet creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) until `createWallet()` runs. |
| `createWallet`    | `(options?: { custody?: CosignCustody }) => Promise<WalletInfo>` | Creates the user's wallet (On demand apps). `custody` carries the user's pick on an app whose custody mode leaves the choice to the user. See [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core). |
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

### Co-signed wallets, recovery and confirmations

These fields matter for an app whose wallets live in Turnkey (co-signed or self-custody). See [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets).

| Property                  | Type                              | Description                                                                 |
|---------------------------|-----------------------------------|-----------------------------------------------------------------------------|
| `cosign`                  | `CosignState`                     | `{ pending, lastResolved? }`: requests waiting for this device's vote.      |
| `openCosignModal`         | `() => void`                      | Opens the approval prompt. It opens by itself when a request arrives.       |
| `setCosignNextStep`       | `(next: string \| null) => void`  | Names the approval a flow asks for next (a ramp's swap after its approve): the prompt stays open after a sent transaction and shows the next request when it arrives, instead of closing. |
| `confirmations`           | `PendingConfirmation[]`           | Signing calls waiting for the user; the provider shows the first one in `<ConfirmModal>`. |
| `recovery`                | `RecoveryState \| null`           | The recovery state of the user's Turnkey wallet: whether it has a way back in without this device, and the methods it has. `null` until read, or for a session without a Turnkey wallet. |
| `recoveryLocked`          | `boolean`                         | `true` while the wallet has no recovery method. It signs nothing but its own setup and on-ramps until it has one; the wallet menu shows the lock and the receive modal hides the address. |
| `refreshRecovery`         | `() => void`                      | Reads the recovery state again (after a method changed elsewhere).          |
| `openRecoveryModal`       | `() => void`                      | Opens `<RecoveryModal>`: passkeys, email, devices and the phrase export.    |
| `custodyMigration`        | `CustodyMigrationState \| null`   | Whether the user's wallet, one Pollar custodies, has to move to this device because the app keeps its wallets in Turnkey. While `required`, the provider shows `<CustodyMigrationModal>` after login, before anything else. `null` until read. |
| `refreshCustodyMigration` | `() => void`                      | Reads the migration state again.                                            |

Every co-signed transaction asks the user, wallet setup included (account creation, trustlines, a new chain): `<CosignModal>` opens for it. Each request is verified on the device before **Approve** is enabled. See [`useCosign()`](#usecosign) for a custom approval UI, and [Passkeys and wallet recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide) for the recovery flow.

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
| `{ provider: '<adapter id>' }`           | Any wallet registered via `walletAdapters` (`'xbull'`, `'lobstr'`, a Solana wallet, ...). See [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters). |

---

### Transactions

| Property                  | Type                                                          | Description                                                              |
|---------------------------|---------------------------------------------------------------|-------------------------------------------------------------------------|
| `tx`                      | `TransactionState`                                            | Current transaction state (reactive).                                   |
| `buildTx`                 | `(operation, params, options?) => Promise<BuildOutcome>`     | Builds an unsigned Stellar transaction.                                |
| `signAndSubmitTx`         | `(unsignedXdr?: string) => Promise<SubmitOutcome>`           | Signs and submits a built transaction (defaults to the current `built` XDR if omitted). |
| `signTx`                  | `(unsignedXdr: string) => Promise<SignOutcome>`              | Sign without submitting (server-side for a managed wallet, in the adapter for an external one; not available to passkey smart wallets). For `skipSponsorship`, call `getClient().signTx(xdr, options)`. |
| `submitTx`                | `(signedXdr: string) => Promise<SubmitOutcome>`            | Submits an already-signed XDR.                                         |
| `buildAndSignAndSubmitTx` | `(operation, params, options?) => Promise<SubmitOutcome>`   | One-shot build, sign and submit.                                       |
| `runTx`                   | `(operation, params, options?) => Promise<SubmitOutcome>`   | Alias of `buildAndSignAndSubmitTx`.                                    |
| `sendPayment`             | `(params: SendPaymentParams) => Promise<SubmitOutcome>`     | One-shot payment on any chain: Stellar (`asset`), Solana (`chain: 'SOLANA'`, `mint?`, base units) or Polygon. |
| `openTxModal`             | `() => void`                                                 | Opens the transaction modal programmatically.                          |

The transaction modal opens automatically when `buildTx` is called. Each signing call first passes the [signature confirmation](#signature-confirmation). See [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) for `TransactionState` step details and the per-call `BuildOutcome` / `SignOutcome` / `SubmitOutcome` return types.

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
| `getSolanaSwapConfig` | `() => Promise<SolanaSwapVenue[]>`                         | Solana venues this app exposes (Jupiter, Titan; mainnet). |
| `getSolanaSwapQuote`  | `(params: SolanaSwapQuoteParams) => Promise<SolanaSwapQuote[]>` | Solana quotes in base units, best first.            |
| `swapSolana`          | `(quote: SolanaSwapQuote, opts?: { slippageBps? }) => Promise<SubmitOutcome>` | Runs a Solana swap; drives `tx`.     |
| `openSwapModal`  | `() => void`                                                   | Opens the swap modal. On an app that offers swaps on Stellar and Solana it shows a Network selector. |

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
| `corridorId` | `string`     | none      | Walk the requirement steps of a ramp route: the `requirement.corridorId` of a route the quote rejected. |
| `providerId` | `string`     | none      | Open this KYC option directly instead of listing the choices.         |
| `country`    | `string`     | `'MX'`    | ISO 3166-1 alpha-2 country code to filter providers.                  |
| `level`      | `KycLevel`   | `'basic'` | Fallback for backends without named options; named options select their own workflow. |
| `onApproved` | `() => void` | none      | Callback invoked when the KYC verification is successfully approved.  |

Without `corridorId` or `providerId` the modal walks the app's own KYC steps, as configured in the dashboard.

---

### Ramps

| Property         | Type         | Description                        |
|------------------|--------------|------------------------------------|
| `openRampModal`  | `() => void` | Opens the fiat on/off-ramp widget. |

The widget runs the v3 ramps API: a ramp is an order of one or more legs (the provider, a swap, a bridge) that Pollar runs server-side. See [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps) and the ramp methods in [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) for a headless flow.

---

### Utilities

| Property    | Type                 | Description                                                            |
|-------------|----------------------|------------------------------------------------------------------------|
| `getClient` | `() => PollarClient` | Returns the underlying `PollarClient` instance for direct API access.  |
| `appConfig` | `PollarConfig`       | Application configuration fetched from the Pollar Dashboard.          |
| `styles`    | `PollarStyles`       | Resolved styles, merging remote config with any local overrides.       |
| `sessions`  | `SessionsState`      | The user's active sessions (reactive).                                 |

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
| `openRecoveryModal()`            | Opens the wallet recovery modal.        |

`<ConfirmModal>` and `<CustodyMigrationModal>` have no entry point: the provider opens them when a signature waits for the user and when the server asks for the move.

---

## Hooks

### `useChains()`

The chains the app serves **and** the user holds a wallet on, in the order configured under **Wallets > Wallet settings** ([guide](https://docs.pollar.xyz/docs/operator-guide/wallets/settings)). Drive every chain selector from this, not from `wallets` alone: a chain can be enabled before this user is provisioned on it.

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

The user's side of a Turnkey wallet, for an app that renders its own approval UI instead of `<CosignModal>`. Subscribes to the client's co-sign store and loads the pending requests once on mount.

| Field          | Type                                                  | Description                                                   |
|----------------|-------------------------------------------------------|---------------------------------------------------------------|
| `pending`      | `CosignRequest[]`                                     | Requests waiting for this device's vote, oldest first.        |
| `lastResolved` | `CosignRequest \| undefined`                          | The last request that reached a final state.                  |
| `loaded`       | `boolean`                                             | Whether the store has been read at least once.                |
| `refresh`      | `() => Promise<void>`                                 | Re-read the pending requests.                                 |
| `verify`       | `(r) => Promise<CosignVerification>`                  | The verification a UI shows before the user decides: what the transaction does and the `proposal` the device will relay to Turnkey. |
| `approve`      | `(r) => Promise<CosignRequest>`                       | Verifies the request on the device and, when it checks out, proposes it to Turnkey; Pollar votes second. Call it from a user action. |
| `reject`       | `(r) => Promise<CosignRequest>`                       | Vote no. Closes the request on the server.                    |
| `inspectQuorum`| `() => Promise<CosignQuorumReport>`                   | Reads the wallet from Turnkey with the device key and checks it is the quorum its custody promises (2-of-2 co-signed, 1-of-1 self-custody) with this device registered. |
| `devices` / `revokeDevice` | see `@pollar/core`                        | The user's enrolled devices; revoke one (`force` to revoke this one). |
| `switchCustody`| `(to: CosignCustody) => Promise<CosignQuorumReport>`  | Moves the wallet between co-signed and self-custody. Only an app whose custody mode leaves the choice to the user allows it (`SDK_COSIGN_CUSTODY_SWITCH_NOT_ALLOWED` otherwise). |

### `createPollarAdapterHook(key)`

Builds a hook over a transaction adapter registered through the `adapters` prop: each adapter method becomes `(params) => Promise<SubmitOutcome>` that builds through the adapter and then calls `signAndSubmitTx`.

A method may instead return `{ unsignedAuthEntry, validUntilLedger, complete }` when someone else submits (an x402 facilitator, a contract that pays the gas). The hook then signs the entry with `signAuthEntry`, submits nothing, and calls `complete(signedAuthEntry)`; the method resolves to `{ status: 'completed', result }` with what `complete` returned, or to the `error` / `cosign_pending` outcome of the signature. Example in [Pay for APIs with x402](https://docs.pollar.xyz/docs/guides/x402-payments).

---

## Components

### `<WalletButton>`

Pre-built button that handles the complete authentication flow. When logged out, opens the login modal. When logged in, shows the wallet address with a dropdown for balance, transaction history, sessions and logout.

Signed in without a wallet, it shows **No wallet** with **Create wallet**, active sessions and logout. For an app whose wallet creation is **Never** it shows **Signed in** without Create wallet. While the wallet has no recovery method (`recoveryLocked`), the menu shows the lock with a way to add one.

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
| `onClose`    | `() => void` | none      | **Required.** Called when the user dismisses the modal. |
| `corridorId` | `string`     | none      | Walk the requirement steps of this ramp route.          |
| `cardProviderId` | `string` | none      | A card provider's steps, in place of a route's.         |
| `providerId` | `string`     | none      | Open this KYC option directly instead of listing the choices. |
| `country`    | `string`     | `'MX'`    | ISO 3166-1 alpha-2 country code to filter providers.    |
| `level`      | `KycLevel`   | `'basic'` | Fallback for backends without named options.            |
| `onApproved` | `() => void` | none      | Called when KYC is successfully approved.               |
| `language`   | `string`     | none      | Language of the modal as a BCP 47 tag. See [Language](#language). |

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

One `FORM` requirement step of a ramp route. Renders the form the backend names, prefilled with the user's previous answers, and stores the answers encrypted. `<RampWidget>` opens it by itself; render it directly when you build your own route list from the `requirement` of a route the quote rejected.

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
| `formId`      | `string`                              | none    | **Required.** The `optionId` of the pending `FORM` step.           |
| `progress`    | `{ position: number; total: number }` | none    | Shown as "Step n of total".                                        |
| `onClose`     | `() => void`                          | none    | **Required.** Called when the user dismisses the modal.            |
| `onSubmitted` | `() => void`                          | none    | **Required.** Called once the answers are stored. Quote again.     |
| `language`    | `string`                              | none    | Language of the modal as a BCP 47 tag. See [Language](#language).  |

A 422 `KYC_FORM_INVALID_ANSWERS` is shown per field; numbers and dates are checked locally before the request.

Labels, help and options show in the modal's language; a form without the Portuguese text shows the Spanish one, then the English one. A field with `showIf` appears only while the earlier field it depends on has one of its values (a select's option, a multiselect containing it, or a checkbox checked or not), and is neither checked nor sent while hidden; `required` applies only while it is shown.

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
| `optionId`   | `string`                              | none    | **Required.** The `optionId` of the pending `REGISTRY_CHECK` step.      |
| `progress`   | `{ position: number; total: number }` | none    | Shown as "Step n of total".                                             |
| `onClose`    | `() => void`                          | none    | **Required.** Called when the user dismisses the modal.                 |
| `onApproved` | `() => void`                          | none    | **Required.** Called once the registry confirmed the data. Quote again. |
| `language`   | `string`                              | none    | Language of the modal as a BCP 47 tag. See [Language](#language).       |

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
| `corridorId`   | `string`                              | none    | The route whose ramp the user registers with. One of `corridorId` / `cardProviderId`. |
| `cardProviderId` | `string`                            | none    | Or the card provider to register with.                                       |
| `progress`     | `{ position: number; total: number }` | none    | Shown as "Step n of total".                                                  |
| `onClose`      | `() => void`                          | none    | **Required.** Called when the user dismisses the modal.                      |
| `onRegistered` | `() => void`                          | none    | **Required.** Called once the user is registered with the provider. Quote again. |
| `language`     | `string`                              | none    | Language of the modal and the steps it opens, as a BCP 47 tag. See [Language](#language). |

A 409 `KYC_REGISTRATION_STEPS_PENDING` means an earlier step is still open; a 422 `KYC_REGISTRATION_MISSING_DATA` lists the fields the identity or the forms lack.

---

### `<CardModal>`

The Cards flow: provider steps (KYC, forms, registry check, provider registration), the provider's own KYC form with terms, verification polling, issuing, the card face with limit / available / to pay, recent activity, **Reveal** (decrypted on the device, auto-hidden after 30 s; the number and CVC can be copied while shown, the expiry date always) and **Add funds** (from the user's Stellar wallet, shown as "Step n of 4" until credited, or a deposit address for another wallet).

```tsx
import { CardModal } from '@pollar/react';

<CardModal onClose={() => setOpen(false)} />
```

| Prop      | Type         | Description                                              |
|-----------|--------------|----------------------------------------------------------|
| `onClose` | `() => void` | **Required.** A funding in flight keeps advancing after close. |

Headless: the card methods on `PollarClient` (see [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)).

---

### `<CosignModal>`

The approval prompt of a Turnkey wallet. It verifies each request on the device before enabling **Approve**, so the user only confirms a transaction the device checked itself. Every co-signed request opens it, wallet setup included. The provider opens it by itself when a request arrives; render it yourself only to control placement.

```tsx
import { CosignModal } from '@pollar/react';

<CosignModal onClose={() => setOpen(false)} />
```

| Prop       | Type                     | Description                                                              |
|------------|--------------------------|--------------------------------------------------------------------------|
| `onClose`  | `() => void`             | **Required.**                                                            |
| `nextStep` | `string \| null`         | The approval the flow asks for next (see `setCosignNextStep`); the prompt waits for it instead of closing. |

---

### `<RecoveryModal>`

The recovery methods of the user's Turnkey wallet: add or remove a passkey, confirm an email with a code Turnkey sends, approve or reject a device that asks to join, recover this device with a passkey or an email code, and export the recovery phrase. The methods go straight to Turnkey from the device; Pollar never sets or confirms them. The provider mounts it for `openRecoveryModal()`, after a custody migration, and from the wallet menu while `recoveryLocked`.

```tsx
import { RecoveryModal } from '@pollar/react';

<RecoveryModal onClose={() => setOpen(false)} />
```

| Prop      | Type         | Description   |
|-----------|--------------|---------------|
| `onClose` | `() => void` | **Required.** |

See [Passkeys and wallet recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide).

---

### `<CustodyMigrationModal>`

Moves the user's custodial wallets to a Turnkey wallet on this device, for an app that keeps its wallets in Turnkey. The provider opens it after login while `custodyMigration.required`, before anything else; the user can leave it for later. A wallet that cannot move yet lists the reasons (`SDK_CUSTODY_MIGRATION_BLOCKED`).

| Prop      | Type                     | Description                                                            |
|-----------|--------------------------|------------------------------------------------------------------------|
| `state`   | `CustodyMigrationState`  | **Required.** From `custodyMigration`.                                 |
| `onMoved` | `() => void`             | **Required.** The wallets moved; the provider then asks for a recovery method. |
| `onLater` | `() => void`             | **Required.** The user chose later; the provider stops asking until the next session. |

---

### `<RampWidget>`

Pre-built fiat on/off-ramp widget on the v3 ramps API. It lists the routes, quotes them, asks for the fields a quote needs, creates the order and follows it at the pace the server suggests. The order's pending action shows as it comes: a payment QR or bank details, **Authorize** for a signature, the co-sign approval or a verification step. A route the quote rejected shows why, with the fix when the user can make it (verify, add a trustline, set up or move a wallet).

```tsx
import { RampWidget } from '@pollar/react';

<RampWidget onClose={() => setOpen(false)} />
```

| Prop      | Type         | Description                                              |
|-----------|--------------|----------------------------------------------------------|
| `onClose` | `() => void` | **Required.** Called when the user dismisses the widget. |
| `language` | `string`    | Language of the widget and the verification steps it opens, as a BCP 47 tag. See [Language](#language). |

Signing a leg only runs on a user press; polling never signs. When the app registered no signer for a leg (`registerRampSigningHandler` in `@pollar/core`), the widget signs with the user's connected wallet after checking the payload: a Stellar XDR must run every operation as the connected account (`assertRampStellarSigner`), and a Solana transfer must be built from the connected Solana wallet (signed through `signSolanaTransaction`).

`RouteDisplay` renders one quote and `RejectedRouteDisplay` one rejected route, for an app that lists routes itself.

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

Template components handle rendering only: they receive all data and callbacks as props and contain no internal logic. Use them to build fully custom UI while reusing Pollar's layout and visual structure.

Each takes an optional `language` (`'en' | 'es' | 'pt'`). Without it, a template under `<PollarProvider>` uses the provider's language (see [Language](#language)) and one outside it the browser's.

| Component                      | Description                                                  |
|--------------------------------|--------------------------------------------------------------|
| `<WalletButtonTemplate>`          | Wallet button (logged-out / logged-in) presentation.         |
| `<LoginModalTemplate>`            | Login provider selection and email OTP screens.              |
| `<KycModalTemplate>`              | KYC provider selection and verification screens.             |
| `<RampWidgetTemplate>`            | Ramp input, route list, order and payment screens.           |
| `<TransactionModalTemplate>`      | Transaction details, signing, and result screens.            |
| `<TxHistoryModalTemplate>`        | Transaction history list screen.                             |
| `<WalletBalanceModalTemplate>`    | Wallet balance screen.                                       |
| `<EnabledAssetsModalTemplate>`    | Enabled-assets / trustline screen.                          |
| `<SendModalTemplate>`             | Send-payment screen.                                         |
| `<SwapModalTemplate>`             | Swap screen (exports `SwapAssetOption`).                    |
| `<ReceiveModalTemplate>`          | Receive (address / QR) screen.                              |
| `<SessionsModalTemplate>`         | Active-sessions list screen.                                |
| `<CosignModalTemplate>`           | Co-sign approval screen.                                    |
| `<RecoveryModalTemplate>`         | Recovery methods screen (`RecoveryView`: `'overview' \| 'email' \| 'export' \| 'recover-email'`). |
| `<CustodyMigrationModalTemplate>` | Custody migration screen.                                   |
| `<DistributionRulesModalTemplate>`| Claimable distribution rules screen.                        |

Props a custom template must handle:

- **`CosignModalTemplateProps`**: `theme`, `accentColor`, `pending`, `current`, `verification`, `busy` (`'approving' \| 'rejecting' \| null`), `error`, `onSelect`, `onApprove`, `onReject` and `onClose` are required; `styleOverrides`, `approveBlocked`, `lastResolved`, `explorerUrl`, `closesIn` and `nextStep` are optional.
- **`RampWidgetTemplate`** takes the v3 flow: `direction`, `countries`, `fiats` / `fiat`, `assets` / `asset`, `amount`, `quotes`, `rejected`, `fields` / `fieldValues`, `order`, `pendingOrders`, the `step` (`RampStep`: `'input' \| 'loading_quote' \| 'select_route' \| 'contact' \| 'status' \| 'error'`) and its handlers (`onFindRoute`, `onSelectQuote`, `onSign`, `onApprove`, `onResumeOrder`, `onNewOrder`, `onBack`, `onRetry`, ...). Optional: `onVerifyRoute`, `onTrustAsset`, `onWalletStep` with `walletBusy` and `custodyChoice`, `onRetryOrder`, `onSetUpRecovery` with `recoveryMissing`, `onCheckPayment` with `checkingPayment`, `notice` and `pollTrouble`.
- **`WalletButtonTemplateProps`** takes `theme`, `accentColor` and an optional `styleOverrides`, like the modal templates, plus `recoveryLocked` / `onRecovery`, `creatingWallet` / `createWalletError`, `custodyChoice` and `onCreateWallet(custody?)`.
- **`RecoveryModalTemplateProps`** carries the recovery `state`, the `devices`, the current `view`, `busy`, `error`, `notice` and one handler per action (`onAddPasskey`, `onSendEmailCode`, `onConfirmEmail`, `onApproveDevice`, `onRecoverWithPasskey`, `onExport`, ...).
- **`CustodyMigrationModalTemplateProps`**: `state`, `busy`, `error`, `blockedReasons`, `onMove(custody?)`, `onLater` and `onLogout`.

Other required props: `SendModalTemplateProps.onMax` / `onPaste`, `SwapModalTemplateProps.onReverse` / `onMax`, `SessionsModalTemplateProps.revokeError`. The Send, Receive and WalletButton templates take an optional `notReadyReason` (from `walletNotReadyReason`).

> Live (non-template) components are also exported for direct rendering: `SendModal`, `SwapModal`, `EarnModal`, `CardModal`, `CosignModal`, `RecoveryModal`, `CustodyMigrationModal`, `ReceiveModal`, `EnabledAssetsModal`, `WalletBalanceModal`, `SessionsModal`, `DistributionRulesModal`, `KycModal`, `RequirementFormModal`, `RegistryCheckModal`, `ProviderRegistrationModal`, `RampWidget`, plus `KycStatus`, `RouteDisplay`, `RejectedRouteDisplay`, `ChainSelect` and `TxStatusView`. Each live modal takes `onClose` (`CustodyMigrationModal` takes `onMoved` / `onLater`).
>
> Styling helpers: `buildModalCssVars(theme, accentColor, overrides?, variant?)`, `modalChrome(styles)`, `readableTextOn(background)` and the `ModalStyleOverrides` type (`backgroundColor`, `textColor`, `buttonColor`, `modalBorderRadius`, `buttonBorderRadius`). The CSS variables they feed are listed in [Theming](https://docs.pollar.xyz/docs/sdk-reference/theming).
>
> Passkeys: `browserPasskeyCeremony` and `browserPasskeySigner` are the WebAuthn implementations the provider installs on the client for smart wallets, and `browserRecoveryPasskey` the one it installs for Turnkey wallet recovery (`recoveryPasskey`). Export them to a client you build yourself.

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
  RecoveryView,
  UseCosignResult,
  UseChainsResult,
  TransactionModalTemplateProps,
  WalletBalanceModalTemplateProps,
  CosignModalTemplateProps,
  RecoveryModalTemplateProps,
  CustodyMigrationModalTemplateProps,
  // re-exported from @pollar/core so you can author custom login providers
  PollarAuthProvider,
  AuthProviderContext,
} from '@pollar/react';
```

Core types such as `WalletInfo`, `TransactionState`, `TxHistoryState`, `EnabledAssetsState`, `WalletBalanceContent`, `SwapQuote`, `EarnOpportunity`, `RampQuote`, `RampOrder`, `CosignCustody`, `RecoveryState`, `CustodyMigrationState`, `ConfirmationPolicy`, `PollarLoginOptions`, `StellarNetwork`, and `WalletType` are imported directly from `@pollar/core`.
