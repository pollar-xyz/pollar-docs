---
title: "Deferred Flow Guide"
---

Deferred mode creates user wallets on-chain without funding them immediately. The XLM reserve is only charged when your backend calls `POST /activate` — typically after a business event like KYC approval or a first deposit.

This guide walks through the full implementation end-to-end.

---

## Prerequisites

- Funding mode set to **Deferred** in **Dashboard → Configuration → Funding Mode**
- A secret key from **Dashboard → Configuration → API Keys**
- That's it — no additional dashboard configuration required

---

## How it works

```mermaid
sequenceDiagram
    participant User
    participant Frontend as Your Frontend
    participant Backend as Your Backend
    participant Pollar as Pollar Server
    participant Stellar as Stellar Network

    User->>Frontend: login()
    Frontend->>Pollar: POST /wallets/create
    Pollar->>Stellar: createAccount (no reserve)
    Pollar-->>Frontend: { status: 'pending' }
    Frontend-->>User: Show KYC flow

    Note over User,Backend: User completes KYC / first deposit / your trigger

    Backend->>Pollar: POST /wallets/activate
    Note over Backend,Pollar: Uses secret key — never from client
    Pollar->>Stellar: beginSponsoringFutureReserves
    Stellar-->>Pollar: Reserve funded (~2s)
    Pollar-->>Backend: 200 { status: 'active' }
    Frontend-->>User: Wallet ready
```

---

## Step 1 — Detect pending wallets in the frontend

After login, check the wallet status. If `pending`, show your KYC or onboarding flow instead of the wallet UI.

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function WalletGate() {
  const { wallet, loading } = usePollar();

  if (loading) return <p>Loading...</p>;

  if (!wallet) return <LoginButton />;

  if (wallet.status === 'pending') {
    return <KycFlow walletId={wallet.id} />;
  }

  return <WalletDashboard />;
}
```

---

## Step 2 — Trigger activation from your backend

When the business event occurs (KYC approved, first deposit confirmed, etc.), your backend calls `POST /activate` using the **secret key**.

```typescript
// Your backend — e.g. Next.js API route, Express handler, webhook receiver
async function activateWallet(walletId: string) {
  const response = await fetch('https://api.pollar.xyz/wallets/activate', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.POLLAR_SECRET_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ walletId }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Activation failed: ${error.error.code}`);
  }

  return response.json();
  // { walletId, address, status: 'active', activatedAt }
}
```

> Never call `POST /activate` from the client. It requires your secret key — exposing it client-side compromises your entire app.

---

## Step 3 — Handle the response

| Code | Meaning | Action |
|---|---|---|
| `200 OK` | Wallet activated successfully | Proceed — wallet is funded on-chain |
| `400 Bad Request` | Missing or malformed `walletId` | Check the request payload |
| `402 Payment Required` | Funding wallet has insufficient XLM | Top up via **Dashboard → Configuration → App Wallets** |
| `404 Not Found` | `walletId` does not exist | Verify the wallet ID |
| `409 Conflict` | Wallet already active | Safe to ignore — treat as success |
| `503 Service Unavailable` | Stellar network issue | Pollar retries automatically |

---

## Step 4 — Notify the frontend

After activation, notify your frontend so the UI updates. The simplest approach is polling `wallet.status`. For real-time updates, use a websocket or server-sent event from your backend.

```tsx
'use client';
import { usePollar } from '@pollar/react';
import { useEffect } from 'react';

export function KycFlow({ walletId }: { walletId: string }) {
  const { wallet, refetchWallet } = usePollar();

  // Poll every 2 seconds until wallet is active
  useEffect(() => {
    if (wallet?.status === 'active') return;
    const interval = setInterval(refetchWallet, 2000);
    return () => clearInterval(interval);
  }, [wallet?.status]);

  if (wallet?.status === 'active') {
    return <p>✓ Wallet activated</p>;
  }

  return <p>Complete KYC to activate your wallet...</p>;
}
```

---

## Full Next.js example

The [template-nextjs](https://github.com/pollar-xyz/template-nextjs) demo includes a working implementation:

- `app/api/activate/route.ts` — the API route that calls `POST /activate`
- `app/components/KycGate.tsx` — the frontend component that triggers it

---

## Testing on testnet

1. Set funding mode to **Deferred** in the Dashboard
2. Log in — the wallet is created with `status: 'pending'`
3. Call your activate endpoint manually (e.g. with curl or Postman)
4. Verify the wallet moves to `status: 'active'`
5. Verify the G-address on [Stellar Expert testnet](https://testnet.stellar.expert)

```bash
curl -X POST https://api.pollar.xyz/wallets/activate \
  -H "Authorization: Bearer sec_testnet_xxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{ "walletId": "wal_abc123" }'
```