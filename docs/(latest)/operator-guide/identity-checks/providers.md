---
title: "Providers"
---

**Dashboard > Identity checks > Providers** · Chains: all

Configure identity verification for your app, independently of ramps. Your users verify through the SDK (`openKycModal()` in [@pollar/react](https://docs.pollar.xyz/docs/sdk-reference/pollar-react), or `getKycProviders()` / `startKyc()` / `getKycStatus()` in [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)), and your app reads their status to decide what to unlock, for example funding a wallet in [Deferred](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding#funding-mode) mode only after a user passes KYC.

The page has two cards. The steps your users complete are under [Verification steps](https://docs.pollar.xyz/docs/operator-guide/identity-checks/steps).

---

## Enabled KYC options

The KYC options your [verification steps](https://docs.pollar.xyz/docs/operator-guide/identity-checks/steps) can use, each with the URL the provider returns your users to.

1. Pick a **KYC option** (the ones Pollar offers to your app, plus your own options from the card below).
2. Enter the **Return URL**: an allowed app origin or a registered redirect URI (see [Websites](https://docs.pollar.xyz/docs/operator-guide/developers/domains)).
3. Click **Enable / update option**.

Each enabled option is listed with **Disable standalone option**. These settings do not replace or disable a ramp's mandatory KYC, which Pollar sets per method (see [Cash in and out > Countries and methods](https://docs.pollar.xyz/docs/operator-guide/ramps/methods#identity-check)).

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

**Create standalone KYC option** saves it; it then appears among the options you can enable. Your own options are also what a ramp running on your own provider account uses for its KYC; Pollar sets that up on request (see [Countries and methods](https://docs.pollar.xyz/docs/operator-guide/ramps/methods#your-own-provider-account-or-identity-check)).
