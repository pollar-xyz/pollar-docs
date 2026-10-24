---
title: "Passkeys and wallet recovery"
description: "How a user keeps access to a Turnkey wallet when they lose the device: recovery passkeys, a confirmed email, a second device, and the phrase export."
---

Passkeys play two roles in Pollar:

- **Smart wallet login.** A passkey is the signer of a Soroban smart account (a `C...` address). See [Smart Wallets](https://docs.pollar.xyz/docs/smart-wallets/overview).
- **Wallet recovery.** A passkey is one of the ways a user gets back into a Turnkey wallet (co-signed or self-custody) from a new device. This guide covers this role.

Requires `@pollar/core` / `@pollar/react` / `@pollar/react-native` 0.12.0 or later.

---

## Why recovery is required

A Turnkey wallet signs with a key on the user's device (see [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets)). Pollar holds no copy of it. If the user loses the device and the wallet has no other way in, nobody can move its funds again.

So a Turnkey wallet needs a **recovery method** before it signs. Until it has one, every signature other than the wallet's own setup (account creation, trustlines, a new chain) and on-ramps is refused with **409 `SDK_WALLET_RECOVERY_REQUIRED`**, on testnet and mainnet. A ramp order that reaches a step needing the wallet waits until a method is added.

A wallet counts as recoverable when it has at least one of:

| Method | How the user adds it | How it recovers |
|---|---|---|
| Passkey | Registers a passkey (synced by the platform: iCloud Keychain, Google Password Manager) | Signs in with the passkey on the new device |
| Email | Enters an email and confirms it with a code Turnkey sends | Receives a code at that email on the new device |
| Second device | Signs in on another device and approves it from the first | The other device approves the new one |

**The user adds every method directly with Turnkey, from their own device.** Pollar never sets a recovery method, never confirms one and never receives the codes: the Turnkey wallet is created with no email, and the OTP codes go from Turnkey to the user. This keeps the wallet out of Pollar's reach, which matters most for a co-signed wallet, where Pollar holds the other vote.

---

## With `@pollar/react`

The provider handles the whole flow:

- `recoveryLocked` on `usePollar()` is `true` while the wallet has no method. The wallet menu (`<WalletButton>`) shows the lock with a way to fix it, and the receive modal hides the address until a method exists, so nobody sends funds to a wallet that cannot be recovered.
- `openRecoveryModal()` opens `<RecoveryModal>`: add or remove passkeys, confirm an email, approve or reject a device that asks to join, and export the recovery phrase.
- After a [custody migration](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) moves the user's wallet to Turnkey, the provider opens `<RecoveryModal>` right away.
- The ramp widget offers the same setup when an order waits on it.

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function RecoveryBanner() {
  const { recoveryLocked, openRecoveryModal } = usePollar();
  if (!recoveryLocked) return null;
  return (
    <button onClick={openRecoveryModal}>
      Set up a way to recover your wallet
    </button>
  );
}
```

`recovery` on `usePollar()` holds the full state (`RecoveryState`): `required` (the user has a Turnkey wallet), `configured`, `email` (`address`, `verified`), `passkeys` and `devices`. `refreshRecovery()` reads it again.

On the web the provider installs `browserRecoveryPasskey`, the WebAuthn ceremony for recovery passkeys. Its relying party is the page's hostname, so a passkey created on your app's domain recovers the wallet on that domain.

On React Native pass your own ceremony as `recoveryPasskey` in the client config; see [`@pollar/react-native`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react-native). Without one the passkey options are unavailable (`SDK_COSIGN_PASSKEY_UNAVAILABLE`) and the user recovers with an email code or another device.

---

## Headless: `client.cosign.recovery`

Every method runs on the user's device and talks to Turnkey through Pollar's relay; Pollar sees no secret.

**State**

| Method | Returns | What it does |
|---|---|---|
| `status()` | `RecoveryState` | Whether the wallet can be recovered without this device, and the methods it has |
| `passkeyAvailable` | `boolean` | Whether a passkey ceremony is configured on this client |

**Adding methods (on a device that has access)**

| Method | Returns | What it does |
|---|---|---|
| `addPasskey({ name? })` | `RecoveryState` | Registers a passkey as a way back in |
| `removePasskey(authenticatorId)` | `RecoveryState` | Removes one |
| `startEmail(email)` | `void` | Turnkey emails a code to confirm `email` |
| `confirmEmail(code)` | `RecoveryState` | Confirms the email with that code; it counts as a method from now on. An email the wallet already holds unconfirmed is replaced |
| `approveDevice(enrollmentId)` | `CosignDevicesContent` | Adds a device that asked to join (`client.cosign.devices()` lists the open `enrollments`) |
| `rejectDevice(enrollmentId)` | `void` | Refuses it |

**Recovering (on a new device)**

| Method | Returns | What it does |
|---|---|---|
| `recoverWithPasskey()` | `RecoveryState` | One of the user's passkeys adds this device's key to their Turnkey user |
| `startEmailRecovery()` | `void` | Turnkey emails a code to the confirmed address |
| `recoverWithEmailCode(code)` | `RecoveryState` | The code opens a short Turnkey session that adds this device's key |
| `requestDeviceEnrollment(label?)` | `{ id, expiresAt }` | Asks an enrolled device to add this one; the user approves it there |

The user signs in to the app on the new device first (social, email or wallet login, as usual); recovery then adds the device to their Turnkey wallet.

**Export**

`exportWallet()` returns the wallet's recovery phrase, decrypted on this device: Turnkey encrypts it to a key that exists only for that call, and nothing readable crosses Pollar. Whoever holds the phrase controls every account of the wallet, so show it only on an explicit user action.

```ts
const state = await client.cosign.recovery.status();
if (state.required && !state.configured) {
  await client.cosign.recovery.startEmail('user@example.com');
  // ... the user types the code Turnkey sent
  await client.cosign.recovery.confirmEmail(code);
}
```

---

## Errors

| Code | Meaning |
|---|---|
| `SDK_WALLET_RECOVERY_REQUIRED` (409) | The wallet has no recovery method; add one, then retry. The SDK also throws it from `recoverWithPasskey()` / `startEmailRecovery()` when the wallet has no passkey / no confirmed email to recover with |
| `SDK_COSIGN_PASSKEY_UNAVAILABLE` | SDK only: no passkey ceremony on this client |
| `SDK_COSIGN_TURNKEY_REJECTED` (502) | Turnkey refused the request; `cosignRefusalMessage(err)` gives the text with Turnkey's reason |
| `SDK_COSIGN_UPSTREAM_ERROR` (502) | Turnkey or the relay failed, or a code did not verify; retry |
| `SDK_COSIGN_DEVICE_NOT_ENROLLED` (403) | This device is not one of the user's; recover it first |

See [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes) for the rest.

---

## Browser and device support

Recovery passkeys use WebAuthn, supported on:

- iOS 16+ (Face ID, Touch ID)
- Android 9+ (fingerprint, face unlock)
- macOS with Touch ID
- Windows Hello
- Any device with a FIDO2 hardware key
