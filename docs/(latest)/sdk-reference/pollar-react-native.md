---
title: "@pollar/react-native"
---

React Native bindings for Pollar: a context provider, a hook, pre-built modals and native panels for authentication, transactions, ramps and Turnkey wallets in mobile apps. Built on top of `@pollar/core`, with the same client underneath as [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react).

**Version:** `0.12.0`. It requires `@pollar/core@^0.12.0` and talks to SDK API v3.

```bash
npm install @pollar/react-native @pollar/core
```

**Peer dependencies:** `@pollar/core ^0.12.0`, `react ^18 || ^19`, `react-native >= 0.72`, `react-native-safe-area-context >= 4` and `react-native-svg >= 13`. QR codes render with `react-native-qrcode-svg`, a dependency of the package.

---

## Setup

### 1. Polyfills

Every authenticated request carries a DPoP proof, which needs `crypto.getRandomValues`, `TextEncoder` and `URL`. Hermes does not ship all of them. Import these at the very top of your entry file, before anything imports `@pollar/core`:

```ts
import 'react-native-get-random-values';
import 'react-native-polyfill-globals/auto';
```

If one is missing, no authenticated request works.

### 2. Storage

React Native has no `localStorage`. Without a storage adapter the session and the DPoP key live in memory, and the user is logged out every time the app restarts (the SDK warns about it in the console). The adapters load their native module lazily, so they are async: create the storage before you render the provider.

```bash
# Expo (works in Expo Go)
npx expo install expo-secure-store react-native-get-random-values
npm i react-native-polyfill-globals

# Bare React Native
npm i react-native-keychain react-native-get-random-values react-native-polyfill-globals
```

```tsx
import type { PollarClientConfig } from '@pollar/core';
import { createSecureStoreAdapter } from '@pollar/core/adapters/expo';
// Bare React Native: import { createKeychainAdapter } from '@pollar/core/adapters/react-native-keychain';
import { PollarProvider } from '@pollar/react-native';
import { useEffect, useState } from 'react';

export default function App() {
  const [config, setConfig] = useState<PollarClientConfig | null>(null);

  useEffect(() => {
    createSecureStoreAdapter().then((storage) => setConfig({ apiKey: 'pub_testnet_xxxxxxxx', storage }));
  }, []);

  if (!config) return null;

  return (
    <PollarProvider config={config}>
      <MyApp />
    </PollarProvider>
  );
}
```

### 3. OAuth (Google, GitHub)

`window.open` does not exist on React Native, so pass an opener and your app's deep link. The SDK polls the auth session until the backend marks it ready, so the opener only has to show the page:

```ts
import * as WebBrowser from 'expo-web-browser';

const config: PollarClientConfig = {
  apiKey: 'pub_testnet_xxxxxxxx',
  storage,
  oauthRedirectUri: 'myapp://auth',
  openAuthUrl: async ({ getUrl, redirectUri }) => {
    const url = await getUrl();
    if (url) await WebBrowser.openAuthSessionAsync(url, redirectUri);
  },
};
```

Add the same redirect URI to your application in the Pollar dashboard (**Build > Domains**).

### 4. App state (optional)

To refresh the session as soon as the app returns to the foreground, pass an `AppState`-backed visibility provider:

```ts
import { createAppStateVisibilityProvider } from '@pollar/core/adapters/react-native-appstate';

const visibilityProvider = await createAppStateVisibilityProvider();
```

### 5. Recovery passkeys (Turnkey wallets)

