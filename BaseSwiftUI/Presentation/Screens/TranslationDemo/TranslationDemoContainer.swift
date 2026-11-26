// Created by Vu The Anh

import Foundation

enum TranslationDemoFeature: MVIFeature {
    struct State: DefaultInitializable {
        var draft = ""
        var sourceLanguage = "English"
        var targetLanguage = "Chinese"
        var islandPreviewEnabled = false
        var notice: String?
    }

    enum Intent {
        case edit(String)
        case sourceLanguage(String)
        case targetLanguage(String)
        case swapLanguages
        case islandPreview(Bool)
        case previewAction(String)
        case dismissNotice
        case openPaywall
        case openAPISample
    }
    enum Effect {
        case navigate(AppRoute, PresentStyle)
    }
}

/// Local UI state only; this sample never translates, records, or reads the clipboard.
final class TranslationDemoContainer: BaseContainer<TranslationDemoFeature> {
    private var shouldShowInitialPaywall: Bool

    init(showPaywall: Bool = false) {
        shouldShowInitialPaywall = showPaywall
        super.init()
    }

    override func dispatchSystem(_ intent: SystemIntent) async {
        guard case .onAppear = intent, shouldShowInitialPaywall else { return }
        shouldShowInitialPaywall = false
        sendEffect(.navigate(.wallpaperPaywall, .modal))
    }

    override func dispatch(_ intent: TranslationDemoFeature.Intent) async {
        switch intent {
        case .openPaywall:
            sendEffect(.navigate(.wallpaperPaywall, .modal))
            return
        case .openAPISample:
            sendEffect(.navigate(.home, .sheet))
            return
        default: break
        }
        updateState { state in
            switch intent {
            case .edit(let text):
                state.draft = text
            case .sourceLanguage(let language):
                state.sourceLanguage = language
            case .targetLanguage(let language):
                state.targetLanguage = language
            case .swapLanguages:
                let source = state.sourceLanguage
                state.sourceLanguage = state.targetLanguage
                state.targetLanguage = source
            case .islandPreview(let enabled):
                state.islandPreviewEnabled = enabled
                if enabled {
                    state.notice = "Preview only. This switch does not start a Live Activity or read text from other apps."
                }
            case .previewAction(let name):
                state.notice = "\(name) is not connected in this UI preview. Your draft stays on this screen."
            case .dismissNotice:
                state.notice = nil
            case .openPaywall, .openAPISample:
                break
            }
        }
    }
}
