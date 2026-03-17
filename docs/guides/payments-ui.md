---
title: "Payments UI"
---

This guide covers how to implement send, receive, and transaction history flows in your app using Pollar's hooks and pre-built components.

---

## Send

### Using `sendPayment()`

```tsx
'use client';
import { usePollarPayments } from '@pollar/react';
import { useState } from 'react';

export function SendForm() {
  const { sendPayment, sending } = usePollarPayments();
  const [to, setTo] = useState('');
  const [amount, setAmount] = useState('');

  async function handleSend() {
    const result = await sendPayment({
      to,
      amount,
      asset: 'USDC',
    });
    console.log('Confirmed:', result.txHash);
  }

  return (
    <div>
      <input
        placeholder="Recipient G-address"
        value={to}
        onChange={e => setTo(e.target.value)}
      />
      <input
        placeholder="Amount"
        type="number"
        value={amount}
        onChange={e => setAmount(e.target.value)}
      />
      <button onClick={handleSend} disabled={sending}>
        {sending ? 'Sending...' : 'Send USDC'}
      </button>
    </div>
  );
}
```

### With memo

Memos are useful for identifying payments on the recipient's side — common in remittance and payroll apps.

```tsx
await sendPayment({
  to: 'GXXX...',
  amount: '100.00',
  asset: 'USDC',
  memo: 'Payroll March 2026',
});
```

### Pre-built `<SendPayment />` component `coming soon`

A pre-built component with address input, asset selector, amount field, and confirmation step. Customizable from **Dashboard → Configuration → Branding & UI**.

---

## Receive

### Showing the user's address

```tsx
'use client';
import { usePollarWallet } from '@pollar/react';

export function ReceiveView() {
  const { wallet } = usePollarWallet();

  async function copyAddress() {
    await navigator.clipboard.writeText(wallet!.address);
  }

  return (
    <div>
      <p>{wallet?.address}</p>
      <button onClick={copyAddress}>Copy address</button>
    </div>
  );
}
```

### QR code

Generate a QR code from the wallet address using any QR library:

```tsx
import QRCode from 'qrcode.react';
import { usePollarWallet } from '@pollar/react';

export function ReceiveQR() {
  const { wallet } = usePollarWallet();

  return <QRCode value={wallet?.address ?? ''} size={200} />;
}
```

### SEP-7 payment request URI `coming soon`

SEP-7 encodes destination, asset, amount, and memo into a single URI that any compatible Stellar wallet can scan to pre-fill a payment form:

```
web+stellar:pay?destination=GXXX&asset_code=USDC&asset_issuer=GXXX&amount=10
```

When available, Pollar will generate SEP-7 URIs automatically via `wallet.paymentRequestUri()`.

### Pre-built `<ReceivePayment />` component `coming soon`

A pre-built component with QR code display, copyable address, and shareable payment link.

---

## Transaction history

### Using `usePollarHistory()`

```tsx
'use client';
import { usePollarHistory } from '@pollar/react';

export function TxHistory() {
  const { txHistory, loadingHistory, fetchMoreHistory, hasMore } = usePollarHistory();

  if (loadingHistory && txHistory.length === 0) return <p>Loading...</p>;

  return (
    <div>
      <ul>
        {txHistory.map(tx => (
          <li key={tx.hash}>
            <span>{tx.type === 'send' ? '↑' : '↓'}</span>
            <span>{tx.amount} {tx.asset}</span>
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

### Filtering by type or asset

```tsx
// Only payments
const payments = txHistory.filter(tx => tx.type === 'payment');

// Only USDC
const usdcTxs = txHistory.filter(tx => tx.asset === 'USDC');
```

For server-side filtering with date ranges, use the REST API directly — see [Transaction History](../core-concepts/transaction-history).

### Pre-built `<PaymentHistory />` component `coming soon`

A pre-built paginated history component with type icons, asset labels, and date grouping.

---

## Asset balances

### Reading balances from the wallet

```tsx
'use client';
import { usePollarWallet } from '@pollar/react';

export function Balances() {
  const { wallet } = usePollarWallet();

  return (
    <ul>
      {wallet?.balances.map(b => (
        <li key={b.asset}>
          {b.amount} {b.asset}
        </li>
      ))}
    </ul>
  );
}
```

### Pre-built `<AssetBalance />` component `coming soon`

A pre-built component for displaying a single asset balance with formatting and asset icon.

```tsx
// coming soon
<AssetBalance asset="USDC" />
```

---

## Fiat on/off-ramp

Enable SEP-24 in **Dashboard → Configuration → Integrations** to add a deposit/withdrawal button:

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function FiatButtons() {
  const { openFiatRamp } = usePollar();

  return (
    <div>
      <button onClick={() => openFiatRamp({ type: 'deposit', asset: 'USDC' })}>
        Deposit USD
      </button>
      <button onClick={() => openFiatRamp({ type: 'withdrawal', asset: 'USDC' })}>
        Withdraw USD
      </button>
    </div>
  );
}
```

See [Fiat Ramps](../operator-guide/configuration/integrations) for setup.
