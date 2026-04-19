# YOLOcide — Design System

A fun, iOS-native decision-making roulette app. When you can't decide, spin the wheel and let fate handle it.

The visual language is **Liquid Glass × Radix** — soft pastel slices separated by thin white dividers, frosted translucent surfaces, a single vibrant purple CTA, and spring-driven transitions. iOS-first.

## Sources

No codebase, Figma file, or slide deck was provided. Everything in this system is derived from the **written product brief** supplied with the project kickoff ("YOLOcide uses a clean, minimal iOS-native aesthetic inspired by Liquid Glass and Radix UI…"). Any future codebase or Figma should be layered in and this system reconciled.

Font substitution: the brief calls for **SF Pro Display**, which is an Apple system font and cannot be redistributed. On Apple devices the `--font-display` stack resolves to the real SF. Elsewhere we use **Inter** (Google Fonts) as the closest visual match. ⚠️ **Please confirm whether you'd like us to swap in a different web-safe typeface or provide licensed font files.**

---

## Index

| File | What |
|---|---|
| `README.md` | This document — brand, content, visual, iconography guidance |
| `SKILL.md` | Claude Code skill wrapper — use this to invoke the system |
| `colors_and_type.css` | All design tokens (colors, type, spacing, radii, motion) |
| `preview/` | Small HTML cards powering the Design System tab |
| `assets/` | Logos, icons (Lucide SVGs — see iconography section) |
| `fonts/` | Empty — see font substitution note above |
| `ui_kits/ios_app/` | Pixel-ish recreation of the YOLOcide iOS app with interactive click-through |

---

## Content fundamentals

YOLOcide's voice is **playful, fatalistic, a little dramatic**. The name is a pun on "YOLO" + "-cide" (as in decide) — the whole brand leans into the joke that making choices is exhausting and letting a wheel decide is liberating. Copy should feel like a friend egging you on, not an app giving instructions.

- **Person:** Second person, imperative. "Spin my fate," "Show options," "Add option."
  (It's fine to occasionally use first-person from the *user's* POV — the primary CTA literally says **"Spin my fate"**, not "Spin the wheel.")
- **Casing:** Sentence case everywhere. No ALL CAPS except inside the logo wordmark. No Title Case in body UI.
- **Length:** Short. A button is 2–3 words. A title is ≤ 5 words. Lists of options tend to be 1–4 words per option ("Tacos", "Sushi", "Call it off").
- **Punctuation:** No trailing periods on buttons or labels. Exclamation marks are allowed but rationed — they live on *moments* ("Spin!", "Fate has spoken."), not on everyday affordances.
- **Emoji:** ❌ Not a brand element. The color dots do the emotional work instead. A lone emoji may appear as a user-entered option label, but never in product chrome.
- **Humor/tone examples:**
  - Primary CTA: **"Spin my fate"** (not "Spin" or "Go")
  - Empty state: **"Nothing to decide yet. Add an option."**
  - After result: **"Fate has spoken."** + the result
  - Confirm delete: **"Delete this option? Fate will forget it."**
- **What to avoid:** Corporate-neutral phrasing ("Submit", "Confirm selection"), productivity-app gravitas, or anything that implies the decision is *serious*. The joke is that the decision isn't.

---

## Visual foundations

### Color
Six core **pastels** sit on the wheel — lavender, sky, mint, peach, rose, violet — with butter and aqua as quiet extension colors for >6 options. Pastels are **solid & opaque in light mode**, **~70% alpha in dark mode** so the `#3a3d4a` canvas bleeds through. Segments are always separated by **pure-white 1.5–2px hairlines** (or `rgba(255,255,255,0.55)` in dark) — that separator is the single most identifiable visual motif in the whole brand.

The accent is **one purple**, `#6c5ce7`, used exclusively for the primary CTA and the occasional selected-state ring. **Never** gradients on buttons. **Never** a second accent color.

### Type
iOS-native. SF Pro Display (bold/extrabold) for display + titles; SF Pro Text for body. Weight 700 for the app title and wheel labels; 600 for headlines + buttons; 500 for body + UI. Tight tracking (`-0.02em`) on display sizes, default elsewhere. Line-heights follow the iOS HIG (title1 = 28/34, body = 17/22).

### Surfaces & blur
Liquid glass is a first-class material:
- **Wheel center cap** — frosted white disc (`rgba(255,255,255,0.72)` + `backdrop-filter: blur(20px) saturate(1.4)`) with "Spin!" in purple.
- **Option pills** — the same frosted white in light mode, `rgba(255,255,255,0.18)` in dark mode, always with a 1px inner hairline (`rgba(0,0,0,0.08)` / `rgba(255,255,255,0.10)`).
- Blur levels: `--blur-sm 12px` (hairlines/tooltips), `--blur-md 20px` (pills/cap), `--blur-lg 30px` (modals).

