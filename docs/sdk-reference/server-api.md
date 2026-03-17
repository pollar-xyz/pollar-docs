---
title: "Pollar Server API"
---

REST API for backend operations. All endpoints require your **secret key** — never call these from client-side code.

**Base URL:** `https://api.pollar.xyz`

**Authentication:**

```bash
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

---

## Wallets

### `POST /wallets/activate`

Activates a wallet by funding its XLM reserve on-chain. Used in Deferred mode when a business event occurs (KYC approved, first deposit, etc.).

This endpoint behaves like a webhook receiver — Pollar retries until it receives a `200` response.

```bash
POST https://api.pollar.xyz/wallets/activate
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "walletId": "wal_abc123"
}
```

**Response codes:**

| Code                      | Meaning                                              |
| ------------------------- | ---------------------------------------------------- |
| `200 OK`                  | Wallet activated. XLM reserve funded on-chain.       |
| `400 Bad Request`         | Missing or malformed `walletId`.                     |
| `402 Payment Required`    | Funding wallet has insufficient XLM.                 |
| `404 Not Found`           | `walletId` does not exist in your app.               |
| `409 Conflict`            | Wallet is already active. Safe to ignore.            |
| `503 Service Unavailable` | Stellar network issue. Pollar retries automatically. |

**Response body (`200`):**

```json
{
  "walletId": "wal_abc123",
  "address": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "status": "active",
  "activatedAt": "2026-03-15T10:30:00Z"
}
```

---

### `GET /wallets/:walletId`

Returns wallet details and current balances.

```bash
GET https://api.pollar.xyz/wallets/wal_abc123
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

**Response (`200`):**

```json
{
  "id": "wal_abc123",
  "address": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "status": "active",
  "balances": [
    { "asset": "XLM", "amount": "2.50" },
    { "asset": "USDC", "amount": "100.00" }
  ],
  "createdAt": "2026-03-15T10:00:00Z",
  "activatedAt": "2026-03-15T10:30:00Z"
}
```

---

### `GET /wallets/:walletId/transactions`

Returns paginated transaction history for a wallet.

```bash
GET https://api.pollar.xyz/wallets/wal_abc123/transactions?limit=20&type=payment
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

**Query parameters:**

| Parameter | Type     | Default | Description                                             |
| --------- | -------- | ------- | ------------------------------------------------------- |
| `limit`   | `number` | `20`    | Transactions per page. Max `100`.                       |
| `cursor`  | `string` | —       | Pagination cursor from previous response.               |
| `type`    | `string` | —       | Filter: `payment`, `activation`, `trustline`, `receive` |
| `asset`   | `string` | —       | Filter by asset code, e.g. `USDC`                       |
| `from`    | ISO 8601 | —       | Start date filter                                       |
| `to`      | ISO 8601 | —       | End date filter                                         |

**Response (`200`):**

```json
{
  "transactions": [
    {
      "hash": "a1b2c3d4...",
      "type": "payment",
      "asset": "USDC",
      "amount": "10.00",
      "from": "GABC...",
      "to": "GXYZ...",
      "feeSponsored": true,
      "ledger": 1234567,
      "timestamp": "2026-03-15T10:30:00Z"
    }
  ],
  "cursor": "eyJsZWRnZXIiOjEyMzQ1NjZ9",
  "hasMore": true
}
```

---

## Apps

### `GET /app`

Returns the current app configuration.

```bash
GET https://api.pollar.xyz/app
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

**Response (`200`):**

```json
{
  "id": "app_xyz789",
  "name": "My App",
  "network": "testnet",
  "fundingMode": "deferred",
  "assets": ["USDC", "EURC"],
  "createdAt": "2026-01-01T00:00:00Z"
}
```

---

## Error format

All errors follow a consistent format:

```json
{
  "error": {
    "code": "INSUFFICIENT_SPONSOR_BALANCE",
    "message": "The funding wallet does not have enough XLM to activate this wallet.",
    "status": 402
  }
}
```

For a full list of error codes see [Error Codes](./error-codes).
