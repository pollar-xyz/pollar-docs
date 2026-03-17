---
title: "Example App"
---

A fully working Next.js demo that shows Pollar's complete onboarding-to-payment flow. Clone it, run it in under 5 minutes, and use it as a starting point for your own integration

**Repository:** <https://github.com/pollar-xyz/demo-nextjs>

---

## What it demonstrates

| Feature                        | Description                                                                                                              | Status        |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | ------------- |
| Social login                   | Google, GitHub, and email OTP via `usePollar().login()`                                                                  | ✓             |
| Wallet creation                | Stellar G-address created and encrypted with AWS KMS on login                                                            | ✓             |
| Deferred mode — KYC simulation | A button triggers a Next.js API route that calls `POST /activate` with the secret key, simulating a backend KYC approval | ✓             |
| Send USDC                      | Transfer USDC to any Stellar address with zero fee UX                                                                    | ✓             |
| Receive                        | QR code (SEP-7 format) and shareable payment link                                                                        | `coming soon` |
| Transaction history            | Full paginated history via `txHistory` hook                                                                              | ✓             |
| Testnet funding                | `fund()` hook requests configured assets from the distribution wallet                                                    | `coming soon` |
| Passkeys                       | Biometric auth with Face ID / Touch ID                                                                                   | `coming soon` |
| SEP-24 fiat deposit            | Fiat on-ramp via Anclap testnet                                                                                          | `coming soon` |

---

## Live demo

[demo-nextjs.pollar.xyz](https://demo-nextjs.pollar.xyz) — runs on Stellar testnet. Complete a full onboarding flow and test every feature without touching mainnet funds.

---

## Run locally

```bash
git clone https://github.com/pollar-xyz/demo-nextjs
cd template-nextjs
npm install
cp .env.example .env.local
```

Add your keys to `.env.local`:

```bash
# Publishable — used in the frontend
NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY=pub_testnet_xxxxxxxxxxxxxxxxxxxx

# Secret — used only in API routes, never exposed to the browser
POLLAR_SECRET_KEY=sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

```bash
npm run dev
```

Open <http://localhost:3000>.

---

## App structure

```
template-nextjs/
├── app/
│   ├── layout.tsx              # PollarProvider wraps the app
│   ├── page.tsx                # Route: login vs wallet view
│   │
│   ├── api/
│   │   └── activate/
│   │       └── route.ts        # POST /api/activate — calls Pollar Server with secret key
│   │
│   └── components/
│       ├── LoginButton.tsx     # OAuth + email OTP
│       ├── WalletCard.tsx      # Balance and address display
│       ├── SendPaymentForm.tsx # sendPayment()
│       ├── ReceiveView.tsx     # QR code + shareable link
│       ├── TxHistoryList.tsx   # txHistory hook
│       └── KycGate.tsx         # Calls /api/activate to simulate KYC approval
│
├── .env.example
└── package.json
```

---

## Key patterns

### Provider setup

```tsx
// app/layout.tsx
import { PollarProvider } from '@pollar/react';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <PollarProvider publishableKey={process.env.NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY!}>
          {children}
        </PollarProvider>
      </body>
    </html>
  );
}
```

### Deferred mode — KYC simulation

The demo includes a Next.js API route that simulates a KYC provider calling your backend after a user is verified. The frontend calls this route — the route calls Pollar's `POST /activate` using the secret key server-side.

```ts
// app/api/activate/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const { walletId } = await req.json();

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
    return NextResponse.json(error, { status: response.status });
  }

  return NextResponse.json({ activated: true });
}
```

The frontend `KycGate` component calls this route — the secret key never leaves the server:

```tsx
// app/components/KycGate.tsx
'use client';
import { usePollar } from '@pollar/react';

export function KycGate() {
  const { wallet } = usePollar();

  if (wallet?.status !== 'pending') return null;

  async function handleActivate() {
    await fetch('/api/activate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ walletId: wallet!.id }),
    });
  }

  return (
    <div>
      <p>Complete identity verification to activate your wallet.</p>
      <button onClick={handleActivate}>
        Simulate KYC approval
      </button>
    </div>
  );
}
```

In a real app, `/api/activate` would be called by your KYC provider's webhook — not by a button in the UI. See [Deferred Flow Guide](../guides/deferred-flow-guide) for the full production setup.

### Testnet funding with `fund()`

The demo exposes a **Fund wallet** button that calls `fund()` from the `usePollar()` hook. This requests assets from your app's distribution wallet — a separate wallet configured in the Dashboard for this purpose.

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function FundButton() {
  const { fund } = usePollar();

  return (
    <div>
      {/* Fund with XLM (default) */}
      <button onClick={() => fund()}>
        Fund with XLM
      </button>

      {/* Fund with a specific asset */}
      <button onClick={() => fund({ asset: 'USDC' })}>
        Fund with USDC
      </button>
    </div>
  );
}
```

`fund()` behavior:

- Called without arguments, funds with XLM by default

- Pass `{ asset: 'USDC' }` (or any configured asset) to fund with a specific token

- Only assets configured in **Dashboard → Distribution Wallet** are accepted — throws an error otherwise

- Works on testnet by default

- Requires mainnet to be explicitly enabled in **Dashboard → Distribution Wallet → Allow fund() on mainnet**

- Throws an error if called on mainnet without that setting enabled

- Amount and rate limits (daily / weekly / monthly) are configured per asset in the Dashboard

- Debits the app's **distribution wallet** — separate from the funding and gas wallets

### Receive — QR code and shareable link

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function ReceiveView() {
  const { wallet } = usePollar();

  // coming soon: SEP-7 payment request URI
  // web+stellar:pay?destination=GXXX&asset_code=USDC&asset_issuer=GXXX
  const paymentLink = `https://pay.pollar.xyz/${wallet?.address}`;

  return (
    <div>
      {/* QR code component renders wallet.address */}
      <QRCode value={paymentLink} />
      <button onClick={() => navigator.clipboard.writeText(paymentLink)}>
        Copy payment link
      </button>
    </div>
  );
}
```

The QR code currently encodes the user's G-address as a payment link. SEP-7 support (which allows pre-filling asset, amount, and memo in any compatible Stellar wallet) is coming soon.

---

## Funding modes in the demo

Switch from **Dashboard → Settings → Funding Mode** — no code changes needed.

| Mode          | Behavior in the demo                                      |
| ------------- | --------------------------------------------------------- |
| **Immediate** | Wallet funded on login. KYC gate hidden.                  |
| **Deferred**  | Wallet unfunded until "Simulate KYC approval" is clicked. |
| **Manual**    | Wallet unfunded. Activate from the Dashboard.             |

---

## Other templates

| Template            | Repository                                                                  |
| ------------------- | --------------------------------------------------------------------------- |
| Next.js             | [pollar-xyz/template-nextjs](https://github.com/pollar-xyz/template-nextjs) |
| Expo / React Native | `coming soon`                                                               |
| TrueLayer           | `coming soon`                                                               |

---

## Deploy

```bash
npx vercel
```

Set `NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY` and `POLLAR_SECRET_KEY` in Vercel environment variables. The secret key is used only in API routes and is never exposed to the browser.
