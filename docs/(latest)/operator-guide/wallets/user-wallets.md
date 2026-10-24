---
title: "Wallets"
---

**Dashboard > Wallets > Wallets** · Chains: Stellar, Solana, Polygon

Every wallet of your app, on every chain. A user has one wallet per enabled chain, so the same user appears once per chain. Search, filters, sorting and pagination run on the server; the cards on top count the whole set.

---

## Summary cards

| Card | What it shows |
| --- | --- |
| **Total wallets** | Every wallet of the app |
| **Active on Stellar** | Stellar wallets whose account exists on-chain |
| **Trustline coverage** | Trustlines open out of the ones expected for the enabled Stellar assets |

---

## The list

| Column | Description |
|---|---|
| **Public key** | The wallet's address with copy and explorer links (stellar.expert for Stellar, Solscan for Solana, devnet on a testnet app, Polygonscan for Polygon, Amoy on testnet), and its type: **SDK User**, or the application wallet's role (for example "Funding wallet"). A user's wallet also links to its account in [Accounts](https://docs.pollar.xyz/docs/operator-guide/users/accounts). |
| **User** | The user's name or email |
| **Network** | Stellar, Solana or Polygon. A **Rail** badge marks a rail wallet (below). |
| **Custody** | **Custodial**, **Co-signed (Turnkey)**, **External** (the user's own wallet) or **Smart wallet** (passkey) |
| **Status** | Stellar: **Active** (the account exists on-chain), **Not funded**, or **Lost** (no record on Stellar; contact support@pollar.xyz). Solana and Polygon: **Active** (holds native gas), **Sponsored** (empty, but the app sponsors its transfers) or **No gas** |
| **Tokens** | Stellar: the trustlines of the enabled assets and their state. Solana and Polygon: how many tokens the app enables on that chain (a wallet there needs nothing enabled to hold them) |
| **Balance** | Stellar: the XLM balance. Solana and Polygon: the native coin, then the balance of each enabled token |
| **Auth type** | How the user signed in (EMAIL, GOOGLE, GITHUB, WALLET, PASSKEY, OIDC, EXTERNAL) |
| **Activity** | Last login and creation time |
| **API key** | The key the wallet was created with |

Search by public key, API key or type. Filters: **Type** (SDK User / Application), **Status** (Active / Not funded / Lost), **Custody**, **Rail** and **Auth type**. **Refresh balances** reloads the on-chain reads.

On an app on [credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits), Pollar's pool pays for the app, so only the users' wallets are listed and the Type filter is hidden.

---

## Assets panel

Expanding a row shows the wallet's assets:

- **Stellar**: each enabled asset with its trustline state (Active, Removed, Not opened), balance, available amount and limit. **Enable trustline** opens a missing trustline on the user's wallet; the 0.5 XLM reserve is paid by the user's wallet, which needs at least 0.5 XLM available. Use it only with a clear product reason.
- **Solana and Polygon**: the balance of each token the app enables on that chain.

A Stellar wallet expands only once its account exists on-chain.

---

## Funding a wallet manually

A Stellar wallet that is **Not funded** (Deferred mode, or an Immediate-mode wallet whose funding did not complete) shows a **Fund** button next to its status. It creates the account exactly as the login does: the funding wallet sponsors the reserve and sends the configured starting XLM. On an app on credits, Pollar's pool sponsors it and the app's credits pay. The status flips to **Active** as soon as the account is on the ledger.

Solana and Polygon wallets have no account to create: they are topped up from the chain's GAS wallet according to [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship), and a new Solana wallet receives its starting SOL from [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding).

---

## Rail wallets

A rail wallet is a user's wallet on a chain this app does not serve. It exists for one of two reasons:

- a **ramp settled through it**: a ramp route can run a leg on another chain (Stereum, for example, settles on Polygon) and creates the user's wallet there, so an app that serves only Stellar can still have Polygon wallets for its users;
- the app **switched the chain off** after the wallets existed (see [Disabling a chain](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#disabling-a-chain)).

It belongs to the user, and nothing in your app shows it to them, so a balance there is money waiting between two steps of a ramp. Use the **Rail** filter (**Rail: all** / **Only rail** / **Hide rail**) to see them; [Accounts](https://docs.pollar.xyz/docs/operator-guide/users/accounts) also marks them. The ramp orders that moved funds through them are under [Ramps > Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders).
