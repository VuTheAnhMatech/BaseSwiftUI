# SDK capability and iOS 17 fallback

Read before introducing or changing a Duo-only API, or when investigating a
missing symbol. Ordinary resizing using existing APIs can proceed without it.

## Establish capability once per unchanged environment

Inspect the selected developer directory and installed SDK using read-only
commands such as `xcode-select -p`, `xcodebuild -version`, and
`xcrun --sdk iphoneos --show-sdk-version`. If the selected SDK lacks a symbol,
check known Xcode installations under `/Applications` before concluding none
is available. Do not scan unrelated directories or download toolchains.

When an installed capable Xcode is appropriate for the requested task, use
command-local `DEVELOPER_DIR` and report it; do not change global selection or
project settings. Distinguish compiler version, Swift language mode, build SDK,
deployment target and Simulator runtime. Swift 5 language mode stays intact.

| API family | Apple availability checked 2026-10-30 | Action |
| --- | --- | --- |
| ArrangementView, ReservedRegion | iOS 27.1 | Verify exact symbol in the SDK and provide older-runtime behavior |
| onHingeChange, toolbarVerticalBehavior, CameraCaptureAccessory | iOS 27.1 in the earlier source review | Recheck the specific declaration before use; camera pipeline is outside this UI skill |
| AnyLayout, ViewThatFits, NavigationSplitView | iOS 16 | Usable within the iOS 17 baseline where ownership fits |
| inspector | iOS 17 | Consider for supporting content; verify desired compact behavior |

Check SwiftUI **and SwiftUICore** interfaces when looking for SwiftUI symbols;
a search of SwiftUI alone can miss them. Read the matching UIKit header only
when implementing UIKit integration. Current public declarations and Apple
docs outrank community snapshots; runtime behavior needs its own evidence.

## Two different compatibility gates

`if #available(iOS 27.1, *)` handles older OS versions only after the compiler
has declarations for those symbols. It does not make SDK 27.0 recognize them.
`#if compiler(>=6.4)` is also insufficient: compiler versions do not uniquely
identify a Duo-capable SDK. `canImport(SwiftUI)` cannot test individual symbols.

With a capable SDK, isolate Duo API code behind accurate availability and
preserve the iOS 17 layout. Verify both branches' navigation and actions.
If older SDK builds must also remain supported, use a deliberately configured
compilation boundary only when that toolchain integration is in scope; do not
invent flags, change CI or update project build settings for a UI task.

Without a capable SDK, make useful changes using baseline APIs, report that
Duo-only code is deferred, and do not add uncompilable symbols to app targets.
Do not claim a generic iOS build validates Duo pose behavior. A Simulator runtime
installed separately is not evidence that the selected build SDK has the APIs.

## Geometry contracts to verify

Reserved regions are local to the querying View, may partially overlap it,
and have frames including clearance margins. Use active regions for current
avoidance; request inactive regions explicitly only for planning. Keep RTL
coordinate policy consistent. Avoid assuming default filtering semantics
where historical docs conflict; make the intended filter explicit.

Do not infer physical pose, hardware identity or layout breakpoints from hinge
angles. No need to adopt hinge input just to support resizing or two panes.

Official entry points:

- https://developer.apple.com/documentation/swiftui/arrangementview
- https://developer.apple.com/documentation/swiftui/reservedregion
- https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle/axes(_:)
- https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo
