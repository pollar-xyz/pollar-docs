---
title: "Chain Support"
---

Pollar is multichain. An app enables the chains it wants under [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains), and every user gets **one wallet per enabled chain** from the same login. This page is the single place that says what works where.

**Solana is fully supported** for the product's core: sign-in, Pollar-managed and co-signed wallets, SOL and SPL token balances, sponsored transfers, history, and fiat ramps. Stellar additionally carries the on-chain DeFi features (swap, earn) and the Soroban policies. Polygon has wallets, balances, token sends and ramps settlement.

---

## Feature matrix

Legend: **Yes** = works today on that chain · **n/a** = the chain has no such concept · **No** = not available on that chain.

### Sign-in and wallets

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| Social / email login creates a managed wallet | Yes | Yes | Yes | `@pollar/core` `login()`; one wallet per chain in `getWallets()` |
| Sign in with the user's own wallet | Yes (SEP-10: Freighter, Albedo, Stellar Wallets Kit) | Yes (Sign In With Solana: Phantom, Solflare, Backpack) | No | [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters) |
| Passkey smart wallets (C-address) | Yes | n/a | n/a | [Smart Wallets](https://docs.pollar.xyz/docs/smart-wallets/overview) |
| Co-signed wallets, Turnkey 2-of-2 (mainnet) | Yes | Yes | Yes | [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) |
| Wallet creation timing (at login / on demand / never) | Yes | Yes | Yes | [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings) |
| Wallet-less sessions (authentication only) | Yes | Yes | Yes | [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) |
| Starting balance for new wallets | Yes (XLM, Immediate / Deferred) | Yes (SOL above the rent-exempt floor) | No (gas top-up policy only) | [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding) |

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
| On/off-ramps | Yes | Yes (PagFinance settles on Solana; Stereum via Circle CCTP) | Yes (Stereum rail) | [Ramp providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers) |
| KYC and requirement steps | Yes | Yes | Yes | chain-agnostic |
| Cards: holder, KYC, issue, reveal | Yes | Yes | Yes | chain-agnostic |
| Cards: fund the card from the wallet | Yes | No | No | [Cards](https://docs.pollar.xyz/docs/operator-guide/cards/providers) |
| Outbound webhooks for on-chain events | Yes | No | No | [Webhooks](https://docs.pollar.xyz/docs/sdk-reference/webhooks) |

### On-chain DeFi and policies

| Feature | Stellar | Solana | Polygon | Where |
|---|:---:|:---:|:---:|---|
| Swap (SDEX, Soroswap, Aquarius) | Yes | No | No | [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap) |
| Earn (DeFindex, Blend) | Yes | No | No | [Earn](https://docs.pollar.xyz/docs/operator-guide/treasury/earn) |
| Token distribution (claimable rules) | Yes | No | No | [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution) |
| Transaction policy (account merge, max fee) | Yes | n/a | n/a | [Transaction Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/transaction-policy) |
| Soroban auth policy | Yes | n/a | n/a | [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy) |
| Contract-call sponsorship rules | Yes | n/a | n/a | [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship) |

---

## Solana in detail

A Solana-enabled app gets the whole wallet lifecycle without any Solana-specific code in the client:

- **Login.** Email, Google or GitHub gives the user a Pollar-managed Solana wallet at sign-in, with no seed phrase. A user who already has Phantom, Solflare or Backpack signs in with **Sign In With Solana** through `@pollar/solana-wallet-standard-adapter`, the Solana counterpart of the Stellar Wallets Kit adapter.
- **Custody.** Managed keys live in Pollar's Solana wallet service, encrypted at rest. A mainnet app can switch new wallets to **co-signed** custody, where every signature is a 2-of-2 vote between the user's device and Pollar through Turnkey, and the device verifies the serialized transaction (including a Solana CCTP burn) before voting.
- **Funding.** Solana has no sponsored reserve, so the app's **Solana GAS wallet** sends each new wallet its starting SOL (0, or at least the platform floor that keeps the account above the rent-exempt minimum) and tops it up whenever it falls below the floor.
- **Payments.** `sendPayment({ chain: 'SOLANA', destination, amount, mint? })` sends SOL or any SPL token. Amounts are integer base units (lamports, or the mint's smallest unit). When the token is marked **sponsor transfers**, the GAS wallet is the fee payer and the recipient's associated token account is created in the same transaction.
- **History.** Every Solana transaction lands in the same history as Stellar ones, with its own reconcile job and explorer link; the dashboard's Monitor shows the fee in lamports.
- **Ramps.** PagFinance (Brazil, BRL via Pix) is paid in USDC on Solana. Stereum (Bolivia, BOB) settles on Polygon and is bridged with Circle CCTP; the bridge mints to Solana when the app serves Solana and not Stellar.
- **Networks.** A testnet app uses **devnet**; a mainnet app uses **mainnet-beta**. The cluster follows the app's network, never a request parameter.

Two Solana facts the client has to respect:

1. **Sending an SPL token the sender does not hold yet** fails with `TX_NO_TRUSTLINE`, the same code Stellar uses for a missing trustline. The sender must have received the token first.
2. **Sign In With Solana needs a wallet with the native `solana:signIn` feature.** Phantom, Solflare and Backpack have it.

---

## Stellar-only features, and why

| Feature | Reason |
|---|---|
| Swap and Earn | The venues (SDEX, Soroswap, Aquarius, DeFindex, Blend) are Stellar and Soroban protocols. The modals hide themselves on a Solana-only app. |
| Trustlines, account merge, Soroban auth entries | Stellar protocol concepts with no Solana equivalent. |
| Passkey smart wallets | Built on Stellar C-addresses. |
| Card funding | The card balance is funded from the user's Stellar wallet. |
| Outbound webhooks | Driven by the Stellar watcher. |

---

## Packages

| Package | Stellar | Solana | Polygon |
|---|:---:|:---:|:---:|
| `@pollar/core` | Yes | Yes | Yes |
| `@pollar/react` | Yes | Yes | Yes |
| `@pollar/react-native` | Yes | Yes (`sendPayment`, balances; no external-wallet adapter) | Yes |
| `@pollar/solana-wallet-standard-adapter` | - | Yes (web) | - |
| `@pollar/stellar-wallets-kit-adapter` | Yes | - | - |
| `@pollar/privy-adapter`, `@pollar/privy-server-adapter` | Yes | No | No |
| `@pollar/accesly-adapter` | Yes | - | - |

---

## Related

- [Chains](https://docs.pollar.xyz/docs/operator-guide/wallets/chains): enable chains and order the default
- [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship): who pays the fee on each chain
- [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets): Turnkey 2-of-2 on Stellar, Solana and Polygon
- [Wallet Adapters](https://docs.pollar.xyz/docs/sdk-reference/wallet-adapters): Stellar Wallets Kit and Solana Wallet Standard adapters
