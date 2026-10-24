---
title: "API Keys"
---

**Dashboard > Build > API Keys** · Chains: all

The page has two tables: **Publishable keys** (safe in frontend code) and **Secret keys** (backend only).

---

## Key types

| Type | Prefix | Use |
|---|---|---|
| Publishable | `pub_testnet_` / `pub_mainnet_` | Passed to `@pollar/core` or `@pollar/react` in your frontend. Calls the SDK API on behalf of a signed-in user, and only from an origin listed under **Build > Domains**. |
| Secret | `sec_testnet_` / `sec_mainnet_` | Used by your backend for the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) (for example `POST /v3/wallets/fund`). Never expose it client-side. |

The network in the prefix is the **app's** network: it is not chosen per key.

---

## Creating a key

1. Click **+ Create key** on the Publishable or the Secret table.
2. Enter a **Name** (for example "Production frontend"). Names are unique per key type within the app, ignoring case; a duplicate is refused with "A key with this name already exists."
3. Optionally set an **Expiration** date. After that date the key stops working (`API_KEY_EXPIRED`).
4. Click **Create key** and copy the key right away. The full key is shown only once, for both types; afterwards the table shows its prefix and a mask.

The tables list each key's **Name**, **Key** (prefix), **Created** and **Expires** dates.

---

## Native clients

A publishable key normally answers only requests that carry an allowed `Origin` header. A native mobile or desktop app sends no `Origin`. The row action **Allow native clients** lets that publishable key be used without an `Origin`; **Disable native clients** turns it back off. Enable it only on a key that ships inside a native app.

---

## Rotating a key

There is no dedicated rotate action. Rotate by creating a replacement and deleting the old one:

1. Create a new key of the same type.
2. Update your environment variables to the new key.
3. **Delete key** on the old one. Requests that still use it fail with `API_KEY_NOT_FOUND`.

Rotate a secret key immediately if you suspect it has been exposed.

---

## Multiple keys

You can create several keys of the same type, for example one per deployment environment, or to rotate without downtime.

---

## Security checklist

- Never commit keys to version control; use environment variables.
- Never prefix secret keys with `NEXT_PUBLIC_` or `VITE_`.
- Give keys an expiration when they are meant to be temporary.
- Rotate keys periodically and immediately after any suspected exposure.
