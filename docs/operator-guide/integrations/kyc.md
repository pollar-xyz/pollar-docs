---
title: "KYC `upcoming`"
---

**Dashboard → Integrations → KYC**

> 🚧 **Not yet available.** The KYC configuration page is gated behind a "coming soon" state in the dashboard.

Connect identity-verification providers so you can gate features — for example, activating a wallet in [Deferred](https://docs.pollar.xyz/docs/core-concepts/funding-modes) mode only after a user passes KYC.

The SDK side already exists: `getClient().getKycProviders()`, `startKyc()`, and `getKycStatus()` from [`@pollar/core`](https://docs.pollar.xyz/docs/sdk-reference/pollar-core), plus `openKycModal()` from [`@pollar/react`](https://docs.pollar.xyz/docs/sdk-reference/pollar-react). What's upcoming is the per-app provider configuration UI here.
