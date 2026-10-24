---
title: "Stellar Primitives"
---

Pollar is built on top of specific Stellar protocol features. You don't need to know Stellar deeply to use Pollar, but understanding these primitives helps you make better decisions about funding modes, security, and fiat ramps.

---

## Account model

Stellar accounts are identified by a **G-address** (a public key starting with `G`). Every account must hold a minimum **XLM reserve** to exist on-chain: currently 1 XLM base reserve plus 0.5 XLM per entry (trustlines, offers, and so on).

This is different from EVM chains, where an address exists as soon as someone sends funds to it.

**What Pollar does:** Creates the G-address for your user and sponsors the XLM reserve on their behalf, so users never need to know what a reserve is or where to get XLM. The reserve comes from your app's funding wallet, or from Pollar's pool on an [app on credits](https://docs.pollar.xyz/docs/core-concepts/credits).

---

## Fee-bump transactions

Every Stellar transaction requires a small XLM fee paid by the submitter. Without fee-bumps, users would need XLM before they can do anything, a problem for new users who have never held crypto.

Fee-bump transactions solve this: a third party (the sponsor) wraps the user's transaction and pays the fee on their behalf. The user's transaction is valid, the sponsor pays, and the user needs zero XLM.

**What Pollar does:** Transactions submitted through the SDK are wrapped in a fee-bump when your app's **Sponsorship** settings cover them. The fee is paid from your app's gas wallet, or from Pollar's pool on an app on credits.

```
User transaction (inner tx)
└── Fee-bump wrapper (outer tx)
    └── Signed by Pollar sponsor
    └── Fee paid from your gas wallet (or Pollar's pool)
```

---

## Account sponsorship

Beyond fee-bumps, Stellar has a native sponsorship model for account reserves. A sponsor can cover the XLM reserve of another account using `beginSponsoringFutureReserves` / `endSponsoringFutureReserves`.

This is how Pollar activates a wallet, at login in Immediate mode or later in Deferred mode: until then the G-address is only an address, with no account on-chain. Activation creates the account and its trustlines in one sponsored transaction.

```
beginSponsoringFutureReserves(userAddress)
  createAccount(userAddress, startingBalance)   // the app's starting balance, 0 by default
  changeTrust(USDC, source: userAddress)
endSponsoringFutureReserves(source: userAddress)
```

If any operation fails, the entire transaction reverts: no partial states.

---

## Trustlines

In Stellar, an account must explicitly opt in to hold an asset by creating a **trustline**. Without a trustline for USDC, an account cannot receive or hold it.

**What Pollar does:** Enables trustlines for the assets configured in your dashboard at wallet creation or activation, with the reserve sponsored. If no assets are configured, no trustlines are set up. On a Pollar-managed wallet this happens without a prompt; on a co-signed or self-custody wallet each trustline is a request the user approves.

---

## SEP-10: Stellar Web Authentication

SEP-10 is a Stellar standard for authenticating ownership of a Stellar account using a challenge-response mechanism: no passwords, no email, just a signed Stellar transaction.

**What Pollar uses it for:** Signing users in with an external Stellar wallet: the SDK has the wallet sign a challenge that proves it owns the account. Pollar also answers an anchor's SEP-10 challenge for a ramp that needs one. (The dashboard itself signs operators in with an email code or Google, not SEP-10.)

---

## SEP-24: Hosted Deposit and Withdrawal

SEP-24 is a Stellar standard for fiat on/off-ramps. It defines a protocol between a wallet app and an **anchor** (a licensed financial institution) for depositing and withdrawing fiat currency in exchange for Stellar assets like USDC.

**What Pollar uses it for:** Ramps through a SEP-24 anchor (Anclap). The anchor's flow opens as a hosted route of a ramp order, where the user picks the payment method inside the anchor's own page. Enable the provider under **Ramps > Providers**; see [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps).

---

## SEP-7: Payment Request URIs `coming soon`

SEP-7 defines a URI scheme for Stellar payment requests, similar to Bitcoin's `bitcoin:` URIs. A SEP-7 URI encodes destination, asset, amount, and memo so any compatible wallet can pre-fill a payment form by scanning a QR code or opening a link.

**What Pollar will use it for:** The receive flow: QR codes and shareable payment links that work with any SEP-7 compatible Stellar wallet.

---

## Quick reference

| Primitive | Used in Pollar for |
|---|---|
| G-address + XLM reserve | Wallet creation, funding modes |
| Fee-bump transactions | Gas sponsorship: users pay zero XLM |
| Account sponsorship | Wallet activation in both funding modes |
| Trustlines | Automatic asset enablement on activation |
| SEP-10 | External Stellar wallet login, anchor authentication |
| SEP-24 | Ramps through a SEP-24 anchor |
| SEP-7 | Receive QR codes and payment links (`coming soon`) |