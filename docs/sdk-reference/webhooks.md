---
title: "Webhooks"
---

Pollar distinguishes event delivery from authenticated API calls:

- **App event webhooks** — Pollar sends a call to your backend when an event occurs (outbound from Pollar, inbound to your app)

- **Server API calls** — your backend calls Pollar to trigger an action (e.g. `POST /v1/wallets/fund`); these are not webhook deliveries

---

## App event webhooks `upcoming`

> 🚧 **Not yet available.** Structured app event webhooks remain pending. The dashboard configuration page is gated behind a "coming soon" state, and the semantic events below describe the **planned** design, not a released delivery contract.
>
> What exists today is an internal, generic on-chain delivery: a single `stellar.tx` event carrying raw Stellar operation data, posted once (no retry/backoff) with an `X-Pollar-Signature: sha256=<hmac>` header. The structured `wallet.*` / `payment.*` events below are not emitted yet.

Ramp lifecycle `ramp.transaction.updated` records are stored in an internal
outbox. Durable delivery to application endpoints, retries and replay remain
pending; an outbox record does not mean your backend received a notification.
Provider-to-Pollar event ingestion is a separate integration.

When available, you'll configure a webhook URL in **Build → Webhooks**. Pollar sends a `POST` request to your URL when an event occurs.

### Authentication

Every request includes an `X-Pollar-Signature` header — an HMAC-SHA256 signature of the raw request body using your webhook secret.

```typescript
import { createHmac, timingSafeEqual } from 'node:crypto';
import { NextResponse, type NextRequest } from 'next/server';

function verifyWebhook(payload: string, signature: string, secret: string): boolean {
  if (!/^sha256=[a-f0-9]{64}$/i.test(signature)) return false;
  const received = Buffer.from(signature.slice(7), 'hex');
  const expected = createHmac('sha256', secret).update(payload).digest();
  return received.length === expected.length && timingSafeEqual(received, expected);
}

// Next.js API route
export async function POST(req: NextRequest) {
  const payload = await req.text();
  const signature = req.headers.get('x-pollar-signature') ?? '';

  if (!verifyWebhook(payload, signature, process.env.POLLAR_WEBHOOK_SECRET!)) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
  }

  const event = JSON.parse(payload);
  // handle event...
  return NextResponse.json({ received: true });
}
```

Verify the raw body before processing and acknowledge accepted events promptly
with a 2xx response. The current internal dispatcher does not retry non-2xx
responses or timeouts.

### Retry policy `upcoming`

> Planned design — there is **no retry/backoff implemented today**. The current internal delivery posts once and logs failures.

Durable attempts, backoff, replay and an operator delivery log are pending.
No retry schedule or attempt limit is part of the current delivery contract.

---

## Events `upcoming`

> These semantic event types are **planned, not yet emitted**. The server currently only delivers a generic `stellar.tx` payload with raw operation data.

### `wallet.created`

Fired when a new wallet G-address is created on-chain.

```json
{
  "event": "wallet.created",
  "timestamp": "2026-03-15T10:00:00Z",
  "data": {
    "walletId": "wal_abc123",
    "address": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "status": "pending"
  }
}
```

### `wallet.activated`

Fired when a wallet is successfully funded and active on-chain.

```json
{
  "event": "wallet.activated",
  "timestamp": "2026-03-15T10:30:00Z",
  "data": {
    "walletId": "wal_abc123",
    "address": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "activatedAt": "2026-03-15T10:30:00Z"
  }
}
```

### `wallet.funded`

Fired when `fund()` distributes assets from the distribution wallet.

```json
{
  "event": "wallet.funded",
  "timestamp": "2026-03-15T11:10:00Z",
  "data": {
    "walletId": "wal_abc123",
    "asset": "USDC",
    "amount": "100.00",
    "txHash": "c3d4e5f6..."
  }
}
```

### `payment.sent`

Fired when a payment is confirmed on-chain.

```json
{
  "event": "payment.sent",
  "timestamp": "2026-03-15T11:00:00Z",
  "data": {
    "txHash": "a1b2c3d4...",
    "fromWalletId": "wal_abc123",
    "from": "GABC...",
    "to": "GXYZ...",
    "asset": "USDC",
    "amount": "10.00",
    "ledger": 1234567
  }
}
```

### `payment.received`

Fired when a wallet receives a payment from any Stellar address.

```json
{
  "event": "payment.received",
  "timestamp": "2026-03-15T11:05:00Z",
  "data": {
    "txHash": "b2c3d4e5...",
    "toWalletId": "wal_abc123",
    "from": "GXYZ...",
    "to": "GABC...",
    "asset": "USDC",
    "amount": "25.00",
    "ledger": 1234600
  }
}
```

### `trustline.added`

Fired when a trustline is enabled on a user wallet.

```json
{
  "event": "trustline.added",
  "timestamp": "2026-03-15T10:01:00Z",
  "data": {
    "walletId": "wal_abc123",
    "asset": "USDC"
  }
}
```

### `sponsor.balance.low`

Fired when any sponsorship wallet drops below its configured minimum threshold.

```json
{
  "event": "sponsor.balance.low",
  "timestamp": "2026-03-15T12:00:00Z",
  "data": {
    "walletType": "funding",
    "address": "GSPONSOR...",
    "balance": "5.00",
    "threshold": "10.00",
    "asset": "XLM"
  }
}
```

---

## Server API calls

Your backend calls Pollar to trigger actions. Currently:

- `POST /v1/wallets/fund` — see [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api)
