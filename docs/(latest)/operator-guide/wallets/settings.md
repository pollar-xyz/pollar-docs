---
title: "Wallet settings"
---

**Dashboard > Wallets > Wallet settings** · Chains: all

The chains your app serves, who holds your users' wallet keys, when their wallets are created, and when a signature asks the user. The page has four cards. Funding has its own page, [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding).

---

## Enabled chains

Your users get **one wallet per enabled chain**. Chains are independent of the network: on a testnet app Polygon means **Amoy** and Solana means **devnet**; on a mainnet app they are Polygon mainnet and Solana mainnet-beta. The network follows the app (see [Settings](https://docs.pollar.xyz/docs/operator-guide/build/settings)).

| Chain | Fees | What your treasury holds |
|---|---|---|
| **Stellar** | Sponsored | XLM in the funding wallet. It pays the account-creation reserve and sponsors your users' fees, so a user wallet can hold zero XLM and still transact. |
| **Polygon** (EVM) | Not sponsored | POL in the Polygon GAS wallet. Every user wallet must hold POL to sign, so Pollar tops each one up from that wallet. |
| **Solana** | Not sponsored | SOL in the Solana GAS wallet. Same as Polygon, and an account that falls below the rent-exempt minimum is deleted by the network with its balance, so the top-up keeps every wallet above that line. |

For an app on credits, Pollar's pool pays these instead and charges credits (see [Credits](https://docs.pollar.xyz/docs/operator-guide/billing/credits)).

### Enabling a chain

Each toggle opens a confirmation that explains what the chain costs your treasury. When you enable Polygon or Solana and the app has no GAS wallet on that chain yet, the confirmation warns that new wallets will be created but cannot sign anything until the GAS wallet exists and holds the native token. Create and fund the GAS wallet under [Sponsorship](https://docs.pollar.xyz/docs/operator-guide/wallets/sponsorship).

Chains the platform does not serve right now are not listed. If a chain you already enabled stops being served, it stays in the list with its toggle locked and the note "Not available on this platform right now", because it still has wallets behind it. Contact Pollar to have it turned on.

### Order

Enabled chains are **ordered**, and the order matters: the SDK receives them in this exact order through `/v3/applications/config`, so **the first chain is the default your users see** in the SDK's chain pickers.

Drag a row by its grip, or use the arrows, to reorder. Reordering saves immediately, with no confirmation. A newly enabled chain joins the end of the list, so enabling never changes your default. A disabled chain has no position and is not sent to the SDK at all. With a single chain the reorder controls are hidden.

Drive your client's chain selector from `/v3/applications/config` rather than from the user's wallet list: a chain can be enabled before a given user has a wallet on it.

### Disabling a chain

Turning a chain off **never deletes wallets or keys**. It stops new ones being created and hides the existing ones from your users. The confirmation tells you how many user wallets exist on that chain: your users stop seeing them, along with any funds left in them, until you enable the chain again. Re-enabling restores access. Those wallets stay visible to you in [Wallets](https://docs.pollar.xyz/docs/operator-guide/wallets/user-wallets) with the **Rail** filter.

---

## Wallet custody

Who holds the key of the wallets created from now on. Wallets that already exist keep the custody they were created with.

| Mode | What happens | Offered on |
| --- | --- | --- |
| **Pollar** | Pollar keeps the encrypted key and signs on behalf of the user. | Testnet only |
| **Co-signed with Turnkey (2-of-2)** | Each user gets a Turnkey sub-organization where their device and Pollar must both approve every signature. Neither side can move funds alone, and the user can export the wallet without Pollar. | Testnet and mainnet |
| **Self-custody with Turnkey (1-of-1)** | Each user gets a Turnkey sub-organization where only their device signs. Pollar cannot move, freeze or recover the funds: it only relays the signatures and decides which fees to sponsor. A user who loses every recovery method loses the wallet. | Testnet and mainnet |

- **Pollar custody is not offered on mainnet.** A mainnet app that still has it keeps it until it picks another mode, and once it does it cannot come back.
- **Letting each user choose** is not offered either. An app that still has it sees it as its current mode and can only leave it.
- On a **testnet** app the Turnkey modes can be saved, but its wallets stay in Pollar custody unless Pollar has enabled Turnkey wallets on testnet for testing. The card says so.
- The Turnkey modes need an SDK that registers the device key and shows the approval prompt (`@pollar/core` 0.12.0 or later). Users on an older SDK cannot create a wallet until they upgrade.

See [Co-signed Wallets](https://docs.pollar.xyz/docs/core-concepts/co-signed-wallets) for how the votes work, how users set up recovery, and what the device checks before it signs.

---

## Wallet creation

| Mode | What happens | Best for |
| ---- | ------------ | -------- |
| **At login** (default) | Every user gets a wallet on every enabled chain the first time they sign in | Apps where every user transacts |
| **On demand** | Users sign in without a wallet; your app creates it with `createWallet()` in the SDK when they need one | Apps where only some users ever need a wallet |
| **Never** | Users get a session and no wallet | Authentication only |

Users who already have a wallet keep it in every mode. Once created, a wallet is funded according to [Account Funding](https://docs.pollar.xyz/docs/operator-guide/wallets/account-funding). Before switching to **On demand** or **Never**, make sure your app runs `@pollar/core` / `@pollar/react` 0.11.4 or later.

See [Wallet Creation](https://docs.pollar.xyz/docs/core-concepts/wallet-creation) for what a session without a wallet looks like.

---

## Signature confirmation

When the SDK asks your users to confirm a signature your app requests.

| Option | What happens |
| --- | --- |
| **Always ask** (default) | Every signature shows the transaction and waits for the user. |
| **Ask, then remember for a while** | A confirmed signature opens a window: the next payments sign without asking until the time runs out or their total reaches the limit. An [x402](https://docs.pollar.xyz/docs/guides/x402-payments) payment in a priced Stellar asset counts too. Anything the SDK cannot value in USD (swaps, contract calls, raw transactions) still asks. |
| **Never ask** | Signatures go through without a prompt: your app's own call is the consent. |

For **Ask, then remember for a while** set the **Window** (1 to 60 minutes, default 5) and the **Limit per window** in USD (above 0 and up to 10,000, default 50).

- If your code sets its own `confirmation` option, the **stricter** of the two applies.
- **Ramp steps always ask**, whatever you choose here.
- The setting applies to every wallet, external ones included.
- It needs SDK 0.12 or later. Older SDKs keep their own setting.

See the `confirmation` option in [@pollar/core](https://docs.pollar.xyz/docs/sdk-reference/pollar-core).
