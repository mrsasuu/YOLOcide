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
BE/                           Go backend (planned, currently empty)
```

## Getting started

1. Open `app/YOLOcide.xcodeproj` in Xcode (16+)
2. Select an iPhone simulator or device
3. Press `⌘R` to build and run

No dependencies to install — the project uses only Swift standard libraries and SwiftUI.

## Development

See [CLAUDE.md](CLAUDE.md) for architecture notes, coding conventions, and design system rules.

The design system documentation lives at `app/YOLOcide Design System/README.md`. For visual design work with an AI agent, invoke the `/yolocide-design` skill.

## Tech stack

| Layer | Technology |
|-------|-----------|
| Language | Swift |
| UI framework | SwiftUI |
| Persistence | UserDefaults |
| Architecture | MVVM-adjacent (`@StateObject` / `@EnvironmentObject`) |
| Tests | XCTest + XCUITest |
