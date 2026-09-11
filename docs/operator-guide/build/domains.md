---
title: "Domains"
---

**Dashboard → Build → Domains**

Two separate allowlists live on this page:

| List | What it controls |
| --- | --- |
| **Allowed origins** | Where your app is served from. Gates CORS, publishable-key use and passkey login. Every request that arrives with an `Origin` header is checked against it. |
| **Allowed redirect URIs** | Where an OAuth login may redirect back to. Nothing else. |

They are separate on purpose. A publishable key is public, so the origins list is what stops someone else from using your key from their own page. Your OAuth callback often lives somewhere you never serve pages from (your backend, say) — listing it as a redirect URI lets it receive the redirect without also becoming allowed to make browser requests with your key.

---

## Adding an origin

Click **Add** under **Allowed origins** and enter the origin including the protocol:

```
http://localhost:3000
https://yourapp.com
https://staging.yourapp.com
```

Changes take effect immediately — no redeployment required.

---

## Adding a redirect URI

Click **Add** under **Allowed redirect URIs** and enter the full callback URL:

```
https://api.yourapp.com/oauth/callback
http://localhost:3000/oauth/callback
```

Only the **origin** of each entry is matched today, so one entry covers every path under that host. Entries with a path are still accepted, and future releases will match them exactly — list the real callback URL rather than a bare origin.

**This list is the only thing an OAuth redirect is checked against.** While it is empty every OAuth login of the app is refused with `APPLICATION_HAS_NO_REDIRECT_URIS`, so register your callback here before going live. Once it is set, drop from the origins list anything that was only ever there to receive a callback.

---

## Development entries on a mainnet app

The dashboard marks any `localhost` or plain-`http` entry on a mainnet app. It does not block it: testing a mainnet app from your machine is a normal thing to do. It is there to remind you that a publishable key is public, so while that entry is in the **origins** list, anyone serving a page on that host can use the key. Remove it once you stop testing.

Listing localhost only as a **redirect URI** does not carry that risk.

---

## Common issues

**SDK throws `Origin not allowed`**
Your app's domain is not in the allowed list. Add it under **Allowed origins**.

**OAuth login fails with `REDIRECT_URI_NOT_ALLOWED`**
The `redirect_uri` your app sent is not covered by either list. Add its origin under **Allowed redirect URIs**.

**Localhost not working**
Add `http://localhost:3000` (or your local port) explicitly, to whichever list applies. Wildcard subdomains and wildcard ports are not supported.

**Staging environment blocked**
Add each environment URL separately — `https://staging.yourapp.com`, `https://preview.yourapp.com`, etc.
