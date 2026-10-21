---
title: "API versions"
description: "Which version of the Pollar SDK API your app uses, and how to move off v1 before it is retired on 2026-11-30."
---

The SDK API is versioned in the path (`/v1/...`, `/v2/...`, `/v3/...`). Each `@pollar/core` release talks to one version, so the version your app uses is decided by the SDK version your users run.

| API version | Status | `@pollar/core` |
|---|---|---|
| v1 | **Retired on 2026-11-30.** Answers `410 Gone` from then on. | 0.10.x and older |
| v2 | Frozen (security fixes only) | 0.11.x |
| v3 | Current | 0.12.0 and later |

---

## Is my app on v1?

- **Dashboard.** Open your app and go to **Monitor > SDK versions** ([guide](https://docs.pollar.xyz/docs/operator-guide/monitor/sdk-versions)). Any build below 0.11.0 calls v1. While your app has called v1 in the last 30 days, a banner on the app's **Home** says so.
- **Response headers.** Every v1 response carries:

  ```http
  Deprecation: true
  Sunset: Mon, 30 Nov 2026 23:59:59 GMT
  Link: <https://docs.pollar.xyz/docs/sdk-reference/api-versions>; rel="successor-version"
  ```

- **Your own client.** If you call the SDK API without `@pollar/core`, check the path prefix of your requests.

SDKs older than 0.11.4 do not identify their version, so the dashboard lists their sessions as not reporting. Treat those as v1 until they upgrade.

---

## What happens on 2026-11-30

From **2026-11-30 23:59:59 UTC** every request to `/v1/*` answers `410 Gone`, `/v1/kyc/*` included, with no exceptions:

```json
{
  "code": "API_VERSION_SUNSET",
  "success": false,
  "message": "sdk-api v1 was retired on 2026-11-30. ...",
  "sunsetAt": "2026-11-30T23:59:59.000Z",
  "migrationGuide": "https://docs.pollar.xyz/docs/sdk-reference/api-versions"
}
```

v2 and v3 keep working. For your users, this means an app still on v1 stops signing them in and stops sending transactions.

### Rehearsals before the date

Before 2026-11-30, v1 is switched off for short, announced windows so an integration that still depends on it fails where you can see it:

- around **2026-11-10**, for 1 hour
- around **2026-11-20**, for 4 hours

The exact times are sent by email to the owners of apps still on v1 and shown in the dashboard banner. During a window v1 answers the same `410` with a `Retry-After` header (seconds until the window ends).

---

## How to move

1. **Upgrade the SDK** to 0.12.0 or later:

   ```bash
   npm install @pollar/core@latest @pollar/react@latest
   ```

   Read the `UPGRADE.md` shipped with the package for every version you skip: 0.9.0 renamed `session.wallet.publicKey` to `session.wallet.address`, 0.11.0 made balances multichain, and 0.12.0 moves the SDK to API v3.
2. **Deploy your frontend.** Users pick up the new SDK on their next page load. Their sessions are kept.
3. **Confirm** on **Monitor > SDK versions** that no live session remains on a build below 0.11.0, and that the banner on Home is gone.

If you pass a custom `baseUrl` to the SDK, pass the origin only (`https://sdk.api.example.com`). The SDK appends the version prefix itself.

---

## What is not affected

The [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api), which your backend calls with a **SECRET** key, is a separate API and is not part of this retirement.
