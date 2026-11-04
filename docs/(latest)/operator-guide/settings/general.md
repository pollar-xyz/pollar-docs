---
title: "General"
---

**Dashboard > Settings > General** · Chains: all

General configuration for your Pollar app.

---

## Application name

The name displayed in your dashboard. Members with write access (owner, admin, editor) can change it.

---

## Application state

Shows the app's environment (**Test mode** or **Live**). The environment is fixed when the app is created and cannot be changed.

Apps start in Test mode. Going live is gated behind a review by the Pollar team:

1. Click **Go live** (also reachable from the **Live** segment of the environment control in the top bar). Only the **owner or an admin** sees it.
2. Fill in the company or project name, the use case, the expected monthly volume, an optional website or repo and a compliance / business contact email, and acknowledge the terms.
3. While the request is **Under review**, the page shows the email the decision is sent to. Reviews usually take 1-2 business days.
4. **Approved**: Pollar creates the app's live counterpart in the same project. The environment control in the top bar then switches between the Test mode app and the live app, keeping the page you are on.
5. **Needs changes**: the reviewer's note is shown and you can **Submit a new request**.

An archived app cannot request to go live until it is restored.

---

## App ID

The app's identifier, used to associate your Pollar client with this app. Read-only, with a copy button.

---

> Token lifetimes live under **Users > Sign-in**. Allowed origins and redirect URIs live under **Developers > Websites**. To take an app offline, use **Settings > Archive app**: archiving disables the app's API keys and SDK access and is reversible. There is no permanent delete.
