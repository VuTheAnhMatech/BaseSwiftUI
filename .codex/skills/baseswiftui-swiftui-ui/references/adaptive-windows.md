# Adaptive windows: iPhone, iPad and iPhone Duo

Use for new screens and changes to responsive layout, window resizing or
keyboard fit. A label/icon-only change does not require this reference or an
app-wide audit. The current UI/Figma/IAP/Duo owner remains primary.

## Template contract

- The app target and the repository's project generator use device family `1,2`
  (native iPhone and iPad), iOS 17 minimum and Swift 5 language mode.
- Preserve SwiftUI App/WindowGroup, MVI, ObservableObject/Combine, Factory,
  CocoaPods and BaseDataSource. Resizing does not require Observation migration.
- Keep the existing iPhone orientation policy and iPad orientation declarations
  unless the product task changes them. Do not use orientation as a device or
  window-size classifier. Keep the launch screen and avoid UIRequiresFullScreen
  as a way to escape adaptive layout.
- Resizable windows do not require enabling multiple windows per app. A
  multi-scene feature has separate navigation, DI and restoration decisions;
  do not enable it or make Containers global as part of a layout task.
- A universal target permits native iPad execution; it does not prove every
  screen works at every size or that Duo-specific SDK behavior is available.

## Choose layout from content and current space

Start with the closest feature and one usable compact presentation. At wider
sizes, expose supporting information only when it helps the task. Do not
stretch phone cards/buttons to fill a tablet or require two panes everywhere.

| Situation | Preferred direction |
| --- | --- |
| Form, settings, article | Readable content width, flexible margins, vertical access when content needs it |
| Items and selected detail | Existing compact route; split presentation only with a clear navigation owner |
| Content and optional tools | Inspector, stable axis layout or a supporting pane; keep tools reachable when collapsed |
| Feed/grid | Existing Base renderer and data source; derive columns from usable width and item needs |
| Media/canvas | Preserve content aspect/interaction, reposition controls; do not recreate the media owner |

Use proposed container size and size classes together. Two windows with the
same size class may have different usable widths/heights. Measure only where
layout needs it, in the View that owns that layout; do not cache bounds at launch
or use UIScreen.main/device model/idiom to choose a phone/tablet layout.

Prefer flexible frames, Layout/AnyLayout and stateless ViewThatFits alternatives
before custom measurement. GeometryReader consumes proposed space: avoid
placing an unconstrained reader in scrolling content merely to obtain width.
Breakpoints come from content requirements, not a global 800/844/1024pt rule.
Height, keyboard and accessibility text can invalidate a width-only decision.

## Figma and scrolling

A Figma frame is the reference composition at its supplied size. Preserve
explicit assets, typography, control dimensions and visual tokens; allow
layout, flexible space, columns and presentation to adapt to the window.
Do not scale the whole screen or silently shrink text/touch targets to fit.
When only a phone frame exists, reuse its visual language and explain the
adaptive arrangement; do not invent a second product flow or new artwork.

**Canvas height is not a scroll switch.** The previous 844pt rule must not
decide whether content remains reachable. Use actual available space, intrinsic
content, keyboard and Dynamic Type. A nominally short design may need scrolling
in a short iPad window; a taller design may fit in a larger usable area.

Give each content region a deliberate scroll owner. Preserve the Base renderer's
isScrollEnabled/contentInsets/scrollPosition contracts; do not wrap an already
scrolling collection in another vertical ScrollView. Keep a stable scrollable
hierarchy where practical rather than switching the entire screen between
ScrollView and non-scroll branches whenever height crosses a threshold.

For a fit-first screen, disable scrolling when the intrinsic content plus
required control spacing fits the usable viewport. Measure at the actual
constrained width, before viewport-filling frames or flexible spacers; measuring
a `minHeight`-expanded container can hide overflow or create a feedback loop.
Update the decision on window/text-size changes and keep buttons interactive
(`scrollDisabled`, not `disabled`). `scrollBounceBehavior(.basedOnSize)` removes
unnecessary bounce but is not an explicit scroll-enable decision. Let decorative
spacers collapse before forcing scrolling. When content overflows, retain access
to the last action; when it fits again, verify no stale scroll offset remains.

Keep full-screen decorative backgrounds outside the scrolling content when they
should remain fixed. Readable-width controls must not inadvertently constrain the
background to a narrow moving rectangle. Verify both a fitting and overflowing
case; a static screenshot alone cannot prove scrolling is disabled.

Keep controls within dynamic safe areas, including window controls and keyboard.
Decorative backgrounds may extend beyond them. Insets belong to the relevant
View/scene and are applied once per edge; avoid UIApplication.connectedScenes
first-window helpers for scene-specific layout. A content-size preference is
not a guarantee that a rotated window can never become smaller.

## State and performance while dragging

Keep the existing Container, BaseDataSource, router path, selected ID, draft,
focus and scroll anchor at stable owners. Pass existing instances to panes;
do not call Factory again in each size branch. Preserve child order/identity
where possible, and inspect lifecycle callbacks when moving View boundaries.

Resizing updates presentation, not load/save/purchase intents. Do not key `.task`
or `.id` by dimensions, dismiss/re-present sheets on each resize, or restart
networking/playback. Coalesce expensive image/render-resource work only when
necessary; normal layout must continue following the drag.

Optional `onInteractiveResizeChange` (iOS 26+) reports whether the window is
being interactively resized. It is not a size callback. Keep an iOS 17 path
and use it only when expensive work actually benefits from deferral.
`windowResizability`/`defaultSize` have iOS 17 availability in the checked SDK;
they express sizing behavior/defaults, not a replacement for adaptive content.
Check platform behavior before adding window preferences; do not impose an
arbitrary global minimum that hides layout defects.

## Duo adds a separate geometry concern

Window resizing uses the same stable layout/state rules. Hinge and camera
reserved regions need additional handling only for content affected by them.
For explicit Duo work, read the relevant section of
`.codex/skills/baseswiftui-iphone-duo/references/layout-patterns.md` without
loading another skill. Follow its SDK checks before adding 27.1 symbols.
No hard-coded fold midpoint or angle threshold; secondary actions stay
reachable on the outer display and in a narrow window.

## Verification proportional to the change

After implementation, inspect compact/short and wide layouts, overflowing text,
keyboard access, safe areas, state ownership and unchanged route semantics.
Build the workspace for `generic/platform=iOS` using the supported installed
toolchain; do not install runtimes or change CI for a UI task.

When runtime validation is explicitly authorized, exercise the affected flow:

- iPhone compact and large text, respecting its supported orientations;
- iPad wide, narrow and short windows, dragging mid-edit/selection/playback;
- keyboard and relevant rotation/RTL/accessibility cases;
- Duo outer/inner and partial-fold cases when supported, plus older-OS fallback.

Record SDK/runtime/device and actual evidence. Source inspection and generic
build success do not prove drag smoothness, state continuity or Duo geometry.
No automatic Simulator, screenshots or whole-app sweep. On unavailable SDKs,
complete baseline layout work and identify deferred API/runtime checks.

## Official evidence checked 2026-10-30

- [Multitasking](https://developer.apple.com/documentation/uikit/multitasking-on-ipad-mac-and-apple-vision-pro): adapt to window size and observe geometry where needed.
- [TN3192](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key): SDK 27 changes UIRequiresFullScreen to discrete scene resizing when that key applies; it is not an opt-out. Older compatibility scaling is not continuous relayout.
- [Interactive resize](https://developer.apple.com/documentation/swiftui/view/oninteractiveresizechange(_:)): iOS 26+; declaration checked in installed SDK 27.0.
- [Window sizing](https://developer.apple.com/documentation/swiftui/scene/windowresizability(_:)): sizing strategy, checked iOS 17 availability.

Windowed Apps arrived in iPadOS 26; Stage Manager supported resizing earlier.
Do not describe all window resizing as a new iPadOS 27 or Duo-only feature.
