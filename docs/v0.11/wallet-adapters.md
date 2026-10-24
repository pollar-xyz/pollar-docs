---
title: "Wallet Adapters"
---

> **@pollar 0.11.x.** This page documents the 0.11 release line, which talks to SDK API v2. The current release is 0.12, documented under [Latest](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters). On 0.11.x the ramp methods answer `410 SDK_RAMPS_MOVED_TO_V3`: ramps need 0.12. To move, read the [0.11 -> 0.12 upgrade notes](https://github.com/pollar-xyz/pollar/blob/main/UPGRADE.md).

Pollar's default login is **custodial** — social / email sign-in and a
platform-managed wallet on every chain the app enables. Wallet adapters let you extend `login()`
with other providers: external Stellar wallets (Freighter, Albedo, xBull, …), external
**Solana wallets** (Phantom, Solflare, Backpack, through Sign In With Solana) and
embedded wallets (Privy). Each adapter is a `WalletAdapter` from `@pollar/core`
that you register on the client's `walletAdapters` array. An adapter declares its
`chain`, and the login modal shows it only when the app serves that chain.

| Adapter package | Chain | Login mechanism |
|---|---|---|
| `@pollar/stellar-wallets-kit-adapter` | Stellar | SEP-10 challenge |
| `@pollar/solana-wallet-standard-adapter` | Solana | Sign In With Solana (SIWS) |
| `@pollar/privy-adapter` | Stellar | Privy embedded wallet |

To connect a wallet whose key you control yourself (a key on the device, an
MPC or HSM signer), implement `WalletAdapter` directly: see
[Build Your Own Wallet Adapter](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter).

> Published versions on npm: `@pollar/solana-wallet-standard-adapter` **0.11.5**,
> `@pollar/stellar-wallets-kit-adapter` **0.11.2**, `@pollar/privy-adapter` **0.11.1**,
> `@pollar/accesly-adapter` **0.10.1**. Each peers on the `@pollar/core` line it
> was released with; install the matching `@pollar/core` / `@pollar/react`.

---

## The `walletAdapters` slot

Adapters are registered through the `walletAdapters` array on
`PollarClientConfig`. Each adapter renders its own button in the login modal and
is reachable with `login({ provider: adapter.type })`.

```ts
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
  walletAdapters: [
    /* adapters from the packages below */
  ],
});
```

The built-in `FreighterAdapter` / `AlbedoAdapter` are **auto-registered** — you
get Freighter and Albedo with no adapter installed. Entries in `walletAdapters`
are added on top and override a built-in by reusing its `type`. If you omit the
slot entirely, `@pollar/core` falls back to just Freighter + Albedo.

Login ids for the built-ins come from the `WalletType` enum:

```ts
import { WalletType } from '@pollar/core';

pollar.login({ provider: WalletType.FREIGHTER }); // 'freighter-native'
pollar.login({ provider: WalletType.ALBEDO });    // 'albedo-native'
```

Adapter packages keep their heavy dependencies out of `@pollar/core`'s bundle,
so you only pay for what you install.

---

## `@pollar/stellar-wallets-kit-adapter`

Plugs [Stellar Wallets Kit](https://stellarwalletskit.dev) into Pollar as a set
of wallet adapters. One install gives Pollar access to **every kit module** —
Freighter, Albedo, xBull, Lobstr, Rabet, Hana, Bitget, OneKey, Klever, Fordefi,
CactusLink, HotWallet (12 by default), plus Ledger / Trezor / WalletConnect via
opt-in.

```bash
npm install @pollar/stellar-wallets-kit-adapter @creit.tech/stellar-wallets-kit
```

`@pollar/core` and `@creit.tech/stellar-wallets-kit` are peer dependencies.

```ts
import { PollarClient } from '@pollar/core';
import { stellarWalletsKitAdapters } from '@pollar/stellar-wallets-kit-adapter';
import { Networks } from '@creit.tech/stellar-wallets-kit';

const pollar = new PollarClient({
  apiKey: 'pub_mainnet_xxxxxxxxxxxxxxxxxxxx',
  walletAdapters: stellarWalletsKitAdapters({ network: Networks.PUBLIC }),
});

// Log in with any registered kit wallet — provider is the wallet id.
pollar.login({ provider: 'xbull' });
```

With React it is the same, on the `client` prop:

```tsx
import { PollarProvider } from '@pollar/react';
import { stellarWalletsKitAdapters } from '@pollar/stellar-wallets-kit-adapter';
import { Networks } from '@creit.tech/stellar-wallets-kit';

<PollarProvider
  client={{
    apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
    walletAdapters: stellarWalletsKitAdapters({ network: Networks.TESTNET }),
  }}
>
  {/* your app */}
</PollarProvider>;
```

Every registered wallet renders as a button inside Pollar's `LoginModal`,
collapsed behind a single **Wallet** gateway (their shared `meta.group`).

### `stellarWalletsKitAdapters(options)`

Returns a `WalletAdapter[]` — one adapter per kit module — that you assign to
`walletAdapters`.

| Option     | Type                    | Notes                                                                                  |
| ---------- | ----------------------- | -------------------------------------------------------------------------------------- |
| `network`  | `Networks`              | **Required** (since 0.8.0). `Networks.PUBLIC` or `Networks.TESTNET`. No default — the kit is a global singleton, so the chain must be explicit to avoid cross-chain signing. |
| `modules?` | `ModuleInterface[]`     | Wallet modules to drive. Defaults to the 12 zero-config modules. Passing this **fully replaces** the default. |
| `picker?`  | `KitPickerOptions`      | `wallets` (subset of ids), `labels` (per-wallet overrides), `groupLabel` (gateway label, default `'Wallet'`), plus `/picker`-only fields. |
| `logLevel?`| `LogLevel`              | `'silent' \| 'error' \| 'warn' \| 'info' \| 'debug'`. Default `'info'`.                 |
| `logger?`  | `PollarLogger`          | Log sink. Defaults to `console`.                                                       |

**Default wallets (no `modules`):** `albedo`, `bitget`, `cactuslink`,
`fordefi`, `freighter`, `hana`, `hotwallet`, `klever`, `lobstr`, `onekey`,
`rabet`, `xbull`. Ledger / Trezor / WalletConnect are opt-in — pass them in
`modules` (Ledger needs a `Buffer` polyfill; Trezor / WalletConnect need
constructor params).

**SSR:** `stellarWalletsKitAdapters()` returns `[]` when `window` is undefined.
Under Next.js / Remix, construct the client on the client side (mounted flag or
`dynamic(..., { ssr: false })`).

**Also exported:** `StellarWalletsKitAdapter` (the class, for direct use) and
the types `KitPickerOptions`, `StellarWalletsKitAdapterOptions`.

---

## `@pollar/solana-wallet-standard-adapter`

The Solana counterpart of the Stellar Wallets Kit adapter. It connects
user-controlled Solana wallets (Phantom, Solflare, Backpack, and any other wallet
that implements the [Wallet Standard](https://github.com/wallet-standard/wallet-standard))
to `@pollar/core`. Login uses **Sign In With Solana (SIWS)** through the wallet's
native `solana:signIn` feature, the Solana analogue of Stellar's SEP-10 challenge:
the SDK requests a SIWS input from Pollar, the wallet signs it, and Pollar verifies
the signature and opens the session.

```bash
npm install @pollar/solana-wallet-standard-adapter @pollar/core
```

`@pollar/core` is the only peer dependency; the `@wallet-standard/*` packages are
real dependencies of the adapter.

```ts
import { PollarClient } from '@pollar/core';
import { solanaWalletStandardAdapters } from '@pollar/solana-wallet-standard-adapter';

const pollar = new PollarClient({
  apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
  walletAdapters: [...solanaWalletStandardAdapters()],
});
```

### `solanaWalletStandardAdapters()`

Discovers every installed Solana wallet and returns one adapter each, so the
login modal lists the wallets the user actually has. It is SSR-safe (returns `[]`
when `window` is undefined): build the `PollarClient` on the client.

Each adapter declares `chain: 'SOLANA'`, which is what routes `login({ provider })`
through the SIWS flow. The adapter also exposes `signMessage` and
`signSolanaTransaction`; the latter is what `sendPayment({ chain: 'SOLANA', ... })`
uses for a wallet the user controls: Pollar builds the transfer (with the app's GAS
wallet as fee payer when the token is sponsored), the wallet signs it, Pollar submits.

### Alongside Stellar wallets

`walletAdapters` is one flat list, so Stellar and Solana wallets coexist:

```ts
import { solanaWalletStandardAdapters } from '@pollar/solana-wallet-standard-adapter';
import { stellarWalletsKitAdapters } from '@pollar/stellar-wallets-kit-adapter';
import { Networks } from '@creit.tech/stellar-wallets-kit';

const pollar = new PollarClient({
  apiKey: '...',
  walletAdapters: [
    ...stellarWalletsKitAdapters({ network: Networks.PUBLIC }),
    ...solanaWalletStandardAdapters(),
  ],
});
```

The login modal filters the list by the app's enabled chains, so a Solana-only
app never shows a Stellar wallet and vice versa.

> Requires a wallet with the `solana:signIn` feature. Phantom, Solflare and
> Backpack have it. After a SIWS login the session holds a Solana wallet and
> `getWallet()` (the Stellar accessor) is `null`; read `getWallets()`.

---

## `@pollar/privy-adapter`

Client-side [Privy](https://privy.io) adapter. It drives the **whole** Privy
flow itself — email / Google / GitHub login, creating the user's **Privy
embedded Stellar wallet**, and raw-hash signing — then hands the signature to
Pollar for the standard SEP-10 login + transaction flow. You configure it once;
you do **not** wire up Privy's hooks yourself.

| Host                          | Status           | Signing engine         |
| ----------------------------- | ---------------- | ---------------------- |
| React (web)                   | ✅ supported     | `@privy-io/react-auth` |
| React Native / Expo           | ✅ supported     | `@privy-io/expo`       |
| Angular, Vue, Svelte, vanilla | ❌ not supported | — (no Privy SDK)       |

In a non-React host it throws `PrivyAdapterUnsupportedError` on first use. For
those frameworks, sign server-side with `@pollar/privy-server-adapter` instead.

```bash
# web
npm i @pollar/privy-adapter @pollar/core @stellar/stellar-sdk @privy-io/react-auth react react-dom
```

Create the adapter, wrap your tree in `PrivyAdapterProvider`, and register it on
the client:

```tsx
import { createPrivyAdapter, PrivyAdapterProvider } from '@pollar/privy-adapter';
import { PollarProvider } from '@pollar/react';

const privy = createPrivyAdapter({
  appId: 'your-privy-app-id',
  loginMethods: ['email', 'google', 'github'],
});

export function App() {
  return (
    <PrivyAdapterProvider adapter={privy}>
      <PollarProvider client={{ apiKey: 'pub_testnet_…', walletAdapters: [privy] }}>
        {/* your app */}
      </PollarProvider>
    </PrivyAdapterProvider>
  );
}
```

This renders a **Privy** button in the login modal that opens a sub-modal with
the `loginMethods` you configured. `login({ provider: 'privy' })` also works
directly. On React Native / Expo the code is identical — the import resolves to
the `@privy-io/expo` build.

### `createPrivyAdapter(config)`

| Field                   | Type                                  | Notes                                                                    |
| ----------------------- | ------------------------------------- | ------------------------------------------------------------------------ |
| `appId`                 | `string`                              | Your Privy app id.                                                       |
| `loginMethods`          | `('email' \| 'google' \| 'github')[]` | Options shown in the sub-modal, in order.                                |
| `clientId?`             | `string`                              | Privy app client id, if your app uses one.                               |
| `appearance?`           | `{ theme?; accentColor?; logo? }`     | Forwarded to Privy's surfaces (web only; ignored on React Native).       |
| `debug?`                | `boolean`                             | Verbose `[privy-adapter]` logging. Off by default.                       |
| `cleanupOAuthRedirect?` | `boolean`                             | Strip `privy_oauth_*` params from the URL after web OAuth. On by default. |
| `meta?`                 | `{ label; iconUrl? }`                 | Login button. Defaults to `{ label: 'Privy' }`.                          |

**Also exported:** `PrivyAdapterProvider`, `PrivyAdapterUnsupportedError`, and
types `PollarPrivyConfig`, `PollarPrivyAppearance`, `PrivyLoginMethod`,
`AuthOption`, `InteractiveAuthAdapter`, `PrivyRuntime`.

> `@pollar/react`'s provider auto-syncs a persisted Privy session on load and
> recovers a web OAuth redirect, so the user does not have to click the login
> button again.

---

## Server-side and transaction adapters

Two more first-party adapters exist for narrower cases:

- **`@pollar/privy-server-adapter`** — server-side Privy custody (signing through
  your Privy app secret on your backend), for non-React hosts or backend flows.
- **`@pollar/accesly-adapter`** — a transaction-building adapter registered via
  the separate `adapters` prop on `PollarProvider` (not `walletAdapters`) and
  driven with `createPollarAdapterHook`.

`@pollar/privy-server-adapter` is published at 0.10.0-rc.10 and `@pollar/accesly-adapter` at 0.10.1.
