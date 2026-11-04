---
title: "Verification steps"
---

**Dashboard > Identity checks > Verification steps** - Chains: all

The steps your users complete, in order. Each step is either **Identity verification (KYC)**, using an option enabled under [Providers](https://docs.pollar.xyz/docs/operator-guide/identity-checks/providers), or a **Form** that Pollar offers to your app. A step can accept several alternatives: it passes with any of them, and when none is done the first one is asked for. Reorder steps and alternatives with the arrows; up to 10 steps with up to 10 alternatives each. **Save steps** stores them; every option used must be enabled for the app.

With no steps, your users can verify with any option enabled under [Providers](https://docs.pollar.xyz/docs/operator-guide/identity-checks/providers).

Nothing is blocked automatically: read the user's status from the SDK and decide.
