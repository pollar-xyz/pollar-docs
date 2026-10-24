---
title: "Providers"
---

**Dashboard → Cards → Providers** · Chains: all (the card is funded from the user's Stellar wallet)

Let your users get a card funded from their Pollar wallet. Enable the card providers you want to offer; they are off by default.

---

## Settings

| Setting | What it does |
| --- | --- |
| **Provider toggle** | Enables the provider for this app. Each provider lists the identity-verification option it requires; the user completes it from `<KycModal>` or the card flow itself |
| **Card label** | The name printed in the card flow, at most 40 characters |
| **Redirect URL** | Where the provider sends the user back after a hosted step. It must be an allowed app origin or a registered redirect URI (see [Domains](https://docs.pollar.xyz/docs/operator-guide/build/domains)) |

---

## What the user does

From the SDK the user creates a card holder, passes the provider's identity check, gets the card issued and reveals its details. Those steps are chain-agnostic. **Funding the card** moves USDC from the user's Stellar wallet, so an app that offers cards serves Stellar.

---

## Related

- [Card holders](https://docs.pollar.xyz/docs/operator-guide/cards/card-holders): your users' cards and their state
- [Chain Support](https://docs.pollar.xyz/docs/core-concepts/chain-support)
