---
title: "Get started"
---

**Dashboard > Overview > Get started** · Chains: all (the funding step is Stellar)

A checklist shown on new apps. It tracks how many steps are completed and the sidebar hides it once every step is done.

| Step | Badge | Done when |
| --- | --- | --- |
| **Configure API keys** ([API Keys](https://docs.pollar.xyz/docs/operator-guide/build/api-keys)) | Required | The app has a publishable key |
| **Configure allowed domains** ([Domains](https://docs.pollar.xyz/docs/operator-guide/build/domains)) | Required | At least one allowed origin is listed |
| **Fund app wallet** ([Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding)) | Required | The app's Stellar wallet exists on-chain and holds more than 10 XLM. Each user wallet costs about 2 XLM of base reserve |
| **Enable trustlines** ([Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines)) | Recommended | At least one asset is enabled. Without it users can only hold XLM |
| **Create your first user wallet via SDK** ([Quickstart](https://docs.pollar.xyz/docs/getting-started/quickstart)) | Verification | At least one SDK user wallet exists |

The funding step checks only the Stellar app wallet. On Solana or Polygon, fund the chain's GAS wallet from [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship); the checklist does not track it.
