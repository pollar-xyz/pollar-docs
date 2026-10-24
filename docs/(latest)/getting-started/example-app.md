---
title: "Example App"
---

The Pollar demo is a Next.js app that exercises the SDK feature by feature, each page next to the code that drives it. Use it to see a feature working before you build it, and to copy the patterns into your own app.

**Repository:** <https://github.com/pollar-xyz/demo>

**Live:** [demo.pollar.xyz](https://demo.pollar.xyz)

---

## What it shows

The sidebar groups the pages in sections:

| Section | Pages |
| --- | --- |
| Products | Authentication (login, logout, sessions), Wallet (send, receive, balance, chains, assets, history, distribution, signer rotation), Transactions (build and sign, sign an XDR) |
| Integrations | KYC, ramps, swap, earn and cards, each with an overview and its implementation |
| Wallet adapters | Stellar Wallets Kit and other wallets plugged in as login providers |
| Adapters | Third-party protocols wired in with `createPollarAdapterHook` (Trustless Work escrows, among others) |
| Built with Pollar | Apps built on Pollar alongside another technology |

Pages marked **Soon** are not live yet. A few groups still in testing open only with a passcode.

---

## Live demo

The live demo runs with Pollar's own demo keys on testnet and mainnet. To try it against your own app, pass your publishable key in the URL:

```
https://demo.pollar.xyz/?apiKey=pub_testnet_xxxxxxxxxxxxxxxxxxxx
```

The network follows the key's prefix (`pub_testnet_` or `pub_mainnet_`). Your app must list the demo's origin under **Build > [Domains](https://docs.pollar.xyz/docs/operator-guide/build/domains)**, or the SDK refuses the requests.

---

## Run locally

```bash
git clone https://github.com/pollar-xyz/demo
cd demo
pnpm install
cp .env.example .env.local
pnpm dev
```

Open <http://localhost:3080>.

The Pollar pages need no variables: they use the demo keys, or the key you pass with `?apiKey=`. When you use your own key, add `http://localhost:3080` to your app's domains. `.env.example` documents the rest:

| Variable | Used by |
| --- | --- |
| `NEXT_PUBLIC_POLLAR_BASE_URL` | Points the SDK at another sdk-api (a local or self-hosted one). Empty uses `https://sdk.api.pollar.xyz` |
| `NEXT_PUBLIC_TW_API_KEY` | The Trustless Work escrow page |
| `ABROAD_API_KEY` | The Abroad ramp page (server-side only) |
| `*_PASSCODE` | Unlocks the groups that are still in testing |

---

## Provider setup

Every page of the demo runs inside one `<PollarProvider>`. In your own app the same setup reads the key from an environment variable:

```tsx
import { PollarProvider } from '@pollar/react';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <PollarProvider client={{ apiKey: process.env.NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY! }}>
          {children}
        </PollarProvider>
      </body>
    </html>
  );
}
```

See [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react) for the provider's props and the modals it mounts.

---

## Funding modes

The demo has no backend of its own, so it shows the **Immediate** flow: the wallet is set up at login. For **Deferred**, where your backend opens each account after a business event (KYC approved, first deposit), see the [Deferred Flow Guide](https://docs.pollar.xyz/docs/guides/deferred-flow-guide), which has the API route and the frontend gate.

---

## Templates

Starting points for a whole app, each built on the SDK:

| Template | What it is |
| --- | --- |
| [pollar-neobank-template](https://github.com/pollar-xyz/pollar-neobank-template) | A consumer banking app: account home, receive with a QR, send, history |
| [pollar-commerce-template](https://github.com/pollar-xyz/pollar-commerce-template) | A shop that charges in USDC, with the commerce core apart from the storefront |
| [pollar-telegram-shop-template](https://github.com/pollar-xyz/pollar-telegram-shop-template) | The commerce template as a Telegram Mini App |
| [pollar-crowdfunding-template](https://github.com/pollar-xyz/pollar-crowdfunding-template) | Milestone crowdfunding on Trustless Work escrows |

[pollar-apps](https://github.com/pollar-xyz/pollar-apps) lists the apps open for contributors to build on these templates.
