---
title: "Ramps"
---

**Dashboard → Integrations → Ramps**

Configure fiat on/off-ramp providers so users can deposit and withdraw real money directly in your app via a modal.

---

## Fiat Ramps

Enable a provider, add its credentials, and select the corridors/assets to support.

### Supported providers

| Provider      | Type                | Notes                                         |
| ------------- | ------------------- | --------------------------------------------- |
| **Bridge**    | REST (bridge.xyz)   | Fiat corridors incl. BRL / Pix                |
| **Etherfuse** | REST                | MXN ↔ USDC-on-Stellar                          |
| **Anclap**    | SEP-24              | USDC and local stablecoins                     |

Each provider is configured with its own credentials (base URL + API keys) and, where applicable, its enabled corridors. Assets you enable must also be configured in [Tokens / Trustlines](https://docs.pollar.xyz/docs/operator-guide/treasury/tokens-trustlines).

Once enabled, the ramp modal is available via `openRampModal()` in the SDK:

```tsx
const { openRampModal } = usePollar();

<button onClick={openRampModal}>
  Deposit / Withdraw
</button>
```

For headless control over quotes and on/off-ramp creation, use `getClient().getRampsQuote()`, `createOnRamp()`, and `createOffRamp()`.

---

## More integrations `coming soon`

| Integration   | Description                                                                         |
| ------------- | ----------------------------------------------------------------------------------- |
| KYC providers | Connect Jumio, Persona, or Sumsub to trigger Deferred mode activation automatically |
| Analytics     | Send wallet and payment events to Mixpanel, Amplitude, or Segment                   |
