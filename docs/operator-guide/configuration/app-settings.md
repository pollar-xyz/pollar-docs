---
title: "App Settings"
---

**Dashboard → Configuration → App Settings**

General configuration for your Pollar app.

---

## App name

The display name for your app. Shown in the Dashboard and in the `WalletButton` modal header.

---

## Allowed origins

A list of domains allowed to make requests to the Pollar Server using your publishable key. Requests from unlisted origins are rejected with a `403 Forbidden` error.

Add your development and production URLs:

```
http://localhost:3000
https://yourapp.com
https://staging.yourapp.com
```

> This is separate from **Dashboard → Configuration → Domains**, which controls domain verification for SEP-10 and anchor flows.

---

## Network

Shows whether this app is configured for **Testnet** or **Mainnet**. Network is set at app creation and cannot be changed. To switch networks, create a new app or use the network selector in the top navigation bar to toggle between your Testnet and Mainnet app environments.

---

## Delete app

Permanently deletes the app and all associated configuration. User wallets on the Stellar network are not affected — they exist independently on-chain. This action cannot be undone.