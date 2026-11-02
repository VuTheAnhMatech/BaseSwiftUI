# Full-screen paywall layout

Read this only for full-screen media paywalls or substantial CTA/content
layout changes.

For exact-node layout, derive row height from text line height, internal padding
and Auto Layout; measure sibling spacing separately from the row's own padding.
Inspect BaseButton's minimum frame before reuse: wrapping it in a shorter outer
frame does not remove its internal minimum or fix its layout/hit bounds. Keep
explicit design geometry unless the user approves a different visual size; use
a narrowly scoped native control when the shared component cannot represent it.
Allow larger text to grow/scroll rather than clipping it to the default height.

- Follow the closest project paywall: commonly `GeometryReader` with a
  full-screen `ZStack` and background/media that ignores safe areas.
- Do not use `safeAreaInset` for the close or legal actions when it would create
  layout space and push the background down.
- Overlay the close control inside the full-height stack using
  `proxy.safeAreaInsets.top` plus the design offset. Use existing max-safe-area
  helpers only when the nearest layout reconciles proxy and window insets.
- Keep legal actions in the bottom content block and pad that block from
  `proxy.safeAreaInsets.bottom`.
- Extract meaningful sections such as title, plans, CTA, and legal actions.
  Keep the complete configured `PurchaseButton` action/product-resolution flow
  together; extract only small decorative overlays separately.
- Keep background sizing independent from control safe-area placement.
  A resizable `scaledToFill` image inside the main ZStack can enlarge its layout
  beyond the proposed viewport. Prefer a background modifier on the bounded
  foreground container; clipping the image alone does not constrain layout.
  Also bound the background's own image/canvas to the proposed viewport before
  clipping. A background modifier stops it influencing foreground size but does
  not prevent its descendants from drawing outside the presented screen during
  dismissal. A viewport-sized color with an overlay/GeometryReader can own those
  bounds without inheriting the image's intrinsic overflow.
- For fit-first paywalls, follow the shared adaptive-window reference's
  intrinsic-height scroll decision. Include price, CTA, legal controls and close
  clearance; collapse optional hero space first. Keep the full-width readability
  scrim stationary behind the purchase panel rather than attached to its scroll
  content. Do not remove overflow access to make the initial screen look fixed.
  Wallpaper and scrim must share the same full-window decorative coordinate
  space, including leading/trailing safe areas. Keep controls in their safe area;
  do not use the narrower safe-content width for a scrim covering full-bleed art.

Validate no top gap, bottom obstruction, clipped pricing/trial copy, or hidden
legal action on compact and representative larger devices.
For scroll fixes, also check a drag while content fits, a genuinely overflowing
window/text size, and a return to a fitting size. Report screenshots, measured
scroll state and performed gestures separately; none substitutes for the others.

For an explicitly requested temporary paywall entry point, keep the underlying
screen and its Container alive during presentation so closing returns to its
draft/selection. Use the existing presentation pattern and dismiss from the
presented scope. Each new presentation must start with a usable dismissal state;
do not reuse a latched `shouldDismiss` flag from a previously closed paywall.
Check open → close → reopen → close, including entry while an editor is focused.
If a startup paywall and an in-screen entry show the same UI, prefer a stable
underlying root and a consistent modal boundary. Swapping root View branches
can change safe-area ownership and is not equivalent to dismissing a cover.
Inspect the underlying bottom bar and background after both entry paths;
checking only that the close button disappears misses stale layers or lost
safe-area content. Exercise the real close action, including accessibility
activation, rather than only toggling presentation state in a debugger.
For a reported stale layer/animation artifact, inspect a recording from Simulator
or the affected display. XCTest snapshots and hit testing can pass while the
composited recording still shows stale pixels; they are separate evidence.
Compare during dismissal and several seconds afterward. A changed presentation
owner alone is not proof that the rendering defect was fixed.
