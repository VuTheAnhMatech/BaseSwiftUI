---
name: baseswiftui-api-maintenance
description: Verify BaseSwiftUI API guidance against the installed SDK and Apple documentation. Use after Xcode/iOS updates or for deprecation-baseline refreshes. Use swiftui-review for ordinary source review.
---

# BaseSwiftUI API Maintenance

Maintain guidance for the actual baseline: iOS 17 and Swift 5. Newer APIs are
optional evidence, not project defaults.

## Required context

1. Read `references/api-baseline.md`.
2. Read `references/scan-manifest.md` when refreshing a topic or SDK version.
3. Confirm deployment target and Swift version from
   `BaseSwiftUI.xcodeproj/project.pbxproj`.

## Workflow

1. Run the local usage scan:

   ```sh
   python3 .codex/skills/baseswiftui-api-maintenance/scripts/scan_swiftui_api_usage.py
   ```

2. Use compiler diagnostics from a workspace Debug build as primary local
   evidence. Verify changes against official Apple documentation and the
   installed SDK interface before updating the baseline.
3. Record API availability, deprecation version, direct replacement, behavior
   differences, and required fallback. If no direct replacement exists, say so.
4. Keep iOS 18+ and iOS 26+ APIs behind availability checks and do not make
   them mandatory for an iOS 17 path.
5. Update only the affected baseline/reference. Code changes require an
   explicit implementation request and GitNexus impact analysis.

## Safety rules

- Preserve current MVI, ObservableObject, Combine, Factory, and router flows.
- Treat stylistic modernization as optional unless the SDK marks an API
  deprecated or a concrete defect is proven.
- Never replace an API by name alone; compare semantics and state ownership.
- Report scan candidates separately from compiler-confirmed deprecations.
