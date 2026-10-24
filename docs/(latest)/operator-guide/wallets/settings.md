---
title: "Wallet settings"
---

**Dashboard → Wallets → Wallet settings** · Chains: all

Who holds your users' wallet keys, and when their wallets are created. Both settings apply to every chain the app enables, and both affect only wallets that do not exist yet: users who already have one keep it. Funding has its own page, [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding).

---

## Wallet custody

| Mode | What happens | Chains |
| --- | --- | --- |
| **Pollar** (default) | Pollar keeps the encrypted key and signs on behalf of the user | Stellar, Solana, Polygon |
| **Co-signed with Turnkey (2-of-2)** | Each user gets a Turnkey sub-organization where their device and Pollar must both approve every signature. Neither side can move funds alone, and the user can export the wallet without Pollar | Stellar, Solana, Polygon (mainnet) |

Co-signing is a mainnet feature: a testnet app keeps its wallets in Pollar custody unless Pollar has enabled co-signing on testnet for testing. It requires an SDK version that registers the device key and shows the approval prompt (`@pollar/core` 0.11.5 or later); users on an older SDK cannot create a wallet until they upgrade.

See [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) for how the two votes work and what the device verifies before it signs, on each chain.

---

## Wallet creation

| Mode | What happens | Best for |
| ---- | ------------ | -------- |
| **At login** (default) | Every user gets a wallet on every enabled chain the first time they sign in | Apps where every user transacts |
| **On demand** | Users sign in without a wallet; your app creates it when they need one | Apps where only some users ever need a wallet |
| **Never** | Users get a session and no wallet | Authentication only |

On demand wallets are created from your app with `createWallet()` in the SDK. Once created, a wallet is funded according to the [Funding Mode](https://docs.pollar.xyz/docs/operator-guide/wallets/funding-mode) on Stellar and the starting SOL on Solana.

Before switching to **On demand** or **Never**, make sure your app runs `@pollar/core` / `@pollar/react` 0.11.4 or later.

See [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) for what a session without a wallet looks like and how to create the wallet.
