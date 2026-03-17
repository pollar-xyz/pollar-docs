---
title: "Mainnet Checklist"
---

Before switching your app to Mainnet, verify every item in this checklist. There are no approval requirements from Pollar — this is a technical checklist you verify independently.

---

## Dashboard configuration

- [ ] Created a separate Mainnet app in the Dashboard (do not reuse your Testnet app)

- [ ] Generated `pub_mainnet_` and `sec_mainnet_` keys

- [ ] Added your production domain(s) in **Dashboard → Configuration → Domains**

- [ ] Funding mode configured correctly for your use case

- [ ] At least one asset configured in **Tokens / Trustlines**

- [ ] Branding & UI configured with your production logo and colors

---

## App Wallets

- [ ] Funding wallet active on Stellar Mainnet with sufficient XLM
  - Recommended minimum: 50 XLM to start

  - Calculate based on expected activations: `activations × (1 + assets × 0.5) XLM`

- [ ] Gas wallet active and funded
  - Recommended minimum: 10 XLM

- [ ] Distribution wallet funded (if using `fund()` on mainnet)

- [ ] Low-balance alerts configured in **Dashboard → Configuration → Alerts**
  - At minimum: email alert for funding wallet below 20 XLM

---

## Environment variables

- [ ] `pub_mainnet_` key set in your production environment

- [ ] `sec_mainnet_` key set in your backend production environment

- [ ] No testnet keys present in production environment variables

- [ ] Keys not committed to version control

---

## Backend (Deferred mode only)

- [ ] `POST /activate` endpoint deployed to production

- [ ] Endpoint uses `sec_mainnet_` secret key

- [ ] Endpoint validates input before calling Pollar

- [ ] `409 Conflict` response handled as success (wallet already active)

- [ ] `402 Payment Required` triggers an alert — your funding wallet needs a top-up

---

## SDK integration

- [ ] `PollarProvider` uses production publishable key

- [ ] No hardcoded testnet addresses or amounts

- [ ] Error handling implemented for `sendPayment()` failures

- [ ] Wallet `status: 'pending'` handled in the UI (Deferred / Manual mode)

- [ ] `fund()` on mainnet explicitly enabled in Dashboard if used

---

## Testing

- [ ] Full onboarding flow tested end-to-end on Mainnet with a real user account

- [ ] At least one real USDC payment sent and confirmed

- [ ] Transaction appears in **Dashboard → Observability → Transactions**

- [ ] Wallet visible on [Stellar Expert](https://stellar.expert)

- [ ] Webhook events received correctly (if configured)

---

## Observability

- [ ] **Dashboard → Observability → Logs** monitored after first real users

- [ ] Error alerting set up (Sentry, Datadog, or similar) for your backend

- [ ] Sponsorship wallet balances checked after first day of real usage

---

## Stellar network reference

- Mainnet passphrase: `Public Global Stellar Network ; September 2015`

- Mainnet Stellar Expert: [stellar.expert](https://stellar.expert)

- Network status: [status.stellar.org](https://status.stellar.org)

> Full network details at [developers.stellar.org/docs/networks](https://developers.stellar.org/docs/networks).
