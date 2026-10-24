---
title: "Security Model"
---

This page explains who holds the key of each kind of wallet, where Pollar-managed keys are stored, and which checks run before Pollar signs anything.

---

## Key management models

| Model | Who holds the key | Where it applies |
|---|---|---|
| **Pollar-managed** | Pollar's wallet services, encrypted at rest | Testnet wallets, and mainnet wallets created before the app moved to Turnkey |
| **Co-signed (Turnkey 2-of-2)** | A Turnkey enclave; every signature needs the user's device and Pollar's vote. See [Co-signed and Self-custody Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) | Mainnet |
| **Self-custody (Turnkey 1-of-1)** | A Turnkey enclave; the user's device alone signs. Pollar cannot move, freeze or recover the funds | Mainnet |
| **External wallet** | The user's own wallet (Freighter, a Solana wallet, your own adapter). Pollar never sees the key | Any network |
| **Smart wallet (passkey)** | A Soroban contract account whose signer is the user's passkey. See [Smart Wallets](https://docs.pollar.xyz/docs/smart-wallets/overview) | Stellar |

On mainnet, every wallet Pollar creates for a user is a Turnkey wallet: Pollar does not custody end-user funds there, and the dashboard does not offer Pollar custody on a mainnet app.

---

## Pollar-managed keys

The keys of Pollar-managed wallets live in Pollar's wallet services, one per chain (Stellar, Solana, Polygon):

- Each private key is encrypted with **AES-256-GCM** (authenticated encryption) under a 256-bit master key held by that wallet service. The database stores only the ciphertext, its IV and its auth tag.
- Every chain and network runs as its own instance, with its own database and its own master key; no two instances share one.
- The wallet services have no public endpoint. Only Pollar's own services call them, and every call is authenticated with an HMAC signature over the request and a timestamp.
- To sign, the wallet service decrypts the key in memory, checks the transaction against the policy below, signs and discards the plaintext.

The same model holds the keys of your app's operator wallets (funding, gas, distribution) on apps that pay with their own wallets. On apps on credits, Pollar's own pool pays fees and reserves instead (see [Credits and Billing Models](https://docs.pollar.xyz/docs/core-concepts/credits)).

---

## What Pollar signs, and what it checks first

| Operation | Allowed |
|---|---|
| Sign fee-bump transactions | Yes, to cover fees on behalf of users |
| Sponsor account reserves and trustlines | Yes, to fund new wallets |
| Sign for a Pollar-managed wallet | Yes, when the user's session asks for it and the transaction passes the policy |
| Sign for a co-signed wallet alone | **No**: its vote is one of two |
| Sign for a self-custody or external wallet | **No**: Pollar holds no vote |

Every Stellar transaction Pollar signs, for a Pollar-managed wallet or as the second vote of a co-signed one, passes the same per-transaction policy first:

- The fee stays within the app's fee cap, and the operation count within its operations cap (**Wallets > Transaction Policy**).
- The transaction has timebounds and its operations run as the wallet's own account.
- `accountMerge` is blocked unless the app allows its destination.
- Signer, master weight and threshold changes are blocked.

On top of that, Pollar sponsors only what the app's **Sponsorship** settings say it sponsors, and on an app on credits a paid flow answers **402 `SDK_CREDITS_INSUFFICIENT`** when the credits do not cover it. These checks run server-side and cannot be bypassed from the SDK.

### Why a sponsor signature cannot move a user's funds

A fee-bump transaction has two layers: an inner transaction signed by the user's key and an outer wrapper signed by the sponsor. The outer signature only authorizes paying the fee; it has no authority over the inner transaction's operations. Moving a user's funds needs a `payment` or `pathPayment` inside the inner transaction, signed by the user's own key, which the sponsor key cannot produce.

For a Pollar-managed wallet, Pollar's wallet service does hold the user's key, which is why it signs only what the user's session asks for and only after the policy above. For a Turnkey or external wallet, it holds no key that can sign the inner transaction.

---

## Attack surface

| Vector | Risk | Mitigation |
|---|---|---|
| Database compromised | Key exposure | Only AES-256-GCM ciphertext is stored; the master key is not in the database |
| Pollar server compromised | Transactions on Pollar-managed wallets | The wallet services are internal and HMAC-authenticated, and the per-transaction policy blocks signer changes and unapproved merges. Turnkey wallets need the user's device |
| Webhook or server call spoofing | Unauthorized wallet activations | Server API calls need a SECRET key |
| Client-side bypass | SDK manipulated to skip policies | Policy enforcement is server-side |
| Device loss (Turnkey wallets) | The device key is gone | Recovery with a passkey, an email code or another enrolled device, added by the user directly with Turnkey |
