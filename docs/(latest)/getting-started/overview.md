---
title: "Overview"
---

**Pollar** is the onboarding-to-payment infrastructure layer for consumer apps on **Stellar and Solana**. The full stack that takes a new user from clicking **Continue with Google** to sending USDC — without ever showing them a seed phrase, a wallet address, a transaction fee, a trustline prompt or a rent-exempt minimum.

One login gives the user a wallet on every chain your app enables. Solana is fully supported for the whole wallet lifecycle: managed and co-signed wallets, Sign In With Solana for Phantom, Solflare and Backpack, SOL and SPL balances, sponsored transfers with the recipient's token account created for them, history, and fiat ramps. See [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support) for the feature matrix.

---

## The problem

Every team building a consumer product on Stellar or Solana hits the same infrastructure wall before writing a single line of their actual product:

- Creating or linking an account for each user

- Handling the XLM reserve, or keeping a Solana account above the rent-exempt minimum

- Configuring trustlines for each asset, or creating associated token accounts

- Abstracting transaction fees from users unfamiliar with blockchain

- Building an onboarding flow that works for people with zero crypto experience

Pollar handles all of this so you can skip straight to building your product.

---

## The solution

```tsx
import { PollarProvider, usePollar } from '@pollar/react';

function App() {
  const { isAuthenticated, login, runTx } = usePollar();

  if (!isAuthenticated) {
    return (
      <button onClick={() => login({ provider: 'google' })}>
        Continue with Google
      </button>
    );
  }

  return (
    <button
      onClick={() =>
        runTx('payment', {
          destination: 'GXXX...',
          amount: '10',
          asset: { type: 'credit_alphanum4', code: 'USDC', issuer: 'GA5Z...' },
        })
      }
    >
      Send 10 USDC
    </button>
  );
}

export default function Root() {
  return (
    <PollarProvider client={{ apiKey: 'pub_testnet_...' }}>
      <App />
    </PollarProvider>
  );
}
```

In a handful of lines: OAuth authentication, a funded Stellar wallet, and USDC payments. No seed phrases. No fee prompts. No trustline configuration. (`runTx` is the one-shot build → sign → submit helper; see the [SDK Reference](https://docs.pollar.xyz/docs/sdk-reference/pollar-react) for the split `buildTx` / `signAndSubmitTx` flow.)

The same app on Solana: the login is identical, and the payment is one call.

```tsx
const { sendPayment } = usePollar();

// 10 USDC on Solana (SPL mint, 6 decimals), fee paid by the app
await sendPayment({
  chain: 'SOLANA',
  destination: '7xKX...',
  amount: '10000000',
  mint: 'EPjFWdd5AufqSSqeM3qQw8xJXpY4zFrPyLKS3jcKBVMy',
});
```

A user who already has Phantom, Solflare or Backpack signs in with **Sign In With Solana** instead of Google, through `@pollar/solana-wallet-standard-adapter`; see [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters).

---

## How it compares

| <br />                | Crossmint       | Privy | Dynamic | Stellar Wallets Kit  | **Pollar**       |
| --------------------- | --------------- | ----- | ------- | -------------------- | ---------------- |
| Stellar native        | Partial         | No    | No      | Yes (connector only) | **Yes**          |
| Solana native         | Yes             | Yes   | Yes     | No                   | **Yes**          |
| One login, a wallet per chain | No      | Partial | Partial | No                | **Yes**          |
| Deferred funding      | No              | N/A   | N/A     | No                   | **Yes (unique)** |
| Fee-bump native       | No              | N/A   | N/A     | No                   | **Yes**          |
| Built for startups    | No (enterprise) | Yes   | Yes     | Partial              | **Yes**          |
| Full onboarding stack | No              | No    | No      | No                   | **Yes**          |

> Pollar also **integrates** with several of these: first-party adapters let you use Privy embedded wallets or any Stellar Wallets Kit wallet as a login method on top of Pollar's stack. See [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters).
