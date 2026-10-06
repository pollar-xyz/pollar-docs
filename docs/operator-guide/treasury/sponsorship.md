---
title: "Sponsorship"
---

**Dashboard > Treasury > Sponsorship**

Sponsorship decides which on-chain costs your app pays for its users, so a user wallet can hold tokens and move them with no XLM of its own. Every rule is evaluated server-side by Pollar on the signed transaction. The client SDK cannot widen it.

There are two mechanisms, and which one applies depends on the cost being covered:

| Mechanism | Covers | Used for |
|---|---|---|
| **Fee bump** | The network fee only | Token transfers, swaps, contract calls |
| **Sponsor as source** | The network fee and the 0.5 XLM reserve of a new ledger entry | Trustlines, account creation, signer rotation |

---

## Which wallet pays

| Cost | Paid by |
|---|---|
| Network fees (fee bumps and sponsored trustlines) | The **GAS** wallet, or **GLOBAL** if the app has not been split |
| Reserves (trustlines, account creation) | The **FUNDING** wallet, or **GLOBAL** if the app has not been split |

Keep the paying wallets funded with XLM. When a fee bump cannot be paid, the transaction is not rejected: it is submitted unsponsored and the user pays (see [When sponsorship does not apply](#when-sponsorship-does-not-apply)).

---

## How a fee bump works

A Stellar [fee bump](https://developers.stellar.org/docs/learn/encyclopedia/transactions-specialized/fee-bump-transactions) is an outer envelope that wraps a transaction someone else already signed and replaces who pays its fee. The flow is:

1. Your app builds the transaction with the **user's wallet as the source** (`buildTx`, or `POST /tx/build`).
2. The user signs it. For a custodial wallet Pollar signs with the user's key; for an external wallet the user's own wallet or adapter signs it on their device.
3. Pollar checks the signed transaction against your sponsorship rules. If it qualifies, Pollar wraps it in a fee-bump envelope whose fee source is your GAS wallet, signs only that outer envelope, and broadcasts it.

What follows from this design:

- **It works for external wallets.** Pollar never needs the user's key. The user's signature stays on the inner transaction untouched. External wallets are only covered when you turn on **Include external wallets** for that kind of transaction (see below).
- **The user's sequence number is used, not the sponsor's.** Many users can be sponsored at the same time without racing each other on the GAS wallet.
- **It pays the fee, not reserves.** A fee bump cannot cover a new trustline or a new account. Those use the sponsor-as-source mechanism.
- **The on-chain hash is the outer envelope's hash.** Transaction history records the transaction as sponsored, together with that fee-bump hash.

### Where the fee bump is applied

| Endpoint / SDK call | Wallet type | Fee bump |
|---|---|---|
| `POST /tx/submit` (`submitTx`) | Custodial and external | Applied when the signed transaction qualifies |
| `POST /tx/sign` (`signTx`) | Custodial | Applied by default, so a caller that broadcasts the returned `signedXdr` itself still gets it. Pass `skipSponsorship: true` to get the plain signed transaction |
| `POST /tx/sign-and-send` (`signAndSubmitTx`) | Custodial | Applied when the transaction qualifies |

External wallets sign on the client, so for them the decision always happens at `POST /tx/submit`. `signAndSubmitTx` with an external wallet signs through the adapter and then calls `submitTx`, so no extra code is needed.

### Fee limits

The fee-bump fee follows the inner transaction's fee rate: `ceil(inner fee / operations) x (operations + 1)` stroops. It is capped by **Max fee (XLM)** in [Transaction Policy](https://docs.pollar.xyz/docs/operator-guide/treasury/transaction-policy), or 10 XLM when that is unset. Before signing, Pollar also re-checks the inner transaction against the transaction policy (operation count, blocked operations, enabled assets).

---

## What can be sponsored

A transaction is fee-bumped only when **all** of these hold:

- The transaction source is the user's wallet.
- It has **exactly one operation**, and that operation has no source of its own (or the source is the user's wallet).
- The operation matches one of the enabled rules below.

The single-operation limit is deliberate. Otherwise a client could attach extra operations to a sponsored one and have your GAS wallet pay for all of them.

| Kind | Operation that qualifies | Turned on in | External wallets |
|---|---|---|---|
| **Token transfer** | `payment` of a non-native token selected under **Token transfer sponsorship** | Token transfer sponsorship | Off by default |
| **Swap (SDEX)** | `pathPaymentStrictSend` whose destination is the user's own wallet, with SDEX enabled | Swap sponsorship | Off by default |
| **Swap (Soroban)** | `invokeHostFunction` on the Aquarius router or the Soroswap aggregator, with that venue enabled | Swap sponsorship | Off by default |
| **Contract call** | `invokeHostFunction` on a contract and method listed in a contract rule, or on any contract when **Sponsor all contracts** is on | Contract sponsorship rules | Off by default |

Not sponsored by a fee bump:

- Payments in **native XLM**. A user who sends XLM already holds XLM to pay the fee.
- Transactions with **more than one operation**.
- Any other operation type (`setOptions`, `manageSellOffer`, `pathPaymentStrictReceive`, `accountMerge`, and so on). A signer rotation is sponsored through its own setting below, not by a fee bump.
- Path payments sent to another account. A swap is a strict-send path payment back to the user's own wallet; paying someone else is not a swap.

---

## Settings

Each card has an **Include external wallets** sub-option. It appears once the card sponsors something (the toggle is on, or a venue, rule or token is selected), since before that there is nothing to extend.

### Trustline sponsorship

**Sponsor trustlines** (on by default): when a user adds a trustline for a token enabled under Tokens & Trustlines, the FUNDING wallet pays the 0.5 XLM reserve and the GAS wallet pays the fee. When off, each wallet pays its own reserve and fee.

**Include external wallets** (on by default): applies the same to wallets Pollar does not custody. For those, `POST /wallet/assets/trustline/build` returns a transaction already signed by the sponsor. The user adds their signature and submits it with `POST /tx/submit`. When sponsoring does not apply, the same endpoint returns a plain unsigned `change_trust` that the user pays for, so the client always calls one endpoint.

### Swap sponsorship

Pick the venues (SDEX, Soroswap, Aquarius) whose swaps your app pays the fee for. Only venues enabled under [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap) appear. **Include external wallets** extends it to wallets Pollar does not custody.

### Contract sponsorship rules

Each rule whitelists a Soroban contract and the exact methods your app pays the fee for. **Sponsor all contracts** covers every contract call on any contract and method, and the individual rules are ignored while it is on. **Include external wallets** extends it to wallets Pollar does not custody.

Because a fee-bumped user is the transaction source, a contract's `require_auth` for the user is satisfied by the source-account signature. No separate authorization entry needs to be signed.

### Signer rotation

For account recovery of wallets Pollar does not custody: the user adds a new signer to their wallet and disables the old key (`setOptions`), keeping the same `G...` address. **Sponsor signer rotations** (off by default) lets your app pay for it. Each new signer is a ledger subentry with a 0.5 XLM reserve, so this uses the sponsor-as-source mechanism, not a fee bump: the FUNDING (or GLOBAL) wallet is the transaction source and pays both the reserve and the fee.

Rotation exists only for wallets Pollar does not custody, so turn on both **Sponsor signer rotations** and its sub-option **Include external wallets**. Even then the settings alone sponsor nothing: a user is covered only while they hold a **grant**, which you give on request:

- From **Users > Accounts**: while both settings are on, the row menu of a user with an external wallet shows **Allow sponsored signer rotation**.
- From your backend: `POST /v1/wallets/{publicKey}/signer-rotation` in the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api).

A grant covers **one** rotation and is spent when that rotation lands on-chain. A later recovery needs a new grant. You can revoke an unspent grant from the same menu or with `DELETE` on the same endpoint.

Signer changes on **custodial** wallets are never allowed: a new signer would take the wallet out of Pollar's custody. How the client builds a rotation is in [Rotate the wallet signer](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter#rotate-the-wallet-signer).

### Token transfer sponsorship

Pick which enabled tokens are sponsored when a user sends them. Only tokens enabled under [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/treasury/tokens-trustlines) appear. **Include external wallets** extends it to wallets Pollar does not custody.

---

## When sponsorship does not apply

Sponsorship never fails a transaction. If the signed transaction does not qualify, or the fee bump itself cannot be produced (no GAS or GLOBAL wallet, fee above the cap, policy check failed), Pollar submits the user's own envelope unchanged and the **user pays the fee**. A user with no XLM then gets `tx_insufficient_balance` from the network.

If you expected a transaction to be sponsored and it was not, check in this order:

1. The operation is in the [What can be sponsored](#what-can-be-sponsored) table, and the transaction has exactly one operation.
2. The matching setting is on: the token is selected, the venue is enabled, or the contract and method are listed.
3. For an external wallet, **Include external wallets** is on for that kind of transaction.
4. The GAS (or GLOBAL) wallet holds enough XLM.

---

## Fee bumps you build yourself

`POST /tx/submit` also accepts a fee-bump envelope your app built and signed with a wallet of its own, and broadcasts it as is. The inner transaction must be sourced by the wallet that is submitting it. Otherwise the request is rejected with `403 FORBIDDEN`. Transaction history records which account paid the fee, so a fee your app paid from its own wallet shows up separately from one Pollar sponsored.
