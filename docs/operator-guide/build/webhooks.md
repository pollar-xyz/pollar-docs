---
title: "Webhooks `upcoming`"
---

**Dashboard → Build → Webhooks** · Chains: Stellar

> 🚧 **Not yet available.** The Webhooks page exists in the dashboard but is gated behind a "coming soon" state — endpoints cannot be delivered to in production yet. Event types, signature verification, and the retry policy below describe the **planned** design. See the [Webhooks reference](https://docs.pollar.xyz/docs/sdk-reference/webhooks) for the current internal behavior.

Configure URLs where Pollar sends event notifications when things happen in your app.

---

## Planned endpoint configuration

1. Click **Add endpoint**
2. Enter your URL (must be HTTPS in production)
3. Select which events to receive
4. Copy the **Webhook secret** — used to verify incoming requests

---

## Verifying webhook signatures

The current internal `stellar.tx` dispatcher signs the raw request body with
HMAC-SHA256 and the configured secret, using `X-Pollar-Signature: sha256=<hex>`.
See the constant-time verification example in the [Webhooks reference](https://docs.pollar.xyz/docs/sdk-reference/webhooks).
Verify the raw bytes before parsing or processing an event. This internal format
does not establish the future durable ramp-webhook contract.

A successful receiver should return a 2xx response promptly. Current internal
delivery attempts once and logs failures; it has no retry/backoff. Durable
application delivery, retry policy and replay tooling remain pending.

---

## Planned event log

A delivery-attempt event log is planned. Do not depend on a dashboard event log
or exhausted-retry controls in this revision. Ramp lifecycle outbox records
store internal events; they do not prove delivery to an application endpoint.
