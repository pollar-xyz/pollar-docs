---
title: "Testnet Sandbox Anchor (ARS and PEN)"
description: "A public testnet anchor to test ARS and PEN on-ramps and off-ramps end to end over SEP-10 and SEP-24."
---

Public Stellar **testnet** anchor at `https://sandbox-anchor.pollar.xyz`. It behaves like a real Latin American
fiat anchor for **ARS** (Argentina) and **PEN** (Peru): same SEP endpoints, fields, statuses, fees and limits. Use it
to build and test on-ramps (deposit) and off-ramps (withdrawal) end to end.

- No real money moves. No real KYC. Not affiliated with any real anchor.
- Testnet only: network passphrase `Test SDF Network ; September 2015`, Horizon `https://horizon-testnet.stellar.org`.
- Protocols: SEP-1 (stellar.toml), SEP-10 (web auth), SEP-24 (hosted interactive deposit/withdraw).
- Not supported: SEP-6, SEP-12 as an API, SEP-31, SEP-38. `account_creation` and `claimable_balances` are off.
- Source: https://github.com/pollar-xyz/pollar-sandbox-anchor (Apache-2.0). Anchor docs: https://sandbox-anchor.pollar.xyz/docs. OpenAPI: https://sandbox-anchor.pollar.xyz/openapi.yaml.

## Addresses

| What | Value |
| --- | --- |
| Home domain | `sandbox-anchor.pollar.xyz` |
| stellar.toml | `https://sandbox-anchor.pollar.xyz/.well-known/stellar.toml` |
| WEB_AUTH_ENDPOINT | `https://sandbox-anchor.pollar.xyz/auth` |
| TRANSFER_SERVER_SEP0024 | `https://sandbox-anchor.pollar.xyz/transfer24` |
| SIGNING_KEY | `GBI34XHNZ3ZXQTOIPYIXPVLPY5SJGWMSSZV42J5O2AEJ23VLNCF2NMJL` |
| ARS issuer | `GCLAJ3NUQJPUIXMOP6EEQOOK556X6JUBSQEDGIYN2QD4MBEF3EVKCMDR` |
| PEN issuer | `GCCMUNJUUZSKIGVRE74GW4ITWEWZZXNMSVVDL56MJY44F4MINGDUPNKM` |
| USDC (Circle testnet) issuer | `GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5` |
| USDC SAC (Soroban) | `CBIELTK6YBZJU5UP2WWQEUCYKLPU6AUNZ2BQ4WWFEIE3USCIHMXQDAMA` |

Asset strings: `ARS:GCLAJ3NUQJPUIXMOP6EEQOOK556X6JUBSQEDGIYN2QD4MBEF3EVKCMDR`,
`PEN:GCCMUNJUUZSKIGVRE74GW4ITWEWZZXNMSVVDL56MJY44F4MINGDUPNKM`,
`USDC:GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5`.

The withdrawal destination account is **not** a constant: always read `withdraw_anchor_account` from the transaction.
Issuers and keys can change if the operator rebootstraps the sandbox, so production code should read them from the
stellar.toml instead of hardcoding them.

### USDC and the DEX

USDC is **not** issued by the sandbox and is not in its stellar.toml. It is Circle's testnet USDC. The sandbox keeps DEX
offers between ARS, PEN, XLM and USDC, so path payments such as ARS -> USDC or USDC -> PEN work on testnet. Default
rates: 1 USDC = 1450 ARS = 3.7 PEN = 4 XLM, with a 1% spread. Get testnet USDC from https://faucet.sozu.capital or
https://faucet.circle.com.

## Prerequisites for a user account

1. Create a testnet account and fund it with friendbot: `https://friendbot.stellar.org?addr=G...`.
2. Add a trustline to `ARS` or `PEN` (issuer above). A deposit to an account without the trustline ends in `error`
   with the message `the account has no trustline to ARS:G...`.

## Getting ARS or PEN (minting)

There is no public mint endpoint, and the issuer secret is never exposed. A user account gets ARS or PEN in one of
two ways:

1. **SEP-24 deposit (the on-ramp is the mint).** Run a deposit (see below), and in the hosted bank ticket press
   **"Simular transferencia recibida"**. The anchor's distribution account sends `amount_out` of the asset to the user
   account on-chain. This is the intended way to get funds, and it needs no real money. Each deposit is limited by the
   per-operation range (ARS 11 to 500000, PEN 2 to 3000) and by the daily cap per account (ARS 1000000, PEN 6000).
   Example: deposit `1000` ARS -> fee `10 + 1%` = `20.00` -> the account receives `980.00` ARS.
