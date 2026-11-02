// Created by Vu The Anh

import Factory
import SwiftUI

/// Figma 13467:10823. Width decisions belong to this screen, not a device model.
struct TranslationDemoView: View {
    @StateObject var container: TranslationDemoContainer
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isEditing: Bool
    @State private var showsAPISample = false
    @State private var showsPaywall = false

    var body: some View {
        GeometryReader { geometry in
            // 400pt composer + 320pt supporting pane + margins and spacing.
            let isWide = geometry.size.width >= 800 && !dynamicTypeSize.isAccessibilitySize
            ScrollView {
                VStack(spacing: 8) {
                    header
                    languages
                        .frame(maxWidth: 560)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    adaptiveContent(isWide: isWide, height: geometry.size.height)
                }
                .frame(maxWidth: isWide ? 1120 : 600)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isWide ? 24 : 0)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
                .frame(maxWidth: 440)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity)
                .background(Color(.TranslationDemo.background).opacity(0.95))
        }
        .background(Color(.TranslationDemo.background).ignoresSafeArea())
        .tint(Color(.TranslationDemo.primary))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isEditing = false }
            }
        }
        .alert("UI preview", isPresented: Binding(
            get: { container.state.notice != nil },
            set: { if !$0 { container.send(.dismissNotice) } }
        )) {
            Button("OK") { container.send(.dismissNotice) }
        } message: {
            Text(container.state.notice ?? "")
        }
        .sheet(isPresented: $showsAPISample) {
            TranslationDemoAPISample()
        }
        .fullScreenCover(isPresented: $showsPaywall) {
            WallpaperPaywallDemoPresentation()
        }
        // This supplied node has a light palette; dark styling is a separate design.
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack {
            BaseButton(style: .plain, onSelect: { preview("Offline translation") }) {
                HStack(spacing: 2) {
                    icon(.TranslationDemo.airplane, size: 24)
                    label("Off", font: .interBold, size: 10)
                }
                .padding(.leading, 3)
                .padding(.trailing, 6)
                .padding(.vertical, 3)
                .background(Color(.QuickCreate.cardBorder), in: Capsule())
            }
            .accessibilityLabel("Offline translation, off. Preview")
            .frame(maxWidth: .infinity, alignment: .leading)

            label("Translate", font: .interSemiBold, size: 16)
                .accessibilityAddTraits(.isHeader)
                .layoutPriority(1)

            BaseButton(style: .plain, onSelect: {
                isEditing = false
                showsPaywall = true
            }) {
                icon(.TranslationDemo.settings, size: 24)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings")
            .accessibilityHint("Opens the IAP preview")
            .contextMenu {
                Button("About this UI preview") { preview("Translation, camera, voice and history") }
                Button("Open API sample") {
                    isEditing = false
                    showsAPISample = true
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 44)
    }

    private var languages: some View {
        HStack(spacing: 8) {
            languageMenu("From", value: container.state.sourceLanguage, isSource: true)
            BaseButton(image: Image(.TranslationDemo.swap), style: .plain) {
                container.send(.swapLanguages)
            }
            .frame(width: 24)
            .accessibilityLabel("Swap languages")
            languageMenu("To", value: container.state.targetLanguage, isSource: false)
        }
    }

    private func languageMenu(_ title: String, value: String, isSource: Bool) -> some View {
        Menu {
            Button("English") { chooseLanguage("English", isSource: isSource) }
            Button("Chinese") { chooseLanguage("Chinese", isSource: isSource) }
            Button("Vietnamese") { chooseLanguage("Vietnamese", isSource: isSource) }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                BaseText(title, font: .interLight, textColor: Color(.TranslationDemo.description), size: 10, lineSpacing: 0)
                HStack(spacing: 4) {
                    label(value, font: .interSemiBold, size: 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    icon(.TranslationDemo.chevron, size: 24)
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color(.QuickCreate.card), in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color(.TranslationDemo.shadow), radius: 6)
        }
        .accessibilityLabel("\(title): \(value)")
    }

    private func adaptiveContent(isWide: Bool, height: CGFloat) -> some View {
        let layout = isWide
            ? AnyLayout(HStackLayout(alignment: .top, spacing: 20))
            : AnyLayout(VStackLayout(spacing: 12))
        // AnyLayout keeps the same editor and Container alive across axis changes.
        return layout {
            composer(minHeight: max(300, height - (isWide ? 112 : 196)))
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: 20) {
                islandCard
                if isWide {
                    VStack(alignment: .leading, spacing: 8) {
                        label("Your space to translate", font: .interSemiBold, size: 24)
                        BaseText("Choose your languages and keep writing as you resize the window.",
                                 font: .interRegular, textColor: Color(.TranslationDemo.description), size: 16)
                        BaseText("UI preview · Translation tools are not connected.",
                                 font: .interRegular, textColor: Color(.TranslationDemo.description), size: 12)
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(width: isWide ? 320 : nil)
            .padding(.horizontal, isWide ? 0 : 20)
        }
    }

    private func composer(minHeight: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Text scrolls inside the editor; the outer scroll owns short-window access.
            BaseTextEditor(
                text: Binding(get: { container.state.draft }, set: { container.send(.edit($0)) }),
                font: .interSemiBold,
                textColor: Color(.TranslationDemo.headline),
                placeholderColor: Color(.TranslationDemo.disabled), size: 24,
                lineSpacing: 6
            )
            .focused($isEditing)
            .overlay(alignment: .topLeading) {
                if container.state.draft.isEmpty {
                    BaseText("Enter text...", font: .interSemiBold,
                             textColor: Color(.TranslationDemo.disabled), size: 24, lineSpacing: 6)
                        .padding(.top, 8)
                        .padding(.horizontal, 5)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel("Text to translate")
            .frame(height: minHeight - 122)
            .padding(.horizontal, 15)

            HStack {
                BaseButton(style: .plain, onSelect: { preview("Photo translation") }) {
                    Image(systemName: "photo.badge.plus.fill")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(Color(.TranslationDemo.headline))
                        .frame(width: 44, height: 44)
                        .background(Color(.TranslationDemo.background), in: RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Translate a photo. Preview")
                Spacer(minLength: 8)
                BaseButton(style: .plain, onSelect: { preview("Voice translation") }) {
                    icon(.TranslationDemo.microphone, size: 36.67)
                        .frame(width: 64, height: 64)
                        .background(Color(.TranslationDemo.primary), in: Circle())
                }
                .accessibilityLabel("Translate speech. Preview")
                Spacer(minLength: 8)
                BaseButton(style: .plain, onSelect: { preview("Camera translation") }) {
                    Image(.TranslationDemo.camera)
                        .resizable().scaledToFit()
                        .frame(width: 27.32, height: 21.33)
                        .frame(width: 44, height: 44)
                        .background(Color(.TranslationDemo.background), in: RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Translate with camera. Preview")
            }
            .frame(height: 66)
            .padding(.horizontal, 32)
        }
        .padding(.vertical, 24)
        .background(Color(.QuickCreate.card), in: RoundedRectangle(cornerRadius: 24))
    }

    private var islandCard: some View {
        Toggle(isOn: Binding(
            get: { container.state.islandPreviewEnabled },
            set: { container.send(.islandPreview($0)) }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                label("Dynamic Island", font: .interBold, size: 16)
                BaseText("Copy text from any app to translate", font: .interRegular,
                         textColor: Color(.TranslationDemo.description), size: 12, lineSpacing: 0)
            }
        }
        .toggleStyle(.switch)
        .accessibilityHint("Preview only. Does not enable a Live Activity or access the clipboard.")
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 68)
        .background(Color(.QuickCreate.card), in: RoundedRectangle(cornerRadius: 16))
    }

    private var bottomBar: some View {
        HStack(spacing: 4) {
            HStack(spacing: 0) {
                BaseButton(style: .plain, onSelect: { isEditing = true }) {
                    ViewThatFits(in: .horizontal) {
                        if !dynamicTypeSize.isAccessibilitySize {
                            HStack(spacing: 6) {
                                icon(.TranslationDemo.translate, size: 28)
                                BaseText("Translate", font: .interSemiBold,
                                         textColor: Color(.TranslationDemo.primary), size: 14, lineSpacing: 0)
                                    .fixedSize()
                            }
                        }
                        icon(.TranslationDemo.translate, size: 28)
                    }
                    .padding(.horizontal, 12)
                    .frame(minHeight: 52)
                    .background(Color(.TranslationDemo.selection), in: Capsule())
                }
                .accessibilityLabel("Translate")
                .accessibilityAddTraits(.isSelected)
                BaseButton(image: Image(.TranslationDemo.conversation), width: 28, height: 28,
                           style: .plain) { preview("Conversation") }
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Conversation. Preview")
                BaseButton(image: Image(.TranslationDemo.records), width: 28, height: 28,
                           style: .plain) { preview("History") }
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("History. Preview")
            }
            .padding(4)
            .modifier(TranslationDemoGlassSurface())

            BaseButton(style: .liquidAdaptive, liquidFrameSize: 60, onSelect: { preview("AI assistant") }) {
                icon(.TranslationDemo.magicWand, size: 28)
                    .frame(width: 60, height: 60)
            }
            .frame(width: 74, alignment: .trailing)
            .accessibilityLabel("AI assistant. Preview")
        }
    }

    private func label(_ text: String, font: AppFont, size: CGFloat) -> some View {
        BaseText(text, font: font, textColor: Color(.TranslationDemo.headline), size: size, lineSpacing: 0)
    }

    private func icon(_ resource: ImageResource, size: CGFloat) -> some View {
        Image(resource).resizable().scaledToFit().frame(width: size, height: size)
    }

    private func preview(_ name: String) {
        container.send(.previewAction(name))
    }

    private func chooseLanguage(_ language: String, isSource: Bool) {
        container.send(isSource ? .sourceLanguage(language) : .targetLanguage(language))
    }
}

private struct TranslationDemoGlassSurface: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *), Constant.isEnableLiquidGlass {
            content.glassEffect(.regular, in: .capsule)
        } else {
            content.background(.ultraThinMaterial, in: Capsule())
        }
    }
}

private struct TranslationDemoAPISample: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        RouterController.Stack {
            Container.shared.homeView()
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

#Preview("Phone · 375 × 812", traits: .fixedLayout(width: 375, height: 812)) {
    TranslationDemoView(container: TranslationDemoContainer())
}

#Preview("Wide window · 1024 × 768", traits: .fixedLayout(width: 1024, height: 768)) {
    TranslationDemoView(container: TranslationDemoContainer())
}

#Preview("Short window · 600 × 380", traits: .fixedLayout(width: 600, height: 380)) {
    TranslationDemoView(container: TranslationDemoContainer())
}

#Preview("Large text", traits: .fixedLayout(width: 375, height: 812)) {
    TranslationDemoView(container: TranslationDemoContainer())
        .environment(\.dynamicTypeSize, .accessibility3)
}
