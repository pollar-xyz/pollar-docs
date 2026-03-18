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
| **Deferred**  | \~2 XLM per activation only | Webhook from your backend | Neobanks, remittance apps, KYC-gated products |

In both modes, any individual wallet can also be activated manually from **Dashboard → Wallet Infrastructure → Wallets → Activate**. This is useful as a fallback or for support workflows.

---

## Immediate

The wallet is funded atomically at the moment the user logs in. Ready in under 3 seconds. No additional setup required.

---

## Deferred

The G-address is created on-chain at registration but without an XLM reserve. Activation happens when your backend calls `POST /wallets/activate` after a business event occurs (KYC approved, first deposit, etc.). See [Deferred Flow Guide](../../guides/deferred-flow-guide) for the full setup.