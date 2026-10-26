# BaseSwiftUI API Maintenance

Maintain guidance for the actual baseline: iOS 17 and Swift 5. Newer APIs are
optional evidence, not project defaults.

## Required context

1. Read `api-baseline.md`.
2. Read `scan-manifest.md` when refreshing a topic or SDK version.
3. Confirm deployment target and Swift version from
   `BaseSwiftUI.xcodeproj/project.pbxproj`.

## Workflow

1. Run the local usage scan:

   ```sh
   python3 .codex/skills/baseswiftui-swiftui-review/scripts/scan_swiftui_api_usage.py
   ```

2. Use existing compiler diagnostics as primary local evidence. For an explicit
   baseline refresh, run a generic iOS workspace Debug build if diagnostics
   are needed; a read-only question or no-build request does not authorize it.
   Verify against official Apple documentation and the installed SDK interface
   before updating the baseline. If evidence is unavailable, report the gap.
3. Record API availability, deprecation version, direct replacement, behavior
   differences, and required fallback. If no direct replacement exists, say so.
4. Keep iOS 18+ and iOS 26+ APIs behind availability checks and do not make
   them mandatory for an iOS 17 path.
5. Update only the affected baseline/reference. Code changes require an
   explicit implementation request and the root code-intelligence gate.

## Safety rules

- Preserve current MVI, ObservableObject, Combine, Factory, and router flows.
- Treat stylistic modernization as optional unless the SDK marks an API
  deprecated or a concrete defect is proven.
- Never replace an API by name alone; compare semantics and state ownership.
- Report scan candidates separately from compiler-confirmed deprecations.
