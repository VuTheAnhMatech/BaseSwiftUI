---
name: baseswiftui-ios-guidelines
description: Apply BaseSwiftUI architecture, component, asset, MVI, Factory, credential, and workspace rules. Use when guidelines are requested or another project skill routes here; otherwise prefer the task-specific skill.
---
# BaseSwiftUI iOS Architecture & Guidelines

## 1. Core Workflow & Philosophy
* **Pattern Consistency**: Always inspect the closest existing feature pattern in the project before creating new code. Match its structure, naming conventions, and layout approach.
* **Scoped Changes**: Keep modifications strictly scoped to the requested feature, component, or screen. Avoid touching unrelated logic.
* **Primitive Over Abstraction**: Prefer existing project primitives, extensions, and utilities over introducing new third-party libraries or custom architectural layers.
* **Workspace Integrity**: Always preserve CocoaPods configuration. Build, test, and validate changes exclusively through `BaseSwiftUI.xcworkspace`.

## 2. Project Map & Directory Structure
* **File Header Author**: For generated or updated file header comments, always use `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another project/person name.
* **App Entry**: `BaseSwiftUI/ContentView.swift` (Transitions from `SplashView` to the routed Home flow).
* **Feature Screens**: `BaseSwiftUI/MT-Screens/` (Organized by feature folders containing Views and Containers).
* **MVI Containers**: Colocated within their respective feature folders under `MT-Screens/`.
* **Dependency Injection**: `BaseSwiftUI/MT-Factory/` (Centralized Factory registrations).
* **Domain Entities**: `BaseSwiftUI/MT-CleanArchitecture/Domain/Entities/` (App data models, screen/domain entities, static mock data, and sample data such as `MockData`). Use `baseswiftui-model-organization` for all model placement. Put feature-specific entities in a feature subfolder such as `Domain/Entities/CreateEmojiFromText/`; put truly shared app-wide entities under `Domain/Entities/Shared/`; do not leave unrelated feature models together in flat root files.
* **Core Infrastructure**: `BaseSwiftUI/Base/` (Reusable base components and foundation logic).
* **Global Extensions**: `BaseSwiftUI/Exts/` (Shared Swift system/UI extensions only).
* **Shared Widgets**: `BaseSwiftUI/Widgets/` (Domain-specific reusable UI blocks).
* **Resources**:
  * `BaseSwiftUI/Resources/Assets.xcassets` (Global images, icons, and vector assets).
  * `BaseSwiftUI/Resources/Colors.xcassets` (Color palettes mapped via `Exts`).
  * `BaseSwiftUI/Resources/Fonts/` (Custom font files - Primary: *Plus Jakarta Sans*).
* **Core Libraries**: `BaseSwiftUI/Libs/` (Embedded internal frameworks like `UnionTabView`).

## 3. Base Component & UI Reuse Rules
* **Immutability of Base**: Do not modify files under `BaseSwiftUI/Base` unless explicitly requested by the user or structurally impossible otherwise.
* **Component First**: Always leverage `BaseText`, `BaseButton`, `BaseNavBar`, and existing widgets in `Widgets/` instead of implementing raw SwiftUI equivalents (`Text`, `Button`).
* **Collection Rendering Through Base**: Never render screen collections with direct `ForEach`, `LazyVGrid`, `GridItem`, manual cell-width calculations, or ad hoc horizontal `ScrollView` loops inside feature views. Use `BaseDataSource` plus existing Base data-source views such as `BaseGridView`, `BaseScrollView`, `BaseStackView`, `BaseLazyListView`, or `BaseListView`.
* **Data Source Ownership**: Initialize static or loaded list data in the MVI Container, repository/data provider, or a `BaseDataSource`; do not initialize list data inside SwiftUI views. Views may only observe/pass `BaseDataSource` and send user actions back to the Container.
* **Design Tokens**: For design-specific interactions (e.g., glassmorphism, liquid, or special tactile states), utilize pre-defined enum styles such as `BaseButton(style: .liquidAdaptive, ...)` instead of custom modifiers.
* **Close Icon Size**: Whenever rendering `Image("ic_close")`, always frame it at exactly `width: 40, height: 40`.
* **Zero One-Off Extensions**: Never create private, screen-isolated extensions for standard types (`View`, `Color`, `String`, etc.). All reusable logic must reside in `BaseSwiftUI/Exts/`.
* **Entities Outside Views/Containers/Exts**: Never place entities, mock data, static sample data, default lists, screen item structs, tab/section enums, or enums such as `MockData` in SwiftUI view files, MVI containers, services, repositories, factories, or `BaseSwiftUI/Exts/`. Put those files under `BaseSwiftUI/MT-CleanArchitecture/Domain/Entities/`; create a feature subfolder when the model is not shared app-wide and use `Shared/` only for true app-wide models.
* **Safe Margins**: Ensure all scrollable content surfaces maintain a bottom padding large enough to prevent interactive elements (floating buttons, sticky footers) from overlaying content.
* **No One-Off Metrics Containers**: Do not create private `Metrics`, `Constants`, or similar enums/structs only to store small layout literals used once or twice in the same SwiftUI view. Write simple values such as padding, spacing, column counts, ratios, and frame sizes directly at the callsite. Extract a named value only when it is reused meaningfully, shared across files, or represents a cross-layer contract.

## 4. Resource & Asset Management
* **Color Usage**: Use existing global color tokens directly at the callsite when they already exist, such as `Color.BG.BG_01`, `Color.Ink.headline`, `Color.Ink.body`, `Color.Primary.primary`, and `Color.Semantic.*`.
* **No Feature Color Aliases**: Never create feature-specific `Color` namespaces such as `extension Color { enum Explore { ... } }`, `Color.Settings`, or `Color.Tabbar` just to alias colors for a screen. For one-off screen colors, write the `Color(...)`, `.white`, `.black`, or opacity expression directly in the view where it is used.
* **Shared Color Tokens Only**: Add or modify `Color` extensions only for true reusable app-wide design tokens that already belong to the global token system under `BaseSwiftUI/Exts/`, not for per-screen styling shortcuts.
* **Asset Mapping**: Use image assets instead of SF Symbols whenever a matching custom asset exists in `.xcassets`.
* **Namespace Accuracy**: Reference assets using their strict, clean slash-separated paths as defined in the catalog (e.g., `Tabbar/ic_search`, `Common/ic_arrow`). Ensure asset folder names do not contain accidental spaces.
* **Raster Scales**: Raster assets exported through Figma MCP or extracted from a supplied screenshot must use correctly sized `@2x` and `@3x` renditions only; omit `@1x`. Never label one bitmap as both scales or upscale an insufficient source.
* **Icon Composition**: For grouped lists or rows featuring icons, prefer dedicated custom asset icons over building compound views out of SF Symbols with custom background frames.

## 5. Flow & Architecture (MVI + Factory)
* **Separation of Concerns**: Strictly follow the MVI (Model-View-Intent) container pattern:
  * **SwiftUI View**: Purely structural and passive. Responsible for rendering the state and forwarding user interactions as intents to the Container.
  * **MVI Container**: Maintains state, owns screen `BaseDataSource` instances when practical, processes intents, executes business logic, manages persistence, handles networking, and triggers side effects. Do not declare model structs/enums in containers.
* **Dependency Injection**: Resolve all instances, repositories, services, and managers using Factory registrations via `Container.shared`. Do not instantiate singletons or dependencies inline within views.
* **Decoupled Adaptations**: When porting patterns or modules from companion projects, strip away all foreign dependencies and streamline the implementation to fit BaseSwiftUI’s lightweight architecture.
* **Single Stack for Page Flows**: Push page destinations on their originating router. Do not re-present the same page inside a new full-screen `AppRouter.Stack` unless the flow genuinely crosses root ownership.
* **Nested Sheet Router Ownership**: `ObservedStack.sheet` wraps presented content in a new `AppRouter.Stack`; a router injected inside that sheet belongs to the nested stack and does not own the parent `sheetRoute`.
* **Sheet Self-Dismissal**: Sheet Views use `@Environment(\.dismiss)`. For async completion, the Container publishes a dismissal request and the View calls `dismiss()`. Only the presenting parent router should call `dismissSheet()`.
* **Credential Storage**: The current `UserDefaults`-backed `TokenStore` is scaffold-only. Production access/refresh tokens must use a `TokenStoreProtocol` implementation backed by Keychain or another approved secure store. Never log tokens or authorization headers.

## 6. Validation & Verification
Before marking a task as complete, execute a Debug build to guarantee code correctness:
```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -workspace BaseSwiftUI.xcworkspace -scheme BaseSwiftUI -configuration Debug -destination generic/platform=iOS -derivedDataPath /private/tmp/BaseSwiftUIDerivedData CODE_SIGNING_ALLOWED=NO build
```
**Pre-flight Checklist**:
- [ ] No local/private color variables are hidden inside view files.
- [ ] All primary UI typography and actions utilize `BaseText` and `BaseButton`.
- [ ] All collections render through `BaseDataSource` and Base data-source views; no direct feature-view `ForEach`, `LazyVGrid`, `GridItem`, or manual cell-size math remains.
- [ ] Screen/domain models and default/static sample data live under `BaseSwiftUI/MT-CleanArchitecture/Domain/Entities/`, preferably in a feature subfolder when not shared, not in Views, Containers, or Exts.
- [ ] One-off layout literals are written directly at callsites instead of being hidden behind private `Metrics`/`Constants` containers.
- [ ] Asset references precisely match their `.xcassets` paths.
- [ ] New Figma/screenshot raster assets contain valid `@2x` and `@3x` renditions and no `@1x` rendition.
- [ ] CocoaPods setup and existing workspace structures remain perfectly intact.
- [ ] `push -> sheet -> dismiss -> Back` flows keep one page stack and let the sheet dismiss its own presentation.
- [ ] Production credentials and tokens are not persisted in `UserDefaults` or written to logs.
