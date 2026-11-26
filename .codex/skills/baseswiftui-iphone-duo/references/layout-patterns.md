# Duo UI patterns within BaseSwiftUI

Read the relevant pattern only. A screen uses the same functionality and state
at narrow and wide sizes; extra space may expose supporting content. Do not
make opening the device a requirement for accessing an action. The same screen
composition also serves iPad windows; the shared adaptive-windows reference owns
window dragging, geometry observation and scroll-fit rules. Add Duo region
handling only to affected content, not to every iPad layout.

## Choose from the content relationship

| Content | Starting point | Base contract |
| --- | --- | --- |
| Items and selected detail | Existing route on narrow layouts; split presentation where justified | One selection and route owner; BaseDataSource remains the item source |
| Content and tools/comments | Inspector, or split/overlay arrangement when its behavior fits | One Container; pane accessible by button/sheet when hidden |
| Media and controls | Stable child layout; arrangement only with suitable pane behavior | Existing player/service owner; resizing does not restart work |
| Feed/grid | Existing BaseGridView with columns based on available space | Stable item IDs, data source, scroll and selection contracts |
| Form/settings | Flexible spacing and readable content width | Preserve draft/focus; keyboard and accessibility can require scrolling |

Size class describes available space, not device identity. Inspect both width
and height where content fit matters, including sheets and narrow windows.
Size classes are optional: `== .regular` establishes an expanded class;
`!= .compact` also accepts nil. Available space and content fit still matter.

## List and detail

Keep the current push flow functional before adding a wide presentation.
`HomeView`/`HomeContainer` under `BaseSwiftUI/Presentation/Screens/Home` illustrate the
base's data source, selection intent and load/cancellation. HomeContainer emits
navigation Effects; HomeView receives them and uses its Environment router;
they are not already a Duo split implementation.

- Preserve one selected item ID and the originating navigation path. Do not
  create a second Container by calling a Factory again in the wide branch.
- Use NavigationSplitView only at an appropriate navigation ownership boundary.
  Do not wrap an existing routed destination in a second stack/split by default.
  If this requires redesigning the shared router contract, use architecture.
- Compact presentation must still reach the same detail, Back and dismissal
  actions. Merely showing two columns is not a navigation migration.
- Keep the scroll anchor with its stable owner if the renderer must change;
  retaining the model alone does not retain a replaced List's scroll/focus.

## Content plus a supporting pane

Use an inspector (available from iOS 17) when a trailing supporting panel with
a compact sheet fits the product. For two related content areas, consider an
ArrangementView only after SDK/API checks; this is not required for all Duo UI.

- Split keeps views in separate spaces; overlay layers them until the system
  separates them around the fold. Choose by content relationship, not pose name.
- Axis restrictions can hide the secondary view. Apple's ArrangementView
  reference also describes primary-only presentation on the closed outer
  display in landscape. Keep a button, sheet or existing route to secondary
  actions; do not assume both children stay visible just because they fit.
- In split style, primary is leading/top; in overlay style, primary is above
  secondary on the z-axis when flat, then trailing/bottom when folded. Choose
  primary by that relationship, not by a label such as “main content”.
- Keep one owner for comments/draft/selection across inline and sheet versions.
  Do not dismiss and re-present sheets merely because geometry changed. If a
  product explicitly transfers editing inline, preserve draft and focus.
- Keep navigation ownership outside the arrangement's children and scrolling
  inside the content panes. Do not place an arrangement inside List, ScrollView
  or Grid. Avoid combining it with NavigationSplitView in either direction
  without targeted evidence; `sources.md` records the conflicting Apple
  nesting guidance. Do not create another navigation owner to work around it.
- Keep exact declarations, availability and coordinate behavior verified;
  do not turn a remembered API name into an app helper guessed to exist.

## Media or two persistent child views

Keep the player, recorder, document or network task in the existing stable
owner. Geometry changes update layout, not business intents such as load,
stop, save or purchase. Review `.task`, `.onAppear` and `.onDisappear` when
moving boundaries: the Home sample, for example, cancels loading on disappear.