### Backgrounds
**No imagery, no gradients, no textures.** The canvas is a flat neutral (`#f4f4f7` / `#3a3d4a`). The color is all on the wheel. Full-bleed photography would break the brand.

### Corner radii
Tight, consistent iOS scale: `6 / 10 / 14 / 20 / 28 / 999`. **Option rows use exactly `14px`** (spec-locked). Primary buttons are full pills (`999`). Cards are `20`.

### Shadows
Soft and purple-tinted rather than neutral-black. The wheel sits on a bespoke shadow (`0 24px 60px rgba(60,40,140,0.18)`) that gives a faint violet bloom. The center cap uses an inset highlight. No hard drop shadows, no stark black.

### Motion
**Springs everywhere.** State transitions (default ↔ list, row add/remove, cap press) use `cubic-bezier(0.34, 1.56, 0.64, 1)` at 260–420ms. The wheel spin itself eases out over ~3.6s with `cubic-bezier(0.16, 1, 0.3, 1)`. Fades alone feel flat in this system and should be avoided except for modal backdrops.

### Interaction states
- **Hover (desktop/preview):** raise `box-shadow` by one step, no color change.
- **Press:** shrink to `scale(0.97)`, hold for the duration of the press; release with spring. Color stays identical.
- **Focus:** 2px outer ring in `--purple-500` at 40% alpha, offset 2px. No focus ring on touch.
- **Disabled:** 40% opacity, no pointer events, no shape change.

### Borders & hairlines
Thin is the rule. Inner hairlines `rgba(0,0,0,0.08)` light / `rgba(255,255,255,0.10)` dark. Wheel dividers are the one exception — pure white, full opacity, 1.5–2px.

### Transparency & blur — *when*
Every surface that **sits over color** (option pills over a list, cap over slices) is translucent + blurred. Surfaces that **sit over neutral bg** (the app itself) are opaque. This keeps the glass effect feeling earned.

### Imagery
None. This is a brand without photography. If marketing material ever needs a hero, the wheel *is* the hero — render it life-sized on the neutral canvas.

### Layout
- Safe-area-aware iOS layouts (respect `env(safe-area-inset-*)`).
- Fixed header: app title left, "+" icon right (44×44 hit target).
- Wheel is always centered horizontally; vertically positioned at ~38% of screen in default state, ~22% in list state (spring between).
- Primary button floats `max(24px, env(safe-area-inset-bottom))` from the bottom edge, full-width minus 20px gutters.
- Option list has 10px gutters between rows, 20px horizontal page padding.

---

## Iconography

YOLOcide ships with a **minimal icon vocabulary** — the product only needs a handful of glyphs (plus, close, trash, chevron, color-swatch-dot). No custom icon font exists. We use **Lucide** (`lucide.dev`, MIT-licensed) as the system-wide icon library — its thin, rounded-caps geometry matches the iOS/Radix aesthetic precisely.

- Weight: **1.75px stroke** (Lucide's default).
- Corners: **round** (`stroke-linecap: round`, `stroke-linejoin: round`).
- Size: **24×24** in chrome, **20×20** inline, **28×28** for the floating `+`.
- Color: always inherits `currentColor`. On the wheel chrome the `+` is `var(--fg1)`; inside option rows, chevrons are `var(--fg3)`.

We bundled the exact Lucide SVGs we reference into `assets/icons/` so the system works offline:

| File | Use |
|---|---|
| `plus.svg` | Top-right add-option control |
| `x.svg` | Dismiss / close |
| `trash-2.svg` | Delete an option |
| `chevron-right.svg` | Row disclosure |
| `chevron-down.svg` | Toggle "Show options" |
| `circle.svg` | Color dot (filled via `currentColor` in CSS) |
| `sparkles.svg` | "Fate has spoken" result decoration |

⚠️ **Substitution flag:** Lucide is a substitution for a bespoke icon set — we picked it because the brief didn't ship icons. If you have a preferred icon library (SF Symbols — Apple-licensed, can't be distributed; Phosphor; Heroicons), tell us and we'll re-thread.

**Emoji:** Not used in chrome. User-entered option labels may contain emoji freely.

**Unicode glyphs:** Not used as icons.

**Logos/brand imagery:** The YOLOcide wordmark + wheel-glyph is in `assets/logo/`. We generated an SVG wordmark from the name since no logo was provided. ⚠️ **Flag: please send the real logo when available.**

---

## How to use this system

If you're designing something for YOLOcide:

1. Load `colors_and_type.css` — it exposes every token you need.
2. Use the six pastels **only on wheel segments + color dots**. Everywhere else is neutral + the single purple.
3. Type: iOS HIG scale. No custom sizes.
4. Motion: springs, not cubic ease.
5. Copy: playful, fatalistic, second person, short.

Component-level references live in `ui_kits/ios_app/`.
