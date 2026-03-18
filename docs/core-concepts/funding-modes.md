---
title: "Funding Modes"
---

Every Stellar account requires a minimum XLM reserve to exist on-chain. Pollar gives you two modes to control exactly when that reserve is funded — so you only pay for users who matter to your app.

Configure the funding mode from **Dashboard → Configuration → Funding Mode**. No code changes required.

---

## The two modes

```mermaid
flowchart TD
    A("User registers"):::neutral
    A --> B{"Funding mode"}:::decision
    B -->|"Immediate"| C("Wallet funded on registration\n~2 XLM charged at login"):::immediate
    B -->|"Deferred"| D("G-address created, no reserve\nActivated via webhook from your backend"):::deferred
    C --> E("Wallet ready"):::ready
    D --> F("Wallet pending"):::pending
    F -->|"POST /activate\nor Dashboard button"| E

    classDef neutral fill:#f1efe8,stroke:#b4b2a9,color:#444441
    classDef decision fill:#faeeda,stroke:#ba7517,color:#633806
    classDef immediate fill:#eaf3de,stroke:#639922,color:#3b6d11
    classDef deferred fill:#eeedfe,stroke:#7f77dd,color:#3c3489
    classDef ready fill:#eaf3de,stroke:#639922,color:#3b6d11
    classDef pending fill:#e6f1fb,stroke:#378add,color:#0c447c
```

| Mode          | XLM cost                    | Activation trigger        | Best for                                      |
| ------------- | --------------------------- | ------------------------- | --------------------------------------------- |
| **Immediate** | \~2 XLM per registration    | Automatic on login        | Apps without compliance requirements          |
| **Deferred**  | \~2 XLM per activation only | Webhook from your backend | Neobanks, remittance apps, KYC-gated products |

In both modes, any individual wallet can also be activated manually from **Dashboard → Wallet Infrastructure → Wallets → Activate**. This is useful as a fallback or for support workflows.

> **How the \~2 XLM is calculated:** Every Stellar account requires a base reserve of **1 XLM**. Each trustline (asset) you configure in the Dashboard adds **0.5 XLM**:
>
> `1 XLM + (number of configured assets × 0.5 XLM)`
>
> | Assets configured    | Reserve required |
> | -------------------- | ---------------- |
> | 0                    | 1 XLM            |
> | 1 (e.g. USDC)        | 1.5 XLM          |
> | 2 (e.g. USDC + EURC) | 2 XLM            |
> | 3                    | 2.5 XLM          |
>
> Pollar does not charge extra — the full amount is consumed from your funding wallet.
>
> References: [Minimum Balance](https://developers.stellar.org/docs/learn/fundamentals/lumens#minimum-balance) · [Trustlines](https://developers.stellar.org/docs/learn/fundamentals/stellar-data-structures/accounts#trustlines)

---

## Immediate

The wallet is funded atomically at the moment the user logs in. Ready in under 3 seconds. No additional setup required.

**Cost:** \~2 XLM per registration, including users who abandon onboarding.

```tsx
const { login, wallet } = usePollar();
await login({ provider: 'google' });
// wallet is funded and ready immediately
```

---

## Deferred

The G-address is created on-chain at registration but without an XLM reserve. The wallet exists but cannot transact until it is activated.

**Cost:** \~2 XLM only for users who complete activation. Zero cost for users who abandon.

This mode solves a problem unique to Stellar: every account needs a minimum XLM reserve to exist on-chain. Without deferred funding, an app with 10,000 users who abandon onboarding burns 20,000 XLM for nothing.

### Activating via webhook

Your backend calls `POST /activate` when a business event occurs — KYC approved, first deposit, email verified, or any trigger you define.

```bash
POST https://api.pollar.xyz/wallets/activate
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "walletId": "wal_abc123"
}
```

The Pollar Server retries until it receives a `200` response.

> Never call `POST /activate` from the client. It requires your secret key and must run on your backend.

**Response codes:**

| Code                      | Meaning                                              |
| ------------------------- | ---------------------------------------------------- |
| `200 OK`                  | Wallet activated. XLM reserve funded on-chain.       |
| `400 Bad Request`         | Missing or malformed `walletId`.                     |
| `402 Payment Required`    | Funding wallet has insufficient XLM.                 |
| `404 Not Found`           | `walletId` does not exist in your app.               |
| `409 Conflict`            | Wallet is already active. Safe to ignore.            |
| `503 Service Unavailable` | Stellar network issue. Pollar retries automatically. |

### Activating manually from the Dashboard

Any wallet in `pending` status can be activated from **Dashboard → Wallet Infrastructure → Wallets → Activate**. This works in both Immediate and Deferred mode and is useful for support workflows or one-off overrides.

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

## Switching modes

You can switch funding modes at any time from the Dashboard without changing any code. The new mode applies to all wallets created after the switch. Existing wallets are not affected.

---

## Cost comparison

For an app with 10,000 registered users where 30% complete activation:

| Mode        | XLM spent        | Cost basis           |
| ----------- | ---------------- | -------------------- |
| Immediate   | \~20,000 XLM     | Every registration   |
| Deferred    | \~6,000 XLM      | Only activated users |
| **Savings** | **\~14,000 XLM** | <br />               |

The Dashboard shows a real-time cost breakdown per mode so you can optimize as your app grows.
