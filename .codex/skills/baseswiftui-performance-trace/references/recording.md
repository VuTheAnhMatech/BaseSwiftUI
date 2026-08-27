# Instruments recording

## Template choice

- Physical iOS device: prefer SwiftUI; use Time Profiler or Animation Hitches
  for a narrower question.
- iOS Simulator: prefer Time Profiler/Animation Hitches because the SwiftUI
  instrument lane may be unavailable or incomplete.
- Slow launch: launch the built app under the selected template.
- Runtime regression: attach to the running app and reproduce one focused flow.

## Capture contract

Record Xcode version, device/OS, app build/configuration, template, start/end
action, duration, and whether the run was warm or cold. Keep the interaction
short and reproducible. Add `os_signpost` only when existing trace evidence
cannot isolate the phase; do not instrument broadly by default.

Use `xcrun xctrace record --help` for the installed Xcode syntax rather than
assuming an upstream wrapper matches the local tool version.
