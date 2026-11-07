---
title: "Community integrations"
---

Packages built by other teams on top of the public Pollar SDK. They are listed here so you can find them.

> **Built by the community.** These integrations are created and maintained by their own authors, and we're glad to share them here. They aren't reviewed or supported by Pollar, so please check each project's scope before using it, and reach out to its authors through their repository with any questions or issues.

## Sub Rosa adapter

**Package:** [`@sub-rosa/pollar-adapter`](https://www.npmjs.com/package/@sub-rosa/pollar-adapter) &nbsp;|&nbsp; **Source:** [github.com/karagozemin/Sub-Rosa](https://github.com/karagozemin/Sub-Rosa) &nbsp;|&nbsp; **License:** MIT

Connects a Pollar Stellar wallet to the [Sub Rosa](https://github.com/karagozemin/Sub-Rosa) SDK, so a user signed in with Pollar can take part in Sub Rosa sealed rounds. The adapter signs with `PollarClient.signTx` and `signAuthEntry`; Sub Rosa submits the signed transaction itself.

Its current scope, as stated by its authors:

- Stellar testnet only
- Classic `G...` accounts only
- Sub Rosa `ReceiptOnly` rounds only
- Self-paid transactions (`skipSponsorship: true`)

```bash
npm install @sub-rosa/pollar-adapter @pollar/core @sub-rosa/sdk
```

See the package README for usage and the checks it runs on every signature.

## List your integration

If you built a package on top of Pollar and want it listed here, contact the Pollar team with the npm package, the source repository and its current scope.
