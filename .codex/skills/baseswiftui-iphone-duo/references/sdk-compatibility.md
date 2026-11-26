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

| API family | iOS introduction, Apple docs checked 2026-11-26 | Use |
| --- | --- | --- |
| ArrangementView, ReservedRegion, GeometryProxy.reservedRegions | 27.1 | Two-pane layout or custom fold/camera avoidance |
| onHingeChange(isEnabled:_:), toolbarVerticalBehavior, toolbarVerticalEdge | 27.1 | Optional hinge input; vertical bar policy/preferred edge |
| ToolbarContent.axisBehavior, ToolbarVerticalCompressionBehavior, ContentMarginGuide.container | 27.1 | Bar participation/compression and container margins |
| ToolbarContent.visibilityPriority, ToolbarOverflowMenu, presentationPlacement | 27.0 | Overflow and sheet placement; not all Duo-related APIs start at 27.1 |
| onInteractiveResizeChange | 26.0 | Begin/end of interactive window resizing, not hinge geometry |
| AnyLayout, ViewThatFits, NavigationSplitView | 16.0 | Usable within the iOS 17 baseline where ownership fits |
| inspector | 17.0 | Supporting panel with compact sheet behavior |

These are iOS versions, not availability guarantees for every platform.
Exact modifier overloads and other-platform availability still need checking.
Camera capture/accessory APIs remain outside this UI skill.

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
coordinate policy consistent. Apple's current type and query references agree
that default queries return only active, overlapping regions. `.includeInactive` adds inactive regions;
use `isActive` when a mixed result must be narrowed to current obstructions.
An inactive region can still have a frame; do not assume zero size. See
`layout-patterns.md` for clipping and placement contracts.

Do not infer physical pose, hardware identity or layout breakpoints from hinge
angles. No need to adopt hinge input just to support resizing or two panes.
When an explicitly requested interaction uses `onHingeChange(isEnabled:_:)`,
handle an absent hinge and reset transient effects when the relevant status
ends. Disabling updates can deliver a final no-hinge context. The system
controls callback cadence; do not assume a fixed angle range or precision.
Respect Reduce Motion and provide an accessible alternative to hinge input.

Official entry points:

- https://developer.apple.com/documentation/swiftui/arrangementview
- https://developer.apple.com/documentation/swiftui/reservedregion
- https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle/axes(_:)
- https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo
