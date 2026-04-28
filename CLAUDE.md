# YOLOcide — Claude Code Guide

## What this project is

YOLOcide is a native iOS SwiftUI app — a decision-making roulette wheel. Users add options, spin the wheel, and let randomness decide. It supports a "rank mode" that eliminates winners one by one until all options are ranked.

The repo has two top-level directories:
- `app/` — the iOS SwiftUI app (all active code)
- `BE/` — future Go backend (currently empty)

---

## Repository layout

```
app/
  YOLOcide/                  ← Swift source files
  YOLOcide.xcodeproj/        ← Xcode project (do not edit manually)
  YOLOcideTests/             ← Unit tests
  YOLOcideUITests/           ← UI tests
  YOLOcide Design System/    ← Design docs, tokens, interactive previews
BE/                          ← Go backend (empty, planned)
```

---

## Build & run

```bash
# Build for simulator
xcodebuild \
  -project app/YOLOcide.xcodeproj \
  -scheme YOLOcide \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Run tests
xcodebuild test \
  -project app/YOLOcide.xcodeproj \
  -scheme YOLOcide \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The normal workflow is to open `app/YOLOcide.xcodeproj` in Xcode and run from there.

---

## Architecture

The app is MVVM-adjacent using SwiftUI's native state tools. There is no third-party dependency — pure SwiftUI + Foundation.

### State ownership

```
YOLOcideApp (root)
 ├── @StateObject HistoryStore  → injected as @EnvironmentObject
 └── @StateObject SettingsStore → injected as @EnvironmentObject

ContentView (main screen)
 ├── @State options: [WheelOption]  ← the wheel's live option list
 ├── @State rankWinners: [WheelOption]
 ├── @State isSpinning, rotation, …
 └── reads HistoryStore + SettingsStore via @EnvironmentObject
```

Child views receive only what they need, either via `@EnvironmentObject` or direct bindings passed down.

### Data models (`Models.swift`)

| Type | Role |
|------|------|
| `WheelOption` | Live in-memory option with `id: UUID`, `name: String`, `color: Color` |
| `SessionOption` | Codable snapshot of an option (stores `colorHex: String` instead of `Color`) |
| `SpinSession` | One completed spin event — persisted to `HistoryStore` |

`WheelOption` is not `Codable` because `Color` isn't. The `.asSessionOption` extension converts it to a `SessionOption` for persistence.

### Persistence

All persistence uses `UserDefaults`. Keys are prefixed `yolocide_`:

| Key | What |
|-----|------|
| `yolocide_history_v1` | JSON-encoded `[SpinSession]` |
| `yolocide_language` | `"en"` or `"es"` |
| `yolocide_appearance` | `"system"`, `"light"`, or `"dark"` |
| `yolocide_haptics` | Bool |

There is no CoreData, SwiftData, or external database.

### Localization

Localization does **not** use `Localizable.strings` or `LocalizedStringKey`. All strings live in `SettingsStore` as two static dictionaries (`en`, `es`). Translate via `settings.t("key")` from any view that has `@EnvironmentObject var settings: SettingsStore`.

When adding a new string, add it to both dictionaries in `SettingsStore.swift`.

---

## Key source files

| File | Lines | Purpose |
|------|-------|---------|
| `YOLOcideApp.swift` | 16 | App entry point, root environment injection |
| `ContentView.swift` | ~694 | Main screen: all wheel state, spin logic, mode management |
| `Models.swift` | 46 | Data types (WheelOption, SessionOption, SpinSession) |
| `DesignSystem.swift` | 105 | Color tokens, `PrimaryButton`, `ScaleButtonStyle` |
| `SettingsStore.swift` | 171 | Settings persistence + inline localization |
| `HistoryStore.swift` | 36 | Session history: add/remove/clear + UserDefaults |
| `WheelView.swift` | 207 | Wheel rendering (Canvas), rotation animation |
| `OptionRowView.swift` | 207 | Option pill UI with inline color picker |
| `HistoryView.swift` | 331 | Past sessions list |
| `HelpView.swift` | 237 | Settings + help text |
| `AddOptionSheet.swift` | 65 | Modal for adding a new option |
| `WinnersSheet.swift` | 100 | Ranked results sheet |
| `ResultOverlay.swift` | 66 | Post-spin winner announcement |
| `ActionSheetContainer.swift` | 135 | Reusable bottom sheet chrome |
| `SignInView.swift` | 78 | Auth UI (stub, not wired) |

---

## Design system

The design system lives at `app/YOLOcide Design System/`. The key rules are:

- **Background**: `Color.ycBg` (adaptive: `#f4f4f7` light / `#3a3d4a` dark)
- **Surface**: `Color.ycSurface` (adaptive: white light / `#454856` dark)
- **Accent**: `Color.ycPurple` = `#6c5ce7` — primary CTA only, no gradients
- **Wheel pastels**: `Color.wheelPastels` — 20 pastel colors, 70% opacity in dark mode
- **Motion**: spring everywhere — `ScaleButtonStyle` scales to 0.97 on press
- **Typography**: SF Pro (system font), semibold for CTAs
- **Icons**: Lucide (round stroke, 1.75px weight)
- **Option pills**: frosted pill shape, 14px corner radius, color dot

For visual design work, invoke the `/yolocide-design` skill to load the full brand guide.

---

## Coding conventions

- **Swift style**: follow Swift API Design Guidelines. Use `camelCase` for variables/functions, `PascalCase` for types.
- **View decomposition**: extract sub-views when a view body grows long or a component is reused. Prefer small, focused views.
- **No comments for obvious code**: only comment non-obvious constraints or workarounds.
- **No third-party dependencies**: keep it dependency-free unless there is a strong reason.
- **Max wheel options**: 20. The pastel palette has exactly 20 colors — this is a hard constraint.
- **Color conversion**: use `Color(hex:)` / `.hexString` from `DesignSystem.swift` — do not add UIColor conversions elsewhere.
- **Button interactions**: always use `ScaleButtonStyle` or `PrimaryButton` for tappable elements — never flat `Button` without a style.
- **Haptics**: gate all haptic feedback behind `settings.hapticsEnabled`.

---

## Things to avoid

- Do not add `Localizable.strings` — localization is handled by `SettingsStore.t()`.
- Do not use `CoreData` or `SwiftData` — persistence is intentionally `UserDefaults`.
- Do not add new accent colors — `ycPurple` is the only accent.
- Do not break the `WheelOption` / `SessionOption` split — `Color` is not `Codable`.
- Do not edit `.xcodeproj` files by hand — use Xcode's project editor.

---

## Planned backend

`BE/` will hold a Go backend. The `.gitignore` already has Go patterns. When the backend is added, update this file with service layout, API contracts, and local development setup.
