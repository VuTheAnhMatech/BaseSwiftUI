# Sources and adaptation decisions

Apple documentation reviewed 2026-11-26 using its documentation JSON, including
API declarations/availability and HIG. This is a task-scoped Duo/iPad adaptive UI reference,
not a claim to have reviewed Apple's entire documentation catalog. Prefer
current Apple contracts and the selected public SDK over community summaries.

## Official evidence by decision

| Decision | Apple reference |
| --- | --- |
| Display continuity, adaptive layout, vertical controls | [Preparing your app](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo), [HIG Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) |
| Split/overlay order and primary-only cases | [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview), [split axes](https://developer.apple.com/documentation/swiftui/splitarrangementviewstyle/axes(_:)) |
| Active filtering, overlapping local frames, margins and RTL | [ReservedRegion](https://developer.apple.com/documentation/swiftui/reservedregion), [GeometryProxy query](https://developer.apple.com/documentation/swiftui/geometryproxy/reservedregions(kind:options:layoutdirectionbehavior:)) |
| Asymmetric container spacing | [ContentMarginGuide.container](https://developer.apple.com/documentation/swiftui/contentmarginguide/container), [safeAreaInset](https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)-6gwby) |
| Stable state/identity when layout changes | [AnyLayout](https://developer.apple.com/documentation/swiftui/anylayout), [StateObject](https://developer.apple.com/documentation/swiftui/stateobject), [ViewThatFits](https://developer.apple.com/documentation/swiftui/viewthatfits) |
| Navigation and supporting panels | [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview), [inspector](https://developer.apple.com/documentation/swiftui/view/inspector(ispresented:content:)) |
| Preferred edge versus visibility | [toolbarVerticalEdge](https://developer.apple.com/documentation/swiftui/environmentvalues/toolbarverticaledge) |
| Vertical participation and compression | [toolbarVerticalBehavior](https://developer.apple.com/documentation/swiftui/view/toolbarverticalbehavior(_:)), [axisBehavior](https://developer.apple.com/documentation/swiftui/toolbarcontent/axisbehavior(_:)), [ToolbarVerticalCompressionBehavior](https://developer.apple.com/documentation/swiftui/toolbarverticalcompressionbehavior) |
| Overflow priority and sheet placement | [visibilityPriority](https://developer.apple.com/documentation/swiftui/toolbarcontent/visibilitypriority(_:)), [ToolbarOverflowMenu](https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu), [presentationPlacement](https://developer.apple.com/documentation/swiftui/view/presentationplacement(_:)) |
| Hinge input instead of layout | [onHingeChange(isEnabled:_:)](https://developer.apple.com/documentation/swiftui/view/onhingechange(isenabled:_:)) |
| Accessibility grouping, focus and order | [contain](https://developer.apple.com/documentation/swiftui/accessibilitychildbehavior/contain), [AccessibilityFocusState](https://developer.apple.com/documentation/swiftui/accessibilityfocusstate), [accessibilitySortPriority](https://developer.apple.com/documentation/swiftui/view/accessibilitysortpriority(_:)) |
| Text and motion adaptation | [DynamicTypeSize](https://developer.apple.com/documentation/swiftui/dynamictypesize), [accessibilityReduceMotion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion) |
| Window resizing rather than hinge callbacks | [onInteractiveResizeChange](https://developer.apple.com/documentation/swiftui/view/oninteractiveresizechange(_:)), [TN3192](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key) |

Camera direction and simultaneous capture-display content are separate work:
[choosing a camera](https://developer.apple.com/documentation/avkit/choosing-a-camera-by-the-direction-it-faces)
and [capture accessories](https://developer.apple.com/documentation/avfoundation/registering-a-camera-capture-accessory-on-iphone-duo).
They do not make the outer display a general-purpose second app window.

## Reconciled and unresolved claims

- **Resolved in current docs:** both ReservedRegion and GeometryProxy's query
  say active-only by default, with `.includeInactive` to include inactive regions.
  Old community reports of conflicting filtering text are historical. Inactive
  does not imply an empty frame; frame includes clearance margins.
- **Still conflicting:** HIG says navigation split/tab containers should wrap
  arrangements; ArrangementView's API reference warns against arrangements
  inside navigation split views and against navigation split/tab views inside
  arrangements. Keep the conservative nesting guidance in `layout-patterns.md`.
  A community example alone does not resolve this; document the exact hierarchy
  and obtain relevant runtime evidence before claiming an exception works.
- **Preferred edge is not visibility:** use the dedicated toolbarVerticalEdge
  reference for its precise contract; shorthand in overview text is insufficient.
- **Evidence levels:** an API declaration proves the symbol/version, not visual
  behavior, callback timing, focus restoration or state continuity in this app.

## SDK audit snapshot

On 2026-11-26, read-only inspection found Xcode 26.4 (17E192) with iOS SDK 26.4
and Xcode 27.1 (27A9275) with iOS SDK 27.1. Global selection pointed to Command
Line Tools; command-local DEVELOPER_DIR was used for inspection. SwiftUI and
SwiftUICore public interfaces in SDK 27.1 confirmed ArrangementView,
ReservedRegion/query, onHingeChange, toolbarVerticalBehavior,
onInteractiveResizeChange, visibilityPriority and presentationPlacement.
No app build or runtime test was performed for this documentation refresh.
This snapshot is provenance, not a hardcoded toolchain path or future capability
check; follow `sdk-compatibility.md` in the environment doing the implementation.

## Community synthesis, not imported workflow

The following exact revisions were read on 2026-11-26. GitHub stars are a dated
popularity signal, not proof of correctness or a ranking of Duo expertise.
Only concepts compatible with Apple evidence and BaseSwiftUI are retained;
upstream templates, scripts and skill chains are not installed.

| Source and pinned revision | Stars at review | Selected concepts | Not adopted |
| --- | ---: | --- | --- |
| [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill/tree/f2920b63995263f57b3e198674e89a602efba6d2) | 6,633 | Resizability reference: optional size classes, safe-area ownership, semantic bars and fallback | Swift 6.4 mandate, automatic whole-app checks, nesting/hinge claims without current evidence |
| [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill/tree/62bd760f005093d1e2e4de5db156e456a5f96400) | 3,943 | Duo reference: choose by content structure, narrow invalidation, continuous state | Observation migration, automatic NavigationSplitView conversion, blanket scroll exemption, tool installation |
| [mirzaaghazadeh/iphone-duo-skills](https://github.com/mirzaaghazadeh/iphone-duo-skills/tree/22ee51fdd78de72414b1a0d6d66414f4bc1373ff) | 340 | Adaptive-layout, vertical-bars and dual-pane skills: contextual displacement, action grouping, optional hinge input | Device-size tables as layout constants, hinge-driven business actions, unrelated paywall workflow |
| [Kimeur/duology](https://github.com/Kimeur/duology/tree/cffd95d90ac0c7a61578c9bfaada80f0b33e0190) | 46 | Layout/accessibility skills: pane grouping, focus fallback, transition scenarios | Fixed focus delays as guarantees, stale filtering claims, EvenSplit framework and companion-skill chain |
| [Bunn/iphone-duo-skill](https://github.com/Bunn/iphone-duo-skill/tree/bb581e08cae8d8a715b2d41eb966509a3e8e292e) | 19 | Exact SDK/declaration checks, separation of source/build/runtime evidence | Mandatory long guide, automatic companion loading and camera pipeline expansion |

Ten downloaded Markdown files from these five repositories were scanned with
baseswiftui-prompt-injection: no pattern findings. Content was also reviewed
for compatibility. A clean scan is not behavioral verification; no upstream
commands were executed and no external text gained authority over repo policy.

Earlier provenance retained: [hechen/iphone-duo-skills](https://github.com/hechen/iphone-duo-skills/tree/3d0e4532534bc090513e0fda416dd4d4f229910b)
informed the stable-owner/narrow-layout approach in the 2026-10-30 review; that
revision's contents were not re-reviewed in this refresh. Earlier Belweave
examples informed hidden-pane access, scroll continuity and collision checks.

## iPad and GameEmu follow-up, 2026-11-26

The shared UI `adaptive-windows.md` reference holds the canonical iPad window
rules and links to HIG Layout/iPadOS, onGeometryChange, windowResizability,
defaultSize, scrollDisabled, scrollBounceBehavior and effectiveGeometry. Those
Apple pages were fetched directly for this follow-up; SDK 27.1 public interfaces
confirmed the geometry overloads and scene-sizing declarations. Prior unchanged
Apple resizing/TN3192 evidence from this session was reused.

Community follow-up: read AvdLee's `references/layout-best-practices.md` at the
revision pinned above and reused twostraws' resizability reference. Retained
context-local measurements, stable container identity and narrow observation.
Did not adopt percentage-based header sizing as a universal rule, the sample
that treats nil size class as expanded, or stateful ViewThatFits alternatives.
Apple and BaseSwiftUI contracts remain authoritative.

GameEmu was inspected read-only at HEAD
`05f55e9dc7d104ae606d5c72885f8f5bd42a6266`; the following source paths were clean
in its working tree at review. Paths are relative to that separate repository,
not required files in BaseSwiftUI:

| GameEmu source | Reusable lesson | Boundary |
| --- | --- | --- |
| GameSimulator/MT-Screens/EmulatorGames/Views/GameLibraryDetail.swift | One scroll owner, AnyLayout, measured overflow | Width caps/spacing are product choices |
| GameSimulator/MT-Screens/EmulatorSettings/Views/SettingScreenView.swift | Keep scroll/SDK host mounted while layout changes | Do not copy ad widths or modal workarounds |
| GameSimulator/MT-Screens/EmulatorHome/Views/GamesHomeTabView.swift | Container/store ownership above presentation branches | Keep BaseSwiftUI's Effect/Environment router and factories |
| GameSimulator/MT-Screens/EmulatorIntro/Views/IntroScreenView.swift | Stable page/media owners, separate measured footer | No onboarding/purchase workflow import |
| GameSimulator/Widgets/EmulatorAdaptive/EmulatorAdaptiveViewport.swift | One existing child; fit-scroll measures before viewport expansion | No general whole-page fold exemption or modal geometry lock |
| GameSimulator/Widgets/EmulatorAdaptive/EmulatorWindowSafeAreaReader.swift and EmulatorWindowFrameReader.swift | Owning-window conversion, deduplication and stale callback guards | Use only for demonstrated hosting mismatch |
| GameSimulator/Widgets/EmulatorAdaptive/EmulatorLayoutGeometry.swift | Intersect local bounds with safe regions before placement | Do not import camera/size heuristics as device detection |
| GameSimulator/Widgets/EmulatorAdaptive/IPadControlSizing.swift | A visual transform needs matching layout/hit bounds | Idiom-based 1.15/1.30 scaling is not a base default |

GameEmu's adaptive README and Home system-controls report were supporting notes;
source was checked rather than treating their verification claims as current
runtime proof. GitNexus CLI could not query this repo because the local registry
did not expose GameEmu/GameSimulator; bounded source inspection was used. No
index refresh, app changes, build, simulator or runtime test was performed there.
External Markdown scanning (11 community files plus GameEmu policy/adaptive docs)
found no pattern hits; Swift source was reviewed as code, not executable guidance.
This is selective source synthesis, not a certification of all GameEmu screens.

## Maintenance

Refresh only sources needed for a changed API or disputed claim. Update checked
dates only after checking that claim; do not require a web/SDK sweep per prompt.
Retain iOS 17, Swift 5, Combine/ObservableObject, Factory and ProjMaker's structure
with BaseSwiftUI's existing layers even when upstream examples choose otherwise.
Routing/metadata validation is not a behavioral or speed benchmark.
