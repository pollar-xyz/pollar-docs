---
title: "Chain Support"
---

Pollar is multichain. An app enables the chains it wants under **Wallets > Wallet settings > Enabled chains** ([Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings)), and every user gets **one wallet per enabled chain** from the same login. This page is the single place that says what works where.

**Solana is fully supported** for the product's core: sign-in, Pollar-managed, co-signed and self-custody wallets, SOL and SPL token balances, sponsored transfers, history and, on mainnet, swaps through Jupiter and Titan. Stellar additionally carries earn, token distribution and the Soroban policies. Polygon has wallets, balances, token sends and ramps. Ramps reach Solana through a Circle CCTP bridge leg.

---

## Feature matrix

Legend: **Yes** = works today on that chain. **n/a** = the chain has no such concept. **No** = not available on that chain.

### Sign-in and wallets

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| Social / email login creates a wallet (Pollar-managed on testnet, Turnkey on mainnet) | Yes | Yes | Yes | `@pollar/core` `login()`; one wallet per chain in `getWallets()` |
| Sign in with the user's own wallet | Yes (SEP-10: Freighter, Albedo, Stellar Wallets Kit) | Yes (Sign In With Solana: Phantom, Solflare, Backpack) | No | [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters) |
| Passkey smart wallets (C-address) | Yes | n/a | n/a | [Smart Wallets](https://docs.pollar.xyz/docs/smart-wallets/overview) |
| Turnkey wallets: co-signed 2-of-2 or self-custody 1-of-1 (mainnet) | Yes | Yes | Yes | [Co-signed and Self-custody Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) |
| Wallet recovery (passkey, email code, another device) | Yes | Yes | Yes | same; one Turnkey wallet holds every chain |
| Wallet creation timing (at login / on demand / never) | Yes | Yes | Yes | [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings) |
| Wallet-less sessions (authentication only) | Yes | Yes | Yes | [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) |
| Starting balance for new wallets | Yes (XLM, Immediate / Deferred) | Yes (SOL above the rent-exempt floor) | Yes (POL, from the Polygon GAS wallet) | [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding) |

### Balances and tokens

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| Native balance | XLM | SOL | POL | `refreshBalance()`, `<WalletBalanceModal>` |
| Token balances | Stellar assets | SPL tokens | ERC-20 | same |
| Per-app token catalog | Yes (code + issuer) | Yes (SPL mint) | Yes (contract) | [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines) |
| Holding a token needs an on-chain entry | Trustline (0.5 XLM reserve, sponsored) | Associated token account, created by Pollar when the user receives the token | n/a | [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines) |
| Testnet faucet hints in the balance modal | Friendbot | Devnet SOL + Circle USDC faucet | Amoy | `<WalletBalanceModal>` |

### Payments

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| `sendPayment()` from a managed wallet | Yes | Yes (SOL and SPL, one server call) | Yes | [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) |
| `sendPayment()` from the user's own wallet | Yes | Yes (build, sign in the wallet, submit) | No | same |
| Fee sponsorship on transfers | Fee bump, GAS wallet | GAS wallet is the fee payer | No (user pays POL) | [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship) |
| Recipient's token account created by the app | n/a (trustline) | Yes, idempotent, rent paid by the app | n/a | automatic |
| `<SendModal>` / `<ReceiveModal>` | Yes | Yes | Yes | [Payments UI](https://docs.pollar.xyz/docs/guides/payments-ui) |
| Memo | Yes | n/a | n/a | `<SendModal>` |
| Low-level `buildTx` / `signTx` / `submitTx` (XDR) | Yes | n/a (use `sendPayment`) | n/a | [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) |
| Transaction history, per-chain explorer links | Yes (stellar.expert) | Yes (explorer.solana.com) | Yes (polygonscan) | [Transaction History](https://docs.pollar.xyz/docs/core-concepts/transaction-history) |
| Monitor > Transactions in the dashboard | Yes | Yes (fee in lamports) | Yes | [Transactions](https://docs.pollar.xyz/docs/operator-guide/monitor/transactions) |

### Fiat, cards and compliance

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| On/off-ramps | Yes (Abroad, Anclap SEP-24, Etherfuse) | Yes (through a Circle CCTP bridge leg) | Yes (Stereum; Uniswap V3 swap legs) | [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps) |
| KYC and requirement steps | Yes | Yes | Yes | chain-agnostic |
| Cards: holder, KYC, issue, reveal | Yes | Yes | Yes | chain-agnostic |
| Cards: fund the card from the wallet | Yes (through a Circle CCTP bridge) | Yes (straight to the provider's Solana address) | No | [Cards guide](https://docs.pollar.xyz/docs/guides/cards-guide) |
| Outbound webhooks for on-chain events | `upcoming` | `upcoming` | `upcoming` | [Webhooks](https://docs.pollar.xyz/docs/sdk-reference/webhooks) |

### On-chain DeFi and policies

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| Swap | Yes (SDEX, Soroswap, Aquarius) | Yes, mainnet only (Jupiter, Titan) | No | [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap) |
| Earn (DeFindex, Blend) | Yes | No | No | [Earn](https://docs.pollar.xyz/docs/operator-guide/treasury/earn) |
| Token distribution (claimable rules) | Yes | No | No | [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution) |
| Transaction policy (account merge, max fee) | Yes | n/a | n/a | [Transaction Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/transaction-policy) |
| Soroban auth policy | Yes | n/a | n/a | [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy) |
| Contract-call sponsorship rules | Yes | n/a | n/a | [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship) |

---

## Solana in detail

A Solana-enabled app gets the whole wallet lifecycle without any Solana-specific code in the client:

- **Login.** Email, Google or GitHub gives the user a Pollar-managed Solana wallet at sign-in, with no seed phrase. A user who already has Phantom, Solflare or Backpack signs in with **Sign In With Solana** through `@pollar/solana-wallet-standard-adapter`, the Solana counterpart of the Stellar Wallets Kit adapter.
- **Custody.** On testnet, managed keys live in Pollar's Solana wallet service, encrypted at rest. On mainnet, the Solana account lives in the user's Turnkey wallet, **co-signed** (a 2-of-2 vote between the user's device and Pollar) or **self-custody**, and the device verifies the serialized transaction (including a Solana CCTP burn) before it signs. A custodial Solana wallet that moves to Turnkey gets a new address, and its funds move with it.
- **Funding.** Solana has no sponsored reserve, so the app's **Solana GAS wallet** (or Pollar's pool, on an [app on credits](https://docs.pollar.xyz/docs/core-concepts/credits)) sends each new wallet its starting SOL (0, or at least the platform floor that keeps the account above the rent-exempt minimum) and tops it up whenever it falls below the floor.
- **Payments.** `sendPayment({ chain: 'SOLANA', destination, amount, mint? })` sends SOL or any SPL token. Amounts are integer base units (lamports, or the mint's smallest unit). When the token is marked **sponsor transfers**, the GAS wallet is the fee payer and the recipient's associated token account is created in the same transaction.
- **History.** Every Solana transaction lands in the same history as Stellar ones, with its own reconcile job and explorer link; the dashboard's Monitor shows the fee in lamports.
- **Swap.** On a mainnet app, `getSolanaSwapQuote` prices a swap on Jupiter and Titan and `swapSolana` runs the picked route; the swap modal offers Solana next to Stellar. A co-signed or self-custody wallet approves the swap on the device, an external wallet signs it in the connected wallet, and Pollar refuses any route whose simulation pays the user less than its minimum. Neither aggregator has devnet liquidity, so a testnet app has no Solana swap.
- **Ramps.** No ramp provider settles natively on Solana. A route reaches a Solana wallet by adding a Circle CCTP bridge leg to a provider that settles USDC on Stellar or Polygon, so the user receives USDC on Solana. See [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps).
- **Networks.** A testnet app uses **devnet**; a mainnet app uses **mainnet-beta**. The cluster follows the app's network, never a request parameter.

Two Solana facts the client has to respect:

1. **Sending an SPL token the sender does not hold yet** fails with `TX_NO_TRUSTLINE`, the same code Stellar uses for a missing trustline. The sender must have received the token first.
2. **Sign In With Solana uses the wallet's native `solana:signIn` feature when it has one** (Phantom, Solflare and Backpack do). A wallet without it signs the same sign-in message through `signMessage`.

---

## Stellar-only features, and why

| Feature | Reason |
|---|---|
| Earn | The providers (DeFindex, Blend) are Soroban protocols. The modal hides itself on a Solana-only app. |
| Trustlines, account merge, Soroban auth entries | Stellar protocol concepts with no Solana equivalent. |
| Passkey smart wallets | Built on Stellar C-addresses. |

---

## Packages

| Package | Stellar | Solana | Polygon |
|---|:---:|:---:|:---:|
| `@pollar/core` | Yes | Yes | Yes |
| `@pollar/react` | Yes | Yes | Yes |
| `@pollar/react-native` | Yes | Yes (`sendPayment`, balances; no external-wallet adapter) | Yes |
| `@pollar/solana-wallet-standard-adapter` | - | Yes (web) | - |
| `@pollar/stellar-wallets-kit-adapter` | Yes | - | - |

---

## Related

- [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings): enable chains, custody and signature confirmation
- [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship): who pays the fee on each chain
- [Co-signed and Self-custody Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets): Turnkey wallets on Stellar, Solana and Polygon
- [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters): Stellar Wallets Kit and Solana Wallet Standard adapters
