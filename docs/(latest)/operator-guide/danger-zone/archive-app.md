---
title: "Archive app"
---

**Dashboard > Danger Zone > Archive app** · Chains: all

Destructive but reversible actions for the app. Only the **owner or an admin** sees this page and can perform them.

---

## Archive application

Archiving an app **disables all of its API keys and SDK access entirely**: every SDK call behaves as if the key never existed. It hides the app from collaborators and locks its settings (members, mainnet requests) until it is restored. No data is deleted, and existing user wallets are unaffected: they exist independently on-chain.

Archiving is confirmed with an explicit prompt. Once archived, the app shows an **Archived** badge and a notice that its keys and SDK access are disabled.

## Unarchive

Archiving is **reversible**: use **Unarchive app** to restore the app and re-enable its API keys and SDK access.

> There is no permanent "delete app" action in the dashboard. Archive is the way to take an app out of service.
