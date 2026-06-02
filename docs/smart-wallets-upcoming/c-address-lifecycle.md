---
title: "How the C-Address Lifecycle Works"
---

> 🚧 **Upcoming — not yet available.** Smart wallets are not implemented in the current SDK yet. This page is a technical explainer of the planned design. See the [section overview](./overview) for status.

Pollar gives you the same simple `login()` call whether a user gets a classic account or a
smart wallet. This page explains what happens underneath for **C-addresses** — useful when
you're debugging, surfacing progress in your UI, or reasoning about costs.

## G-address vs C-address at a glance

A **G-address** is a classic Stellar account controlled by an ed25519 keypair. A **C-address**
is a smart contract deployed on Soroban that *acts as an account* — its authorization logic
lives in code rather than in a fixed signature scheme.

| Aspect           | G-address (classic)       | C-address (smart wallet)               |
|------------------|---------------------------|----------------------------------------|
| Identifier       | Starts with `G`           | Starts with `C`                        |
| Authorization    | Native ed25519 signature  | `__check_auth` in the contract         |
| Creation         | `createAccount` operation | `InvokeHostFunction` (contract deploy) |
| Holding an asset | `changeTrust` trustline   | SAC balance (no classic trustline)     |
| Keeping it alive | XLM reserve               | Storage rent + TTL                     |
| Fees             | XLM or fee-bump           | Fee-bump (same mechanism)              |
| Flexibility      | Fixed (ed25519 only)      | Programmable auth                      |

## The lifecycle

Pollar models a smart wallet as a small state machine. `login()` walks the user through it
automatically; you can observe each transition via the `walletProgress` event.

```
unregistered ──deploy──▶ deployed ──sponsor──▶ sponsored ──▶ payment_ready
                                                                  │
                                                          (TTL expires)
                                                                  ▼
                                                              archived ──restore──▶ sponsored
```

| State           | What it means                                                   |
|-----------------|-----------------------------------------------------------------|
| `unregistered`  | The user exists in your backend but has no contract yet         |
| `deploying`     | Deploy transaction submitted, awaiting confirmation             |
| `deployed`      | Contract is on-chain; the C-address exists and the owner is set |
| `sponsoring`    | Pollar is paying storage rent and extending the TTL             |
| `sponsored`     | Rent covered, TTL extended                                      |
| `payment_ready` | The wallet can send and receive assets                          |
| `archived`      | The TTL expired and the contract was archived; needs a restore  |

### Deploy

Creating a classic account is a single `createAccount` operation. Creating a C-address means
deploying a contract: Pollar submits an `InvokeHostFunction` transaction that instantiates the
smart wallet contract with the user's public key as the authorized owner. The contract's
constructor runs atomically during deploy, so there's no separate "initialize" step exposed to
you. The resulting contract ID *is* the C-address.

### Sponsorship: rent instead of reserve

This is the biggest conceptual difference, and Pollar hides most of it.

- **G-address:** Stellar requires a base XLM reserve (plus more per trustline). It's paid once
  and recovered if the account closes.
- **C-address:** There is no XLM reserve in the classic sense. Instead, every entry in the
  contract's storage has a **TTL (time-to-live)**. If the TTL lapses, the entry is archived and
  must be restored before use. Pollar extends the TTL on the user's behalf so the wallet stays
  live.

The practical implication: instead of a one-time reserve, there's a small *recurring* cost to
keep a smart wallet alive. Pollar's sponsor account handles TTL extension automatically as part
of reaching `payment_ready`.

### Holding assets: the SAC

C-addresses don't use classic trustlines. They interact with assets through the **Stellar Asset
Contract (SAC)** — a built-in contract that wraps each classic Stellar asset. A C-address can
receive a SAC-wrapped asset without an explicit trustline step (provided the issuer isn't gating
with authorization flags). Pollar routes payments through the SAC for you, so `pay()` looks
identical to the classic flow from your side.

### Signing: full transaction vs auth entries

For G-addresses, the user's key signs the full transaction, which Pollar then wraps in a
fee-bump. For C-addresses the signing model changes:

1. Pollar builds the contract invocation.
2. It simulates the transaction to discover which **auth entries** need signatures.
3. The user's KMS-managed key signs only those auth entries — the contract's `__check_auth`
   verifies them.
4. Pollar reassembles the transaction with the signed auth entries.
5. Pollar's sponsor account signs the envelope as the fee source and submits it.

You don't implement any of this — it's what `login()` and `pay()` do internally — but it's why
smart wallet transactions are contract invocations rather than classic payment ops.

## How Pollar abstracts all of this

| You write              | Pollar handles                                            |
|------------------------|-----------------------------------------------------------|
| `walletType: 'smart'`  | Choosing the deploy + sponsor + SAC path                  |
| `login()`              | Deploy, TTL extension, reaching `payment_ready`           |
| `pay()`                | Building the SAC invocation, auth-entry signing, fee-bump |
| `walletProgress` event | Surfacing each lifecycle transition and tx hash           |

The goal is that adopting smart wallets is a configuration choice, not a rewrite. The
differences above matter for debugging and cost modeling, but not for day-to-day integration.

## Cost considerations

On testnet, rent and fees are effectively free. On mainnet, each smart wallet carries a small
recurring cost to keep its storage TTL extended — this replaces the one-time XLM reserve of the
classic model. Pollar's sponsor account covers it automatically; account for it when estimating
per-user costs at scale.

## References

- [Contract accounts overview](https://developers.stellar.org/docs/build/guides/contract-accounts)
- [Smart wallets guide](https://developers.stellar.org/docs/build/guides/contract-accounts/smart-wallets)
- [Signing Soroban invocations](https://developers.stellar.org/docs/build/guides/transactions/signing-soroban-invocations)
- [Stellar Asset Contract (SAC)](https://developers.stellar.org/docs/tokens/stellar-asset-contract)
- [State archival (TTL / rent)](https://developers.stellar.org/docs/build/guides/archival)

## Next steps

- [C-Address Quickstart](./quickstart-c-address.md)
- [Migrating from G-Addresses](./migration-g-to-c.md)
