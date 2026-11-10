---
title: "Signing"
---

**Dashboard > Cash in and out > Signing** · Chains: Stellar, Solana, Polygon

Who signs the legs of your users' ramps. Pollar enables the modes for your app; a route that needs a mode your app does not have is not offered to your users.

---

## Signing modes

| Mode | Who signs each leg |
| --- | --- |
| **Co-signed** | The user's co-signed wallet. Each leg that moves funds asks the user to approve it. |
| **External wallet** | A wallet the user brings. Your app hands each leg to that wallet to sign. |
| **Self-custody** | The user approves each leg alone, with no vote from Pollar. |
| **App custody** | Your app signs with keys it holds. Requires accepting the app-custody terms. |

Each mode shows its status:

- **In use**: enabled and effective.
- **Waiting on terms**: Pollar enabled app custody, but it only counts once your app accepts the app-custody terms.
- **Not enabled**.

To enable another mode, contact Pollar.

Whatever the mode, a ramp leg signed in the SDK always asks the user to confirm, whatever the app's [signature confirmation](https://docs.pollar.xyz/docs/operator-guide/wallets/settings#signature-confirmation) setting. The one exception is the payment partner's sign-in ("Confirm it's you"): it moves no money and sends nothing, so with signature confirmation set to **Auto** a co-signed wallet approves it without a prompt.

Some payment partners keep a session for the order that lapses after about a day. When it is about to lapse on a wallet Pollar does not sign for, the user is asked to sign in again; the order keeps running meanwhile, and the request never covers a payment or verification step the order is showing.

---

## App custody terms

The terms are shown on the page with their title, version and sections. Only the **owner or an admin** can click **Accept these terms**; once accepted, the page shows the version and the date.

While the terms are a **DRAFT** (pending legal review), they are not binding and cannot be accepted, so app custody stays off for every app until the final version is published.
