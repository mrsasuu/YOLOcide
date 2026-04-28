# YOLOcide — Claude Code Guide

## What this project is

YOLOcide is a native iOS SwiftUI app — a decision-making roulette wheel. Users add options, spin the wheel, and let randomness decide. It supports a "rank mode" that eliminates winners one by one until all options are ranked.

The repo has two top-level directories:
- `app/` — the iOS SwiftUI app
- `BE/` — Go backend (auth + Postgres). See [BE/README.md](BE/README.md) and [BE/ROADMAP.md](BE/ROADMAP.md).

---

## Repository layout

```
app/
  YOLOcide/                  ← Swift source files
  YOLOcide.xcodeproj/        ← Xcode project (do not edit manually)
  YOLOcideTests/             ← Unit tests
  YOLOcideUITests/           ← UI tests
  YOLOcide Design System/    ← Design docs, tokens, interactive previews
BE/                          ← Go backend
  cmd/api/                   ← entry point (main.go)
  internal/auth/             ← Apple + Google verification, session JWT, middleware
  internal/config/           ← env loading
  internal/db/               ← pgxpool + embedded migration runner
  internal/db/migrations/    ← *.up.sql files (embedded into the binary)
  internal/server/           ← chi router + route wiring
  internal/user/             ← user model + Postgres repository
  docker-compose.yml         ← local Postgres
  Makefile                   ← run / build / test / db helpers
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

## Backend

The backend in `BE/` is a Go HTTP API whose only current job is authentication. See [BE/README.md](BE/README.md) for the full setup and endpoint reference, and [BE/ROADMAP.md](BE/ROADMAP.md) for the milestone plan toward wheel + spin-history sync.

### Stack at a glance

| Layer | Choice |
|-------|--------|
| Language | Go 1.23+ |
| Router | `github.com/go-chi/chi/v5` |
| DB | Postgres 16 via `github.com/jackc/pgx/v5` + `pgxpool` |
| Migrations | [goose](https://github.com/pressly/goose) v3 — plain SQL in `internal/db/migrations/`, embedded with `//go:embed`, applied at startup |
| Apple sign-in | `github.com/golang-jwt/jwt/v5` + a small JWKS cache fetching `https://appleid.apple.com/auth/keys` |
| Google sign-in | `google.golang.org/api/idtoken.Validate` |
| Session JWTs | HS256 via `golang-jwt/jwt/v5`, secret from `SESSION_JWT_SECRET` |
| Logging | `log/slog` (stdlib) |

### Endpoints (current)

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| GET | `/healthz` | — | Liveness. |
| POST | `/auth/apple` | — | Verify Apple `identityToken`, upsert user, return session JWT. |
| POST | `/auth/google` | — | Verify Google `idToken`, upsert user, return session JWT. |
| GET | `/me` | Bearer | Return the authenticated user. |

### Running locally

```bash
cd BE
go mod tidy           # first time only
cp .env.example .env  # fill in APPLE_CLIENT_ID, GOOGLE_CLIENT_IDS, SESSION_JWT_SECRET
make db-up            # local Postgres via docker-compose
make run              # migrations apply on startup
```

### Schema

One `users` table with nullable `apple_user_id` / `google_user_id` (each unique), nullable `email` (CITEXT) and `name`, plus `created_at` / `updated_at` / `last_login_at`. A check constraint enforces at least one provider ID. Account linking (one user with both Apple and Google IDs) is a roadmap item.

### Backend conventions

- **No ORM.** SQL is hand-written and lives next to the repo type that uses it (`internal/user/repo.go`).
- **No third-party logger.** Use `log/slog`.
- **No business logic in HTTP handlers.** Handlers parse → call repo/verifier → write JSON.
- **Errors propagate with `%w`.** The handler decides the status code.
- **Time is `time.Time`, IDs are `uuid.UUID`.** No string-typed IDs in domain types.
- **Migrations use goose.** Create with `make goose-create name=<thing>`. Each file has `-- +goose Up` and `-- +goose Down` sections. Inspect with `make goose-status`; roll back with `make goose-down`. Goose tracks state in `goose_db_version`.
- **Trust only verified claims.** Fields like `email` come from the verified provider token first; client-supplied values are a fallback (Apple omits email after the first sign-in).