2. **Buy on the testnet DEX.** The sandbox keeps offers against XLM and USDC, so a friendbot-funded account can swap
   XLM (or testnet USDC) into ARS/PEN with a path payment to itself:

```ts
// Needs the ARS trustline first. Spends at most 10 XLM and receives exactly 1000 ARS.
Operation.pathPaymentStrictReceive({
  sendAsset: Asset.native(),
  sendMax: '10',
  destination: user.publicKey(),
  destAsset: new Asset('ARS', 'GCLAJ3NUQJPUIXMOP6EEQOOK556X6JUBSQEDGIYN2QD4MBEF3EVKCMDR'),
  destAmount: '1000',
  path: [],
});
```

   Check the price and depth first with Horizon `GET /paths/strict-receive` or `GET /order_book`. Depth is limited
   (it is backed by the sandbox's own USDC), so prefer deposits for large amounts.

Operators of the sandbox (not integrators) can issue new supply to a liquidity wallet with
`pnpm cli mint <liquidityAccountId> <ARS|PEN> <amount>`. This pays from the issuer to that liquidity wallet only, and it
is used to keep the DEX offers funded.

## Flow overview

1. SEP-1: read the stellar.toml.
2. SEP-10: get a JWT for the user account.
3. SEP-24: `POST .../deposit/interactive` or `.../withdraw/interactive`, open the returned `url` for the user.
4. Poll `GET /transfer24/transaction?id=...` until the status is terminal.
5. Withdrawal only: once `withdraw_anchor_account` appears, send exactly `amount_in` of the asset to it with the
   `withdraw_memo` as a **hash** memo.

## SEP-10 authentication

```
GET  /auth?account=G...[&memo=<id>][&home_domain=sandbox-anchor.pollar.xyz][&client_domain=...]
  -> { "transaction": "<challenge XDR>", "network_passphrase": "Test SDF Network ; September 2015" }

POST /auth   { "transaction": "<signed challenge XDR>" }   (application/json)
  -> { "token": "<JWT>" }
```

- Challenge valid 15 minutes. JWT valid 24 hours (HS256, `iss` = `https://sandbox-anchor.pollar.xyz/auth`).
- `home_domain`, if sent, must be `sandbox-anchor.pollar.xyz`.
- `memo` must be an **ID** memo (unsigned 64-bit integer). With a memo, `sub` is `G...:memo` and every transaction is
  scoped to that memo (shared/custodial accounts).
- Existing accounts are verified against their signers and medium threshold (multisig works). An account that does not
  exist yet signs with its master key.
- `client_domain` is accepted but not attested: the JWT never carries it.
- Send the token as `Authorization: Bearer <JWT>` on every `/transfer24` call except `/info`. Missing or invalid
  token -> `403`.

## SEP-24 endpoints

Base: `https://sandbox-anchor.pollar.xyz/transfer24`. CORS is open (OPTIONS preflight supported).

### GET /info (no auth)

```json
{
  "deposit": {
    "ARS": { "enabled": true, "min_amount": 11, "max_amount": 500000, "fee_fixed": 10, "fee_percent": 1 },
    "PEN": { "enabled": true, "min_amount": 2, "max_amount": 3000, "fee_fixed": 1, "fee_percent": 1 }
  },
  "withdraw": {
    "ARS": { "enabled": true, "min_amount": 11, "max_amount": 500000, "fee_fixed": 10, "fee_percent": 2 },
    "PEN": { "enabled": true, "min_amount": 2, "max_amount": 3000, "fee_fixed": 1, "fee_percent": 2 }
  },
  "fee": { "enabled": true, "authentication_required": true },
  "transactions": { "enabled": true, "authentication_required": true },
  "transaction": { "enabled": true, "authentication_required": true },
  "features": { "account_creation": false, "claimable_balances": false }
}
```

The operator can change these values; `/info` is always the live source.

### POST /transactions/deposit/interactive and /transactions/withdraw/interactive

Body (JSON or form):

| Field | Required | Notes |
| --- | --- | --- |
| `asset_code` | yes | `ARS` or `PEN` |
| `asset_issuer` | no | If sent, must match the sandbox issuer |
| `account` | no | Defaults to the JWT account; must equal it (else `403`) |
| `amount` | no | Prefills the form; up to 2 decimals |
| `memo`, `memo_type` | no | Deposit only. Memo the anchor attaches to the on-chain payment: `text` (default), `id` or `hash` (hex or base64). Without it, a SEP-10 ID memo is used |
| `lang` | no | Stored; the hosted UI is in Spanish |

Response:

```json
{ "type": "interactive_customer_info_needed", "url": "https://sandbox-anchor.pollar.xyz/interactive/<id>?token=...", "id": "<uuid>" }
```

The `url` token expires in **15 minutes**; open it right away (popup or new tab). The hosted page does not send
`postMessage` or callbacks: poll the transaction.

### GET /transaction

`?id=<uuid>` or `?stellar_transaction_id=<hash>` or `?external_transaction_id=<id>`. Only returns transactions owned by
the JWT account (and memo). `404` if not found.

### GET /transactions

`?asset_code=ARS|PEN` (required), `kind=deposit|withdrawal`, `limit` (max 200), `no_older_than` (ISO 8601),
`paging_id` (a transaction id; returns older ones). Newest first.

### GET /fee

SEP-24 fee endpoint, requires the JWT. Fee formula: `fee = fee_fixed + amount_in * fee_percent / 100`, rounded to 2
decimals; `amount_out = amount_in - fee`.

## Transaction object

Amounts are strings with 2 decimals. Null fields are omitted.

| Field | Notes |
| --- | --- |
| `id`, `kind` (`deposit`/`withdrawal`), `status`, `status_eta`, `more_info_url` | |
| `amount_in`, `amount_fee`, `amount_out` | Set when the user submits the amount in the hosted form |
| `started_at`, `completed_at` | |
| `stellar_transaction_id` | Deposit: anchor payment hash. Withdrawal: the user's payment hash |
| `external_transaction_id` | Simulated bank transfer id (`DEP-...` / `WDR-...`) |
| `from`, `to`, `message`, `refunded`, `refunds` | |
| `withdraw_anchor_account`, `withdraw_memo`, `withdraw_memo_type` (`hash`) | Withdrawal only, present after the form is submitted. Memo is 32 bytes, base64 |
| `external_extra`, `external_extra_text` | Deposit only: the fake bank ticket (`CBU` for ARS, `CCI` for PEN, alias, holder, bank, REF) |

## Statuses

```
deposit:    incomplete -> pending_user_transfer_start -> pending_anchor -> completed
withdrawal: incomplete -> pending_user_transfer_start -> pending_anchor -> completed
```

Terminal: `completed`, `error`, `refunded`, `expired`, `too_small`, `too_large`, `no_market`. Any non-terminal status
can end in a failure status.

- `incomplete`: created, user has not finished the hosted form.
- `pending_user_transfer_start`: deposit -> bank ticket shown, waiting for the (simulated) bank transfer. Withdrawal ->
  waiting for the user's Stellar payment.
- `pending_anchor`: anchor is paying out (on-chain for deposits, simulated bank payout for withdrawals).
- Transactions waiting on the user expire after **60 minutes** (default) -> `expired`.

## Hosted interactive flow

Steps (Spanish UI):

1. **KYC**, once per account: a form prefilled with fake but stable data (first_name, last_name, email, id_type
   `DNI`/`CE`, id_country_code `AR`/`PE`, id_number 6-12 digits). The user confirms and it is approved immediately.
2. **Deposit**: payment method -> amount -> confirm. The page shows a bank ticket with a fake account. Press
   **"Simular transferencia recibida"** and the anchor sends `amount_out` of the asset on-chain to the user account
   (with the memo, if any) -> `completed`.
3. **Withdrawal**: amount -> destination (holder + `CBU` of 22 digits for ARS, `CCI` of 20 digits for PEN) -> confirm.
   The transaction moves to `pending_user_transfer_start` and shows `withdraw_anchor_account` + `withdraw_memo`.

### Paying a withdrawal

Build a Stellar payment from the user account:

- destination: `withdraw_anchor_account`
- asset: the same ARS/PEN asset (code **and** issuer)
- amount: at least `amount_in`
- memo: `Memo.hash(Buffer.from(withdraw_memo, 'base64'))`

A watcher on Horizon matches the payment by memo. Wrong asset or less than `amount_in` -> `error`. Otherwise it goes to
`pending_anchor` and then `completed` with a simulated bank payout id. A payment without the hash memo is not matched.
A withdrawal paid after it expired is not refunded.

## Magic amounts

Enter these amounts in the hosted form (ARS or PEN) to force an outcome:

| Amount | Final status |
| --- | --- |
| `13.13` | `error` |
| `66.60` | `refunded` (with a `refunds` object) |
| `77.70` | `expired` |
| `11.11` | `too_small` |
| `2999.99` | `too_large` |
| `55.55` | `no_market` |

Deposits apply the outcome when the transfer is marked received; withdrawals when the user's payment arrives.

## Limits

- Per operation: see `/info` (ARS 11 to 500000, PEN 2 to 3000). Out of range -> form error.
- Daily cap per account and asset (UTC day, deposits + withdrawals combined): ARS 1000000, PEN 6000.
- Rate limits: per IP burst 120 then 2 req/s; per account burst 60 then 1 req/s. Over the limit -> `429` with
  `Retry-After`. Poll `/transaction` every 5 seconds or slower.

## Error format

Every error body is `{ "error": "<message>" }`. `400` invalid input, `403` auth, `404` not found, `429` rate limit.

## Minimal client example (TypeScript, @stellar/stellar-sdk)

```ts
import { Asset, Horizon, Keypair, Memo, Networks, Operation, TransactionBuilder, WebAuth } from '@stellar/stellar-sdk';

const ANCHOR = 'https://sandbox-anchor.pollar.xyz';
const horizon = new Horizon.Server('https://horizon-testnet.stellar.org');
const user = Keypair.fromSecret(process.env.USER_SECRET!);

// SEP-10
const { transaction } = await (await fetch(`${ANCHOR}/auth?account=${user.publicKey()}`)).json();
const challenge = TransactionBuilder.fromXDR(transaction, Networks.TESTNET);
challenge.sign(user);
const { token } = await (
  await fetch(`${ANCHOR}/auth`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ transaction: challenge.toXDR() }),
  })
).json();
const auth = { authorization: `Bearer ${token}`, 'content-type': 'application/json' };

// SEP-24 withdrawal
const { url, id } = await (
  await fetch(`${ANCHOR}/transfer24/transactions/withdraw/interactive`, {
    method: 'POST',
    headers: auth,
    body: JSON.stringify({ asset_code: 'ARS', amount: '1000' }),
  })
).json();
console.log('Open in a browser:', url);

// Poll until the anchor publishes where to pay
let tx;
do {
  await new Promise((r) => setTimeout(r, 5000));
  tx = (await (await fetch(`${ANCHOR}/transfer24/transaction?id=${id}`, { headers: auth })).json()).transaction;
} while (tx.status === 'incomplete');

if (tx.status === 'pending_user_transfer_start') {
  const account = await horizon.loadAccount(user.publicKey());
  const pay = new TransactionBuilder(account, { fee: '1000', networkPassphrase: Networks.TESTNET })
    .addOperation(
      Operation.payment({
        destination: tx.withdraw_anchor_account,
        asset: new Asset('ARS', 'GCLAJ3NUQJPUIXMOP6EEQOOK556X6JUBSQEDGIYN2QD4MBEF3EVKCMDR'),
        amount: tx.amount_in,
      }),
    )
    .addMemo(Memo.hash(Buffer.from(tx.withdraw_memo, 'base64')))
    .setTimeout(60)
    .build();
  pay.sign(user);
  await horizon.submitTransaction(pay);
}
// Keep polling until status is terminal.
```

## Testing with a ready-made wallet

`https://demo-wallet.stellar.org`: create a testnet account, add the asset with home domain
`sandbox-anchor.pollar.xyz`, then run SEP-24 deposit or withdrawal.

## Common pitfalls

- Deposit ends in `error` "no trustline": add the ARS/PEN trustline before depositing.
- Withdrawal stuck in `pending_user_transfer_start`: the payment had no hash memo, a text memo, or went to a hardcoded
  address instead of `withdraw_anchor_account`.
- Interactive page says expired: the `url` token lives 15 minutes; start a new transaction.
- `403` on `/transfer24/*`: missing `Bearer` token, expired JWT (24 h), or `account` different from the JWT account.
- SEP-10 `memo` must be numeric (ID memo); text memos are rejected.
- Amounts accept at most 2 decimals.
