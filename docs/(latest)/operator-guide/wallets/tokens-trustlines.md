---
title: "Tokens & Trustlines"
---

**Dashboard > Wallets > Tokens & Trustlines** · Chains: Stellar, Solana, Polygon

Configure which tokens your users' wallets hold, on every chain the app enables. One table lists them all, with a filter tab per chain (**All**, **Stellar**, **Solana**, **Polygon**) once more than one chain is on.

---

## How it works

| Chain | What enabling a token does |
| --- | --- |
| **Stellar** | When a user wallet is created or activated, Pollar sets up a **trustline** for each enabled asset, sponsored by your funding wallet (0.5 XLM of reserve each, see [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding)). Users never enable assets by hand |
| **Solana** | The SPL token shows up in the user's balance, send and receive modals. Solana needs no trustline: the user's **associated token account** is created by Pollar the first time the token reaches the wallet, with the rent paid by the app |
| **Polygon** | The ERC-20 shows up in the user's modals; nothing is created on-chain |

Each enabled token also carries a **sponsor transfers** switch on the [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship) page: on Stellar a fee bump, on Solana the GAS wallet as fee payer.

---

## The table

| Column | Description |
| --- | --- |
| **Code** / **Issuer** | The token's symbol and its issuer (Stellar) or contract / mint address (Polygon, Solana) |
| **Valid** | Whether the asset checks out on-chain |
| **Wallets** | Stellar only: how many user wallets have the trustline open |
| **Balance** | Polygon and Solana: your app wallet's balance of the token |
| **Added** / **Last modified** | When the token was added and last changed |
| **Enabled** | Enabled or Disabled |

---

## Adding a token

Click **Add token** and pick the chain:

- **Stellar**: pick one of the **Recommended** assets (verified issuers, one click), or **Search on Stellar** by asset code or issuer public key and click a result.
- **Solana and Polygon**: pick one of the **Recommended tokens** curated by the platform, or **Add a custom token** by its **Mint address** (Solana) or **Contract address** (Polygon). **Read from chain** fills in the symbol, name and decimals, or you type them. Then click **Enable token**.

New accounts get the enabled tokens set up when they are created. On Stellar, existing accounts pick up an enable or disable on their next login, and each trustline operation consumes gas from the app wallet; on Solana and Polygon the token is visible immediately.

---

## Activating trustlines on existing wallets

Expanding a Stellar token's row (**Show wallets**) shows how many wallets have its trustline active, how many are inactive, and why some cannot be activated (unfunded, external, or low XLM). **Activate N trustline(s)** opens the trustline on every eligible wallet at once. Each wallet pays its own 0.5 XLM base reserve.

---

## Common assets on Stellar

| Asset | Issuer                                                     |
| ----- | ---------------------------------------------------------- |
| USDC  | `GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN` |
| EURC  | `GDHU6WRG4IEQXM5NZ4BMPKOXHW76MZM4Y2IEMFDVXBSDP6SJY4ITNPP`  |
| AQUA  | `GBNZILSTVQZ4R7IKQDGHYGY2QXL5QOFJYQMXPKWRRM5PAV7Y4M67AQUA` |

Always verify issuer addresses from the official asset issuer before adding.

---

## Common tokens on Solana

| Token | Mint (mainnet-beta) |
| ----- | ------------------- |
| USDC  | `EPjFWdd5AufqSSqeM3qQw8xJXpY4zFrPyLKS3jcKBVMy` |
| USDT  | `Es9vMFrzaCETj8uUkUHdrK1xHGdmsAiRd9yiirtm3fab` |

On devnet, Circle's USDC mint is `4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU`; the SDK's balance modal links to Circle's faucet for it.

---

## Removing a token

Removing a token from the list stops it from being added to new wallets and hides it from the user's modals. On Stellar, existing trustlines on active wallets are not removed: trustlines can only be removed by the wallet owner. On Solana, existing token accounts and their balances stay on-chain.
