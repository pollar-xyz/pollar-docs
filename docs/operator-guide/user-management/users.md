---
title: "Users"
---

**Dashboard → User Management → Users**

Browse and manage all users who have authenticated through your app.

---

## User list

| Column | Description |
|---|---|
| **User ID** | Pollar user ID (`usr_...`) |
| **Email** | User email — shown if authenticated via email OTP or OAuth with email scope |
| **Provider** | Auth provider used (Google, GitHub, Discord, Email) |
| **Wallet** | Associated wallet ID and status |
| **Created** | First login timestamp |
| **Last seen** | Most recent activity |

Search by email or user ID. Filter by auth provider or wallet status.

---

## User detail

Click any user to see:

- Auth provider and login history
- Associated wallet — ID, G-address, status, and balances
- Full transaction history
- Option to manually activate their wallet (Deferred / Manual mode)