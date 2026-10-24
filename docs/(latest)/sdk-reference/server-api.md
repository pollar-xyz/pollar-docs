---
title: "Pollar Server API"
---

REST API for your backend. Every endpoint takes your **secret key**, so never call it from client-side code.

**Base URL:** `https://server.api.pollar.xyz/v3`.

**Versions.** `/v3` is the current version: new integrations use it, and server-side features land here. `/v1` is frozen (security fixes only) and keeps working; its retirement will be announced with its own date. The two are not identical:

| | v1 | v3 |
|---|---|---|
| `POST /users`, `POST /users/with-wallet`, `GET /users/{externalId}/balances` | Yes | No |
| `/ramps` (server-side ramps) | No | Yes |
| `/billing` (credits, usage, vault) | No | Yes |
| Every other group on this page | Yes | Yes, same requests and answers |

A backend on `/v1` that does not call the three user routes moves by changing the prefix. One that does keeps them on `/v1`: in v3 a server-side user is your own id for that user, sent in `x-pollar-external-user-id` and created by the first ramp call that names it. The v1 reference is [Server API v1](https://docs.pollar.xyz/docs/v0.11/server-api); see also [API versions](https://docs.pollar.xyz/docs/sdk-reference/api-versions).

**Reference.** The OpenAPI documents are public: `https://server.api.pollar.xyz/openapi.v3.json` (v3) and `https://server.api.pollar.xyz/openapi.json` (v1). The interactive reference for v3 is `https://server.api.pollar.xyz/docs/v3`, where you can paste a secret key and send real requests.

**Authentication:** pass your secret key in the `x-pollar-api-key` header (not `Authorization`).

```bash
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
```

The key decides the app and its network: every call acts on the app that owns the key, and on no other.

| Code | Meaning |
|---|---|
| `404 API_KEY_NOT_FOUND` | No `x-pollar-api-key` header, an unknown key, or the key of a deleted or archived app |
| `401 API_KEY_EXPIRED` | The key is past its expiration date |
| `403 API_KEY_TYPE_NOT_ALLOWED` | A publishable (`pub_`) key was sent; this API takes secret keys only |

There is no rate limit on the Server API.

**Response envelope.** Every response is wrapped:

- Success: `{ "content": <data>, "code": "<SUCCESS_CODE>", "success": true }`
- Error: `{ "code": "<ERROR_CODE>", "success": false }` (plus any extra fields). The HTTP status carries the status; there is no `status` field in the body.

`GET /v3/health` answers without a key.

---

## Wallets

Stellar wallets are identified by their on-chain **public key** (a `G...` address), not by an opaque id.

### `GET /v3/wallets`

Lists the app's wallets on every chain, in three arrays: `appWallets` (the app's own wallets: funding, gas, distribution), `sdkWallets` (wallets Pollar holds for your users) and `externalWallets` (wallets your users bring, identified by their sign-in identity). Each row carries `id`, `network`, `public_key`, `created_at` and per-source metadata. Code `SERVER_WALLETS_LIST`.

### `GET /v3/wallets/{address}/balance`

Reads the on-chain balance of any address. `?chain=stellar|polygon|solana` is optional: without it the chain is inferred from the address format. Stellar lists every trustline; Polygon and Solana list the native coin and token balances. Balances are public data, so the address does not have to belong to the app. Code `SERVER_WALLET_BALANCE`; `400` when the chain cannot be told.

### `POST /v3/wallets/fund`

Opens a Deferred wallet's Stellar account when a business event happens (KYC approved, first deposit, etc.). A custodial wallet is funded on-chain the same way the SDK login does it: a CAP-33 sponsored createAccount whose sponsor locks the base reserve, seeding the wallet with the app's configured starting balance.

The sponsor is the app's funding wallet (its global wallet when the app has no split wallets). For an app on credits, Pollar's pool sponsors the account and the app's credits pay for it (see [Credits](https://docs.pollar.xyz/docs/core-concepts/credits)).

A co-signed or self-custody (Turnkey) wallet needs its user's vote, so the call opens the account creation request instead and answers `202` with its `requestId`. The user approves it in their next session (the SDK shows it like any setup request), and the account is created with the same sponsor and starting balance. Calling again while it is pending answers the same request. A wallet your user brings is refused (`400 TX_EXTERNAL_WALLET_SERVER_SIGN`).

