---
title: "Providers"
---

**Dashboard > Ramps > Providers** · Chains: Stellar, Solana, Polygon (per route)

Fiat-to-crypto and crypto-to-fiat providers for your users. The page lists the providers Pollar offers on your app's network; turn one on and its routes become available to your users through the SDK's ramp widget (`openRampModal()`) or the headless ramp API. How a ramp runs is explained in [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps).

---

## Providers

| Provider | Type | What it serves |
| --- | --- | --- |
| **Abroad Finance** | REST | Off-ramp to BRL (Pix) and COP (BreB) |
| **Anclap** | SEP-24 | Hosted deposit and withdrawal on the anchor's own page |
| **Etherfuse** | REST | MXN via SPEI, with the provider's own KYC |
| **Stereum** | REST | BOB: buy by bank QR, sell to a bank account. Settles on Polygon |
| **Bridge** `upcoming` | REST | Being integrated |
| **PagFinance** `upcoming` | REST | Being integrated |

The provider card is the source of truth for what it serves on your network.

---

## Enabling a provider

Each provider card has a switch. Turning it on makes its routes available; turning it off removes them. Members with write access can change it.

### Corridors

Under each enabled provider the card lists its **corridors**: direction (Buy / Sell), country, fiat currency, rail (Pix, SPEI, bank QR, bank transfer, hosted page and so on) and the token the user ends up with. Each corridor is labelled:

- **No FX**: fiat and token are the same currency and the provider only tokenizes it. The rate is 1 and only a fee applies.
- **With FX**: one currency goes in and another comes out, so the provider applies an exchange rate that arrives with each quote.

Each corridor has its own switch, so your app can serve some corridors of a provider and not others. Limits and prices come from the provider with each quote; they are not set here.

A corridor does not have to end on the provider's own chain. Pollar builds **routes**: a provider leg, then swap or bridge legs that carry the funds to the asset and chain your user wants, and only to chains your app enables. See [Routes](https://docs.pollar.xyz/docs/operator-guide/ramps/routes). When a leg runs on a chain your app does not serve, Pollar creates the user's wallet there (a rail wallet, see [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets#rail-wallets)).

---

## Configure (your own provider account)

REST providers that accept per-app accounts show a **Configure** button. Without it, the provider runs on Pollar's account and Pollar sets the transaction fee.

With **Use my own keys** checked, fill in:

| Field | Notes |
| --- | --- |
| **Base URL** | Required. The provider's API URL for your account |
| **API Key** | Required. A saved key is kept when you leave it blank |
| **Company ID** / **Secret key** | Stereum only. The secret key is optional and signs customer registrations, needed on routes that register the user with Stereum |
| **Your fee (%)** | Your markup, for example `1.0` = 1%. Blank means no fee. Abroad and Stereum price all-in, so their fee is reference only |

Your own provider keys need your own KYC: both or neither. For every route of the provider that requires KYC, pick one of your own KYC options. Create them under [Integrations > KYC](https://docs.pollar.xyz/docs/operator-guide/integrations/kyc) ("Use your own Didit account"). Until each such route has one, users cannot use it.

---

## Mandatory KYC per corridor

When Pollar requires identity verification on a corridor, the provider card shows a **KYC** section:

- **KYC required. Accepted options, in order**: users must be approved before using the corridor, whatever the amount. A user approved on any accepted option passes; otherwise the first one is asked for. With your own keys, the section shows the own option you picked instead.
- **KYC redirect URL**: where users return after verification. Use an allowed app origin or a registered redirect URI, not a webhook URL. **Save redirect URL** stores it.

Only Pollar can change whether a corridor requires KYC. A corridor without Pollar KYC may still have the provider's own onboarding.

---

## Transactions under review by Pollar

Ramps that could not be settled automatically and that Pollar is reviewing are listed in their own section, each with its transaction ID, provider, direction, amounts and the date it went into review. No action is needed from you: Pollar resolves them and the entry updates once it is resolved. Share the transaction ID with your user if they ask. The section is hidden while there are none.

---

## In your app

```tsx
const { openRampModal } = usePollar();

<button onClick={openRampModal}>Deposit / Withdraw</button>
```

For headless control use the ramp methods of [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) (`getRampRoutes`, `quoteRamp`, `createRampOrder`, `pollRampOrder`), or `/v3/ramps` in the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api). Ramps need `@pollar/core` 0.12.0 or later.
