---
title: "Community integrations"
---

Packages built by other teams on top of the public Pollar SDK. They are listed here so you can find them.

> **Community-maintained.** These packages are written, published and supported by their own authors. Pollar does not audit, maintain or support them, and listing one here is not an endorsement. Review the code and its scope before you use it, and report issues to its repository.

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
