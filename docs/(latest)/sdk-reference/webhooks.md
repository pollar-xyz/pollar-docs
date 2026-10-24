---
title: "Webhooks"
---

Pollar uses webhooks in two directions:

- **Inbound**: your backend receives a call from Pollar when an event occurs

- **Outbound**: your backend calls Pollar to trigger an action (e.g. `POST /v3/wallets/fund`)

---

## Inbound webhooks `upcoming`

> **Not yet available.** Pollar delivers no webhooks today, on any chain. The dashboard configuration page shows a "coming soon" state, and everything below (the signature, the delivery rules, the retry schedule and the events) is the **planned** design, documented so you can prepare your integration.
>
> The first delivery is planned as a single generic `stellar.tx` event carrying the raw Stellar operation data, posted once with no retry; the structured `wallet.*` / `payment.*` events come after it.

When available, you'll configure a webhook URL in **Build > Webhooks**. Pollar sends a `POST` request to your URL when an event occurs.

### Authentication

Every request includes an `X-Pollar-Signature` header: an HMAC-SHA256 signature of the raw request body using your webhook secret.

```typescript
import { createHmac } from 'crypto';

function verifyWebhook(payload: string, signature: string, secret: string): boolean {
  const expected = createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  return `sha256=${expected}` === signature;
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

Respond with `200` as quickly as possible: Pollar waits up to **10 seconds** for your answer. A non-2xx status or a timeout counts as a failed delivery, and the first release does not retry it (see the retry policy below).

### Retry policy `upcoming`

> Planned for a later release. The first delivery posts each event once and does not retry.

| Attempt | Delay      |
| ------- | ---------- |
| 1       | Immediate  |
| 2       | 1 minute   |
| 3       | 10 minutes |
| 4       | 1 hour     |
| 5       | 24 hours   |

After 5 failed attempts the event is marked as failed and visible in **Build > Webhooks > Event log**.

---

## Events `upcoming`

> These event types are **planned**: none is emitted today.

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

## Outbound webhooks

Your backend calls Pollar to trigger actions. Currently:

- `POST /v3/wallets/fund`: see [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api)
