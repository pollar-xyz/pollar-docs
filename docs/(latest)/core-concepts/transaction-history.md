---
title: "Transaction History"
---

Pollar keeps the transaction history of every wallet in its own database. It does not read history from the chain at request time and does not index the whole blockchain.

---

## Where history comes from

```mermaid
flowchart LR
    A("Every transaction Pollar builds,\nsigns, sponsors or submits"):::stellar
    B("Pollar PostgreSQL\ntx_records"):::db
    C("Pollar Server"):::server
    D("Your App\nSDK, REST API"):::app

    A -->|"recorded"| B
    B -->|"paginated"| C
    C --> D

    classDef stellar fill:#faeeda,stroke:#ba7517,color:#633806
    classDef db fill:#e6f1fb,stroke:#378add,color:#0c447c
    classDef server fill:#eeedfe,stroke:#7f77dd,color:#3c3489
    classDef app fill:#e1f5ee,stroke:#1d9e75,color:#085041
```

Pollar records a transaction when it handles it, on every chain: Stellar fee-bumps and sponsored operations, Solana and Polygon transfers, co-signed requests and ramp legs. A background reconcile then follows each record until the chain settles it. Transaction records are kept for at least 5 years, the period anti-money-laundering rules require for transaction records.

A transaction an external wallet submits on its own, without going through Pollar, does not appear in the history.

---

## SDK: React hook

`txHistory` is a reactive state machine (`TxHistoryState`). Trigger a load with `fetchTxHistory()` on the underlying client; the provider keeps `txHistory` in sync.

```tsx
'use client';
import { useEffect } from 'react';
import { usePollar } from '@pollar/react';

export function TxHistory() {
  const { txHistory, getClient } = usePollar();

  useEffect(() => {
    getClient().fetchTxHistory({ limit: 20, offset: 0 });
  }, [getClient]);

  if (txHistory.step !== 'loaded') return <p>Loading...</p>;

  return (
    <ul>
      {txHistory.data.records.map((tx) => (
        <li key={tx.id}>
          {tx.summary} · {tx.status} · {new Date(tx.createdAt).toLocaleDateString()}
        </li>
      ))}
    </ul>
  );
}
```

> The simplest path is the built-in modal: call `openTxHistoryModal()` from `usePollar()`.

## SDK: Core client

```typescript
await pollar.fetchTxHistory({ limit: 20, offset: 0 });

const state = pollar.getTxHistoryState();
if (state.step === 'loaded') {
  console.log(state.data.records, state.data.total);
}
```

`fetchTxHistory` drives `TxHistoryState` (it does not return the records directly). Subscribe with `onTxHistoryStateChange` for updates.

---

## REST API

The end-user transaction history is served by the SDK API (publishable key + authenticated end-user session), not by the secret-key Server API:

```bash
GET https://sdk.api.pollar.xyz/v3/tx/history?limit=20&offset=0
```

> There is currently **no secret-key Server API endpoint** for wallet transaction history. Use the SDK (`fetchTxHistory`) from an authenticated session.

**Query parameters:**

| Parameter | Type     | Default | Description                          |
| --------- | -------- | ------- | ------------------------------------ |
| `limit`   | `number` | `20`    | Records per page, 1 to 50.           |
| `offset`  | `number` | `0`     | Offset for pagination.               |
| `chain`   | `'STELLAR' \| 'SOLANA' \| 'POLYGON'` | all | Only this chain's records. |

The network is the one of the API key; there is no `network` parameter. A `limit` outside 1 to 50 answers `400 VALIDATION_ERROR`.

**Response (`content`):**

```json
{
  "records": [
    {
      "id": "tx_abc123",
      "chain": "STELLAR",
      "hash": "a1b2c3d4...",
      "network": "testnet",
      "status": "SUCCESS",
      "operation": "payment",
      "fee": { "amount": "0.00001", "unit": "XLM" },
      "details": {},
      "summary": "Sent 10.00 USDC",
      "createdAt": "2026-03-15T10:30:00Z"
    },
    {
      "id": "tx_def456",
      "chain": "SOLANA",
      "hash": "5UfD...",
      "network": "testnet",
      "status": "SUCCESS",
      "operation": "transfer",
      "fee": { "amount": "5000", "unit": "lamports" },
      "details": {},
      "summary": "Sent 10.00 USDC",
      "createdAt": "2026-03-15T10:31:00Z"
    }
  ],
  "total": 42,
  "limit": 20,
  "offset": 0
}
```

---

## Pagination

History uses **offset-based** pagination. Increase `offset` by `limit` to page forward; `total` tells you when to stop.

```typescript
async function getAllTransactions() {
  const all = [];
  let offset = 0;
  const limit = 50;

  for (;;) {
    await pollar.fetchTxHistory({ limit, offset });
    const state = pollar.getTxHistoryState();
    if (state.step !== 'loaded') break;
    all.push(...state.data.records);
    offset += limit;
    if (offset >= state.data.total) break;
  }

  return all;
}
```

---

## Transaction status

Each record carries a `status` reflecting its lifecycle:

| Status    | Description                                  |
| --------- | -------------------------------------------- |
| `PENDING` | Built/submitted, not yet confirmed on-chain. |
| `SUCCESS` | Confirmed on-chain.                          |
| `FAILED`  | Rejected by the chain, or failed before submission. |

The human-readable `operation` and `summary` fields describe what the transaction did.

---

## Record type

```typescript
type TxHistoryRecord = {
  id: string;
  chain: 'STELLAR' | 'POLYGON' | 'SOLANA';
  hash: string;
  network: 'testnet' | 'mainnet';
  status: 'PENDING' | 'SUCCESS' | 'FAILED';
  operation: string;
  fee?: { amount: string; unit: string }; // XLM on Stellar, lamports on Solana, wei on Polygon
  resultCode?: string;
  details: Record<string, unknown>;
  summary: string;
  createdAt: string; // ISO 8601
};
```
