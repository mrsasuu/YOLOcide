# YOLOcide — iOS UI Kit

A pixel-ish recreation of the YOLOcide iOS app, built as modular JSX components with Babel-in-browser. Everything renders inside the `IOSDevice` frame from the shared starter component.

## Files

| File | Role |
|---|---|
| `index.html` | Three side-by-side device frames: default / list-open / result |
| `ios-frame.jsx` | Device bezel, status bar, dynamic island (starter component) |
| `Wheel.jsx` | The roulette wheel — slices, dividers, cap, pointer, `spin()` |
| `OptionRow.jsx` | Frosted pill with color swatch + inline color picker |
| `Chrome.jsx` | `AppHeader`, `PrimaryButton`, `ToggleButton`, `ResultBanner`, `AddSheet` |
| `Screen.jsx` | Full `YolocideScreen` wiring everything together |

## Screens covered

1. **Default** — full-size wheel, "Show options" toggle, "Spin my fate" CTA
2. **List** — shrunken wheel, "Hide options" toggle, scrollable option rows (with per-row color picker), CTA hidden
3. **Result** — spring-animated result modal ("Fate has spoken")
4. **Add sheet** — bottom sheet for entering a new option (triggered by `+`)

## What's faked

- `spin()` picks a random winner after 3.6s but results aren't persisted
- Color picker doesn't allow custom hex — only the 6 brand pastels
- No haptics, no sound, no share-result action
- No onboarding screen, no settings, no history
