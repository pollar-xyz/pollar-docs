---
title: "USDC bridges"
---

**Dashboard > Treasury > USDC bridges** · Chains: Stellar, Solana, Polygon (mainnet)

Your users moving USDC between their own wallets on Stellar, Solana and Polygon. Each move goes through Circle's CCTP: the USDC is burned on the source chain, Circle attests the burn in a few minutes, and your app's network fee wallet sends the mint on the destination. To offer it, see the [Bridge guide](https://docs.pollar.xyz/docs/guides/bridge-guide).

---

## The list

Newest first. Filter by status; each filter shows how many moves are in it.

| Status | Meaning |
|---|---|
| Sending | The burn is being sent |
| Waits on the user | The user signs the step in their wallet, or approves it on their device |
| Confirming with Circle | Burned; Circle is attesting it |
| Arriving | Attested; the mint is being sent |
| Completed | The USDC is in the destination wallet |
| Failed | Nothing left the user's wallet; the user can start again |
| Held by Pollar | The USDC was burned and what followed failed. Pollar is alerted and resolves it; nothing is lost and there is nothing for your app to do |

Open a move to see its addresses, the amount that arrived, the failure code if any, and the burn and mint transactions, each linked to its explorer.

---

## Fees

Each completed move is charged to your app in credits as `bridge.transfer`, a percentage of the amount with a minimum and a maximum; see **Billing > Credits > Prices**. The network fees your app's wallets pay are charged as usual (`gas.sponsored_tx`).

---

## From your backend or an agent

- `GET /v1/applications/{id}/bridge-transfers` (with `status`, `userId`, `limit`, `offset`) and `GET /v1/applications/{id}/bridge-transfers/{transferId}` answer the same data with a token that has `applications:read`.
- The [MCP Gateway](https://docs.pollar.xyz/docs/sdk-reference/mcp-gateway) offers them as `list_bridge_transfers` and `get_bridge_transfer`.
- Your backend can move a user's USDC itself with the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api) `/v3/bridge`.
