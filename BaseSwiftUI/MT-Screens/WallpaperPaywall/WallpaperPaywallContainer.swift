// Created by Vu The Anh

import Foundation

enum WallpaperPaywallFeature: MVIFeature {
    struct State: DefaultInitializable {
        var selectedPlan: WallpaperPaywallPlan = .weekly
        var notice: String?
        var shouldDismiss = false
    }

    enum Intent {
        case select(WallpaperPaywallPlan)
        case continuePreview
        case restorePreview
        case legalPreview(String)
        case dismissNotice
        case close
    }
}

/// No purchase SDK, account, entitlement or clipboard access in this visual demo.
final class WallpaperPaywallContainer: BaseContainer<WallpaperPaywallFeature> {
    override func handleIntent(_ intent: WallpaperPaywallFeature.Intent) {
        updateState { state in
            switch intent {
            case .select(let plan):
                state.selectedPlan = plan
            case .continuePreview:
                state.notice = "Selected: \(state.selectedPlan.samplePeriod), \(state.selectedPlan.samplePrice). These are sample prices from the design. No purchase will be made."
            case .restorePreview:
                state.notice = "Restore is not connected in this UI preview. No subscription or purchase status has changed."
            case .legalPreview(let name):
                state.notice = "\(name) has no configured URL in this UI preview."
            case .dismissNotice:
                state.notice = nil
            case .close:
                state.shouldDismiss = true
            }
        }
    }
}
