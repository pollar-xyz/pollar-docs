---
title: "Swaps"
---

This guide shows how to let your users swap one asset for another (for example XLM to USDC) from inside your app. It has two parts:

- **[Part 1: React with the pre-built modal](#part-1-react-with-the-pre-built-modal)**: one function call opens a complete swap flow.
- **[Part 2: Headless with `@pollar/core`](#part-2-headless-with-pollarcore)**: build your own UI (or run swaps from non-React code) with the client methods.

Both parts use the same backend and the same rules. The modal in Part 1 is built on the methods in Part 2.

---

## How swaps work

A swap is a two-step flow:

1. **Quote.** Pollar asks the enabled venues how much of the buy asset your user gets for a given amount of the sell asset. Quotes are read-only: no funds move. They come back ranked by output, best first.
2. **Execute.** You pass the chosen quote to `swap()`. Pollar creates the buy-asset trustline if the wallet needs one, then signs and submits the transaction through the normal transaction pipeline. The quote carries a `minReceived` amount that is enforced on-chain, so the user never gets less than that.

**Venues:**

| Venue      | Type                                   | Notes                                                        |
|------------|----------------------------------------|--------------------------------------------------------------|
| `aquarius` | Soroban AMM                            |                                                              |
| `soroswap` | Soroban aggregator (Soroswap, Phoenix) | Only available when the Pollar server has a Soroswap API key. |
| `sdex`     | Stellar classic DEX (path payment)     |                                                              |

When you ask for the `auto` route, Pollar quotes every enabled venue and returns the best one first.

---

## Before you start

### 1. Enable venues in the dashboard

Go to **Dashboard > Treasury > Swap** and enable at least one venue. **Until a venue is enabled, swap is turned off for your app**: `getSwapConfig()` returns an empty list and the pre-built modal shows "Swap is not available for this app."

On the same page, the **Buy tokens** card lets you add tokens from the platform catalog that your users can buy, on top of your enabled assets. See [Swap](https://docs.pollar.xyz/docs/operator-guide/treasury/swap).

### 2. Check the wallet type

| Wallet                       | Swaps         |
|------------------------------|---------------|
| Custodial G-address          | Supported     |
| External wallet (G-address)  | Supported     |
| Smart wallet (passkey, C-address) | **Not supported yet**. `swap()` returns an error and the modal shows a notice. |

### 3. Use a funded wallet

The wallet needs a balance of the asset it sells, plus enough XLM for the network fee. If the buy asset needs a new trustline, the wallet also locks **0.5 XLM** as reserve for it, unless your app sponsors trustlines.

> **Testnet liquidity is thin.** Many pairs have no pool or path on testnet, so a quote can return no route. That is expected: try another pair or venue.

---

## Part 1: React with the pre-built modal

`<PollarProvider>` already renders the swap modal, so you don't mount anything. Open it with `openSwapModal()` from `usePollar()`:

```tsx
'use client';
import { usePollar } from '@pollar/react';

export function SwapButton() {
  const { isAuthenticated, openSwapModal } = usePollar();

  if (!isAuthenticated) return null;
  return <button onClick={openSwapModal}>Swap</button>;
}
```

That's the whole integration. The modal handles:

- **Sell list**: native XLM plus every asset the wallet holds a trustline for.
- **Buy list**: your enabled assets, the buy tokens you enabled in the dashboard, and any token the user adds by pasting its code and issuer.
- **Route selector**: `Auto` (best price) plus each venue you enabled. Venues you didn't enable are not shown.
- **Live quote**: re-quotes as the user types, showing the amount out, price impact and minimum received. Slippage is fixed at 0.5%.
- **Trustline**: if the buy asset needs a trustline, the button reads **"Create trustline & swap"** and the modal warns about the 0.5 XLM reserve.
- **Execution**: signing, submission and the result screen, with a retry on error.

Its appearance follows your **Build > Branding** settings, like every other Pollar modal.

### Hide the button when swap is off

The modal already tells the user when swap is not available, but you can avoid showing the button at all. `getSwapConfig()` returns the venues your app exposes, and an empty list means swap is off:

```tsx
'use client';
import { useEffect, useState } from 'react';
import { usePollar } from '@pollar/react';

export function SwapButton() {
  const { isAuthenticated, getSwapConfig, openSwapModal } = usePollar();
  const [enabled, setEnabled] = useState(false);

  useEffect(() => {
    if (!isAuthenticated) return;
    getSwapConfig()
      .then((venues) => setEnabled(venues.length > 0))
      .catch(() => setEnabled(false));
  }, [isAuthenticated, getSwapConfig]);

  if (!enabled) return null;
  return <button onClick={openSwapModal}>Swap</button>;
}
```

### Refresh balances after a swap

A swap drives the same `tx` state as any other transaction. To update your own balance display when it finishes, watch for `success`:

```tsx
const { tx, refreshWalletBalance } = usePollar();

useEffect(() => {
  if (tx.step === 'success') refreshWalletBalance();
}, [tx.step, refreshWalletBalance]);
```

### Custom look, Pollar layout

If you need more than Branding allows, `@pollar/react` also exports `<SwapModalTemplate>`: the same screen as a pure presentational component that receives all data and callbacks as props. Pair it with the hook methods in Part 2 (`getSwapQuote`, `swap`, ...). See [Template components](https://docs.pollar.xyz/docs/sdk-reference/pollar-react#template-components).

---

## Part 2: Headless with `@pollar/core`

Use this part when you want your own swap UI, or when you are not in React (Vue, Svelte, vanilla JS, a script). Everything goes through `PollarClient`.

> **In React?** Every method below is also on `usePollar()` with the same signature (`getSwapConfig`, `getSwapTokens`, `getSwapQuote`, `swap`), and the transaction state is the `tx` value. You don't need to call `PollarClient` directly.

All swap methods need a logged-in user. See [Authentication](https://docs.pollar.xyz/docs/sdk-reference/pollar-core#authentication).

```typescript
import { PollarClient } from '@pollar/core';

const pollar = new PollarClient({
  apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx',
});
```

### Step 1: Check which venues are enabled

```typescript
const venues = await pollar.getSwapConfig(); // e.g. ['aquarius', 'sdex']

if (venues.length === 0) {
  // Swap is off for this app: hide your swap UI.
}
```

`getSwapConfig()` never returns `'auto'`. If the list is not empty, add `'auto'` to your route selector yourself, as the pre-built modal does:

```typescript
const routes = venues.length > 0 ? ['auto', ...venues] : [];
```

### Step 2: Build the asset lists

Assets use the same shape as payments:

```typescript
type AssetRef =
  | { type: 'native' }
  | { type: 'credit_alphanum4'; code: string; issuer: string }   // code of 1 to 4 chars
  | { type: 'credit_alphanum12'; code: string; issuer: string }; // code of 5 to 12 chars
```

- **Sell**: assets the wallet holds. Read them from the wallet balance (`pollar.refreshBalance()`, then `pollar.getWalletBalanceState()`). See [Wallet Balance](https://docs.pollar.xyz/docs/sdk-reference/pollar-core#wallet-balance).
- **Buy**: your enabled assets plus the buy tokens enabled in the dashboard:

```typescript
const tokens = await pollar.getSwapTokens();
// [{ code: 'AQUA', issuer: 'GBNZ...', name: 'Aquarius', domain: 'aqua.network' }, ...]

const buyOptions = tokens.map((t) =>
  t.code.length <= 4
    ? { type: 'credit_alphanum4' as const, code: t.code, issuer: t.issuer }
    : { type: 'credit_alphanum12' as const, code: t.code, issuer: t.issuer },
);
```

### Step 3: Get a quote

```typescript
const XLM = { type: 'native' } as const;
// Use the issuer of the USDC asset enabled in your app.
const USDC = { type: 'credit_alphanum4', code: 'USDC', issuer: 'GA5Z...' } as const;

const quotes = await pollar.getSwapQuote({
  sellAsset: XLM,
  buyAsset: USDC,
  amount: '10',       // amount of the SELL asset, as a decimal string
  provider: 'auto',   // optional, default 'auto'
  slippageBps: 50,    // optional, default 50 (0.5%)
});
```

**Parameters:**

| Field         | Type                                         | Default  | Description                                                        |
|---------------|----------------------------------------------|----------|--------------------------------------------------------------------|
| `sellAsset`   | `AssetRef`                                   |          | **Required.** Asset the user gives.                                |
| `buyAsset`    | `AssetRef`                                   |          | **Required.** Asset the user gets.                                 |
| `amount`      | `string`                                     |          | **Required.** Amount of `sellAsset` to swap.                       |
| `provider`    | `'auto' \| 'aquarius' \| 'soroswap' \| 'sdex'` | `'auto'` | `auto` quotes every enabled venue; a venue name quotes only that one. |
| `slippageBps` | `number`                                     | `50`     | Allowed slippage in basis points (100 = 1%). Sets `minReceived`.   |

The connected wallet's address and the network are filled in by the SDK. The network comes from your API key.

**Each `SwapQuote` has:**

| Field            | Description                                                           |
|------------------|-----------------------------------------------------------------------|
| `provider`       | Venue this quote comes from (`aquarius`, `soroswap` or `sdex`).        |
| `sellAsset` / `buyAsset` | The pair.                                                     |
| `amountIn`       | Amount of the sell asset.                                              |
| `amountOut`      | Estimated amount of the buy asset.                                     |
| `minReceived`    | Lowest amount accepted on-chain after slippage. Show this to the user. |
| `priceImpactPct` | Price impact, as a percentage string.                                  |
| `route`          | `hops` (asset path) and, for AMMs, the `poolAddress`.                  |
| `build`          | Ready-to-run transaction payload. Pass the whole quote to `swap()`; you don't need to read this. |

`quotes[0]` is the best price. With `provider: 'auto'` you can also show every quote and let the user pick a route.

**Quotes go stale.** Pool prices move, so re-quote when the user changes the amount or the pair (debounce the input; the pre-built modal waits 400 ms) and right before executing if the quote has been on screen for a while.

### Step 4: Execute the swap

```typescript
const quote = quotes[0];
const outcome = await pollar.swap(quote);

if (outcome.status === 'success') {
  console.log('Swapped. Tx hash:', outcome.hash);
} else if (outcome.status === 'pending') {
  // Submitted but not confirmed yet. Track it with onTransactionStateChange.
} else {
  console.error('Swap failed:', outcome.details);
}
```

What `swap()` does, in order:

1. Returns an error right away for smart (C-address) wallets.
2. If the buy asset is a credit asset and the wallet has no trustline for it, creates the trustline first. If that fails, it returns an error and no swap is attempted.
3. Signs and submits the swap. The transaction is re-simulated on the server, and `minReceived` is enforced on-chain.

To skip the trustline step (for example, because you already created it with `setTrustline()`), pass `{ autoTrustline: false }`:

```typescript
await pollar.swap(quote, { autoTrustline: false });
```

### Step 5: Show progress

`swap()` drives the same `TransactionState` machine as `runTx()`, so you can reuse any progress UI you already have for payments:

```typescript
const unsubscribe = pollar.onTransactionStateChange((state) => {
  switch (state.step) {
    case 'building-signing-submitting':
    case 'signing':
    case 'submitting':
      showSpinner();
      break;
    case 'success':
      showDone(state.hash);
      pollar.refreshBalance();
      break;
    case 'error':
      showError(state.message ?? state.details);
      break;
  }
});
```

The full list of steps is in [`TransactionState`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core#transactions). Call `pollar.resetTransactionState()` before starting a new swap if your UI shows the last result.

### Handling errors

`getSwapConfig()`, `getSwapTokens()` and `getSwapQuote()` throw on failure; the error message is the error code. `swap()` never throws: check `outcome.status`.

| Where                | Error                                | Meaning / what to do                                             |
|----------------------|--------------------------------------|------------------------------------------------------------------|
| `getSwapQuote`       | empty array, or `SDK_SWAP_NO_ROUTE`  | No pool or path for this pair on this network. Try another pair, a smaller amount or another venue. |
| `getSwapQuote`       | `VALIDATION_ERROR`                   | Invalid input: for example, the same asset on both sides or a bad amount. |
| any read             | `SDK_SWAP_QUOTE_ERROR`               | A venue or the network failed to answer. Retry.                  |
| `getSwapQuote`       | `No wallet connected`                | The user is not logged in.                                       |
| `swap`               | `Swaps are not yet supported for smart (passkey) wallets` | Hide swap for smart wallets (`wallet.custody === 'smart'`). |
| `swap`               | `Trustline for <CODE> failed: ...`   | The trustline step failed, usually for lack of XLM for the 0.5 XLM reserve. |
| `swap`               | status `error` from the network      | Often the price moved past `minReceived` or the wallet lacks the sell balance or the fee. Get a new quote and try again. |

Treat a no-route result as a normal outcome, not a crash: for example, show "No route for this pair" and keep the form open.

### Full example

A minimal headless flow, from config to result:

```typescript
import { PollarClient, type SwapQuote } from '@pollar/core';

const pollar = new PollarClient({ apiKey: 'pub_testnet_xxxxxxxxxxxxxxxxxxxx' });

const XLM = { type: 'native' } as const;
const USDC = {
  type: 'credit_alphanum4',
  code: 'USDC',
  issuer: 'GA5Z...', // the USDC issuer enabled in your app
} as const;

export async function swapXlmToUsdc(amount: string) {
  if (pollar.getWallet()?.custody === 'smart') {
    throw new Error('Swaps are not available for passkey wallets yet');
  }

  const venues = await pollar.getSwapConfig();
  if (venues.length === 0) throw new Error('Swap is not enabled for this app');

  let quotes: SwapQuote[];
  try {
    quotes = await pollar.getSwapQuote({ sellAsset: XLM, buyAsset: USDC, amount });
  } catch (e) {
    if ((e as Error).message === 'SDK_SWAP_NO_ROUTE') quotes = [];
    else throw e;
  }
  if (quotes.length === 0) throw new Error('No route for XLM to USDC right now');

  const best = quotes[0];
  console.log(`~${best.amountOut} USDC via ${best.provider} (min ${best.minReceived})`);

  const outcome = await pollar.swap(best);
  if (outcome.status === 'error') throw new Error(outcome.details);
  return outcome;
}
```

---

## Going to mainnet

- Your mainnet app is a separate app with its own API key. Enable venues and buy tokens again in **Treasury > Swap** of the mainnet app.
- Use mainnet asset issuers: testnet issuers are not valid on mainnet.
- Mainnet wallets are not funded by friendbot: make sure users hold XLM for fees and trustline reserves.

See the [Mainnet Checklist](https://docs.pollar.xyz/docs/guides/mainnet-checklist).