```bash
POST https://server.api.pollar.xyz/v3/wallets/fund
x-pollar-api-key: sec_testnet_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json

{
  "publicKey": "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
```

`publicKey` must be a 56-character Stellar public key starting with `G`.

**Response codes:**

| Code | Meaning |
| --- | --- |
| `200 OK` | Wallet funded (`SERVER_WALLET_FUNDED`). Its reserve is sponsored on-chain. |
| `202 Accepted` | Turnkey wallet: the account creation waits for the user's approval (`SERVER_WALLET_ACCOUNT_REQUESTED`, content `{ publicKey, requestId }`). |
| `400 Bad Request` | Missing or malformed `publicKey` (`VALIDATION_ERROR`), or a wallet your user brings (`TX_EXTERNAL_WALLET_SERVER_SIGN`). |
| `402 Payment Required` | App on credits: its credits do not cover the account (`SDK_CREDITS_INSUFFICIENT`), or a postpaid statement is overdue (`SDK_BILLING_OVERDUE`). Top up from **Billing > Credits**. |
| `403 Forbidden` | `publicKey` belongs to a wallet owned by another app (`FORBIDDEN`). |
| `404 Not Found` | `publicKey` is not a known wallet (`WALLET_NOT_FOUND`), or the app has no funding or global wallet to sponsor it (`APP_WALLET_NOT_FOUND`). |
| `409 Conflict` | Wallet is already funded (`WALLET_ALREADY_FUNDED`). Safe to ignore. |
| `502 Bad Gateway` | Funding the reserve failed (`FUND_XLM_FAILED`): the funding wallet lacks XLM, or a transient Stellar network issue. Retry after topping it up. |

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

