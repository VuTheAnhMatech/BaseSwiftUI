# IAP Introduction (For Next Dev)

## 1. Purpose
This folder contains all custom IAP UIs and shared components used by `IAPSDK` presentation callbacks.

## 2. Current Architecture
- Route type: `CustomRoute.iap(payload: IAPRoutePayload)` in `Base/AppRouter/CustomRoute.swift`.
- Binding bridge: `Libs/IAPSDK/IAPRouteBindingStore.swift` stores `BaseIAPScreenBinding` by `routeId` because route payload must be `Codable`.
- Screen host: `IAPRouteHostView` maps `screenId` to `IAP01View`.

## 3. How IAP Is Opened
1. Call `IAPMTSDK.present(position: ...)`.
2. In `onIAP` callback, create `routeId`.
3. Save binding to `IAPRouteBindingStore.shared.set(binding, for: routeId)`.
4. Push route: `.iap(payload: .init(routeId: routeId, screenId: iapId))`.

Reference: `MT-Screens/Onboarding/Main/OnboardingContainer.swift`.

## 4. Implementing A New IAP Screen
1. Create new folder `IAPXX` with `IAPXXView` and `IAPXXContainer`.
2. Conform view to `IAPScreen` and set `static var screenId`.
3. Keep `@StateObject internal var binding: BaseIAPScreenBinding`.
4. Use SDK actions from binding:
- `binding.purchaseTapped(product:)`
- `binding.restore()`
- `binding.closeTapped()`
5. Register mapping in `IAPRouteHostView.iapView(screenId:binding:)`.

## 5. Terms/Privacy Flow (Common)
- Shared component: `MT-Screens/IAP/Common/IAPLegalSheet.swift`.
- Use `@State private var legalSheet: IAPLegalSheet?` in each IAP view.
- Present with `.fullScreenCover(item: $legalSheet) { IAPLegalFullScreenView(sheet: $0) }`.
- Open by assigning `.termsOfUse` or `.privacyPolicy`.

<!--## 6. Important Behaviors-->
<!--- IAP04 is full-screen dim overlay (`Color.Opacity.OP_4`) with bottom white panel.-->
<!--- IAP04 `No Thanks` posts `.didRequestFinishIAPFlow` via `IAP04Container`; onboarding listens and moves to main tabbar.-->
<!--- IAP03 countdown duration comes from `binding.payload.content?.countdownSale`, default `300` seconds.-->

## 7. Purchase-Gate Trigger Pattern (Outside IAP UI)
When gating a feature by IAP access, use:

```swift
let access = await IAPMTSDK.triggerWithPurchaseDebug(position: .your_position)
guard access == .allowed else { return }
```

Current position constants live in `Libs/IAPSDK/Position+Ext.swift`.
Note: some keys intentionally use `postion_` spelling (follow existing constant names exactly).

## 8. Purchased State Flag
- Persisted key: `UserDefaultManager.isAppPurchased`.
- Publisher: `UserDefaultManager.isAppPurchasedPublisher`.
- Use it to hide premium entry points and banners when user already purchased.

## 9. Quick Checklist Before Merge
1. New screen is mapped in `IAPRouteHostView`.
2. Terms/Privacy open via `IAPLegalFullScreenView`.
3. Close/purchase/restore actions are wired to `binding`.
4. Safe area behavior matches design (content and background checked separately).
5. Any feature gate uses correct `PositionID` constant.
