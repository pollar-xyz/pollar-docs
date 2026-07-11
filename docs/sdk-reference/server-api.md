---
title: "Pollar Server API"
---

REST API for backend operations. All endpoints require your **secret key** — never call these from client-side code.

**Base URL:** `https://api.pollar.xyz` — all routes are versioned under `/v1`.

**Authentication:** pass your secret key in the `x-pollar-api-key` header (not `Authorization`).

```bash
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

Wallets are identified by their on-chain **public key** (`G…` address), not by an opaque id.

**Response envelope.** Every response is wrapped:

- Success: `{ "content": <data>, "code": "<SUCCESS_CODE>", "success": true }`
- Error: `{ "code": "<ERROR_CODE>", "success": false }` (plus any extra fields). The HTTP status carries the status; there is no `status` field in the body.

---

## Wallets

### `POST /v1/wallets/activate`

Activates a wallet by funding its XLM reserve on-chain. Used in Deferred mode when a business event occurs (KYC approved, first deposit, etc.).

```bash
POST https://api.pollar.xyz/v1/wallets/activate
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "publicKey": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
```

`publicKey` must be a 56-character Stellar public key starting with `G`.

**Response codes:**

| Code                      | Meaning                                                                    |
| ------------------------- | -------------------------------------------------------------------------- |
| `200 OK`                  | Wallet activated. XLM reserve funded on-chain.                             |
| `400 Bad Request`         | Missing or malformed `publicKey` (`VALIDATION_ERROR`).                     |
| `403 Forbidden`           | `publicKey` belongs to a wallet owned by another app (`FORBIDDEN`).        |
| `404 Not Found`           | `publicKey` is not a known wallet (`WALLET_NOT_FOUND`).                    |
| `409 Conflict`            | Wallet is already funded (`WALLET_ALREADY_FUNDED`). Safe to ignore.        |
| `502 Bad Gateway`         | Funding the XLM reserve failed (`FUND_XLM_FAILED`) — e.g. the funding wallet has insufficient XLM, or a transient Stellar network issue. Retry. |

**Response body (`200`):**

```json
{
  "content": {
    "publicKey": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "amount": "1.5"
  },
  "code": "SERVER_WALLET_ACTIVATED",
  "success": true
}
```

`amount` is the XLM reserve funded (1 XLM base + 0.5 per configured asset).

---

## Trustlines

Enable or disable asset trustlines on a user wallet. The wallet must already be funded.

### `POST /v1/wallets/:address/trustlines/default`

Enables trustlines for all of your app's configured (default) assets on the given wallet.

```bash
POST https://api.pollar.xyz/v1/wallets/GXXX.../trustlines/default
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

### `POST /v1/wallets/:address/trustlines`

Enables explicit trustlines for the assets in the body.

```bash
POST https://api.pollar.xyz/v1/wallets/GXXX.../trustlines
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "assets": [
    { "code": "USDC", "issuer": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
  ]
}
```

Returns `code: "SERVER_TRUSTLINES_ENABLED"`.

### `DELETE /v1/wallets/:address/trustlines/:asset`

Removes a trustline (the asset must have a zero balance). The `:asset` segment is `CODE:ISSUER` (e.g. `USDC:GA5Z…`). Returns `code: "SERVER_TRUSTLINE_DISABLED"`.

---

## Users

Register an app user (and optionally provision a wallet for them).

### `POST /v1/users`

```bash
POST https://api.pollar.xyz/v1/users
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "externalId": "your-user-id",
  "email": "user@example.com"
}
```

`externalId` (1–255 chars) is required; `email`, `firstName`, `lastName`, and `avatar` are optional. Returns `201` with `code: "SERVER_USER_REGISTERED"`.

### `POST /v1/users/with-wallet`

Same body as above, but also creates a Stellar wallet for the user in one call. Returns `201` with `code: "SERVER_USER_WALLET_CREATED"`.

---

## Tokens

### `POST /v1/tokens/verify`

Validates an SDK end-user access token server-side (e.g. to authenticate a user on your backend from a token minted client-side by the SDK).

```bash
POST https://api.pollar.xyz/v1/tokens/verify
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "token": "<sdk access token>"
}
```

On success returns `code: "SERVER_TOKEN_VERIFIED"` with content
`{ userId, applicationId, expiresAt, network, wallet, profile, authProvider }`.

**Error codes:** `SDK_AUTH_TOKEN_EXPIRED` (`401`), `SDK_AUTH_INVALID_TOKEN` (`401`), `SDK_TOKEN_WRONG_APPLICATION` (`403`).

---

## Error format

Errors are returned in the standard envelope:

```json
{
  "code": "FUND_XLM_FAILED",
  "success": false
}
```

The HTTP status code carries the status. For the list of codes see [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes).
