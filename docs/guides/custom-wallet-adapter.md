---
title: "Build Your Own Wallet Adapter"
---

This guide shows how to connect a wallet whose key **you** control (a key in the phone's secure storage, an MPC or HSM signer, an in-house wallet) to Pollar, so that Pollar handles login, transaction building, sponsorship and history while the key never leaves your side.

A wallet adapter is a plain object that implements the `WalletAdapter` interface from `@pollar/core`. If the wallet you want is already supported (Freighter, Albedo, xBull, Lobstr, Privy and others), use the packages in [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters) instead.

---

## What Pollar does with your adapter

Pollar treats an adapter as a black box that can tell it an address and sign Stellar transactions. Users who log in through an adapter get an **external** wallet: Pollar holds no key for it.

**Login** (`pollar.login({ provider: adapter.type })`):

1. `isAvailable()` is called. If it returns `false`, the login stops with the `wallet_not_installed` state.
2. `connect()` returns the user's `G...` address.
3. Pollar asks the server for a [SEP-10](https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0010.md) challenge for that address and checks that it is a real challenge (sequence number 0), so it cannot be a live transaction.
4. `signTransaction(challengeXdr)` signs the challenge, and the server verifies the signature. That proves the user controls the key.
5. The session is created and the adapter's `type` is stored with it.

**Transactions**: every time the SDK needs the user's signature (`signTx`, `signAndSubmitTx`, `createAccount`, `setTrustline`, swaps, contract calls), it calls `signTransaction(xdr, { networkPassphrase, accountToSign })` and sends the result to `POST /tx/submit`. That is where the app's [sponsorship](https://docs.pollar.xyz/docs/operator-guide/treasury/sponsorship) is applied, so a fee-bumped transaction needs no extra code in the adapter.

**Page reloads and app restarts**: the session is restored from storage and the adapter is looked up again **by `type`** in the client's `walletAdapters`. If no adapter with that `type` is registered, the session is still valid, but signing returns `Wallet not connected. Reconnect your wallet to sign.`

---

## The interface

```ts
import type { WalletAdapter } from '@pollar/core';
```

| Member | Required | What it must do |
|---|---|---|
| `type` | Yes | A stable, unique id. It is the value of `login({ provider })` and the key used to restore the session, so never change it once users have logged in. Do not use `google`, `github` or `email`. |
| `meta` | Yes | `{ label, iconUrl?, group? }` for the login button Pollar renders. Adapters with the same `group` share one gateway button. |
| `custody` | No | `'external'` (the default). Leave it out. |
| `isAvailable()` | Yes | Resolve `true` when the wallet can be used on this device. Must not prompt the user. |
| `connect()` | Yes | Prompt or unlock if needed, and resolve `{ address }` with the user's `G...` public key. |
| `disconnect()` | Yes | Release whatever `connect()` opened. Resolve without doing anything if there is nothing to release. Called on logout. |
| `getPublicKey()` | Yes | Resolve the address if the wallet is already connected, otherwise `null`. Must not prompt the user. |
| `signTransaction(xdr, options)` | Yes, for Stellar | Add the user's signature to the transaction and resolve `{ signedTxXdr }`. |
| `signAuthEntry(entryXdr, options)` | No | Sign a Soroban authorization entry. Only needed if your app calls `pollar.signAuthEntry`. |
| `signStellarMessage(message, options)` | No | [SEP-53](https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0053.md) message signature. Only needed if your app uses the ownership-proof flow. |

Every method signals failure, including a user cancel, by **throwing**. Pollar maps the error to the right auth or transaction state.

---

## Example: an adapter backed by a device key

This adapter signs with an ed25519 key stored on the device. `DeviceKeyStore` stands for your own storage (iOS Keychain, Android Keystore, a secure enclave, an MPC client): anything that can return the public key and sign 32 bytes.

```ts
import { Networks, TransactionBuilder } from '@stellar/stellar-sdk';
import type {
  ConnectWalletResponse,
  SignTransactionOptions,
  SignTransactionResponse,
  WalletAdapter,
} from '@pollar/core';

/** Your key storage. Implement it with whatever holds the key on the device. */
export interface DeviceKeyStore {
  hasKey(): Promise<boolean>;
  /** G... address of the stored key, unlocking it (biometrics, PIN) if needed. */
  unlock(): Promise<string>;
  /** G... address if the key is already unlocked, otherwise null. No prompt. */
  currentAddress(): Promise<string | null>;
  lock(): Promise<void>;
  /** Raw ed25519 signature (64 bytes) over the 32-byte payload, base64-encoded. */
  signHash(hash: Uint8Array): Promise<string>;
}

export class DeviceKeyAdapter implements WalletAdapter {
  readonly type = 'acme-device';
  readonly meta = { label: 'Acme Wallet' };

  constructor(
    private readonly keys: DeviceKeyStore,
    private readonly defaultPassphrase: string = Networks.PUBLIC,
  ) {}

  isAvailable(): Promise<boolean> {
    return this.keys.hasKey();
  }

  async connect(): Promise<ConnectWalletResponse> {
    const address = await this.keys.unlock();
    return { address };
  }

  disconnect(): Promise<void> {
    return this.keys.lock();
  }

  getPublicKey(): Promise<string | null> {
    return this.keys.currentAddress();
  }

  async signTransaction(xdr: string, options?: SignTransactionOptions): Promise<SignTransactionResponse> {
    const passphrase = options?.networkPassphrase ?? this.defaultPassphrase;
    const tx = TransactionBuilder.fromXDR(xdr, passphrase);

    const address = await this.keys.currentAddress();
    if (!address) throw new Error('Wallet is locked');
    if (options?.accountToSign && options.accountToSign !== address) {
      throw new Error(`Asked to sign for ${options.accountToSign}, but this wallet is ${address}`);
    }

    // Add a signature to the transaction as it arrived. Do not rebuild it: a
    // sponsored createAccount or trustline already carries the sponsor's
    // signature, and any change to the transaction invalidates it.
    const signature = await this.keys.signHash(tx.hash());
    tx.addSignature(address, signature);
    return { signedTxXdr: tx.toXDR() };
  }
}
```

If your signer can only sign a whole transaction (it takes the XDR and returns signed XDR), call it from `signTransaction` and return its result directly. The contract is the same: the XDR goes in, and the same transaction comes back with one more signature.

---

## Register it and log in

Pass the adapter in `walletAdapters`. Register it **every time the client is created**, with the same `type`, so a restored session finds its signer.

```ts
import { PollarClient } from '@pollar/core';
import { DeviceKeyAdapter } from './device-key-adapter';

const deviceWallet = new DeviceKeyAdapter(myKeyStore);

const pollar = new PollarClient({
  apiKey: 'pub_mainnet_xxxxxxxxxxxxxxxxxxxx',
  stellarNetwork: 'mainnet',
  walletAdapters: [deviceWallet],
});

await pollar.login({ provider: 'acme-device' });
```

With React, pass the same config to `PollarProvider`. The adapter also gets its own button in the login modal, labelled with `meta.label`:

```tsx
<PollarProvider client={{ apiKey: 'pub_mainnet_...', walletAdapters: [deviceWallet] }}>
  {/* your app */}
</PollarProvider>
```

The same code runs on React Native and Expo. The adapter is plain TypeScript, so it has no browser dependency unless your key store adds one.

---

## Activate the account and send a payment

A new external wallet does not exist on the Stellar network yet. The app always pays for creating the account, and pays for the trustline while trustline sponsorship is on (the default):

```ts
// 1. Create the account. The app's sponsor pays the base reserve and fee;
//    the adapter adds the new account's signature.
await pollar.createAccount();

// 2. Add the token's trustline. Sponsored when the app sponsors trustlines;
//    otherwise the same call returns a self-paid one.
await pollar.setTrustline({ code: 'USDC', issuer: 'GA5Z...' });

// 3. Send the token. The adapter signs, and /tx/submit wraps the transaction
//    in a fee bump when the app sponsors transfers of this token.
const built = await pollar.buildTx('payment', {
  destination: 'GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
  amount: '10.00',
  asset: { type: 'credit_alphanum4', code: 'USDC', issuer: 'GA5Z...' },
});
if (built.status === 'built') {
  const result = await pollar.signAndSubmitTx(built.buildData.unsignedXdr);
}
```

For step 3 to be paid by the app, the dashboard needs, under **Treasury > Sponsorship > Token transfer sponsorship**:

- The token selected.
- **Include external wallets** on. It is off by default. While it is off, the user pays the fee, and a user with no XLM gets `tx_insufficient_balance`.

The [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/treasury/sponsorship) page lists exactly which transactions qualify. In short: one operation, sourced by the user, and a payment of a selected token, a swap on an enabled venue, or a whitelisted contract call. XLM payments are never sponsored.

### Using the REST API directly

If your app talks to the API without `@pollar/core`, the flow is the same: `POST /tx/build`, sign the returned `unsignedXdr` on the device, then `POST /tx/submit` with the `signedXdr`. Send the plain signed transaction, not one you wrapped in a fee bump yourself. Pollar decides whether to sponsor it and adds the fee bump at submit.

---

## Rotate the wallet signer

For account recovery, a wallet can change which key controls it while keeping the same `G...` address: a `setOptions` adds the new key as a signer and sets the old master key's weight to 0.

**Logging in after a rotation.** Pollar checks the SEP-10 challenge against the account's on-chain signers and its medium threshold, as SEP-10 specifies. After the rotation, `connect()` still returns the same `G...` address and `signTransaction` signs with the new key. A key whose weight is 0, such as the disabled master key, can no longer log in.

**Having the app pay for it.** A new signer is a ledger subentry with a 0.5 XLM reserve, which a user with no XLM cannot cover. The app can sponsor the rotation, one at a time and only for users it allows:

1. The app turns on **Sponsor signer rotations** and **Include external wallets** under [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/treasury/sponsorship#signer-rotation).
2. When a user asks to recover, the app grants them one rotation: from **Users > Accounts**, or from its backend with `POST /v1/wallets/{publicKey}/signer-rotation` ([Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api)).
3. The client builds the rotation with the user's session:

   ```http
   POST /wallet/signer/build
   Content-Type: application/json

   {
     "signer": "GNEW...KEY",
     "signerWeight": 1,
     "masterWeight": 0,
     "removeSigners": []
   }
   ```

   The response `content` is `{ sponsorSignedXdr, hash, expiresAt }`. The app's sponsor is the transaction source, pays the fee and the reserve, and has already signed.
4. The wallet adds its signature to `sponsorSignedXdr` and sends it to `POST /tx/submit` before `expiresAt` (unix seconds, 5 minutes after the build). The signatures must meet the account's **high** threshold as it is before the rotation, since that is what Stellar requires to change signers.
5. Once the rotation lands, the grant is spent. Another rotation needs a new grant.

| Field | Rule |
|---|---|
| `signer` | The key to add. Not the account's own address: the master key is changed with `masterWeight`. |
| `signerWeight` | 1 to 255, default 1. Must be at least the account's high threshold, so the new key alone keeps full control. |
| `masterWeight` | Optional, 0 to 255. `0` disables the old master key. |
| `removeSigners` | Up to 3 existing signers to remove, for example the key from a previous recovery. |

Only wallets Pollar does not custody can rotate, and only once they exist on the network. While a rotation built for the user can still be submitted, a second build returns `409 SIGNER_ROTATION_PENDING`. The other refusals are listed under [Signer rotation errors](https://docs.pollar.xyz/docs/sdk-reference/error-codes#signer-rotation).

---

## Checklist

- [ ] `type` is unique, stable, and not `google`, `github` or `email`.
- [ ] The adapter is registered on every client start, with the same `type`.
- [ ] `isAvailable()` and `getPublicKey()` never prompt the user.
- [ ] `signTransaction` signs with the `networkPassphrase` it receives, adds a signature without rebuilding the transaction, and refuses an `accountToSign` that is not its own.
- [ ] Every failure and cancel throws.
- [ ] For sponsored transfers from external wallets: the token is selected and **Include external wallets** is on, and the GAS wallet holds XLM.
