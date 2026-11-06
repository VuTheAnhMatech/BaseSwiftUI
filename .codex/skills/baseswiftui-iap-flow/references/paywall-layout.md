# Full-screen paywall layout

Read this only for full-screen media paywalls or substantial CTA/content
layout changes.

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

Validate no top gap, bottom obstruction, clipped pricing/trial copy, or hidden
legal action on compact and representative larger devices.
