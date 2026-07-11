---
title: "Overview"
---

**Pollar** is the onboarding-to-payment infrastructure layer for consumer apps on Stellar. The full stack that takes a new user from clicking **Continue with Google** to sending USDC — without ever showing them a seed phrase, a wallet address, a transaction fee, or a trustline prompt.

---

## The problem

Every team building a consumer product on Stellar hits the same infrastructure wall before writing a single line of their actual product:

- Creating or linking a Stellar account for each user

- Handling XLM reserve funding

- Configuring trustlines for each asset

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

---

## How it compares

| <br />                | Crossmint       | Privy | Dynamic | Stellar Wallets Kit  | **Pollar**       |
| --------------------- | --------------- | ----- | ------- | -------------------- | ---------------- |
| Stellar native        | Partial         | No    | No      | Yes (connector only) | **Yes**          |
| Deferred funding      | No              | N/A   | N/A     | No                   | **Yes (unique)** |
| Fee-bump native       | No              | N/A   | N/A     | No                   | **Yes**          |
| Built for startups    | No (enterprise) | Yes   | Yes     | Partial              | **Yes**          |
| Full onboarding stack | No              | No    | No      | No                   | **Yes**          |

> Pollar also **integrates** with several of these: first-party adapters let you use Privy embedded wallets or any Stellar Wallets Kit wallet as a login method on top of Pollar's stack. See [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters).
