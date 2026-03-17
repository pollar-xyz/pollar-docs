---
title: "API Keys"
---

**Dashboard → Configuration → API Keys**

---

## Key types

| Type | Prefix | Network | Use |
|---|---|---|---|
| Publishable | `pub_testnet_` | Testnet | Frontend only (safe to expose) |
| Publishable | `pub_mainnet_` | Mainnet | Frontend only (safe to expose) |
| Secret | `sec_testnet_` | Testnet | Backend only (never expose client-side) |
| Secret | `sec_mainnet_` | Mainnet | Backend only (never expose client-side) |

**Publishable keys** are passed to `@pollar/core` or `@pollar/react` in your frontend. They can only initiate user-authenticated operations.

**Secret keys** are used in your backend for privileged endpoints like `POST /wallets/activate`. Never expose them client-side.

---

## Generating a key

1. Click **Generate key**
2. Select type (Publishable or Secret) and network
3. Copy the key immediately — secret keys are only shown once

---

## Rotating a key

1. Click **Rotate** next to the key
2. A new key is generated immediately
3. Update your environment variables
4. The old key is invalidated — requests using it return `API_KEY_REVOKED`

Rotate your secret key immediately if you suspect it has been exposed.

---

## Key permissions

| Operation | Publishable | Secret |
|---|---|---|
| Login / logout | ✓ | ✓ |
| Send payment | ✓ | ✓ |
| Get wallet | ✓ | ✓ |
| Get history | ✓ | ✓ |
| Activate wallet | — | ✓ |
| Get app config | — | ✓ |
| List all wallets | — | ✓ |

---

## Multiple keys

You can generate multiple keys of the same type — useful for separate deployment environments (staging, production) or rotating keys without downtime.

All active keys are listed with their creation date and last used timestamp.

---

## Security checklist

- Never commit keys to version control — use environment variables
- Never prefix secret keys with `NEXT_PUBLIC_` or `VITE_`
- Use separate keys for testnet and mainnet
- Rotate keys periodically and immediately after any suspected exposure