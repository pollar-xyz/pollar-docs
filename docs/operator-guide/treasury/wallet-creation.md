---
title: "Wallet Creation"
---

**Dashboard → Treasury → Account Funding** (the **Wallet creation** card sits above the funding mode on the Account Funding page; there is no standalone page).

Controls when your users get a wallet. Changing it affects only wallets that do not exist yet: users who already have one keep it.

---

## Modes

| Mode | What happens | Best for |
| ---- | ------------ | -------- |
| **At login** (default) | Every user gets a wallet the first time they sign in | Apps where every user transacts |
| **On demand** | Users sign in without a wallet; your app creates it when they need one | Apps where only some users ever need a wallet |
| **Never** | Users get a session and no wallet | Authentication only |

On demand wallets are created from your app with `createWallet()` in the SDK. Once created, a wallet is funded according to the [Funding Mode](https://docs.pollar.xyz/docs/operator-guide/treasury/funding-mode).

Before switching to **On demand** or **Never**, make sure your app runs `@pollar/core` / `@pollar/react` 0.11.4 or later.

See [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) for what a session without a wallet looks like and how to create the wallet.
