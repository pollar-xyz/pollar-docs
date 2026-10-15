---
title: "Providers"
---

**Dashboard → Ramps → Providers** · Chains: Stellar, Solana, Polygon (per provider)

Configure fiat on/off-ramp providers so users can deposit and withdraw real money directly in your app via a modal.

---

## Fiat Ramps

Enable a provider, add its credentials, and select the corridors/assets to support.

### Supported providers

| Provider           | Type              | Notes                                                           |
|--------------------|-------------------|-----------------------------------------------------------------|
| **Bridge**         | REST (bridge.xyz) | BRL ↔ USDC on Stellar, via Pix. Hosted KYC.                     |
| **PagFinance**     | REST              | BRL ↔ USDC on Solana, via Pix. Withdrawal requires an attributable payment destination. |
| **Abroad Finance** | REST              | Off-ramp only — BRL (Pix) and COP (BreB) from USDC on Stellar.  |
| **Etherfuse**      | REST              | MXN ↔ USDC on Stellar, via SPEI. Per-user hosted KYC.           |
| **Stereum**        | REST              | BOB ↔ USDC on Stellar or Solana — buy by bank QR, sell to a bank account. |
| **Anclap**         | SEP-24            | USDC and local stablecoins (any SEP-24 anchor).                 |

These are implemented provider capabilities, not a statement that every route is
enabled or certified in your deployment. Credentials, application settings,
network, wallet support and required settlement readers determine availability.
Use the quotes returned to your app; `getRampRoutes()` describes eligible
registered adapters and does not replace the legacy provider catalog.

The real unit of a ramp is the **corridor**: direction + country + fiat + rail + the on-chain asset the user ends up
with. Corridors are seeded from what the backend can actually execute — from the adapter's capability matrix for REST
providers, from the anchor's `stellar.toml` + SEP-24 `/info` for Anclap — so the dashboard can never enable a route with
no code behind it. You own the overrides: turn a corridor off, or tighten its minimum and maximum amount.

| Provider       | Direction | Country | Fiat | Rail | User's asset    |
|----------------|-----------|---------|------|------|-----------------|
| Bridge         | Buy, Sell | BR      | BRL  | Pix  | USDC on Stellar |
| PagFinance     | Buy, Sell | BR      | BRL  | Pix  | USDC on Solana  |
| Abroad Finance | Sell      | BR      | BRL  | Pix  | USDC on Stellar |
| Abroad Finance | Sell      | CO      | COP  | BreB | USDC on Stellar |
| Etherfuse      | Buy, Sell | MX      | MXN  | SPEI | USDC on Stellar |
| Stereum        | Buy       | BO      | BOB  | QR   | USDC on Stellar |
| Stereum        | Sell      | BO      | BOB  | ACH  | USDC on Stellar |
| Stereum        | Buy       | BO      | BOB  | QR   | USDC on Solana  |
| Stereum        | Sell      | BO      | BOB  | ACH  | USDC on Solana  |

Each corridor settles on a chain, and a user only needs a wallet on that chain:

- **PagFinance** is paid USDC **on Solana** by its Partner API. On a Solana app the funds land straight in the user's Solana wallet.
- **Stereum** delivers on the user's Polygon wallet (a [rail wallet](https://docs.pollar.xyz/docs/operator-guide/wallets/rail-wallets)) and bridges it with **Circle CCTP** to the user's Stellar wallet, or to their Solana wallet when the app serves Solana and not Stellar. The app's GAS wallet relays the mint.
- **Bridge**, **Etherfuse**, **Abroad** and **Anclap** settle on Stellar.

The bridges are internal plumbing: your users see one order and one balance.

PagFinance withdrawals require either a dedicated `depositAddress` or a shared
receiver with a provider-issued memo. An intent with neither is recorded and
declined before payment. External Solana wallets cannot execute its withdrawal
flow. Provider outcome ingestion remains a separate integration gate; code for
submitting a payment does not establish end-to-end settlement.

Each provider is configured with its own credentials (base URL + API keys) and, where applicable, its enabled corridors.
Assets you enable must also be configured
in [Tokens / Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines).

Once enabled, the ramp modal is available via `openRampModal()` in the SDK:

```tsx
const { openRampModal } = usePollar();

<button onClick={openRampModal}>
  Deposit / Withdraw
</button>
```

For headless control over quotes and on/off-ramp creation, use `getClient().getRampsQuote()`, `createOnRamp()`, and
`createOffRamp()`.

---

## More integrations `coming soon`

| Integration   | Description                                                                         |
|---------------|-------------------------------------------------------------------------------------|
| Additional KYC providers | Additional provider integrations; see [KYC](https://docs.pollar.xyz/docs/operator-guide/integrations/kyc) for the existing SDK flow and configuration UI status |
| Analytics     | Send wallet and payment events to Mixpanel, Amplitude, or Segment                   |
