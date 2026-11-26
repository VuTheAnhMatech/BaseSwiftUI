---
name: baseswiftui-ios-guidelines
description: Reference BaseSwiftUI architecture, component, asset, MVI, Factory, credential, and workspace rules only when guidelines are explicitly requested or a specialist routes here. Never load for a one-node Figma/local-View task.
---
# BaseSwiftUI iOS Architecture & Guidelines

## 1. Core Workflow & Philosophy
* **Pattern Consistency**: Always inspect the closest existing feature pattern in the project before creating new code. Match its structure, naming conventions, and layout approach.
* **Scoped Changes**: Keep modifications strictly scoped to the requested feature, component, or screen. Avoid touching unrelated logic.
* **Primitive Over Abstraction**: Prefer existing project primitives, extensions, and utilities over introducing new third-party libraries or custom architectural layers.
* **Workspace Integrity**: Always preserve CocoaPods configuration. Build, test, and validate changes exclusively through `BaseSwiftUI.xcworkspace`.

## 2. Project Map & Directory Structure
* **File Header Author**: For generated or updated file header comments, always use `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another project/person name.
* **App Entry**: `BaseSwiftUI/Core/App/ContentView.swift` (Transitions from `SplashView` to the routed Home flow).
* **Feature Screens**: `BaseSwiftUI/Presentation/Screens/` (Organized by feature folders containing Views and Containers).
* **MVI Containers**: Colocated within their respective feature folders under `Presentation/Screens/`.
* **Dependency Injection**: `BaseSwiftUI/Core/DI/` (Centralized Factory registrations).
* **Domain Entities**: `BaseSwiftUI/Domain/Entities/` (Business models and their fixtures; UI-only items remain in Presentation and DTOs in Data). Use `baseswiftui-model-organization` for all model placement. Put feature-specific entities in a feature subfolder such as `Domain/Entities/CreateEmojiFromText/`; put truly shared app-wide entities under `Domain/Entities/Shared/`; do not leave unrelated feature models together in flat root files.
* **Core Infrastructure**: `BaseSwiftUI/Core/` (Reusable base components and foundation logic).
* **Global Extensions**: `BaseSwiftUI/Utils/Extensions/` (Shared Swift system/UI extensions only).
* **Shared Widgets**: `BaseSwiftUI/Widgets/` owns cross-screen reusable UI, generic UI layouts/adapters, and app-wide overlays. Configure visual widgets through focused types/models and actions rather than a concrete Container. Keep feature UI near its screen and document every Widget contract and call site in `Widgets/README.md`.
* **Resources**:
  * `BaseSwiftUI/Resources/Assets.xcassets` (Global images, icons, and vector assets).
  * `BaseSwiftUI/Resources/Colors.xcassets` (Color palettes mapped via `Utils/Extensions`).
  * `BaseSwiftUI/Resources/Fonts/` (Custom font files - Primary: *Plus Jakarta Sans*).
* **Core Libraries**: `BaseSwiftUI/Libs/` (Embedded internal frameworks like `UnionTabView`).

## 3. Base Component & UI Reuse Rules
* **Immutability of Base**: Do not modify files under `BaseSwiftUI/Core` unless explicitly requested by the user or structurally impossible otherwise.
* **Component First**: Always leverage `BaseText`, `BaseButton`, `BaseNavBar`, and existing widgets in `Widgets/` instead of implementing raw SwiftUI equivalents (`Text`, `Button`).
* **Collection Rendering Through Base**: Never render screen collections with direct `ForEach`, `LazyVGrid`, `GridItem`, manual cell-width calculations, or ad hoc horizontal `ScrollView` loops inside feature views. Use `BaseDataSource` plus existing Base data-source views such as `BaseGridView`, `BaseScrollView`, `BaseStackView`, `BaseLazyListView`, or `BaseListView`.
* **Data Source Ownership**: Initialize static or loaded list data in the MVI Container, repository/data provider, or a `BaseDataSource`; do not initialize list data inside SwiftUI views. Views may only observe/pass `BaseDataSource` and send user actions back to the Container.
* **Adaptive BaseButton**: Keep the default `BaseButton` style unless the design explicitly requires no glass. The component owns Liquid Glass on iOS 26+ when enabled and a material fallback on earlier iOS; never duplicate availability checks or glass modifiers at callsites.
* **Close Icon Size**: Whenever rendering `Image("ic_close")`, always frame it at exactly `width: 40, height: 40`.
* **Zero One-Off Extensions**: Never create private, screen-isolated extensions for standard types (`View`, `Color`, `String`, etc.). All reusable logic must reside in `BaseSwiftUI/Utils/Extensions/`.
* **Model Ownership**: Business entities live in Domain/Entities, transport DTOs in Data/DTOs, and UI-only items in separate Presentation feature files. Defaults/mocks stay beside their model. State/Intent/Effect remain with the feature Container. Do not flatten these layers or declare unrelated models inside Views, Containers or Utils/Extensions.
* **Safe Margins**: Ensure all scrollable content surfaces maintain a bottom padding large enough to prevent interactive elements (floating buttons, sticky footers) from overlaying content.
* **844pt Scroll Switch**: For fixed screen content, a Figma frame above 844pt uses a screen-level `ScrollView`; a frame at or below 844pt uses no screen-level `ScrollView` and must adapt responsively from iPhone SE through iPhone 17 Pro Max. Intrinsically scrolling Base list/grid components are exempt from this screen-level switch.
* **No One-Off Metrics Containers**: Do not create private `Metrics`, `Constants`, or similar enums/structs only to store small layout literals used once or twice in the same SwiftUI view. Write simple values such as padding, spacing, column counts, ratios, and frame sizes directly at the callsite. Extract a named value only when it is reused meaningfully, shared across files, or represents a cross-layer contract.

## 4. Resource & Asset Management
* **Color Usage**: Match RGBA against `Resources/Colors.xcassets` first and use its generated resource, such as `Color(.OP.OP_01)`, `Color(.Ink.body)`, or `Color(.Semantic.green)`. Never use `Color("path")`, a wrapper variable, or inline RGB/hex for a catalog color.
* **Missing Colors**: Add a color set using the supplied Figma semantic path. If no meaningful name exists, use `Color<RRGGBB><AA-percent>`, omitting alpha at 100% (for example `ColorFFFFFF10`). Never create feature-specific `Color` namespaces or View-local color properties merely to alias colors.
* **Shared Color Tokens Only**: Add or modify `Color` extensions only for true reusable app-wide design tokens that already belong to the global token system under `BaseSwiftUI/Utils/Extensions/`, not for per-screen styling shortcuts.
* **Typography Source of Truth**: Use the Figma or screenshot font family when it is already bundled and registered in the app. Otherwise use the app's primary bundled font. Preserve the requested size and line height, and map weight to the exact or closest bundled face. Add or download a missing family only when the user explicitly requests it.
* **Asset Mapping**: Use image assets instead of SF Symbols whenever a matching custom asset exists in `.xcassets`.
* **Asset Organization**: Put feature image sets in a namespaced screen folder and reference them as `Screen/asset_name`, for example `Home/ic_setting`. Put only genuinely cross-screen assets in `Shared`; keep AppIcon and AccentColor at the catalog root.
* **Typed Asset Usage**: Use Xcode-generated resources such as `Image(.Home.icSetting)`, never `Image("Home/ic_setting")` or static wrapper variables.
* **Namespace Accuracy**: Reference assets using their strict, clean slash-separated paths as defined in the catalog (e.g., `Tabbar/ic_search`, `Common/ic_arrow`). Ensure asset folder names do not contain accidental spaces.
* **Raster Scales**: Raster assets exported through Figma MCP or extracted from a supplied screenshot must use correctly sized `@2x` and `@3x` renditions only; omit `@1x`. Never label one bitmap as both scales or upscale an insufficient source.
* **Icon Composition**: For grouped lists or rows featuring icons, prefer dedicated custom asset icons over building compound views out of SF Symbols with custom background frames.

## 5. Flow & Architecture (MVI + Factory)
* **Separation of Concerns**: Strictly follow the MVI (Model-View-Intent) container pattern:
  * **SwiftUI View**: Purely structural and passive. Responsible for rendering the state and forwarding user interactions as intents to the Container.
  * **MVI Container**: Maintains state, owns screen `BaseDataSource` instances when practical, processes intents, calls injected UseCases, and emits Effects. Networking and persistence remain behind Repository/Service boundaries. Do not declare model structs/enums in containers.
* **Dependency Injection**: AppDIFactory owns the registry; Service/Repository/UseCase registration files and ScreenDIFactory keep responsibilities separate without pass-through wrappers. Inject Containers through initializers; no Container.shared in Views.
* **ProjMaker Priority**: Use async dispatch, attachContainer lifecycle and one-shot Effects. Preserve Domain, UseCase, Repository and DTO layers.
* **Navigation**: AppRouteFactory maps AppRoute. Views observe Effects and use Environment router. Each presentation owns its own path; current router.dismiss closes that presentation. Native sheets can also use Environment dismiss. asRoot replaces the full tree.
* **Credential Storage**: TokenStore uses Keychain and migrates legacy defaults only after a successful secure write. Handle throwing save/clear and preserve failure paths. Never log tokens or authorization headers; never fall back to plaintext on Keychain errors.

## 6. Validation & Verification
Before marking a task as complete, execute a Debug build to verify compilation:
```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -workspace BaseSwiftUI.xcworkspace -scheme BaseSwiftUI -configuration Debug -destination generic/platform=iOS -derivedDataPath /private/tmp/BaseSwiftUIDerivedData CODE_SIGNING_ALLOWED=NO build
```
**Pre-flight Checklist**:
- [ ] No local/private color variables are hidden inside view files.
- [ ] All primary UI typography and actions utilize `BaseText` and `BaseButton`.
- [ ] Fixed Figma content uses screen-level scroll only above 844pt; content at or below 844pt adapts from iPhone SE through iPhone 17 Pro Max without screen-level scroll.
- [ ] `BaseButton` keeps adaptive Liquid Glass on iOS 26+ unless the design explicitly requires `.plain`.
- [ ] Typography uses the requested family when bundled; otherwise it falls back to the app's primary font while preserving size and closest weight.
- [ ] All collections render through `BaseDataSource` and Base data-source views; no direct feature-view `ForEach`, `LazyVGrid`, `GridItem`, or manual cell-size math remains.
- [ ] Business models live in Domain, DTOs in Data and UI-only items in Presentation; defaults/mocks stay beside their model.
- [ ] One-off layout literals are written directly at callsites instead of being hidden behind private `Metrics`/`Constants` containers.
- [ ] Asset references precisely match their `.xcassets` paths.
- [ ] New Figma/screenshot raster assets contain valid `@2x` and `@3x` renditions and no `@1x` rendition.
- [ ] CocoaPods setup and existing workspace structures remain perfectly intact.
- [ ] `push -> sheet -> dismiss -> Back` flows keep one page stack and let the sheet dismiss its own presentation.
- [ ] Production credentials and tokens are not persisted in `UserDefaults` or written to logs.
