---
title: "Pollar Server API"
---

REST API for backend operations. All endpoints require your **secret key** — never call these from client-side code.

**Base URL:** `https://server.api.pollar.xyz` — all routes are versioned under `/v1`.

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

### `POST /v1/wallets/fund`

Funds a custodial wallet on-chain, the same way the SDK login does: a CAP-33 sponsored createAccount where the app's funding wallet sponsors the base reserve and the wallet is seeded with the app's configured starting balance. Used in Deferred mode when a business event occurs (KYC approved, first deposit, etc.). Custodial (Pollar-managed) wallets only — external wallets fund themselves.

```bash
POST https://server.api.pollar.xyz/v1/wallets/fund
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
| `200 OK`                  | Wallet funded. Its reserve is sponsored on-chain.                          |
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
    "startingBalance": "1"
  },
  "code": "SERVER_WALLET_FUNDED",
  "success": true
}
```

`startingBalance` is the XLM the wallet was seeded with (the app's configured starting balance from **Dashboard → Treasury → Account Funding**; `"0"` when unset). The sponsored base reserve is locked in the funding wallet, not transferred.

### `POST /v1/wallets/{publicKey}/signer-rotation`

Grants the user whose external Stellar wallet is `publicKey` one sponsored signer rotation, for account recovery. The user then builds it from the client with `POST /wallet/signer/build` (see [Rotate the wallet signer](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter#rotate-the-wallet-signer)), and the app pays the fee and the 0.5 XLM reserve of the new signer. The grant is spent when that rotation lands; another rotation needs a new grant.

```bash
POST https://server.api.pollar.xyz/v1/wallets/GBW4...CX7H/signer-rotation
x-pollar-api-key: sec_mainnet_xxxxxxxxxxxxxxxxxxxx
```

Requires **Signer rotation** on under **Dashboard > Treasury > Sponsorship**. Granting while the user already holds an unspent grant returns that grant.

**Response codes:**

| Code | Meaning |
| --- | --- |
| `200 OK` | Granted (`SERVER_SIGNER_ROTATION_GRANTED`). `content` is `{ userId, grant }`. |
| `403 Forbidden` | The app does not sponsor rotations (`SIGNER_ROTATION_NOT_ENABLED`). |
| `404 Not Found` | No user of this app has that wallet (`USER_NOT_FOUND`). |
| `422 Unprocessable` | The wallet is custodial; only wallets Pollar does not hold are rotated (`SIGNER_ROTATION_INVALID`). |

### `DELETE /v1/wallets/{publicKey}/signer-rotation`

Revokes the user's unspent grant. Returns `200` with `code: "SERVER_SIGNER_ROTATION_REVOKED"` and `content: { userId, revoked }`, where `revoked` is `false` when there was nothing to revoke.

---

## Trustlines

There is no server-side trustline endpoint. `change_trust` is a signed operation and server-api never signs an end-user wallet, so trustlines are set from the SDK, where the wallet signs client-side: `setTrustline()` on the client, or the app's default assets configured in **Dashboard → Treasury → Tokens & Trustlines**, which are applied at login.

---

## Users

Register an app user (and optionally provision a wallet for them).

### `POST /v1/users`

```bash
POST https://server.api.pollar.xyz/v1/users
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
POST https://server.api.pollar.xyz/v1/tokens/verify
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
