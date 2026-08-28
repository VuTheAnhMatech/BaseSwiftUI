---
name: baseswiftui-iap-flow
description: Build or edit BaseSwiftUI paywalls, subscriptions, pricing, trials, purchases, restore, product selection, sale badges, and Remote Config IAP flows. This is the primary skill for all IAP UI.
---

# BaseSwiftUI IAP Flow

Treat product identifiers, pricing, trial/sale copy, purchase, restore, Remote
Config, analytics, and SDK calls as fragile integration behavior.

## Inspect

1. Inspect the closest IAP screen and search product helpers under `Exts`, SDK
   integration under `Libs`/`Helper`, and related domain/service files.
2. Reuse existing price, period, trial, discount, sale, product-selection,
   route, and presentation patterns before creating anything.
3. Read `BaseSwiftUI/MT-Screens/IAP/README_IAP.md` when it exists and structure,
   selection, routing, or SDK behavior changes.
4. For a full-screen image/video paywall or major CTA-layout change, read
   `references/paywall-layout.md`.

## Implement

- Mirror the nearest IAP structure. New/updated headers use
  `Created by Vu The Anh`.
- Keep screen-specific selection state in the paywall. Reusable product display
  logic and wording belong in dedicated files under `BaseSwiftUI/Exts`.
- Keep purchase, restore, event logging, Remote Config, and SDK calls in their
  existing IAP-facing layers. Preserve product IDs and configuration keys.
- Wire presentation through existing IAP routes/stores; do not add ad hoc
  navigation.
- Reuse matching Base views and paywall components. Keep price, trial, sale,
  legal text, and CTA layout resilient to compact width and localization.
- For fixed paywall content, Figma height above 844pt uses a screen-level
  `ScrollView`; height at or below 844pt uses no screen-level `ScrollView` and
  must adapt responsively from iPhone SE through iPhone 17 Pro Max.
- Keep `BaseButton`'s adaptive default for Liquid Glass on iOS 26+ and its
  earlier-iOS plain fallback; opt into `.plain` only when explicitly designed.
- Use the bundled/documented project font even when the design names another
  family; map to the closest size/weight without asking. Add font files only
  when explicitly requested.
- Raster assets exported through Figma MCP or extracted from a supplied
  screenshot use correctly sized `@2x` and `@3x` renditions only; omit `@1x`.
  Never label one bitmap as both scales or upscale an insufficient source.
- Do not duplicate helpers or append reusable extensions to a screen file.
  Keep changes scoped to the requested flow.

## Validate

Verify product/helper reuse; selection and CTA state; purchase and restore SDK
calls; product IDs and config keys; compact-width/localized pricing; legal
actions; accessibility; and every changed presentation/dismissal edge. Build
through `BaseSwiftUI.xcworkspace` when Swift changed. Do not claim sandbox or
StoreKit behavior passed unless it was exercised.
