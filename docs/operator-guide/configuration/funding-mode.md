---
title: "Funding Mode"
---

**Dashboard → Configuration → Funding Mode**

Controls when new user wallets are funded with their XLM reserve. Switch modes at any time without code changes — the new mode applies to all wallets created after the switch.

---

## Modes

| Mode          | Cost                        | Activation trigger                                    | Best for                                      |
| ------------- | --------------------------- | ----------------------------------------------------- | --------------------------------------------- |
| **Immediate** | \~2 XLM per registration    | Automatic on login                                    | Apps without compliance requirements          |
| **Deferred**  | \~2 XLM per activation only | Webhook from your backend, or manually from Dashboard | Neobanks, remittance apps, KYC-gated products |
| **Manual**    | \~2 XLM per activation only | Dashboard only                                        | Testing, ops workflows                        |

---

## Immediate

The wallet is funded atomically at the moment the user logs in. Ready in under 3 seconds. No additional setup required.

---

## Deferred

The G-address is created on-chain at registration but without an XLM reserve. Activation happens in one of two ways:

**Webhook from your backend** — your backend calls `POST /wallets/activate` when a business event occurs (KYC approved, first deposit, etc.). See [Deferred Flow Guide](../../guides/deferred-flow-guide) for the full setup.

**Manually from Dashboard** — navigate to **Dashboard → Wallet Infrastructure → Wallets**, find the user, and click **Activate**.

---

## Manual

Identical to Deferred but without webhook support. Activation is done exclusively from **Dashboard → Wallet Infrastructure → Wallets → Activate**. No backend integration required.
