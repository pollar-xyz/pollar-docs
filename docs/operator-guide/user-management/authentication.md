---
title: "Authentication"
---

**Dashboard → User Management → Authentication**

Configure which authentication providers are available to your users.

---

## Supported providers

| Provider | Type | Setup required |
|---|---|---|
| **Google** | OAuth 2.0 | None — Pollar handles the OAuth flow |
| **GitHub** | OAuth 2.0 | None — Pollar handles the OAuth flow |
| **Discord** | OAuth 2.0 | None — Pollar handles the OAuth flow |
| **Email OTP** | One-time password | None — Pollar sends the OTP email |

Enable or disable each provider here. Only enabled providers appear in the `WalletButton` modal and are accepted by `login()`.

---

## Custom OAuth app `coming soon`

By default, Pollar uses its own OAuth credentials for Google, GitHub, and Discord. You can configure your own OAuth app credentials for a fully branded experience — users will see your app name in the OAuth consent screen instead of Pollar's.