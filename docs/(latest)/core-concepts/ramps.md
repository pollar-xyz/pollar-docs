---
title: "Ramps"
description: "Fiat on-ramps and off-ramps as orders of legs: a provider, a swap, a bridge, run by Pollar server-side."
---

A ramp turns fiat into a token in the user's wallet (on-ramp) or a token into fiat in the user's bank account (off-ramp). In Pollar a ramp is an **order of one or more legs** that Pollar runs server-side. Ramps need `@pollar/*` **0.12** and the v3 API; see [API Versions](https://docs.pollar.xyz/docs/sdk-reference/api-versions).

---

## Legs and routes

| Leg | What it does |
| --- | --- |
| `PROVIDER_ONRAMP` / `PROVIDER_OFFRAMP` | The ramp provider takes the fiat and delivers a token, or takes a token and pays out fiat |
| `SWAP` | Changes one token for another on the same chain (Stellar venues, Uniswap V3 on Polygon) |
| `BRIDGE` | Moves USDC between chains with Circle CCTP (Stellar, Polygon, Solana) |

A **route** is a path of legs from a fiat currency and rail (for example BRL over Pix) to a token on a chain your app serves. A provider only settles on its own chain, so Pollar's planner adds the swap and bridge legs that get the funds from there to the user's wallet. For example, a provider that delivers USDC on Polygon reaches a Stellar-only app through a CCTP bridge leg.

The providers registered today:

| Provider | Settles on | Notes |
| --- | --- | --- |
| Abroad | Stellar | |
| Anclap | Stellar | A SEP-24 anchor; its routes are `HOSTED`, the user picks the method inside Anclap's page |
| Stereum | Polygon | |
| Etherfuse | Stellar | |

Bridge and PagFinance are being integrated and are not offered on any route yet.

Which routes an app offers depends on the providers and corridors it enables under **Ramps > Providers** and on the chains it serves. **Ramps > Routes** in the dashboard lists them leg by leg. Routes end only on chains the app serves.

---

## Quotes

`quoteRamp({ direction, fiat, asset, amount: { value, denomination } })` prices every usable route and answers:

- `quotes`, best first: most received for an exact input (or least sent for an exact output), then fewer legs, then faster. Each quote lists its legs with their amounts, fees, ETA and the user's wallet on each leg, plus the `requiredFields` the user fills in (bank account, Pix key, name...).
- `rejected`, the routes that cannot run right now, each with a `failure` that says who can fix it (`resolutionOwner`) and how (`resolutionAction`). A route waiting on a verification step carries a `requirement`: the KYC, form, registry check or provider registration to complete through `/v3/kyc` or `/v3/requirements` (from the server, `/v3/ramps/kyc` and `/v3/ramps/requirements`) before quoting again. `rampNoRouteText(rejected)` gives the text to show.

Fees are inside the amounts: the provider's, venue's or bridge's own fees, plus Pollar's and the app's fees per leg. On an [app on credits](https://docs.pollar.xyz/docs/core-concepts/credits), a quote or an order the credits do not cover answers **402 `SDK_CREDITS_INSUFFICIENT`**.

---

## Orders

`createRampOrder({ quoteId, payee })` turns a quote into an order; `payee` holds a value for each required field. A payee the provider would refuse answers `400 VALIDATION_ERROR` with the reason, before anything moves.

The order moves leg by leg. Read it with `getRampOrder(id)`, or follow it with `pollRampOrder(id, { onUpdate })`, which waits as long as the order's `nextPollAfter` says. When the order needs the user, it carries a `pendingAction`:

| `pendingAction.kind` | What the user does |
| --- | --- |
| `FIAT_PAYMENT` | Pays the fiat: a QR (already rendered in `instructions.scannable`), bank transfer details, or the provider's hosted page |
| `SIGNATURE` | Signs the leg's transaction with the wallet (`signRampLeg(orderId, actionId)`) |
| `COSIGN_APPROVAL` | Approves the leg on a co-signed or self-custody wallet, like any other co-sign request |
| `KYC` | Completes the verification the provider asks for |

`listRampOrders({ open: 'true' })` returns the orders a client should resume.

### Signing

**A ramp leg always asks the user**, whatever the app's signature confirmation policy. `signRampLeg` reads the order again and signs only the action the user saw; polling an order never signs. Every chain and encoding needs a signer registered with `registerRampSigningHandler(chain, encoding, handler)`; `<RampWidget>` lends the connected wallet for it while the user authorizes. How each wallet signs is set per app under **Ramps > Signing**.

### When a leg fails

A leg that cannot finish stops the order with a `failure` naming the leg, whether it can be retried, and who resolves it; `rampResolutionText(failure)` says what the user can do. A leg that stopped with funds still in the user's wallet or in transit is **held**, not failed, so nothing is lost. `retryRampOrder(id)` runs the order again from the leg that stopped; the operator can do the same from **Ramps > Orders**.

---

## Rail wallets

A route can pass through a chain the app does not show its users: a provider that settles on Polygon, bridged to Stellar, needs a wallet on Polygon for that leg. Pollar gives the user a **rail wallet** there. When a route needs one, the quote says so as a wallet step (`rampWalletStep`), and `runRampWalletStep(step)` or `setUpRampWallet(chain)` creates it with this device as its key, in the app's custody. A rail wallet in Turnkey signs only once it has a recovery method; a route waiting on that offers the recovery step first.

Rail wallets show up under **Wallets > Wallets** with a Rail badge, next to the user's other wallets.

---

## From the server

An app's backend can run ramps for users it manages, without an SDK session, through `/v3/ramps` on the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api). Each call names the user with the `x-pollar-external-user-id` header. The verification steps a route needs are on the same surface; see [Verification steps](https://docs.pollar.xyz/docs/sdk-reference/server-api#verification-steps). The user's own verification with a KYC provider always happens with the user, at the provider's page: the backend sends the user there and never handles documents or biometrics.

---

## Related

- [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core): the ramp methods and helpers
- [Routes](https://docs.pollar.xyz/docs/operator-guide/ramps/routes), [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders) and [Signing](https://docs.pollar.xyz/docs/operator-guide/ramps/signing) in the Operator Guide
- [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support): ramps per chain
