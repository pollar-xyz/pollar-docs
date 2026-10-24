---
title: "Account Funding"
---

**Dashboard > Wallets > Account Funding** · Chains: Stellar, Solana (one tab each)

What a new user wallet receives when it is created, per chain. The page shows one tab per enabled chain that has a funding policy:

- **Stellar**: the app's **funding wallet** and the **Funding Mode** (Immediate / Deferred, with the starting XLM).
- **Solana**: the **starting SOL** each new Solana wallet receives from the Solana GAS wallet.

Polygon has no tab: its new wallets start empty and their gas is topped up under [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship).

> **Apps on credits.** When the app is on [credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits), Pollar's pool pays the reserves, the starting balances and the top-ups, and charges the app's credits. The app's own wallets do not pay for its users. The rest of this page describes apps that pay with their own wallets.

---

## Stellar tab

### Funding wallet

The Stellar account that sponsors the XLM reserve of new user wallets (CAP-33) and sends them the configured starting balance. The card shows:

- its balance, split into **Available** and **Locked in reserve** (Stellar locks a minimum per trustline, offer and sponsorship the account pays for; only the available amount can be spent)
- an estimate of how many more wallets the available XLM can fund
- its public key, with copy and explorer links
- **Fund on testnet** (testnet apps only): funds it from the Stellar testnet faucet

To top it up on mainnet, copy the public key and send XLM to it from any Stellar wallet or exchange. A wallet that is created but not yet on Stellar needs at least 2 XLM sent to it to activate.

If the app has no Stellar wallet yet, the tab offers **Create wallet**. By default one app wallet covers funding, gas and distribution. An app that Pollar has set up with one wallet per role shows its funding wallet here, its gas wallet under [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship) and its distribution wallet under [Token Distribution](https://docs.pollar.xyz/docs/operator-guide/treasury/token-distribution).

### Funding Mode

Controls when new Stellar wallets get their account on-chain. Switching applies to wallets created after the switch; no code change is needed. Whether a user gets a wallet at all is set by [Wallet creation](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#wallet-creation).

| Mode | When the account is created | Best for |
| --- | --- | --- |
| **Immediate** | When the user logs in, automatically | Apps without compliance requirements |
| **Deferred** | When your backend calls `POST /v3/wallets/fund` after a business event (KYC approved, first deposit) | Neobanks, remittance apps, KYC-gated products |

In Deferred mode the user has an address at registration, but its account is not created on-chain, and nothing is paid, until your backend funds it. `POST /v3/wallets/fund` funds a Pollar-custody wallet directly; for a co-signed or self-custody wallet it opens the account creation request the user approves in their next session. External wallets are refused. See the [Deferred Flow Guide](https://docs.pollar.xyz/docs/guides/deferred-flow-guide).

**Starting XLM balance** (Immediate mode): extra XLM added to each new wallet on top of the sponsored reserve, paid by the funding wallet. From 0 to 100 XLM, up to 7 decimals; 0 (the default) means wallets start empty.

In both modes a single wallet can be funded by hand with **Fund** in [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets).

### Reserve cost per wallet

The XLM locked per funded user wallet depends on the assets enabled in [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines), when their trustlines are sponsored:

`1 XLM + (number of sponsored trustlines x 0.5 XLM)`

| Assets enabled | Reserve locked |
| --- | --- |
| 0 | 1 XLM |
| 1 (e.g. USDC) | 1.5 XLM |
| 2 (e.g. USDC + EURC) | 2 XLM |
| 3 | 2.5 XLM |

The reserve stays locked in the funding wallet while it sponsors the user wallet; it is not spent. The starting balance, if any, is transferred on top as spendable XLM.

> References: [Minimum Balance](https://developers.stellar.org/docs/learn/fundamentals/lumens#minimum-balance), [Trustlines](https://developers.stellar.org/docs/learn/fundamentals/stellar-data-structures/accounts#trustlines)

---

## Solana tab

Solana has no sponsored reserve: a new wallet holds only the SOL you give it here, sent from the app's **Solana GAS wallet**. The tab shows that wallet and one setting. If the app has no Solana GAS wallet, the tab links to [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship), where it is created.

| Setting | Values | What it does |
| --- | --- | --- |
| **Starting SOL balance** | `0`, or at least the platform floor (up to 10 SOL, 9 decimals) | SOL sent to each new Solana wallet at creation. `0` sends nothing: the user then relies on the transfers you sponsor, where the GAS wallet is the fee payer. Any other value must be at least the platform floor shown on the tab, because below it the network reaps the account |

After creation, every Solana wallet is topped up from the GAS wallet whenever it falls below the floor; that policy is on the Solana tab of [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship). Keep the GAS wallet funded: when it is empty no user of this app can sign on Solana.

On a testnet app the GAS wallet lives on **devnet**; the balance modal in the SDK offers your users the devnet SOL faucet and Circle's USDC faucet.

---

## Low balances

Watch the funding wallet's available XLM and the GAS wallets' balances. Low-balance alerts under [Alerts](https://docs.pollar.xyz/docs/operator-guide/monitor/alerts) are not available yet; on credits, the low-balance alert lives on the [Credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits) page.
