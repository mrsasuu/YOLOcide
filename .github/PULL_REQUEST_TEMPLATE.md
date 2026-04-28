## Related issue
<!-- Link the issue this PR closes, if any. -->
Closes #

## Type of change
<!-- Check all that apply. -->
- [ ] Bug fix
- [ ] New feature
- [ ] UI / visual polish
- [ ] Refactor (no behavior change)
- [ ] Tests
- [ ] Documentation / design system

## What this PR does
<!-- One or two sentences on the change and why it's needed. -->

## Changes
<!-- Bullet list of what changed and why. -->
-

## Visual evidence
<!-- Required for any UI change. Delete this section only if the PR has zero visual impact. -->

### Before / After

| Before | After |
|--------|-------|
| <!-- drag screenshot here --> | <!-- drag screenshot here --> |

<!-- For animations or transitions, attach a screen recording or GIF instead. -->

## How to test
<!-- Steps a reviewer should follow to verify the change works correctly. -->
1.
2.
3.

**Edge cases to verify:**
-

## Design checklist
<!-- For UI changes — uncheck any that don't apply and explain why. -->
- [ ] Uses `Color.ycPurple` for the accent — no new accent colors introduced
- [ ] Adaptive surfaces use `Color.ycBg` / `Color.ycSurface` (not hardcoded hex values)
- [ ] All tappable elements use `ScaleButtonStyle` or `PrimaryButton`
- [ ] New UI strings added to both `en` and `es` dictionaries in `SettingsStore.swift`
- [ ] Haptics gated behind `settings.hapticsEnabled`
- [ ] Tested in light mode and dark mode
- [ ] Tested on a small screen (iPhone SE) and a large screen (iPhone Pro Max)
- [ ] Spring animations used for state transitions — no flat fades

## General checklist
- [ ] Self-reviewed the diff before requesting review
- [ ] No debug code, `print()` statements, or TODO comments left in
- [ ] No new third-party dependencies added
- [ ] Tests added or updated if behavior changed
- [ ] `WheelOption` / `SessionOption` split preserved (`Color` is not `Codable`)

## Notes for reviewer
<!-- Non-obvious decisions, trade-offs, areas that need extra scrutiny, or anything the reviewer should know before diving in. -->
