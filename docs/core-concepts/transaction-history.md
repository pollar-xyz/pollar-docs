---
title: "Transaction History"
---

Pollar provides complete transaction history for every wallet through two complementary layers — one from the Stellar network and one from Pollar's own database.

---

## Two-layer architecture

```mermaid
flowchart LR
    subgraph sources["Data sources"]
        A("Stellar RPC\nLast 7 days"):::stellar
        B("Pollar PostgreSQL\nFull history"):::db
    end

    C("Pollar Server"):::server
    D("Your App\nSDK · REST API"):::app

    A -->|"recent txs"| C
    B -->|"full history"| C
    C -->|"merged, paginated"| D

    classDef stellar fill:#faeeda,stroke:#ba7517,color:#633806
    classDef db fill:#e6f1fb,stroke:#378add,color:#0c447c
    classDef server fill:#eeedfe,stroke:#7f77dd,color:#3c3489
    classDef app fill:#e1f5ee,stroke:#1d9e75,color:#085041
```

| Layer  | Source            | Retention  |
| ------ | ----------------- | ---------- |
| Recent | Stellar RPC       | 7 days     |
| Full   | Pollar PostgreSQL | Indefinite |

The Pollar Server captures every transaction at fee-bump signing time and persists it to PostgreSQL. Because Pollar processes all fee-bumps for your app, it has full visibility without indexing the entire blockchain.

> Horizon (the older Stellar API) is formally deprecated by SDF. Pollar uses Stellar RPC exclusively.

---

## SDK — React hook

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function TxHistory() {
  const { txHistory, loadingHistory, fetchMoreHistory, hasMore } = usePollar();

  return (
    <div>
      <ul>
        {txHistory.map((tx) => (
          <li key={tx.hash}>
            {tx.type === 'send' ? '↑' : '↓'} {tx.amount} {tx.asset}
            <span>{new Date(tx.timestamp).toLocaleDateString()}</span>
          </li>
        ))}
      </ul>
      {hasMore && (
        <button onClick={fetchMoreHistory} disabled={loadingHistory}>
          {loadingHistory ? 'Loading...' : 'Load more'}
        </button>
      )}
    </div>
  );
}
```

## SDK — Core client

```typescript
const { transactions, nextCursor, hasMore } = await pollar.getHistory({
  walletId: 'wal_abc123',
  limit: 20,        // default: 20, max: 100
  cursor: undefined, // pass nextCursor from previous response to paginate
});
```

---

## REST API

Available for backend use with your secret key.

```bash
GET https://api.pollar.xyz/wallets/:walletId/transactions
Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

**Query parameters:**

| Parameter | Type     | Default | Description                                   |
| --------- | -------- | ------- | --------------------------------------------- |
| `limit`   | `number` | `20`    | Transactions per page. Max `100`.             |
| `cursor`  | `string` | —       | Pagination cursor from previous response.     |
| `type`    | `string` | —       | Filter: `payment`, `activation`, `trustline`. |
| `asset`   | `string` | —       | Filter by asset code, e.g. `USDC`.            |
| `from`    | ISO 8601 | —       | Start date.                                   |
| `to`      | ISO 8601 | —       | End date.                                     |

**Response:**

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

## Pagination

Pollar uses cursor-based pagination. Cursors are stable — new transactions don't shift existing pages.

```typescript
async function getAllTransactions(walletId: string) {
  const all = [];
  let cursor: string | undefined;

  do {
    const page = await pollar.getHistory({ walletId, limit: 100, cursor });
    all.push(...page.transactions);
    cursor = page.nextCursor;
  } while (page.hasMore);

  return all;
}
```

---

## Transaction types

| Type         | Description                             |
| ------------ | --------------------------------------- |
| `payment`    | Asset transfer between wallets          |
| `activation` | Wallet funded — XLM reserve established |
| `trustline`  | Asset trustline enabled                 |
| `receive`    | Incoming payment from outside Pollar    |

---

## `TxRecord` type

```typescript
type TxRecord = {
  hash: string;
  type: 'payment' | 'activation' | 'trustline' | 'receive';
  asset: string;
  amount: string;
  from: string;
  to: string;
  feeSponsored: boolean;
  ledger: number;
  timestamp: string; // ISO 8601
};
```
