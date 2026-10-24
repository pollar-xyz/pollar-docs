---
title: "API Keys"
---

---

Pollar issues two types of keys for each app. Understanding the difference is important before writing any code.

---

## Key types

| Type        | Prefix         | Network | Use                                     |
| ----------- | -------------- | ------- | --------------------------------------- |
| Publishable | `pub_testnet_` | Testnet | Frontend only (safe to expose)          |
| Publishable | `pub_mainnet_` | Mainnet | Frontend only (safe to expose)          |
| Secret      | `sec_testnet_` | Testnet | Backend only (never expose client-side) |
| Secret      | `sec_mainnet_` | Mainnet | Backend only (never expose client-side) |

The **publishable key** is passed to `@pollar/core` or `@pollar/react` in your frontend. The **secret key** stays on your backend and calls the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api), for privileged operations like funding deferred wallets with `POST /v3/wallets/fund`.

A key belongs to one app, and its network is the app's: a testnet app issues `_testnet_` keys and a mainnet app issues `_mainnet_` keys. To get mainnet keys, request mainnet for your app and create the keys on its mainnet counterpart.

> For details on Stellar networks (Testnet vs Mainnet) see the [Stellar Networks docs](https://developers.stellar.org/docs/networks).

---

## Generating a key

1. Go to [dashboard.pollar.xyz](https://dashboard.pollar.xyz) and sign in with Google or an email code
2. Open your app and go to **Build > API Keys**
3. Click **+ Create key** under **Publishable keys** or **Secret keys**
4. Give it a **Name** and, optionally, an **Expiration** date
5. Copy the key and store it securely: the full key is shown only once, right after you create it, for both types

A key name is unique among the app's keys of the same type, ignoring case; a name already in use is refused (`409 API_KEY_NAME_TAKEN`). A key past its expiration date stops working (`401 API_KEY_EXPIRED`).

A publishable key used from a native app (React Native, Expo, mobile), which sends no `Origin` header, needs **Allow native clients** turned on for that key in the key's menu.

Start with `pub_testnet_` for development. Switch to `pub_mainnet_` when ready for production.

---

## Rate limits

Limits are per minute and the same on testnet and mainnet:

| API | Limit |
|---|---|
| SDK API (`sdk.api.pollar.xyz`), every route | 200 requests per minute for each publishable key and client IP |
| SDK API sign-in routes (`/auth/*`) | On top of the above, 20 requests per minute for each client IP and route; 60 for `/auth/refresh` and `/auth/session/resume`. The login status polls (`/auth/session/status/*`, `/auth/sessions`) count only toward the general limit |
| Server API (`server.api.pollar.xyz`) | None |
| MCP Gateway (`mcp.api.pollar.xyz`) | None |

The SDK API bucket is the key and the client IP together, so one looping client never spends the quota of an app's other users. Over the limit, a request answers `429` with code `RATE_LIMITED` and `RateLimit-*` headers that say when the window resets.

---

## Environment variables

Store keys in environment variables: never hardcode them or commit them to version control.

### Next.js

```bash
# .env.local
NEXT_PUBLIC_POLLAR_PUBLISHABLE_KEY=pub_testnet_xxxxxxxxxxxxxxxxxxxx
POLLAR_SECRET_KEY=sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

`NEXT_PUBLIC_` prefix makes the publishable key available client-side. Never apply this prefix to the secret key.

### Vite / CRA

```bash
# .env.local
VITE_POLLAR_PUBLISHABLE_KEY=pub_testnet_xxxxxxxxxxxxxxxxxxxx
POLLAR_SECRET_KEY=sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

`VITE_` prefix exposes the variable to the browser bundle. Never apply it to the secret key.

---

## Security rules

- The publishable key is safe to expose in frontend code: it can only initiate user-authenticated operations

- The secret key must never appear in client-side code, browser bundles, or public repositories

- For mainnet, use build-time environment injection or a backend proxy: never hardcode `pub_mainnet_` in source

- Delete a compromised key immediately from **Dashboard > Build > API Keys** and create a new one
