---
title: "Token Distribution"
---

**Dashboard > Treasury > Token Distribution** · Chains: Stellar

Configures **distribution rules**: assets your app makes available for users to claim. Users claim them from the SDK (`openDistributionRulesModal()`, or `getClient().listDistributionRules()` / `claimDistributionRule()`).

---

## Distribution wallet

The top of the page shows the wallet claims are paid from: the app's **distribution vault**. By default that is the app wallet (or its DISTRIBUTION wallet, when Pollar has set up one wallet per role). Fund it by sending assets to its address; on testnet the card offers **Fund on testnet**. If the app has no wallet, claims fail with `DISTRIBUTION_NO_DISTRIBUTION_WALLET`.

On an app on credits, the vault holds the app's own assets and has its own page, [Distribution vault](https://docs.pollar.xyz/docs/operator-guide/billing/distribution-vault), where the owner or an admin can withdraw from it.

---

## Distribution rules

Stack several rules to combine drips. **+ Add rule** opens the rule form:

| Setting | Description |
|---|---|
| **Name** | A label for the rule, for example "Welcome drip" |
| **Asset** | XLM is always available; any other asset must be enabled in [Tokens & Trustlines](https://docs.pollar.xyz/docs/operator-guide/wallets/tokens-trustlines). It cannot be changed after the rule is created |
| **Amount per user** | How much a user receives per claim |
| **Max claims per period** and **Period** | The per-user rate limit. Periods: per day (rolling or calendar), per week (rolling), per month (rolling or calendar), or lifetime (no reset). Rolling counts from the user's previous claim; calendar resets for everyone at 00:00 UTC (daily, or on the 1st of the month) |
| **Cap total claimants** | Optional cap across all users, for campaigns like "the first 1,000 users get 10 USDC". Once reached, the rule stops dispensing to new users; existing claimants can keep claiming within their rate limit |
| **Valid from** / **Valid until** | Optional validity window; claims outside it fail |
| **Enabled** | A disabled rule dispenses nothing |

The rules table shows each rule's asset, amount and rate limit, its validity, how many users have claimed out of the cap, and a state: **Active**, **Disabled**, **Scheduled**, **Expired** or **Cap reached**.

Claiming an asset with no rule returns `DISTRIBUTION_ASSET_NOT_ENABLED`. Other errors: `DISTRIBUTION_RULE_NOT_FOUND`, `DISTRIBUTION_RULE_DISABLED`, `DISTRIBUTION_RULE_NOT_STARTED`, `DISTRIBUTION_RULE_EXPIRED`, `DISTRIBUTION_RULE_EXHAUSTED`, `DISTRIBUTION_RATE_LIMIT_EXCEEDED`.

---

## Recent distributions

The latest drips processed by these rules, with the rule, user, amount and status (success or pending).
