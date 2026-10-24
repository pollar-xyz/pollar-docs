---
title: "Theming"
---

Every modal in `@pollar/react` and the `<WalletButton>` read their colors, corners and stacking order from public CSS custom properties (`--pollar-*`). You can set any of them from your own stylesheet.

**Requires:** `@pollar/react` 0.12.0 or later.

---

## Where a value comes from

Each variable resolves from three sources. The first one that sets it wins:

1. **Your stylesheet.** A rule in your app that sets the variable on a Pollar element.
2. **Dashboard Branding.** The values configured in [Build -> Branding](https://docs.pollar.xyz/docs/operator-guide/build/branding), loaded by the SDK at startup.
3. **Theme defaults.** The Light set. If your page has `<html class="dark">` and Branding leaves the palette open (see [Dark mode](#dark-mode)), the Dark set is used instead.

You only set what you want to change. Anything you leave out still comes from Branding, and then from the defaults.

---

## Override from your stylesheet

Set the variables on the Pollar root elements:

```css
.pollar-modal-card,
.pollar-wallet-wrapper,
.pollar-wallet-login-btn {
  --pollar-accent: #7c3aed;
  --pollar-btn-primary-fg: #ffffff;
  --pollar-buttons-border-radius: 12px;
}

.pollar-overlay {
  --pollar-overlay-z-index: 1000;
}
```

| Element | What it is |
|---|---|
| `.pollar-modal-card` | The card of every modal (login, KYC, send, swap, ramp, history, ...) |
| `.pollar-wallet-wrapper` | The signed-in `<WalletButton>` and its dropdown |
| `.pollar-wallet-login-btn` | The signed-out `<WalletButton>` |
| `.pollar-overlay` | The backdrop behind a modal (only `--pollar-overlay-z-index` and `--pollar-overlay-bg`) |

You don't need `!important`, and load order doesn't matter: the SDK declares its own values with zero specificity, so any selector with a class wins.

**Set them on these elements, not on `:root` or `body`.** Each Pollar root declares the variables itself, and a value declared on an element takes precedence over one inherited from `:root`. The two font variables are the exception: the SDK doesn't declare them, so they also work from `:root`.

To theme a single modal, target its own class. Each card has one next to `.pollar-modal-card`, for example `.pollar-modal` (login), `.pollar-send-modal`, `.pollar-swap-modal`, `.pollar-ramp-modal` or `.pollar-hist-modal`:

```css
.pollar-send-modal {
  --pollar-modal-border-radius: 0px;
}
```

---

## Dark mode

The SDK picks the palette like this:

- **Branding theme Dark**: dark palette, always.
- **Branding theme Light with no Background or Text color**: light palette. If your page has `<html class="dark">`, the modals switch to the dark palette, so they follow a Tailwind-style dark toggle without extra code.
- **Branding sets a Background or Text color**: that palette is pinned, and `html.dark` does not change it.

For a pinned palette, or if your app marks dark mode in some other way, set the variables yourself:

```css
html.dark .pollar-modal-card,
html.dark .pollar-wallet-wrapper {
  --pollar-bg: #0b0b0f;
  --pollar-text: #f4f4f5;
  --pollar-border: #27272a;
  --pollar-muted: #a1a1aa;
  --pollar-input-bg: #18181b;
}

[data-theme='dark'] .pollar-modal-card {
  --pollar-bg: #0b0b0f;
  --pollar-text: #f4f4f5;
}
```

---

## Variable reference

| Variable | Branding setting | Default (light / dark) | What it styles |
|---|---|---|---|
| `--pollar-accent` | Accent | `#005db4` | Primary button fill, focus rings, spinners, active tabs, switches |
| `--pollar-btn-primary-fg` | follows Accent | `#ffffff` or `#111827` | Primary button label. The SDK picks the one readable on the accent, so **set it whenever you override `--pollar-accent`**. |
| `--pollar-btn-secondary-bg` | Buttons | not set | Secondary buttons: wallet, social and provider entries, back/cancel buttons, inline actions. Not set: the filled ones use `--pollar-input-bg` and the outlined ones stay transparent. |
| `--pollar-btn-secondary-fg` | follows Buttons | not set | Secondary button label. Set it together with `--pollar-btn-secondary-bg`. |
| `--pollar-bg` | Background | `#ffffff` / `#1a1a1a` | Modal card and dropdown background |
| `--pollar-text` | Text | `#111827` / `#ffffff` | Body text |
| `--pollar-border` | blended from Background + Text | `#e5e7eb` / `#374151` | Card, input and divider borders |
| `--pollar-muted` | blended from Background + Text | `#6b7280` / `#9ca3af` | Secondary text, hints, captions |
| `--pollar-input-bg` | blended from Background + Text | `#f9fafb` / `#374151` | Inputs and filled secondary buttons |
| `--pollar-error-bg` | theme only | `#fef2f2` / `#2a1515` | Error banners |
| `--pollar-error-border` | theme only | `#fecaca` / `#7f1d1d` | Error banner border |
| `--pollar-error-text` | theme only | `#dc2626` / `#f87171` | Error text and destructive actions |
| `--pollar-success-text` | theme only | `#16a34a` / `#4ade80` | Success states |
| `--pollar-modal-border-radius` | Corners -> Modal | `16px` | Modal card corners |
| `--pollar-buttons-border-radius` | Corners -> Buttons | `6px` | Button corners, including `<WalletButton>` |
| `--pollar-overlay-z-index` | Stacking order | `50` | Stacking order of the modal overlay. Set it on `.pollar-overlay`. |
| `--pollar-overlay-bg` | none | `rgba(0, 0, 0, 0.5)` | Backdrop behind a modal. Set it on `.pollar-overlay`. |
| `--pollar-buttons-height` | none | `44px` | Height of the full-width buttons |
| `--pollar-input-height` | none | `44px` | Height of text inputs |
| `--pollar-input-border-radius` | Corners > Buttons | `var(--pollar-buttons-border-radius)` | Input corners. Inputs sit in the same column as the buttons, so they follow the button radius unless you set this |
| `--pollar-card-border-radius` | none | `10px` | Inner cards and list items |
| `--pollar-modal-padding` | none | `1.75rem`; `2rem` on the login modal and the ramp widget | Padding of the modal card |
| `--pollar-modal-heading-size` | none | `1.375rem` | Login modal heading |
| `--pollar-modal-subtitle-size` | none | `0.9rem` | Subtitles of the login, KYC, ramp and requirement form modals |
| `--pollar-font-family` | none | not set: your page's font | Every text, button and input in the modals and `<WalletButton>` |
| `--pollar-font-family-mono` | none | `ui-monospace, SFMono-Regular, Menlo, monospace` | Addresses, hashes, codes and XDR |

"Blended" means that when Branding sets a Background or Text color, the SDK mixes the border, secondary text and input fill from those two colors, so they match the custom pair. With neither set, they come from the theme.

### Not affected by the variables

- The **Google** and **GitHub** sign-in buttons keep their providers' brand styling (their corners still follow `--pollar-buttons-border-radius`).
- The **QR code** in Receive and the **KYC provider frame** stay on white, so they remain readable.
- The **card artwork** in the Card modal.

---

## Custom templates

If you render the `*Template` components yourself, pass `theme`, `accentColor` and `styleOverrides` the way the live components do. `modalChrome(usePollar().styles)` returns all three. To theme your own markup the same way, put one of the root classes above on it and spread `buildModalCssVars(theme, accentColor, styleOverrides)` into its `style`.

`buildModalCssVars` writes the Branding values under private `--pollar-brand-*` names. Don't set or read those in your CSS: they are the input to the public variables above, and they may change between versions.
