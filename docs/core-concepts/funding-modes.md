---
title: "Funding Modes"
---

Every Stellar account requires a minimum XLM reserve to exist on-chain. Pollar gives you three modes to control exactly when that reserve is funded — so you only pay for users who matter to your app.

Configure the funding mode from **Dashboard → Settings → Funding Mode**. No code changes required.

---

## The three modes

```mermaid
flowchart TD
    A("User registers"):::neutral
    A --> B{"Funding mode"}:::decision
    B -->|"Immediate"| C("Wallet funded on registration\n~1 XLM charged immediately"):::immediate
    B -->|"Deferred"| D("G-address created, no reserve\nFunded automatically via webhook\nor manually from Dashboard"):::deferred
    B -->|"Manual"| E("G-address created, no reserve\nFunded only from Dashboard"):::manual

    classDef neutral fill:#f1efe8,stroke:#b4b2a9,color:#444441
    classDef decision fill:#faeeda,stroke:#ba7517,color:#633806
    classDef immediate fill:#eaf3de,stroke:#639922,color:#3b6d11
    classDef deferred fill:#eeedfe,stroke:#7f77dd,color:#3c3489
    classDef manual fill:#e6f1fb,stroke:#378add,color:#0c447c
```

| Mode | XLM cost | Activation trigger | Best for |
|---|---|---|---|
| **Immediate** | ~2 XLM per registration | Automatic on login | Apps without compliance requirements |
| **Deferred** | ~2 XLM per activation only | Webhook from your backend, or manually from Dashboard | Neobanks, remittance apps, KYC-gated products |
| **Manual** | ~2 XLM per activation only | Dashboard only | Testing, ops workflows, custom flows |

> **How the ~2 XLM is calculated:** Every Stellar account requires a base reserve of **1 XLM**. Each trustline (asset) you configure in the Dashboard adds **0.5 XLM**:
>
> `1 XLM + (number of configured assets × 0.5 XLM)`
>
> | Assets configured | Reserve required |
> |---|---|
> | 0 | 1 XLM |
> | 1 (e.g. USDC) | 1.5 XLM |
> | 2 (e.g. USDC + EURC) | 2 XLM |
> | 3 | 2.5 XLM |
>
> Pollar does not charge extra — the full amount is consumed from your funding wallet.
>
> References: [Minimum Balance](https://developers.stellar.org/docs/learn/fundamentals/lumens#minimum-balance) · [Trustlines](https://developers.stellar.org/docs/learn/fundamentals/stellar-data-structures/accounts#trustlines)

---

## Immediate

The wallet is funded atomically at the moment the user logs in. Ready in under 3 seconds.

**Cost:** ~2 XLM per registration, including users who abandon onboarding.

```tsx
const { login, wallet } = usePollar();
await login({ provider: 'google' });
// wallet is funded and ready immediately
```

---

## Deferred

The G-address is created on-chain at registration but without an XLM reserve. The wallet exists but cannot transact until it is activated.

**Cost:** ~2 XLM only for users who complete activation. Zero cost for users who abandon.

This mode solves a problem unique to Stellar: every account needs a minimum XLM reserve to exist on-chain. Without deferred funding, an app with 10,000 users who abandon onboarding burns 10,000 XLM for nothing.

Activation can happen in two ways:

### Option A — Webhook from your backend

Your backend calls `POST /activate` when a business event occurs (KYC approved, first deposit, etc.). The Pollar Server activates the wallet and funds the XLM reserve.

```bash
POST https://api.pollar.xyz/wallets/activate
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "walletId": "wal_abc123"
}
```

This endpoint behaves like a webhook — the Pollar Server retries until it receives a `200` response.

> Never call `POST /activate` from the client. It requires your secret key and must run on your backend.

**Response codes:**

| Code | Meaning |
|---|---|
| `200 OK` | Wallet activated. XLM reserve funded on-chain. |
| `400 Bad Request` | Missing or malformed `walletId`. |
| `402 Payment Required` | Funding wallet has insufficient XLM. |
| `404 Not Found` | `walletId` does not exist in your app. |
| `409 Conflict` | Wallet is already active. Safe to ignore. |
| `503 Service Unavailable` | Stellar network issue. Pollar retries automatically. |

### Option B — Manual activation from Dashboard

Navigate to **Dashboard → Wallets**, find the user, and click **Activate**. Useful as a fallback or for support workflows.

### Checking wallet status

```tsx
const { wallet } = usePollar();

if (wallet?.status === 'pending') {
  // wallet exists but is not yet funded — show KYC flow
}

if (wallet?.status === 'active') {
  // wallet is funded and ready to transact
}
```

---

## Manual

The G-address is created at registration with no reserve — identical to Deferred. The difference is that there is no webhook integration. Activation is done exclusively from the Dashboard.

**Use when:** you are testing, running an ops workflow, or activating wallets based on criteria that don't map to an automated event in your backend.

---

## Switching modes

You can switch funding modes at any time from the Dashboard without changing any code. The new mode applies to all wallets created after the switch. Existing wallets are not affected.

---

## Cost comparison

For an app with 10,000 registered users where 30% complete activation:

| Mode | XLM spent | Cost basis |
|---|---|---|
| Immediate | ~20,000 XLM | Every registration |
| Deferred / Manual | ~6,000 XLM | Only activated users |
| **Savings** | **~14,000 XLM** | |

The Dashboard shows a real-time cost breakdown per mode so you can optimize as your app grows.