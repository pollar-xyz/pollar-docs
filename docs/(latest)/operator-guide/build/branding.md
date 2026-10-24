---
title: "Branding"
---

**Dashboard → Build → Branding** · Chains: all

Customize the appearance of every modal in `@pollar/react` (login, KYC, transaction, send, swap, receive, ramp, history, balance, sessions, ...) and of the `<WalletButton>`.

---

## What you can customize

| Setting | Description |
|---|---|
| **Theme** | Modal appearance: **Light** or **Dark** |
| **Accent** | Primary button fill, focus rings and spinners (default `#005DB4`). The primary button label switches to dark text on a pale accent. |
| **Buttons** | Fill of the secondary buttons (wallet, social and provider entries, back/cancel). Empty: the theme default. |
| **Text** | Body text color. Empty: the theme default. |
| **Background** | Modal card background. Empty: the theme default. Setting Background or Text also blends the borders, secondary text and input fills from the pair. |
| **Modal title** | Heading of the **login** modal only. Empty: the application's name. |
| **Corners** | Border radius of the modal card and, separately, of its buttons |
| **Stacking order** | z-index of the modal overlay (default 50). Raise it when a layer of your own app renders on top of the modal. |
| **Logo** | Logo displayed in the login modal (PNG, JPG, SVG, WEBP, max 1 MB) |
| **Login methods** | Toggle **Email** login on/off. **Social providers** are marked _Coming soon_ and are not individually toggleable yet. |
| **Wallets** | **Embedded wallets** and **Smart Wallet (passkey)** options |

> App name is edited in **Build → Settings**, not here.

Each setting maps to a CSS variable, and your app's own stylesheet takes precedence over the dashboard. See [Theming](https://docs.pollar.xyz/docs/sdk-reference/theming) to override them per app or follow your app's dark mode.

---

## Preview

The Dashboard shows a live preview of the branded surfaces as you make changes, with tabs for **Login**, **KYC**, **Transaction**, **Tx History**, **Balance**, **Ramp**, and **Button**. You can also **Export configuration**.

Changes apply immediately — no SDK update or redeployment required.