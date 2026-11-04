---
title: "Features"
---

**Dashboard > Features** - Chains: all

Choose which areas of Pollar your app uses. Each area is a card. Turn a card on and its section shows up in the sidebar, and the card gets a **Set up** link to its first page. Cards that are on are listed under **On**; the rest are under **Available to turn on**.

---

## The cards

| Card | What it is for | Status |
| --- | --- | --- |
| **Wallets** | Every user gets their own wallet to keep money in | Always on |
| **Cash in and out** | Users add money from their bank and take it back out | Shows the [Cash in and out](https://docs.pollar.xyz/docs/operator-guide/ramps/orders) section |
| **Identity checks** | Confirms who your users are before they move money | Shows the [Identity checks](https://docs.pollar.xyz/docs/operator-guide/identity-checks/providers) section |
| **Cards** | Give your users a card to spend their balance online or in stores | Shows the [Cards](https://docs.pollar.xyz/docs/operator-guide/cards/card-holders) section |
| **Savings** | Users earn interest on the money they keep in their wallet | Shows the [Savings](https://docs.pollar.xyz/docs/operator-guide/wallets/earn) page under Wallets |
| **Pollar Pay** | Get paid in your customers' local currency, in person or online | [Coming soon](https://docs.pollar.xyz/docs/operator-guide/pollar-pay/overview): not available yet, and it cannot be turned on |

---

## Turning a feature off

Turning a feature off **only hides it in the dashboard**. Nothing stops working: the SDK and the API keep working as before, and your users notice no change.

A page of a turned-off feature is gone from the sidebar. If you open it by its URL, it says the feature is off and offers **Go to Features**.

---

## Features that need Identity checks

Cash in and out and Cards need Identity checks. When you turn on either one, Identity checks is added for you. Its card then says **Added for you**, and it stays on while either of them is on.

---

## Who can change features

Anyone who can write the app: the owner, an admin or an editor. Viewers see the page but cannot change it.
