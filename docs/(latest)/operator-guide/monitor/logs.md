---
title: "Logs"
---

**Dashboard > Monitor > Logs** · Chains: all

The application logs Pollar's services write for your app: what happened when your users signed in, sent transactions or ramped, with the errors.

---

## The table

| Column | Description |
| --- | --- |
| **Timestamp** | When the entry was written |
| **Level** | The severity (for example error, warning, info) |
| **Message** | The log message. Open an entry to see its full content and highlights |

---

## Finding entries

- **Level**: show one severity or all.
- **Search messages**: filter by text in the message.
- **From** / **To**: a date range (**Clear dates** removes it).
- **Rows to fetch**: how many entries to load.
- **Live**: streams new entries as they are written ("Streaming live"); **Refresh** reloads.

Use it to debug an integration: an error your users hit usually shows up here with the reason.