For an ordinary axis change, AnyLayout is available below the iOS 17 minimum:

```swift
// Illustration inside a View with an existing owner; not a complete Duo layout.
// `fitsSideBySide` comes from usable container space and content requirements.
let layout = fitsSideBySide
    ? AnyLayout(HStackLayout(spacing: 16))
    : AnyLayout(VStackLayout(spacing: 16))
layout {
    primaryContent
    controlsContent
}
```

Keep the same child order and identity as the layout changes. This preserves
structural identity across the axis switch; it does not avoid a fold or prove
playback continuity. For fold-aware placement use a supported arrangement or a
small custom Layout reading local reserved regions. Verify usable space for
both children rather than squeezing essential controls into a tiny pane.

Do not put stateful alternative trees inside ViewThatFits and assume they share
state. It is useful for alternative stateless labels/control arrangements.

## Feed and grid

Inspect `BaseSwiftUI/Presentation/DataSource/Core/BaseGridView.swift` and the closest
call site. It accepts columns/columnCount, contentInsets, scrollPosition and
isScrollEnabled; it does not claim to implement hinge avoidance.

- Keep BaseDataSource ownership and existing selection/visibility callbacks.
  Do not replace it with a raw array or a new data source per pane.
- Prefer changing columns within the same renderer. Even columns can help
  around a division, but do not guarantee the gutter aligns with it: safe
  areas are asymmetric and the region is in the querying View's coordinates.
- If a card/control still intersects the division, adapt the specific layout
  using the region. Two filtered renderers require deliberate ordering,
  scrolling and selection semantics; do not introduce them automatically.
- Assign scrolling to one owner. Preserve an existing scrollPosition binding
  and stable IDs; do not nest scrolling just to make the wide layout fit.

## Forms, Figma and safe areas

Keep readable text width, let flexible spacing/decorations yield first, and
allow vertical access when keyboard, large text or a short window needs it.
Do not double fonts or scale the whole screen to fill the inner display.

For exact Figma work the Figma skill remains primary. Keep supplied assets,
tokens and control dimensions. Shared scrolling/window policy lives in
`.codex/skills/baseswiftui-swiftui-ui/references/adaptive-windows.md`:
actual content/keyboard fit and existing renderer contracts decide scrolling,
not mockup height. Report the adaptive arrangement where the design supplies
only one state; do not silently invent new artwork or product behavior.

Keep readable and interactive content clear of system UI; decorative backgrounds
can extend into safe areas. Read each edge from the relevant View/scene, not a
global first key window; each inset has one owner. For a custom pinned bar,
`safeAreaInset` works within the iOS 17 baseline and reserves content space.
On a capable SDK/runtime, `ContentMarginGuide.container` provides container
margins that can be asymmetric; do not turn documented point ranges into constants.

Query reserved regions at the view positioning the affected content, and react
to geometry updates rather than caching once in onAppear. The default query
returns active intersecting regions; `.includeInactive` is for deliberate
planning, not evidence of a current obstruction. A partially overlapping frame
can have negative coordinates or extend outside the view: intersect it with
usable bounds before deriving pane dimensions, and handle insufficient space.
Frames already include margins. SwiftUI mirrors them by default for RTL;
use `.fixed` only with placement that does not mirror. In custom Layout, keep
calculations in the query's coordinates and add `bounds.origin` at placement.
After moving content, check bounds, other controls and remaining regions too.

Lists and scrolling containers do not automatically split items around a
division. Allow content across it when usable; adapt items whose readability
or interaction suffers. Do not apply a blanket scroll-content exemption.

## Bars and actions

System navigation toolbars adapt according to supported SDK/runtime behavior.
A custom BaseNavBar does not become vertical simply by adding a modifier.
Preserve existing back, dismissal, loading and action contracts when choosing
a system-toolbar presentation; do not replace the shared navbar globally.
Use `bars-and-presentations.md` for edge semantics, action priorities and
sheets, and `accessibility.md` when pane order or focus changes. Keep the
existing iOS 17 presentation below new API availability.
