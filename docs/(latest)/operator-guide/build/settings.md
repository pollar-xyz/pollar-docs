---
title: "Settings"
---

**Dashboard > Build > Settings** · Chains: all

General configuration for your Pollar app.

---

## Application name

The name displayed in your dashboard. Members with write access (owner, admin, editor) can change it.

---

## Application state

Shows the app's network (**Testnet** or **Mainnet**). The network is fixed when the app is created and cannot be changed.

Apps start on Testnet. Mainnet access is gated behind a review by the Pollar team:

1. Click **Request Mainnet access** (also reachable from the **MainNet** segment of the network control in the top bar). Only the **owner or an admin** sees it.
2. Fill in the company or project name, the use case, the expected monthly volume, an optional website or repo and a compliance / business contact email, and acknowledge the terms.
3. While the request is **Under review**, the page shows the email the decision is sent to. Reviews usually take 1-2 business days.
4. **Approved**: Pollar creates the app's mainnet counterpart in the same project. The network control in the top bar then switches between the testnet and the mainnet app, keeping the page you are on.
5. **Needs changes**: the reviewer's note is shown and you can **Submit a new request**.

An archived app cannot request mainnet access until it is restored.

---

## Authentication & Sessions

Control how long the tokens the SDK issues to end users live:

| Field | Range | Default |
| --- | --- | --- |
| **Access token TTL** | 5-60 minutes | 10 minutes |
| **Refresh token TTL** | 1-90 days | 30 days |

Leave a field empty (or click **Reset to defaults**) to use the platform default. Changes apply to tokens issued from then on; active sessions keep their lifetime until their next refresh.

---

## App ID

The app's identifier, used to associate your Pollar client with this app. Read-only, with a copy button.

---

> Allowed origins and redirect URIs live under **Build > Domains**. To take an app offline, use **Danger Zone > Archive app**: archiving disables the app's API keys and SDK access and is reversible. There is no permanent delete.
