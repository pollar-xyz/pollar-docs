---
title: "Pay for APIs with x402"
---

[x402](https://developers.stellar.org/docs/build/agentic-payments/x402) turns HTTP `402 Payment Required` into a payment flow an app or an AI agent can run on its own: the server answers `402` with what it charges, the client authorizes a USDC transfer, retries the request with that authorization, and a facilitator settles it on Stellar and pays the network fee.

On Stellar the client does not send a transaction. It signs a Soroban **authorization entry** (`SorobanAuthorizationEntry`) for a USDC `transfer`, and the facilitator submits it. With Pollar, the user's wallet signs that entry: your app holds no secret key, the app's allowlist decides what may be authorized, and a wallet with no XLM can pay, because the facilitator pays the fee.

This guide covers the dashboard setup, paying with the official `@x402/fetch` client, an adapter that signs without sending, and anchoring a receipt on Stellar.

---

## Before you start

In the dashboard, for the app whose API key you use:

1. **Wallets > [Auth Policy](https://docs.pollar.xyz/docs/operator-guide/wallets/auth-policy).** Add a row for the USDC contract with the function **`transfer`**, in lowercase. `Transfer` is a different name and authorizes nothing.

   | Network | USDC contract |
   | --- | --- |
   | Mainnet | `CCW67TSZV3SSS2HXMBQ5JFGCKJNXKZM7UQUWUZPUTHXSTZLEO7SJMI75` |
   | Testnet | `CBIELTK6YBZJU5UP2WWQEUCYKLPU6AUNZ2BQ4WWFEIE3USCIHMXQDAMA` |

2. **Signature validity window** (same page). x402 asks the signature to last the `maxTimeoutSeconds` the server sends in its `402`, converted to ledgers (about 5 seconds each). It must fit in the app's window, 120 ledgers by default and 300 at most, or the signature is refused with `SOROBAN_AUTH_EXPIRATION_TOO_LONG`.
3. **Wallets > [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines).** Enable USDC, so your users' wallets hold the trustline they pay from.
4. **Mainnet.** A mainnet app has to be approved first; see the [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist). Your users need USDC on the wallet to pay.

---

## Which wallets can pay

| Wallet | How the entry is signed |
| --- | --- |
| Custodial (social or email login) | Pollar signs server-side, after checking the entry against the Auth Policy allowlist and the validity window. |
| Co-signed (Turnkey) | Same checks, then the user's device votes. It recomputes the entry's hash itself before approving, like any co-signed transaction. With `cosignManual`, the call resolves to `cosign_pending` and your app votes through `pollar.cosign`. |
| External (Freighter, Albedo and other adapters) | The wallet signs the entry itself, and the user approves it there. The allowlist does not apply. |
| Passkey smart account (C-address) | Not supported by this flow. |

---

## Pay with `@x402/fetch`

`pollar.stellar.authEntrySigner()` is a [SEP-43](https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0043.md) signer over the logged-in user's wallet, the kind x402's Stellar scheme takes. Register it once, after login, and wrap `fetch`:

```bash
npm install @x402/fetch @x402/stellar
```

```typescript
import { PollarClient } from '@pollar/core';
import { decodePaymentResponseHeader, wrapFetchWithPayment, x402Client } from '@x402/fetch';
import { ExactStellarScheme } from '@x402/stellar/exact/client';

const pollar = new PollarClient({ apiKey: 'pub_mainnet_...', stellarNetwork: 'mainnet' });
// ... the user logs in ...

const x402 = new x402Client().register(
  'stellar:*',
  // x402 builds the USDC transfer by simulating it, so it needs a Soroban RPC.
  // There is no public SDF RPC on mainnet: use your provider's URL.
  new ExactStellarScheme(pollar.stellar.authEntrySigner(), { url: 'https://your-soroban-rpc.example' }),
);
const payFetch = wrapFetchWithPayment(fetch, x402);

const res = await payFetch('https://api.example.com/premium/report');
const report = await res.json();

// The settlement the facilitator made, with its transaction hash.
const header = res.headers.get('PAYMENT-RESPONSE');
if (header) console.log(decodePaymentResponseHeader(header).transaction);
```

The first request comes back `402`; `payFetch` reads the requirements, has the wallet sign the USDC transfer, and retries with the payment. Your code only sees the final response.

Inside the signer, x402 (through stellar-sdk) hands over the entry's authorization preimage and expects the raw signature back. Pollar signs the whole entry instead, because the allowlist check needs to read the contract and function. The signer rebuilds the entry from the preimage, signs it through `pollar.signAuthEntry()` (see [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)), and returns the signature. It throws instead of returning a signature when:

- the payment is for another network than the client's;
- Pollar refuses the entry (the error carries the code, for example `SOROBAN_AUTH_FUNCTION_NOT_ALLOWED`);
- a co-signed wallet has not approved yet;
- the entry comes back signed to a different expiration, which would be a signature over a different hash.
- the wallet signs with a key other than its address. A wallet that moved from Pollar's custody to a co-signed one keeps its address and signs with its new key; the network accepts that, but stellar-sdk's `signAuthEntries` (which x402 uses) only takes a bare signature and checks it against the address. For such a wallet, sign the entry with `pollar.signAuthEntry()`, which returns the entry with the right key in it, and put it in the transaction yourself.

---

## In React: an adapter that signs without sending

An adapter (see `createPollarAdapterHook` in [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react)) usually returns `{ unsignedTransaction }` and Pollar signs and submits it. When someone else submits (an x402 facilitator, a contract that pays the gas), an adapter can return the entry to sign instead, plus what to do with the signature:

```tsx
import type { AuthEntryAdapterFn } from '@pollar/core';
import { createPollarAdapterHook } from '@pollar/react';

const settle: AuthEntryAdapterFn<{ orderId: string }, { receiptId: string }> = async ({ orderId }) => {
  const { entryXdr, validUntilLedger } = await myBackend.prepareAuthorization(orderId);
  return {
    unsignedAuthEntry: entryXdr,
    validUntilLedger,
    complete: (signedAuthEntry) => myBackend.submitAuthorization(orderId, signedAuthEntry),
  };
};

// <PollarProvider adapters={{ settlement: { settle } }}>
const useSettlement = createPollarAdapterHook<{ settle: typeof settle }>('settlement');

function PayButton({ orderId }: { orderId: string }) {
  const { settle } = useSettlement();
  return (
    <button
      onClick={async () => {
        const outcome = await settle({ orderId });
        if (outcome.status === 'completed') console.log(outcome.result.receiptId);
        else console.error(outcome); // 'error' or 'cosign_pending'
      }}
    >
      Pay
    </button>
  );
}
```

Pollar signs the entry and submits nothing. `complete` runs only after a signature exists, and its result comes back as `{ status: 'completed', result }`. A refusal or a pending co-sign vote comes back as the same `error` or `cosign_pending` that `signAuthEntry` returns, and `complete` is not called. The same works in `@pollar/react-native`.

---

## Anchor a receipt on Stellar

To leave public proof that a record existed at a given time (an agent's receipt, a document's SHA-256), put its digest in a payment's memo. A `hash` memo takes the 32 bytes as 64 hex characters:

```typescript
await pollar.runTx(
  'payment',
  { destination: 'GXXX...', amount: '0.0000001', asset: { type: 'native' } },
  { memo: { type: 'hash', value: receiptSha256Hex } },
);
```

Horizon returns a hash memo as the base64 of those 32 bytes, so compare it with the digest decoded from base64. The memo field in `<SendModal>` offers the same `Hash` type.

---

## Troubleshooting

| Code | What happened | What to do |
| --- | --- | --- |
| `SOROBAN_AUTH_NO_POLICY` | The app has no Auth Policy rows | Add the USDC row, and check the API key belongs to the app you configured: the error body carries `applicationId` |
| `SOROBAN_AUTH_FUNCTION_NOT_ALLOWED` | The row does not name `transfer` | Name it in lowercase |
| `SOROBAN_AUTH_CONTRACT_NOT_ALLOWED` | The server charges in another token, or on another network's contract | Check the `asset` in the server's `402` against your row |
| `SOROBAN_AUTH_EXPIRATION_TOO_LONG` | The server's `maxTimeoutSeconds` is longer than the app's window | Raise the window (up to 300 ledgers) or ask for a shorter timeout |
| `SDK_WALLET_RECOVERY_REQUIRED` | A co-signed wallet with no recovery method signs nothing that moves funds | Have the user set up recovery first |
| `TX_EXTERNAL_WALLET_SERVER_SIGN` | The session's wallet signs on its own (external or passkey) | External wallets sign through their adapter; passkey accounts cannot pay with x402 yet |

The full list is in [Error Codes](https://docs.pollar.xyz/docs/sdk-reference/error-codes).
