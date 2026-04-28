# YOLOcide

A native iOS SwiftUI app for making decisions by spinning a wheel. Add your options, spin, and let fate decide.

## Features

- Spinning wheel with up to 20 pastel-colored segments
- Rank mode — spin repeatedly to rank all options by elimination
- Full spin history with session replay
- English / Spanish localization
- Light, dark, and system appearance modes
- Haptic feedback

## Repo structure

```
app/                          iOS SwiftUI application
  YOLOcide/                   Swift source files
  YOLOcide.xcodeproj/         Xcode project
  YOLOcideTests/              Unit tests
  YOLOcideUITests/            UI tests
  YOLOcide Design System/     Design tokens, brand guide, interactive previews
BE/                           Go backend (auth + Postgres; see BE/README.md)
  cmd/api/                    main entry point
  internal/                   auth, config, db, server, user packages
  internal/db/migrations/     embedded SQL migrations
  docker-compose.yml          local Postgres
```

## Getting started

1. Open `app/YOLOcide.xcodeproj` in Xcode (16+)
2. Select an iPhone simulator or device
3. Press `⌘R` to build and run

No dependencies to install — the project uses only Swift standard libraries and SwiftUI.

## Backend

The Go backend lives in [BE/](BE/). It currently handles Sign in with Apple / Google and issues session JWTs against a Postgres database. See [BE/README.md](BE/README.md) for setup and [BE/ROADMAP.md](BE/ROADMAP.md) for the planned wheel + spin-history sync work.

```bash
cd BE
cp .env.example .env   # fill in APPLE_CLIENT_ID, GOOGLE_CLIENT_IDS, SESSION_JWT_SECRET
make db-up             # local Postgres in Docker
make run               # applies migrations + starts API on :8080
```

## Development

See [CLAUDE.md](CLAUDE.md) for architecture notes, coding conventions, and design system rules.

The design system documentation lives at `app/YOLOcide Design System/README.md`. For visual design work with an AI agent, invoke the `/yolocide-design` skill.

## Tech stack

### iOS app

| Layer | Technology |
|-------|-----------|
| Language | Swift |
| UI framework | SwiftUI |
| Persistence | UserDefaults |
| Architecture | MVVM-adjacent (`@StateObject` / `@EnvironmentObject`) |
| Tests | XCTest + XCUITest |

### Backend

| Layer | Technology |
|-------|-----------|
| Language | Go 1.23+ |
| Router | chi v5 |
| DB | Postgres 16 via pgx v5 / pgxpool |
| Migrations | embedded SQL, applied at startup |
| Auth in | Apple / Google ID token verification |
| Auth out | HS256 session JWTs |
