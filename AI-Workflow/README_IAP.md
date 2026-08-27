# IAP Integration Status

## Current state

BaseSwiftUI does not currently contain a complete paywall flow, IAP route,
purchase SDK bridge, product-selection screen, restore flow, or Remote Config
mapping. `AppNavigationRoute` currently exposes only the sample Home/detail
routes. StoreKit-related error helpers alone do not constitute an IAP feature.

Do not generate references to `CustomRoute.iap`, `IAPMTSDK`,
`BaseIAPScreenBinding`, `IAPRouteHostView`, or numbered companion-project
paywalls unless those dependencies are explicitly introduced and verified in
this repository.

## Adding IAP deliberately

When the user requests an IAP implementation:

1. Read `.codex/skills/baseswiftui-iap-flow/SKILL.md`.
2. Confirm the selected purchase SDK or StoreKit architecture and product-ID
   source. This is a material integration choice and must not be guessed.
3. Add the smallest complete boundary: product loading, purchase, restore,
   entitlement state, errors, and test/store configuration.
4. Keep StoreKit/SDK calls behind a service protocol and inject dependencies
   through Factory. Paywall Views render state and forward actions.
5. Add a typed `AppNavigationRoute` case only when the paywall is routed.
6. Store no secrets in source. Product identifiers and Remote Config keys are
   configuration contracts; change them deliberately.
7. Add legal links, accessibility, localization, loading/error states, and
   purchase restoration before treating the flow as production-ready.
8. Build through `BaseSwiftUI.xcworkspace` and test with StoreKit configuration
   or the selected SDK sandbox.

## Porting from a companion project

Port behavior only after verifying every dependency exists or is intentionally
being added. Do not copy Firebase Coin, Native Ads, onboarding-IAP, Lottie, or a
project-specific purchase SDK merely because another app uses it. Adapt routes,
Factory registrations, product helpers, analytics, and legal UI to BaseSwiftUI
instead of retaining foreign names or hidden assumptions.
