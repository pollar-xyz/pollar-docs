---
title: "Auth Policy"
---

**Dashboard → Treasury → Auth Policy**

Control which Soroban contracts a custodial wallet may **authorize**. This is the signing allowlist for Soroban authorization entries.

When your own contract sponsors gas and settles a transfer, the user signs only an authorization entry — Pollar signs it **only if every contract and function in it is allowlisted here**. A custodial wallet refuses to sign an authorization entry that touches any contract or function not on the list; that is what prevents the signer from being used to drain a user's funds.

---

## Contract allowlist

Each row allowlists **one contract** and the **exact functions** a custodial wallet may authorize on it.

Include every contract in the call tree — your settlement contract and anything it sub-invokes (e.g. the AMM, the token). For each row you provide:

- **Contract** — the Soroban contract id.
- **Functions** — the specific function names allowed (e.g. `settle, swap`).
- **Label** — an optional human-readable name (e.g. `RouterV1 settlement`).

---

## Allow any (bypass)

An **allow-any** switch bypasses the allowlist entirely — every contract and function is authorized and the list below is ignored. Use only if you fully control transaction construction; an explicit allowlist is strongly preferred.
