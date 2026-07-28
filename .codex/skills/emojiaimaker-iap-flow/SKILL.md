---
name: emojiaimaker-iap-flow
description: Use whenever the user asks to create, add, build, implement, edit, or polish an IAP, paywall, subscription, pricing, purchase, restore, trial, sale-badge, product-selection, or Remote Config driven view or flow in EmojiAIMaker, including IAP screens under EmojiAIMaker/MT-Screens when present, product display helpers, IAP route presentation, purchase SDK behavior, and Product extension helpers. This is the complete view workflow for IAP views; do not use emojiaimaker-swiftui-ui as the primary skill for IAP screens.
---

# EmojiAIMaker IAP Flow

## Overview

Use this as the complete workflow for EmojiAIMaker IAP and paywall view work. IAP
views are special because product identifiers, pricing, trial copy, sale copy,
purchase, restore, analytics, SDK calls, and Remote Config behavior are fragile.

Reuse product helpers, shared paywall UI patterns, and existing purchase integration points
instead of adding screen-local duplicates.

## Project Map

- IAP screens: `EmojiAIMaker/MT-Screens/IAP` when the feature exists.
- IAP integration: existing purchase SDK or service files in `EmojiAIMaker/Libs`, `EmojiAIMaker/Helper`, or `EmojiAIMaker/MT-CleanArchitecture`.
- Product helpers: product-related extensions under `EmojiAIMaker/Exts`.
- Router and presentation: existing router types under `EmojiAIMaker/Base`.
- Shared SwiftUI components: `EmojiAIMaker/Base`.
- Feature screens: `EmojiAIMaker/MT-Screens`.

## Before Editing

- Treat any paywall, subscription, product price, trial, purchase, restore, or
  sale-badge request as IAP work.
- Search existing helpers and integration files first:
  - product-related files under `EmojiAIMaker/Exts`
  - purchase or IAP files under `EmojiAIMaker/Libs`
  - purchase or IAP files under `EmojiAIMaker/Helper`
  - related domain/service files under `EmojiAIMaker/MT-CleanArchitecture`
- Search for related terms: `IAPProduct`, `price`, `trial`, `sale`, `purchase`, `restore`, `RemoteConfig`.
- Identify whether the change is display-only, screen selection state, SDK integration, or presentation routing.
- Inspect nearby IAP screens before creating a new IAP view.
- Read `EmojiAIMaker/MT-Screens/IAP/README_IAP.md` when it exists and the task changes IAP structure,
  product selection behavior, routing, or SDK integration.

## IAP View Creation Workflow

1. Mirror the closest existing IAP screen structure.
2. Keep screen-specific product selection state inside the paywall view.
3. Reuse existing price, period, trial, discount, sale, and product display
   helpers before adding any new helper.
4. Put reusable IAP wording or product display logic in `EmojiAIMaker/Exts`.
5. Wire presentation through existing IAP route and presentation store patterns.
6. Keep purchase, restore, event logging, and SDK calls in existing IAPSDK-facing
   layers when possible.
7. Keep view layout responsive and resilient to long localized pricing or trial
   strings.

## Full-Screen Paywall Layout

- For full-screen IAP/paywall screens with image or video backgrounds, use the
  CarWidget IAP02 layout pattern:
  `GeometryReader` -> full-screen `ZStack` -> `.ignoresSafeArea()`.
- Do not anchor the close button or legal actions with SwiftUI `safeAreaInset`
  on full-screen paywalls. `safeAreaInset` creates layout space and can push the
  background/media down, causing a visible top gap.
- Place the close button as an overlay inside the full-screen `ZStack`, usually
  in a full-height `VStack` aligned to `.top`. Padding must use:
  `UIApplication.shared.maxTopSafeArea(value: proxy.safeAreaInsets.top) + <design offset>`.
- Place `legalActions` inside the bottom content stack, aligned at the bottom.
  Apply bottom padding to the whole bottom block with:
  `UIApplication.shared.maxBottomSafeArea(value: proxy.safeAreaInsets.bottom) + <design offset>`.
- Keep the background/media independent from safe-area layout. It should fill or
  ignore safe areas first; controls are then overlaid using safe-area padding.

## Paywall View Readability

- Keep paywall content stacks readable by extracting meaningful subviews into
  private computed views or private helper methods.
- Do not inline long `PurchaseButton` chains inside the main content stack. Put
  the configured CTA in a dedicated computed view such as `continueButton`, and
  put its overlay icon in a small helper such as `continueArrow`.
- When a CTA needs container actions and product resolution, keep the whole
  `PurchaseButton { ... }` flow inside `continueButton`: send the container
  action, resolve the selected product, call `binding.purchaseTapped(product:)`,
  apply config/gradient/corner/frame there, and move trailing arrow/image
  overlays into a separate tiny view/helper.
- Prefer extracted sections such as `titleContent`, `plansContent`,
  `continueButton`, and `legalActions` over large mixed stacks of text, product
  list, CTA, and legal controls.

## Rules

- For generated or updated file header comments, always use
  `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another
  project/person name.
- Do not create duplicate helpers for price, period, trial, discount, or sale wording.
- Put reusable product display logic in `EmojiAIMaker/Exts`.
- Keep screen-specific product selection state inside the paywall view.
- Keep purchase, restore, event logging, and presentation store behavior in existing IAPSDK-facing layers when possible.
- Preserve existing route and presentation patterns instead of adding ad hoc navigation.
- Treat product identifiers, pricing, and remote config keys as fragile values; avoid renaming them casually.
- Reuse `BaseText`, `BaseButton`, `BaseNavBar`, and other `Base/Views`
  components when they match the existing paywall style.
- Do not append reusable `extension` blocks to IAP screen files. Put reusable
  Swift extensions in dedicated files under `EmojiAIMaker/Exts`.

## Validation

- Check all touched paywall screens for helper reuse.
- Verify purchase and restore flows still call the existing SDK abstraction.
- Confirm display text uses a shared helper when the wording can appear on more than one screen.
- Check compact-width paywall layout for clipped price, trial, discount, and CTA
  text.
- Confirm product identifiers, Remote Config keys, and SDK-facing behavior were
  not renamed casually.
