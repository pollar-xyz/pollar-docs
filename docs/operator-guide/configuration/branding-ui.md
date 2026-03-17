---
title: "Branding & UI"
---

**Dashboard → Configuration → Branding & UI**

Customize the appearance of the `WalletButton` modal — the pre-built login component from `@pollar/react`.

---

## What you can customize

| Setting | Description |
|---|---|
| **Logo** | Your app's logo shown at the top of the modal |
| **Primary color** | Button and accent color |
| **App name** | Displayed in the modal header |
| **Auth providers** | Which providers appear in the modal (Google, GitHub, Discord, Email OTP) |
| **Border radius** | Rounded or sharp corners |
| **Dark mode** | Auto (follows system), always light, or always dark |

---

## Auth providers

Enable or disable each provider from the Branding & UI section. Only enabled providers appear in the `WalletButton` modal.

| Provider | Type |
|---|---|
| Google | OAuth |
| GitHub | OAuth |
| Discord | OAuth |
| Email | OTP (one-time password sent to inbox) |

Changes apply immediately — no SDK update or redeployment required.

---

## Preview

The Dashboard shows a live preview of the modal as you make changes.