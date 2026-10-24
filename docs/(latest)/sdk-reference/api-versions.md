---
title: "API versions"
description: "Which version of the Pollar SDK API your app uses, and how to move off v1 before it is retired on 2026-11-30."
---

The SDK API (`https://sdk.api.pollar.xyz`) is versioned in the path (`/v1/...`, `/v2/...`, `/v3/...`). Each `@pollar/core` release talks to one version, so the version your app uses is decided by the SDK version your users run.

| API version | Status | `@pollar/core` |
|---|---|---|
| v1 | **Retired on 2026-11-30.** Answers `410 Gone` from then on. Ramps already answer `410`. | 0.10.x and older |
| v2 | Frozen (security fixes only). Ramps answer `410`. | 0.11.x |
| v3 | Current | 0.12.0 and later |

The reference for each release line is in the version selector at the top of the sidebar: **Latest** documents 0.12 and API v3, and **SDK 0.11 / Server API v1** keeps the [0.11 reference](https://docs.pollar.xyz/docs/v0.11/pollar-core) and the [Server API v1 reference](https://docs.pollar.xyz/docs/v0.11/server-api).

---

## Ramps run on v3 only

Ramps are a v3 feature: routes with several legs, orders and per-leg approvals. On `/v1/ramps/*` and `/v2/ramps/*`, every call that starts a ramp answers `410 Gone` today, whatever SDK sent it:

```json
{
  "code": "SDK_RAMPS_MOVED_TO_V3",
  "success": false,
  "message": "Ramps moved to /v3/ramps. Upgrade @pollar/core (and @pollar/react) to 0.12.0 or later.",
  "migrationGuide": "https://docs.pollar.xyz/docs/sdk-reference/api-versions"
}
```

`/ramps/transaction/*` stays open on both, so a ramp already under way can still be signed, completed and followed to its end. To offer ramps, upgrade to 0.12.0 (see [How to move](#how-to-move)).

## KYC

KYC lives on `/v3/kyc`, and also on `/v2/kyc` for 0.11.x. `/v1/kyc/*` retires with the rest of v1. A client of your own that calls `/v1/kyc` moves to `/v3/kyc`; the requests and answers are the same.

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

v2 and v3 keep working (ramps aside, see above). For your users, this means an app still on v1 stops signing them in and stops sending transactions.

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

| Server API version | Status |
|---|---|
| v1 | Frozen (security fixes only). Keeps working; its retirement will be announced with its own date. [Reference](https://docs.pollar.xyz/docs/v0.11/server-api). |
| v3 | Current; new server-side features land here. [Reference](https://docs.pollar.xyz/docs/sdk-reference/server-api). |

There is no Server API v2: the Server API jumps to v3 so both APIs share the current version number. v3 serves every v1 endpoint with the same requests and answers except three user routes, and adds two groups:

| | v1 | v3 |
|---|---|---|
| `POST /users`, `POST /users/with-wallet`, `GET /users/{externalId}/balances` | Yes | No |
| `/ramps` (server-side ramps, for a user named in `x-pollar-external-user-id`) | No | Yes |
| `/billing` (credits, usage, statements, deposit addresses, distribution vault; read only) | No | Yes |

A backend that does not call those three user routes moves from `/v1` to `/v3` by changing the prefix. One that does keeps them on `/v1`: in v3, a server-side user is your own id for that user, created by the first ramp call that names it.
