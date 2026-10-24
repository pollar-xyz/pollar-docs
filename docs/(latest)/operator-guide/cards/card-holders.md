---
title: "Card holders"
---

**Dashboard → Cards → Card holders** · Chains: all

Your users' cards: identity verification, the card and its credit line. Card numbers are never shown here; only the user reveals them, from the SDK.

---

## The list

| Column | Description |
| --- | --- |
| **User** | Email or name of the holder |
| **Provider** | The card provider the holder was created with |
| **Verification** | The provider's identity check: pending, waiting for the user, approved, rejected |
| **Card** | Whether a card has been issued, and its state |
| **Credit line** | The balance available on the card and its recent movements (bank deposit, purchase adjustment, card issuance) |
| **Created** | When the holder was created |

Open a row to see the holder's timeline: each verification step, the issuance, and the funding movements that fed the credit line.

---

## Related

- [Card providers](https://docs.pollar.xyz/docs/operator-guide/cards/providers)
- [KYC](https://docs.pollar.xyz/docs/operator-guide/integrations/kyc)
