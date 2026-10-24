---
title: "Accounts"
---

**Dashboard > Users > Accounts** · Chains: all

Every user who has signed in to your app. The cards on top show **Total users**, **With wallet** and **Active last 7 days**.

---

## User list

| Column | Description |
|---|---|
| **User** | Avatar, name or email, and a second line with the email or ID |
| **Providers** | How the user signs in (Google, GitHub, Email, external wallet, passkey) |
| **Wallets** | Every wallet of the user, one line per chain: the network, the address (click it to open the wallet in [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets)), a copy button, and a **Co-signed**, **External** or **Rail** badge when it applies. A dash means the user has no wallet yet |
| **Status** | Active |
| **Activity** | Last login and when the user joined |

Search by name, email, ID or wallet address. Filter with **All accounts**, **With wallet**, **No wallet** or **Active last 7d**, and by provider. **Export CSV** exports the list with every wallet of each user.

---

## Row actions

The row menu offers:

- **Copy user ID** and **Copy wallet public key**
- **Allow sponsored signer rotation** / **Revoke signer rotation**, for a user with an external wallet, while signer rotation and its external sub-option are on under [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship#signer-rotation). A grant covers one rotation.

There is no per-user detail page. To fund a user's Stellar wallet by hand, use **Fund** on the wallet's row in [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets); transactions are in [Monitor > Transactions](https://docs.pollar.xyz/docs/operator-guide/monitor/transactions).