`startingBalance` is the XLM the wallet was seeded with (the app's starting balance from **Dashboard > Wallets > Account Funding**; `"0"` when unset). The sponsored base reserve stays locked in the sponsor's account, not transferred.

### `POST /v3/wallets/{publicKey}/signer-rotation`

Grants the user whose external Stellar wallet is `publicKey` one sponsored signer rotation, for account recovery. The user then builds it from the client with `POST /wallet/signer/build` (see [Rotate the wallet signer](https://docs.pollar.xyz/docs/guides/custom-wallet-adapter#rotate-the-wallet-signer)), and the app pays the fee and the 0.5 XLM reserve of the new signer. The grant is spent when that rotation lands; another rotation needs a new grant.

```bash
POST https://server.api.pollar.xyz/v3/wallets/GBW4...CX7H/signer-rotation
x-pollar-api-key: sec_mainnet_xxxxxxxxxxxxxxxxxxxx
```

Requires **Sponsor signer rotations** and its **Include external wallets** sub-option on under **Dashboard > Wallets > Sponsorship**. Granting while the user already holds an unspent grant returns that grant.

**Response codes:**

| Code | Meaning |
| --- | --- |
| `200 OK` | Granted (`SERVER_SIGNER_ROTATION_GRANTED`). `content` is `{ userId, grant }`, where `grant` has `id`, `status` (`ACTIVE`, `CONSUMED`, `REVOKED`) and its timestamps. |
| `403 Forbidden` | The app does not sponsor rotations (`SIGNER_ROTATION_NOT_ENABLED`). |
| `404 Not Found` | No user of this app has that wallet (`USER_NOT_FOUND`). |
| `422 Unprocessable` | The wallet is custodial; only wallets Pollar does not hold are rotated (`SIGNER_ROTATION_INVALID`). |

### `DELETE /v3/wallets/{publicKey}/signer-rotation`

Revokes the user's unspent grant. Returns `200` with `code: "SERVER_SIGNER_ROTATION_REVOKED"` and `content: { userId, revoked }`, where `revoked` is `false` when there was nothing to revoke.

---

## Trustlines

There is no server-side trustline endpoint. `change_trust` is a signed operation and the Server API never signs for an end-user wallet, so trustlines are set from the SDK, where the wallet signs client-side: `setTrustline()` on the client, or the app's default assets configured in **Dashboard > Wallets > Tokens & Trustlines**, which are applied at login.

---

## Users

### `GET /v3/users`

Lists the app's SDK end users, a page at a time. Query parameters, all optional:

| Parameter | Values |
|---|---|
| `q` | Search by name, email, id or wallet |
| `filter` | `all`, `with-wallet`, `without-wallet`, `active-7d` |
| `sortBy` | `user`, `providers`, `wallet`, `last_login_at` |
| `sortDir` | `asc`, `desc` |
| `page` | Page number, from 1 |
| `limit` | Page size, 1 to 200 |

`content` is `{ items, total, page, limit, totalPages, stats }`. Each item has `id`, name, `email`, `providers`, `wallet_public_key` (the primary wallet), `wallets` (one `{ network, public_key }` per chain), `last_login_at` and `created_at`; `stats` is `{ total, withWallet, active7d }`. Code `SERVER_SDK_USERS_LIST`.

### `GET /v3/users/export.csv`

The same users as a CSV file (`text/csv`).

---

## Ramps

Server-side ramps: the same routes and answers as the SDK's v3 ramps, for an end user your backend names. See [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps) for how routes, quotes, orders and legs fit together.

Every ramp call needs the header **`x-pollar-external-user-id`**: your backend's id for the end user, 1 to 128 characters from `A-Za-z0-9_.:@-`. It is never personal data. The user is created on the first call that names them, and every call acts only on that user's quotes and orders. A call without a valid header answers `400 VALIDATION_ERROR`.

```bash
x-pollar-api-key: sec_mainnet_xxxxxxxxxxxxxxxxxxxx
x-pollar-external-user-id: user_8231
```

| Route | Does |
|---|---|
| `GET /v3/ramps/routes?direction=ONRAMP\|OFFRAMP` | The fiat and asset pairs the app can ramp between, each with the leg kinds of its shortest path. Nothing is quoted. |
| `POST /v3/ramps/quotes` | Plans every route between the fiat and the asset and quotes each leg live. |
| `POST /v3/ramps/orders` | Turns a quote into an order and runs its first leg. |
| `GET /v3/ramps/orders` | The user's orders, newest first. |
| `GET /v3/ramps/orders/{id}` | One order: every leg, the `pendingAction`, the `failure` and `nextPollAfter`. |
| `POST /v3/ramps/orders/{id}/legs/{index}/signature` | The signature of a `SIGNATURE` pending action. |
| `POST /v3/ramps/orders/{id}/retry` | Runs a held leg again from where it stopped. |
| `POST /v3/ramps/orders/{id}/cancel` | Cancels an order before any funds move. |
| `PUT /v3/ramps/customers/wallets/{chain}` | Links a wallet the user holds outside Pollar. |

### Quote

```json
POST /v3/ramps/quotes
{
  "direction": "ONRAMP",
  "fiat": { "currency": "BRL", "rail": "PIX", "country": "BR" },
  "asset": { "code": "USDC", "identifier": "GA5Z...KZVN", "chain": "STELLAR" },
  "amount": { "value": "100", "denomination": "in" }
}
```

`amount.denomination` is `in` (fixes what the user sends) or `out` (fixes what the user receives); `value` is a decimal string, never a number. `asset.identifier` is the issuer on Stellar, the contract on Polygon, the mint on Solana, and `null` for the native coin.

The answer (`SDK_RAMPS_QUOTES`) is `{ quotes, rejected }`. `quotes` is best first: most received (exact in) or least sent (exact out), then fewer legs, then faster. Each quote has `quoteId`, `expiresAt`, `amountIn`, `amountOut`, `etaSeconds` and its `legs`; each leg has its `kind` (`PROVIDER_ONRAMP`, `PROVIDER_OFFRAMP`, `SWAP`, `BRIDGE`), amounts, `providerFees`, `fees`, the user's `wallet` on it, and `requiredFields`: the values the user fills in before the order (a payout account, a name, a bank from a list). `rejected` says why every other candidate route dropped out; a route waiting on a verification step carries a `requirement` naming the step to complete through `/v3/kyc` or `/v3/requirements` in the SDK.

No route at all answers `422 SDK_RAMPS_NO_ROUTE` with `rejected`.

### Order

```json
POST /v3/ramps/orders
{
  "quoteId": "<quoteId from the quote>",
  "payee": { "pixKeyType": "EMAIL", "bankAccount": "user@example.com" }
}
```

`payee` carries a value for each of the quote's `requiredFields`, by key; a missing or wrong one answers `400` before anything moves. The same quote always answers the same order, so retrying a request that timed out is safe. The answer is `201` with the order.

An order has `id`, `direction`, `state` (`created`, `awaiting_payment`, `processing`, `settling_onchain`, `completed`, `failed`, `refunded`), its `legs` (each with planned and actual amounts, `status`, `onchainTxHash`, `failure`, and the chain `steps` of a swap or bridge leg), the `pendingAction`, the order's `failure`, and `nextPollAfter`: when to read it again, `null` once it no longer moves.

`pendingAction` says what the order waits on:

| `kind` | What to do |
|---|---|
| `FIAT_PAYMENT` | Show your user the `instructions`: a QR to scan (`qr`, with a rendered `scannable` image), bank details (`bank_transfer`) or the provider's page (`hosted`) |
| `SIGNATURE` | Sign `payload` unchanged and send it to the signature route. Comes up for an `EXTERNAL` wallet (linked with `PUT /customers/wallets/{chain}`) or an app-custody wallet |
| `COSIGN_APPROVAL` | The user approves it on their device, where the SDK holds the co-signed wallet's key |
| `KYC` | The user completes the verification steps |
| `NONE` | Nothing to do: read the order again at `nextPollAfter` |

`GET /v3/ramps/orders` takes `state`, `pending=true` (only orders waiting on the user or on you), `open=true` (only orders not yet final), `since` (ISO date), `limit` (1 to 100, default 20) and `cursor`; it answers `{ orders, nextCursor }`.

### Sign, retry, cancel, link a wallet

- **Signature:** body `{ "actionId": "...", "signedPayload": "..." }`. `actionId` is the `SIGNATURE` action's; an action that changed since you read it answers `409 SDK_RAMPS_ACTION_STALE`. Answers the order after the signed step ran (`SDK_RAMPS_SIGNATURE_ACCEPTED`).
- **Retry:** no body. Runs a held leg again once its failure is resolved (`SDK_RAMPS_ORDER_RETRIED`); `409 SDK_RAMPS_NOTHING_TO_RETRY` when nothing is held.
- **Cancel:** no body. Refused with `409 SDK_RAMPS_ORDER_NOT_CANCELLABLE` once a payment, burn or swap was sent, or while an approval is open (`SDK_RAMPS_ORDER_CANCELLED` otherwise).
- **Link a wallet:** `PUT /v3/ramps/customers/wallets/{chain}` with `{ "address": "..." }` (`chain` is `STELLAR`, `POLYGON` or `SOLANA`). Links the address as `EXTERNAL`: each step that spends from it is a `SIGNATURE` action you or the user sign, and you answer for the address. The same address again is a no-op; a different one on a chain that already has a wallet is refused with `409`.

There is no server-side equivalent of the SDK's `POST /orders/{id}/check`: read the order at `nextPollAfter` instead.

### Ramp errors

| Code | Meaning |
|---|---|
| `400 VALIDATION_ERROR` | Bad body, or a missing or invalid `x-pollar-external-user-id`, or a `payee` value that does not fit its field (`message` says which) |
| `400 SDK_RAMPS_QUOTE_EXPIRED` | The quote expired: quote again |
| `402 SDK_CREDITS_INSUFFICIENT` / `SDK_BILLING_OVERDUE` | App on credits: its credits do not cover the route's fees, or a statement is overdue |
| `404 SDK_RAMPS_QUOTE_NOT_FOUND` | Unknown quote, or another user's |
| `404 SDK_RAMPS_TX_NOT_FOUND` | Unknown order, or another user's |
| `409 VALIDATION_ERROR` | The order's input does not match its quote |
| `409 SDK_RAMPS_ACTION_STALE` | The pending action changed or the leg is busy: read the order again |
| `409 SDK_RAMPS_NOTHING_TO_RETRY` | Nothing to retry, or the order needs a new quote |
| `409 SDK_RAMPS_ORDER_NOT_CANCELLABLE` | Funds already moved, or an approval is open |
| `422 SDK_RAMPS_NO_ROUTE` | No route can serve the request; `rejected` says why |
| `422 SDK_RAMPS_WALLET_NOT_READY` | The route's wallet on another chain waits for the user's approval; retry once it is approved |
| `502` | Ramps are unavailable; retry |

---

## Billing

Reads only, for the app behind the key. Credits are explained in [Credits](https://docs.pollar.xyz/docs/core-concepts/credits). Taking assets out of the distribution vault is not possible with a secret key: a withdrawal needs the owner's session in the dashboard (see [Distribution vault](https://docs.pollar.xyz/docs/operator-guide/billing/distribution-vault)), so a leaked key cannot empty it.

| Route | Answers |
|---|---|
| `GET /v3/billing/credits` | The app's credits (100 credits = 1 USD): `ledger`, `billingModel` (`PREPAID` or `POSTPAID`), `paid`, `promo`, `overdraft`, `available`, `negativeSince`, `overdueStatementId` and its latest `movements`, newest first (a charge is negative and names its `event`). Query: `since` (ISO date, only newer movements), `limit` (1 to 200, default 50). Code `SERVER_BILLING_CREDITS`. |
| `GET /v3/billing/usage` | What the app used per billable event in a period: `{ from, to, totalCredits, events: [{ event, count, credits }] }`. Query: `from` (inclusive) and `to` (exclusive), ISO dates; the last 30 days by default; `from` not before `to` answers `400`. Code `SERVER_BILLING_USAGE`. |
| `GET /v3/billing/statements` | A postpaid app's monthly statements, newest first (up to 36): period, `amountDue`, `outstanding`, `dueAt`, `status` (`ISSUED`, `PAID`, `OVERDUE`, `VOID`) and the usage breakdown. An app on prepaid credits has none. Code `SERVER_BILLING_STATEMENTS`. |
| `GET /v3/billing/deposit-addresses` | Where the app tops up its credits: `{ addresses: [{ chain, address, assets }] }`, the stablecoins each address accepts, credited at par. A Stellar address is listed once it can receive. Code `SERVER_BILLING_DEPOSIT_ADDRESSES`. |
| `GET /v3/billing/distribution-vault` | The wallet holding the app's own assets that pays its distribution claims: `chain`, `address`, `custody`, `balances` and its latest `withdrawals`. `vault` is `null` when the app has none. Code `SERVER_BILLING_VAULT`. |

The deposit-address and vault reads answer `SERVER_BILLING_REFUSED` (`404`, `409`, `422` or `502`, with a `reason`) when billing cannot answer.

---

## Treasury

The app's sponsorship and signing policies, the same settings as **Dashboard > Wallets**.

| Route | Does |
|---|---|
| `GET /v3/treasury/sponsorship` | The app's sponsorship flags (`sponsor_trustlines`, `sponsor_swap_venues`, `sponsor_all_contracts`, `sponsor_signer_rotation`, and the `*_external` flags that extend each to wallets Pollar does not hold) |
| `PATCH /v3/treasury/sponsorship` | Updates any of those flags, plus the transfer flags per chain and custody (`sponsor_transfer_native`, `sponsor_transfer_external`, `sponsor_transfer_cosigned` and their `sponsor_solana_transfer_*` counterparts). At least one field |
| `GET /v3/treasury/sponsorship/contract-rules` | The Soroban contracts whose calls the app sponsors |
| `POST /v3/treasury/sponsorship/contract-rules` | Creates or updates a rule: `contract_id` (a `C...` address), `methods` (1 to 50 names), optional `label` and `enabled` |
| `PATCH /v3/treasury/sponsorship/contract-rules/{ruleId}` | Updates `methods`, `label` or `enabled` |
| `DELETE /v3/treasury/sponsorship/contract-rules/{ruleId}` | Deletes a rule |
| `PATCH /v3/treasury/sponsorship/asset-transfer` | Turns transfer sponsorship on or off for one enabled token: `chain` (`STELLAR` or `SOLANA`), `code`, `issuer` (issuer or mint), `sponsor_transfer` |
| `GET /v3/treasury/tx-policy` | The app's transaction policy (`null` is the strict default) |
| `PATCH /v3/treasury/tx-policy` | Sets `tx_policy` (or `null` to clear it): `maxFeeStroops` (0.01 to 100 XLM, in stroops), `maxOperations` (1 to 100), `accountMerge.allowedDestinations` (`[]`, `["*"]` alone, or up to 100 `G...` addresses) |
| `GET /v3/treasury/soroban-auth/policies` | The contracts and functions a custodial wallet may sign Soroban auth entries for, and `maxLedgerWindow` |
| `POST /v3/treasury/soroban-auth/policies` | Creates or updates a policy: `contract_id` (a `C...` address, or `"*"` with `functions: ["*"]`), `functions` (`["*"]` alone or 1 to 50 names), optional `label` and `enabled` |
| `PATCH /v3/treasury/soroban-auth/policies/{policyId}` | Updates `functions`, `label` or `enabled` |
| `DELETE /v3/treasury/soroban-auth/policies/{policyId}` | Deletes a policy |
| `PATCH /v3/treasury/soroban-auth/settings` | Sets `maxLedgerWindow`: how many ledgers ahead an auth-entry signature stays valid, 1 to 300 (`null` resets it to 120) |

---

## API keys

| Route | Does |
|---|---|
| `GET /v3/api-keys` | The app's keys, redacted: `id`, `key_prefix`, `name`, `type`, `allow_native_clients`, `expires_at`, timestamps. Never the key itself |
| `POST /v3/api-keys` | Creates a **publishable** key: `name` (1 to 100 characters, unique per app and type), optional `allow_native_clients` and `expires_at`. The full key is in `plaintext`, returned only in this answer. Secret keys are created only in the dashboard |
| `PATCH /v3/api-keys/{keyId}` | Updates `name`, `allow_native_clients` or `expires_at` (`null` removes the expiration) |
| `DELETE /v3/api-keys/{keyId}` | Revokes a key. Clients using it stop working at once |

A name already in use answers `409 API_KEY_NAME_TAKEN`; an unknown key id answers `404 API_KEY_NOT_FOUND`.

---

## Assets

| Route | Does |
|---|---|
| `POST /v3/assets/enable` | Enables a token on the app: `chain` (`STELLAR`, `POLYGON` or `SOLANA`; default `STELLAR`), `code`, `issuer` (a Stellar `G...` issuer or `"0"` for XLM, a Polygon `0x` contract, a Solana mint), `name`, optional `decimals` |
| `POST /v3/assets/disable` | Disables it, same body |

Both answer the app's link to the asset (`enabled`, `name`, `sponsor_transfer`).

---

## Distribution

The app's token distribution rules: an amount each user can claim, paid from the app's distribution wallet.

| Route | Does |
|---|---|
| `GET /v3/distribution/rules` | Every rule with its asset and claim stats (`uniqueUsers`, `totalAmount`) |
| `POST /v3/distribution/rules` | Creates a rule: `assetId` (an enabled asset id, or `"native"` for XLM), `name`, `amountPerUser` (a decimal string above 0), `maxClaims`, `period` (`DAY`, `DAY_CALENDAR`, `WEEK`, `MONTH`, `MONTH_CALENDAR`, `LIFETIME`), `globalCap` (or `null`), `validFrom` and `validUntil` (ISO dates or `null`), `enabled` |
| `PATCH /v3/distribution/rules/{ruleId}` | Updates any of those fields |
| `DELETE /v3/distribution/rules/{ruleId}` | Deletes a rule |
| `GET /v3/distribution/claims?limit=` | The latest claims (`limit` 1 to 50, default 10), each with its rule, user, amount, `tx_hash` and `status` |

---

## Metrics

### `GET /v3/metrics`

Transaction counts for the app. Query: `range` (`7d`, `14d` or `30d`; default `14d`), `tz` (an IANA timezone for the day buckets; default `UTC`). Answers `totalCount`, `todayCount`, `perAsset`, `countSeries` and `byAssetSeries` per local day, and `distribution` per asset. Code `SERVER_METRICS`.

---

## Tokens

### `POST /v3/tokens/verify`

Validates an SDK end-user access token server-side, for example to authenticate a user on your backend with a token the SDK minted client-side.

```bash
POST https://server.api.pollar.xyz/v3/tokens/verify
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
