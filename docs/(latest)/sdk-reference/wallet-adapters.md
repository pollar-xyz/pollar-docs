---
title: "Wallet Adapters"
---

Pollar's default login is social / email sign-in with a Pollar wallet on every chain the app enables. Wallet adapters extend `login()` with wallets the user brings: external Stellar wallets (Freighter, Albedo, xBull, ...) and external **Solana wallets** (Phantom, Solflare, Backpack, through Sign In With Solana). Each adapter is a `WalletAdapter` from `@pollar/core` that you register on the client's `walletAdapters` array. An adapter declares its `chain`, and the login modal shows it only when the app serves that chain.

| Adapter package | Chain | Login mechanism |
|---|---|---|
| `@pollar/stellar-wallets-kit-adapter` | Stellar | SEP-10 challenge |
| `@pollar/solana-wallet-standard-adapter` | Solana | Sign In With Solana (SIWS) |

To connect a wallet whose key you control yourself (a key on the device, an MPC or HSM signer), implement `WalletAdapter` directly: see [Build Your Own Wallet Adapter](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter).

> **Versions.** Both adapters are at **0.12.0**, with the `@pollar/core` peer range `^0.11.2 || ^0.12.0`. Releases before 0.12.0 refuse core 0.12, so upgrade the adapters together with `@pollar/core` and `@pollar/react`. `@pollar/privy-adapter`, `@pollar/privy-server-adapter` and `@pollar/accesly-adapter` have no 0.12 release and their published ranges do not accept core 0.12. For 0.11.x, see the [0.11 reference](https://docs.pollar.xyz/docs/v0.11/wallet-adapters).

---

## The `walletAdapters` slot

Adapters are registered through the `walletAdapters` array on `PollarClientConfig`. Each adapter renders its own button in the login modal and is reachable with `login({ provider: adapter.type })`.

```ts
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
  walletAdapters: [
    /* adapters from the packages below */
  ],
});
```

The built-in `FreighterAdapter` / `AlbedoAdapter` are **auto-registered**: you get Freighter and Albedo with no adapter installed. Entries in `walletAdapters` are added on top and override a built-in by reusing its `type`. If you omit the slot entirely, `@pollar/core` falls back to just Freighter + Albedo.

Login ids for the built-ins come from the `WalletType` enum:

```ts
import { WalletType } from '@pollar/core';

pollar.login({ provider: WalletType.FREIGHTER }); // 'freighter-native'
pollar.login({ provider: WalletType.ALBEDO });    // 'albedo-native'
```

Adapter packages keep their heavy dependencies out of `@pollar/core`'s bundle, so you only pay for what you install.

Every signature an adapter makes goes through the app's [signature confirmation](https://docs.pollar.xyz/docs/sdk-reference/pollar-react#signature-confirmation) first: under the default policy the user confirms in `<ConfirmModal>`, then the wallet asks for its own approval.

---

## `@pollar/stellar-wallets-kit-adapter`

Plugs [Stellar Wallets Kit](https://stellarwalletskit.dev) into Pollar as a set of wallet adapters. One install gives Pollar access to **every kit module**: Freighter, Albedo, xBull, Lobstr, Rabet, Hana, Bitget, OneKey, Klever, Fordefi, CactusLink, HotWallet (12 by default), plus Ledger / Trezor / WalletConnect via opt-in.

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

// Log in with any registered kit wallet: provider is the wallet id.
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

Every registered wallet renders as a button inside Pollar's `LoginModal`, collapsed behind a single **Wallet** gateway (their shared `meta.group`).

### `stellarWalletsKitAdapters(options)`

Returns a `WalletAdapter[]`, one adapter per kit module, that you assign to `walletAdapters`.

| Option     | Type                    | Notes                                                                                  |
| ---------- | ----------------------- | -------------------------------------------------------------------------------------- |
| `network`  | `Networks`              | **Required.** `Networks.PUBLIC` or `Networks.TESTNET`. No default: the kit is a global singleton, so the chain must be explicit to avoid cross-chain signing. |
| `modules?` | `ModuleInterface[]`     | Wallet modules to drive. Defaults to the 12 zero-config modules. Passing this **fully replaces** the default. |
| `picker?`  | `KitPickerOptions`      | `wallets` (subset of ids), `labels` (per-wallet label overrides) and `groupLabel` (gateway label, default `'Wallet'`, the same group as the built-in Freighter / Albedo). The type also declares `order`, `showInstalledOnly`, `layout` and `theme`; the login modal does not read them. |
| `logLevel?`| `LogLevel`              | `'silent' \| 'error' \| 'warn' \| 'info' \| 'debug'`. Default `'info'`.                 |
| `logger?`  | `PollarLogger`          | Log sink. Defaults to `console`.                                                       |

**Default wallets (no `modules`):** `albedo`, `bitget`, `cactuslink`, `fordefi`, `freighter`, `hana`, `hotwallet`, `klever`, `lobstr`, `onekey`, `rabet`, `xbull`. Ledger / Trezor / WalletConnect are opt-in: pass them in `modules` (Ledger needs a `Buffer` polyfill; Trezor / WalletConnect need constructor params).

**SSR:** `stellarWalletsKitAdapters()` returns `[]` when `window` is undefined. Under Next.js / Remix, construct the client on the client side (mounted flag or `dynamic(..., { ssr: false })`).

**Also exported:** `StellarWalletsKitAdapter` (the class, for direct use) and the types `KitPickerOptions`, `StellarWalletsKitAdapterOptions`.

---

## `@pollar/solana-wallet-standard-adapter`

The Solana counterpart of the Stellar Wallets Kit adapter. It connects user-controlled Solana wallets (Phantom, Solflare, Backpack, and any other wallet that implements the [Wallet Standard](https://github.com/wallet-standard/wallet-standard)) to `@pollar/core`. Login uses **Sign In With Solana (SIWS)**, the Solana analogue of Stellar's SEP-10 challenge: the SDK requests a SIWS input from Pollar, the wallet signs it, and Pollar verifies the signature and opens the session.

```bash
npm install @pollar/solana-wallet-standard-adapter @pollar/core
```

`@pollar/core` is the only peer dependency; the `@wallet-standard/*` packages are real dependencies of the adapter.

```ts
import { PollarClient } from '@pollar/core';
import { solanaWalletStandardAdapters } from '@pollar/solana-wallet-standard-adapter';

const pollar = new PollarClient({
  apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
  walletAdapters: [...solanaWalletStandardAdapters()],
});
```

### `solanaWalletStandardAdapters(options?)`

Discovers every installed Solana wallet (one that advertises a Solana chain and standard connect) and returns one adapter each, so the login modal lists the wallets the user actually has. It is SSR-safe (returns `[]` when `window` is undefined): build the `PollarClient` on the client.

| Option        | Type                     | Notes                                                                      |
| ------------- | ------------------------ | -------------------------------------------------------------------------- |
| `wallets?`    | `string[]`               | Subset of wallet names to include. Defaults to every Solana wallet found.  |
| `labels?`     | `Record<string, string>` | Per-wallet button label overrides, keyed by the wallet's `name`.           |
| `groupLabel?` | `string`                 | Gateway button these wallets collapse behind. Default `'Solana Wallet'`, a group apart from the Stellar `'Wallet'` gateway. |

Each adapter declares `chain: 'SOLANA'`, which is what routes `login({ provider })` through the SIWS flow. A wallet with the native `solana:signIn` feature (Phantom, Solflare, Backpack) signs the SIWS input there; a wallet without it signs the same message text through `solana:signMessage`.

The adapter also exposes `signMessage` and `signSolanaTransaction`; the latter is what `sendPayment({ chain: 'SOLANA', ... })` uses for a wallet the user controls: Pollar builds the transfer (with the app's GAS wallet as fee payer when the token is sponsored), the wallet signs it, Pollar submits. A Solana ramp leg is signed the same way.

After a SIWS login the session holds a Solana wallet and `getWallet()` (the Stellar accessor) is `null`; read `getWallets()`.

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

The login modal filters the list by the app's enabled chains, so a Solana-only app never shows a Stellar wallet and vice versa.

---

## Transaction adapters

`<PollarProvider>` also takes a separate `adapters` prop for transaction-building adapters, driven with `createPollarAdapterHook`; it is not the login slot. See [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react).
