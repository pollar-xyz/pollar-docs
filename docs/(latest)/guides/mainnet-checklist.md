---
title: "Mainnet Checklist"
---

Every app starts on testnet. Mainnet access is requested from the dashboard and approved by Pollar; the approval creates the app's mainnet counterpart in the same project. Before you request it, and before you send real users to it, verify every item below.

---

## Mainnet access

- [ ] Requested mainnet access from **Build > Settings > Request Mainnet access** (or the network control in the top bar). Only the app's owner or an admin can request it.

- [ ] The request is approved, and the mainnet app appears in the project. A rejected request carries Pollar's review note; fix what it says and resubmit.

- [ ] Generated `pub_mainnet_` and `sec_mainnet_` keys in the mainnet app.

---

## Dashboard configuration

- [ ] Added your production domain(s) in **Build > Domains**

- [ ] **Wallets > Wallet settings > Wallet custody** set to **Co-signed with Turnkey (2-of-2)** or **Self-custody with Turnkey (1-of-1)**. Pollar custody is not available on mainnet. See [Co-signed and Self-custody Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets).

- [ ] **Wallets > Wallet settings > Signature confirmation** set to the policy you want (always ask, ask once for a window, or never ask). Ramp legs always ask.

- [ ] Funding mode configured for your use case. In Deferred mode on mainnet, `POST /v3/wallets/fund` opens each Turnkey wallet's account creation and the user approves it in their next session (`202`). See [Funding Modes](https://docs.pollar.xyz/docs/core-concepts/funding-modes).

- [ ] At least one asset configured in **Wallets > Tokens & Trustlines**

- [ ] Branding configured with your production logo and colors

---

## Paying for the chain

Check which [billing model](https://docs.pollar.xyz/docs/core-concepts/credits) the app is on (**Billing > Credits** says it).

**On credits:**

- [ ] A credit balance that covers your expected activations and transactions, topped up at one of the app's deposit addresses (USDC or USDT)

- [ ] The low-balance alert on **Billing > Credits** set, so you hear about it before paid flows start answering 402

**On your own wallets:**

- [ ] Funding wallet active on Stellar mainnet with sufficient XLM
  - Recommended minimum: 50 XLM to start
  - Calculate based on expected activations: `activations x (1 + assets x 0.5) XLM`, plus the starting balance

- [ ] Gas wallet active and funded
  - Recommended minimum: 10 XLM

- [ ] Solana or Polygon GAS wallet created and funded under **Wallets > Sponsorship**, if the app enables those chains

- [ ] Distribution wallet funded (if distributing tokens)

---

## Environment variables

- [ ] `pub_mainnet_` key set in your production environment

- [ ] `sec_mainnet_` key set in your backend production environment

- [ ] No testnet keys present in production environment variables

- [ ] Keys not committed to version control

---

## Backend (Deferred mode only)

- [ ] `POST /v3/wallets/fund` endpoint deployed to production

- [ ] Endpoint uses the `sec_mainnet_` secret key

- [ ] Endpoint validates input before calling Pollar

- [ ] `409 WALLET_ALREADY_FUNDED` handled as success

- [ ] `202 SERVER_WALLET_ACCOUNT_REQUESTED` handled as pending: the account opens once the user approves it

- [ ] `402 SDK_CREDITS_INSUFFICIENT` / `SDK_BILLING_OVERDUE` (apps on credits: top up the credits) and `502 FUND_XLM_FAILED` (apps on their own wallets: the funding wallet needs XLM) trigger an alert

---

## SDK integration

- [ ] `@pollar/core`, `@pollar/react` or `@pollar/react-native` **0.12.0 or later**: Turnkey wallets and the signature confirmation need it

- [ ] `PollarProvider` uses the production publishable key (`client={{ apiKey: 'pub_mainnet_...' }}`)

- [ ] A headless integration subscribes to `onConfirmationRequest()`; with a prompt due and nothing subscribed, signatures end with `SDK_CONFIRMATION_UNAVAILABLE`

- [ ] Users can add a recovery method (a passkey, an email code or another device) before they receive funds: until they do, a Turnkey wallet signs only its own setup and answers `SDK_WALLET_RECOVERY_REQUIRED`. `@pollar/react` shows `<RecoveryModal>` for it

- [ ] No hardcoded testnet addresses or amounts

- [ ] Error handling implemented for transaction (`runTx` / `signAndSubmitTx`) failures: inspect the returned `SubmitOutcome.status`

- [ ] Wallets still being provisioned handled in the UI (`wallet.provisioning === 'CREATING'`, `SDK_WALLET_NOT_READY`)

- [ ] Token distribution rules configured in the dashboard if used

---

## Testing

- [ ] Full onboarding flow tested end-to-end on mainnet with a real user account, including approving the wallet setup and adding a recovery method

- [ ] At least one real USDC payment sent and confirmed

- [ ] Transaction appears in **Monitor > Transactions**

- [ ] Wallet visible on [Stellar Expert](https://stellar.expert)

---

## Observability

- [ ] **Monitor > Logs** watched after the first real users

- [ ] Error alerting set up (Sentry, Datadog, or similar) for your backend

- [ ] Credit balance, or operator wallet balances, checked after the first day of real usage

---

## Stellar network reference

- Mainnet passphrase: `Public Global Stellar Network ; September 2015`

- Mainnet Stellar Expert: [stellar.expert](https://stellar.expert)

- Network status: [status.stellar.org](https://status.stellar.org)

> Full network details at [developers.stellar.org/docs/networks](https://developers.stellar.org/docs/networks).
