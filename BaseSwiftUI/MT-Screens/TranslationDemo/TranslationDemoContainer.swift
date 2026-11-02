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
    }
}

/// Local UI state only; this sample never translates, records, or reads the clipboard.
final class TranslationDemoContainer: BaseContainer<TranslationDemoFeature> {
    override func handleIntent(_ intent: TranslationDemoFeature.Intent) {
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
            }
        }
    }
}
