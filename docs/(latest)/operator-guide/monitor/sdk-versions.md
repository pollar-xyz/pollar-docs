---
title: "SDK versions"
---

**Dashboard > Monitor > SDK versions** · Chains: all

Which `@pollar/core` builds your app is running, and how many live sessions are still on each. Recorded at sign-in and on every session resume.

Use it before you switch on a feature that needs a minimum SDK version: on-demand wallet creation and wallet-less sessions need **0.11.4**, co-signed custody needs **0.11.5**. The page tells you how many sessions would be left behind.

---

## The list

| Column | Description |
| --- | --- |
| **Version** | The `@pollar/core` version the session reported (`0.11.5`, `0.12.0-rc.1`, ...) |
| **Platform** | Web, React Native or Node |
| **Live sessions** | Sessions on that build whose refresh token is still valid |
| **Last seen** | The most recent sign-in or resume on that build |

The newest build the app runs is highlighted; older builds are listed relative to it. The comparison is within your app, not against npm.

Versions appear once your users sign in or reload with `@pollar/core` **0.11.4 or newer**. Older SDKs do not report themselves.

---

## Related

- [Wallet settings](https://docs.pollar.xyz/docs/operator-guide/wallets/settings): the features gated on an SDK version
- [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core)