The passkey methods of wallet recovery need a WebAuthn ceremony. On the web `@pollar/react` installs one; on React Native pass your own as `recoveryPasskey` in the client config (a `RecoveryPasskeyCeremony` with `create` and `get`, backed by a native passkey library). Without it the passkey options are unavailable (`SDK_COSIGN_PASSKEY_UNAVAILABLE`) and the user recovers with an email code or another device. See [Passkeys and wallet recovery](https://docs.pollar.xyz/docs/guides/passkeys-guide).

---

## `<PollarProvider>`

Creates the `PollarClient`, exposes it through `usePollar()` and mounts the modals: login, transaction, KYC, ramp, cards, transaction history, wallet balance, the feature modals (send, receive, assets, sessions, swap, earn, distribution), co-sign approval, signature confirmation, wallet recovery and custody migration. You do not render them yourself.

| Prop           | Type                     | Required | Description                                                            |
| -------------- | ------------------------ | -------- | ---------------------------------------------------------------------- |
| `config`       | `PollarClientConfig`     | Yes      | Passed to `new PollarClient(config)`.                                  |
| `appConfig`    | `PollarConfig`           | No       | Local replacement for the remote `/applications/config`; the remote fetch is skipped. |
| `styles`       | `PollarStyles`           | No       | Merged over the styles configured in the dashboard.                    |
| `adapters`     | `PollarAdapters`         | No       | Custom transaction builders, used with `createPollarAdapterHook(key)`. |
| `platform`     | `NativePlatformAdapters` | No       | `storage`, `visibilityProvider` and `openAuthUrl` (each overrides the same field of `config`), and `copyText` for the clipboard actions. |
| `privyAdapter` | `InteractiveAuthAdapter` | No       | An interactive login adapter, added to `walletAdapters`. Mount its native provider above `PollarProvider`. |

How the provider runs:

- Children render after the provider creates its client. Put startup UI outside the provider if it must show during that initialization.
- Changing the client configuration, `platform.storage`, `platform.visibilityProvider`, `platform.openAuthUrl` or `privyAdapter` cancels a login in progress, destroys the client and starts a new one. An equivalent inline scalar configuration does not restart it; memoize object-valued configuration, wallet adapter arrays and platform adapters. Theme, application configuration and clipboard updates stay live.
- A null or malformed config response leaves `configStatus: 'error'` with `configError` and `retryConfig()`, instead of showing default configuration. Supply `appConfig` for an app that does not fetch remote configuration.

---

## `usePollar()`

Returns a `PollarContextValue` (exported, for custom integrations and test mocks): the client methods bound to the session, the reactive state and the modal actions.

```ts
const {
  // session
  isAuthenticated, // true for a signed-in user without a wallet too
  verified, // the server confirmed the session
  hasWallet, // a wallet on any chain
  createWallet, // (options?: { custody }) => Promise<WalletInfo>, for an app that creates wallets on demand
  wallet, // the Stellar wallet, or null
  wallets, // every wallet, one per chain
  walletAddress, // '' when logged out
  walletType, // the external wallet id when one is connected
  authState,
  login,
  logout,
  getClient,

  // transactions
  tx, // TransactionState (also as `transaction`)
  buildTx, // opens the transaction modal
  signTx,
  signAndSubmitTx,
  submitTx,
  buildAndSignAndSubmitTx,
  runTx,
  sendPayment,

  // balances, assets and history
  walletBalance,
  refreshBalance, // (publicKey?) => Promise<void>, only the connected address
  enabledAssets,
  refreshAssets,
  setTrustline,
  txHistory,
  fetchTxHistory,
  sessions,
  fetchSessions,
  revokeSession,

  // swap, earn, distribution
  getSwapConfig, getSwapTokens, getSwapQuote, swap,
  getEarnProviders, getEarnOpportunities, getEarnPosition, earnDeposit, earnWithdraw,
  listDistributionRules, claimDistributionRule,

  // ramps (v3)
  getRampRoutes, quoteRamp, createRampOrder, getRampOrder, listRampOrders, signRampLeg,
  ramp, // { direction, order } the widget follows, kept while it is closed
  setRamp,

  // Turnkey wallets and confirmations
  cosign, openCosignModal, setCosignNextStep,
  recovery, recoveryLocked, refreshRecovery, openRecoveryModal,
  custodyMigration, refreshCustodyMigration,
  confirmations,

  // network and configuration
  network, setNetwork,
  appConfig, // also as `config`
  styles,
  configStatus, configError, retryConfig,
  copyText, // needs platform.copyText

  // modals
  openLoginModal,
  openTransactionModal, // also as `openTxModal`
  openKycModal, // (options?: { country?, level?, onApproved? }) => void
  openRampWidget, // also as `openRampModal`
  openCardModal,
  openTxHistoryModal,
  openWalletBalanceModal,
  openSendModal, openReceiveModal, openEnabledAssetsModal, openSwapModal, openEarnModal,
} = usePollar();
```

`buildTx` opens the transaction modal and the user confirms from there. The other transaction methods work through core state without opening it; call `openTransactionModal()` when your flow needs that screen. Every signing call passes the app's [signature confirmation](https://docs.pollar.xyz/docs/sdk-reference/pollar-react#signature-confirmation) first; the provider renders the prompt.

For a balance of another address, use `getClient().getWalletBalance(publicKey)`.

### Login options

```ts
login({ provider: 'google' });
login({ provider: 'github' });
login({ provider: 'email', email: 'user@example.com' });
login({ provider: WalletType.FREIGHTER }); // import { WalletType } from '@pollar/core'
```

The login modal also offers Freighter and Albedo when the application enables them. `@pollar/core` ships those two adapters for the web (browser extension and popup), so on a device they only work if you register adapters with the same ids through `walletAdapters` in the client config.

---

## Components

- `<WalletButton>`: opens the login modal when logged out; when logged in, shows the address with a menu for balance, transaction history and logout, and the recovery lock while `recoveryLocked`.
- `<KycModal>`, `<KycStatus>`, `<WalletBalanceModal>`, `<CardModal>`: the modals, for when you mount one yourself.
- `<RequirementFormModal>`, `<RegistryCheckModal>`, `<ProviderRegistrationModal>`: the requirement steps a ramp route or a card provider asks for. Props as in [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react).
- `<RampWidget>`, `<RouteDisplay>`, `<RejectedRouteDisplay>`: the ramp flow on the v3 API (below).
- `<CosignModal>`, `<RecoveryModal>`, `<CustodyMigrationModal>`: the Turnkey wallet screens the provider opens by itself.
- Feature modals: `SendModal`, `ReceiveModal`, `EnabledAssetsModal`, `SessionsModal`, `SwapModal`, `EarnModal`, `DistributionRulesModal` (or `FeatureModal` with a `feature` name).
- Templates: `LoginModalTemplate`, `TransactionModalTemplate`, `KycModalTemplate`, `RampWidgetTemplate`, `TxHistoryModalTemplate`, `WalletBalanceModalTemplate`, `WalletButtonTemplate`, `CosignModalTemplate`, `RecoveryModalTemplate`, `CustodyMigrationModalTemplate`: the presentational layer of each component, to build your own container around it.
- `createPollarAdapterHook(key)`: builds a typed hook over an adapter passed to `PollarProvider`. Each method builds the transaction and then signs and submits it.

Components are styled with `StyleSheet`; there is no stylesheet to import. Theme, accent color, logo and login methods come from the dashboard and can be overridden with the `styles` prop.

### Native screens

The package also exports building blocks for a whole app: `AppShell`, `FeatureCatalog`, `FeaturePanel` and `FeatureExample`, `AccountOnboarding`, panels per feature (`AuthPanel`, `WalletPanel`, `SendPanel`, `ReceivePanel`, `AssetsPanel`, `HistoryPanel`, `SessionsPanel`, `SwapPanel`, `EarnPanel`, `DistributionPanel`, `RampPanel`, `ChainsPanel`, ...) and layout primitives (`PollarUIProvider`, `ScreenLayout`, `Card`, `ActionButton`, `Field`, ...).

### Ramps

`<RampWidget>` and `RampPanel` run the v3 ramps API: they list the routes (`getRampRoutes(direction)`), quote them leg by leg, ask for the fields a quote needs, create the order and follow it at the pace the server suggests. The order's pending action shows as it comes: a payment QR or bank details, **Authorize** for a signature, the co-sign approval or a verification link. The widget keeps the order in `usePollar().ramp` while it is closed.

Signing uses a handler registered for the action's chain and encoding (`registerRampSigningHandler` in `@pollar/core`); a Stellar or Solana leg falls back to the connected wallet after the same checks as on the web. Signing only runs on a user press; polling never signs. See [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps).
