---
title: "KYC"
---

**Dashboard > Integrations > KYC** · Chains: all

The **Identity verification** page: configure identity verification for your app, independently of ramps. Your users verify through the SDK (`openKycModal()` in [@pollar/react](https://docs.pollar.xyz/docs/sdk-reference/pollar-react), or `getKycProviders()` / `startKyc()` / `getKycStatus()` in [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)), and your app reads their status to decide what to unlock, for example funding a wallet in [Deferred](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding#funding-mode) mode only after a user passes KYC.

The page has three cards.

---

## Enabled KYC options

The KYC options your verification steps can use, each with the URL the provider returns your users to.

1. Pick a **KYC option** (the ones Pollar offers to your app, plus your own options from the card below).
2. Enter the **Return URL**: an allowed app origin or a registered redirect URI (see [Domains](https://docs.pollar.xyz/docs/operator-guide/build/domains)).
3. Click **Enable / update option**.

Each enabled option is listed with **Disable standalone option**. These settings do not replace or disable a ramp's mandatory KYC, which is set per corridor under [Ramps > Providers](https://docs.pollar.xyz/docs/operator-guide/ramps/providers#mandatory-kyc-per-corridor).

---

## Verification steps

The steps your users complete, in order. Each step is either **Identity verification (KYC)**, using an option enabled above, or a **Form** that Pollar offers to your app. A step can accept several alternatives: it passes with any of them, and when none is done the first one is asked for. Reorder steps and alternatives with the arrows; up to 10 steps with up to 10 alternatives each. **Save steps** stores them; every option used must be enabled for the app.

With no steps, your users can verify with any option enabled above.

Nothing is blocked automatically: read the user's status from the SDK and decide.

---

## Use your own Didit account

Create a private KYC option for this app on your own [Didit](https://didit.me) account. Credentials are encrypted and never sent to your users.

| Field | Notes |
| --- | --- |
| **Option name** | How the option appears in the lists above |
| **Workflow ID** | The Didit workflow to run |
| **API key** | Your Didit API key |
| **Webhook signing secret** | Optional. Without it, the status is read by polling |
| **Presentation** | **Iframe** (inside your app) or **Redirect** (Didit's page) |
| **Return URL** | An allowed app origin or a registered redirect URI |

**Create standalone KYC option** saves it; it then appears among the options you can enable. Your own options are also what a ramp running on your own provider keys uses for its KYC (see [Configure](https://docs.pollar.xyz/docs/operator-guide/ramps/providers#configure-your-own-provider-account)).
