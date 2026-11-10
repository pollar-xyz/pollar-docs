---
title: "Countries and methods"
---

**Dashboard > Cash in and out > Countries and methods** · Chains: Stellar, Solana, Polygon

Choose where your users can buy and sell crypto, and how they pay or get paid. Turn on Buy or Sell for each payment method in each country. Your users then see those methods in the SDK's ramp widget (`openRampModal()`) or through the headless ramp API. How a ramp runs is explained in [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps).

You do not pick providers. Pollar decides which payment partners serve each method, and for every quote it picks the route with the best price.

---

## Return URL after identity check

At the top of the page. This is where your users come back after they verify their identity. It applies to every country and method.

- It must be an https URL.
- It must be one of your app's allowed origins or redirect URIs (see [Websites](https://docs.pollar.xyz/docs/operator-guide/developers/domains)). Do not use a webhook URL.
- Click **Save**. Leave it empty and save to remove it.

---

## Countries

The page shows one card per country. Countries with at least one method turned on come first, and the card says how many are on (for example **2 on**).

Each card lists the country's methods. A method is a payment rail and a currency, for example **QR** in BOB, **Bank transfer**, **Cash**, **Card**, **PIX** or **SPEI**. **Several options at checkout** means your user picks how to pay on the payment partner's own page.

For each method you see:

| Item | What it means |
| --- | --- |
| **Buy** | Switch. Your users pay in local money and receive crypto |
| **Sell** | Switch. Your users send crypto and receive local money |
| **Amount** | Under each switch: the smallest and largest amount in local money, for example `10 BOB to 5,000 BOB`, **From** or **Up to** an amount, or **No limit** |
| **Tokens** | What your user receives or sends, and on which chain, for example USDC on Stellar |
| **Identity check** | Your users must verify their identity before they can use this method |

A method shows only the switches it supports: some methods offer Buy only, or Sell only. Every method starts off. Methods depend on the environment: Test mode and Live can offer different countries and methods. If none is offered yet, the page says so.

Owners, admins and editors can change the switches and the return URL. Viewers see the page read-only. **Refresh** reloads the list.

### Reaching your user's chain

Your user does not have to receive the token on the chain listed on the method. Pollar can add steps after the payment: a swap to another token, or a bridge to another chain. It only sends funds to the chains your app enables under [Wallets > Settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#enabled-chains). Each step is priced when your user asks for a quote.

When a step runs on a chain your app does not serve, Pollar creates the user's wallet there (a rail wallet, see [All wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets#rail-wallets)). When a step leaves a Stellar token in a wallet with no trustline for it, your user is asked to add it first. Your app sponsors that trustline: the token is listed as **Used by ramps** under [Tokens](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines).

A method that needs a signing mode your app does not have is not offered to your users. See [Signing](https://docs.pollar.xyz/docs/operator-guide/ramps/signing).

---

## Identity check

When a method shows **Identity check**, your users must be approved before they use it, whatever the amount. Pollar decides which methods need it; you cannot change it here. After the check, your users return to the [return URL](#return-url-after-identity-check).

---

## Your own provider account or identity check

Some apps use their own account with a payment partner, or their own identity check options for a method. These are not set in the dashboard. To set one up, contact Pollar.

---

## In your app

```tsx
const { openRampModal } = usePollar();

<button onClick={openRampModal}>Deposit / Withdraw</button>
```

For headless control use the ramp methods of [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core) (`getRampRoutes`, `quoteRamp`, `createRampOrder`, `pollRampOrder`), or `/v3/ramps` in the [Server API](https://docs.pollar.xyz/docs/sdk-reference/server-api). Ramps need `@pollar/core` 0.12.0 or later.

---

## Related

- [Orders](https://docs.pollar.xyz/docs/operator-guide/ramps/orders): the ramp orders your users open
- [Transactions](https://docs.pollar.xyz/docs/operator-guide/ramps/transactions): older ramps, and the ones Pollar is reviewing
- [Ramps](https://docs.pollar.xyz/docs/core-concepts/ramps): how an order runs, step by step
