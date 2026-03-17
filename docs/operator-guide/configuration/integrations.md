---
title: "Integrations"
---

**Dashboard → Configuration → Integrations**

Connect third-party services to extend Pollar's functionality.

---

## Fiat Ramps (SEP-24)

Enable fiat on/off-ramps so users can deposit and withdraw real money directly in your app via a modal.

### Supported anchors

| Anchor       | Assets                  | Status        |
| ------------ | ----------------------- | ------------- |
| **Anclap**   | USDC, local stablecoins | Available     |
| More anchors | —                       | `coming soon` |

### Setup

1. Toggle **Enable SEP-24** on
2. Select your anchor
3. Select the assets to support (must also be configured in [Tokens / Trustlines](../wallet-infrastructure/tokens-trustlines))

Pollar handles the SEP-10 authentication handshake with the anchor automatically. No anchor credentials or account setup required.

Once enabled, the SEP-24 modal is available via `openFiatRamp()` in the SDK:

```tsx
const { openFiatRamp } = usePollar();

<button onClick={() => openFiatRamp({ type: 'deposit', asset: 'USDC' })}>
  Deposit
</button>
```

---

## More integrations `coming soon`

| Integration   | Description                                                                         |
| ------------- | ----------------------------------------------------------------------------------- |
| KYC providers | Connect Jumio, Persona, or Sumsub to trigger Deferred mode activation automatically |
| Analytics     | Send wallet and payment events to Mixpanel, Amplitude, or Segment                   |
