// Created by Vu The Anh

import SwiftUI

struct WallpaperPaywallView: View {
    @StateObject var container: WallpaperPaywallContainer
    let onClose: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var panelHeight: CGFloat = 0
    @ScaledMetric(relativeTo: .caption) private var legalLineHeight: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            // 340pt of artwork + 360pt readable purchase panel + 80pt margins.
            let isWide = geometry.size.width >= 780 && !dynamicTypeSize.isAccessibilitySize
            // Reserve the close button's touch area. Decorative space can collapse.
            let topClearance: CGFloat = 64
            let needsScrolling = ceil(panelHeight + topClearance) > floor(geometry.size.height)
            ZStack(alignment: .topLeading) {
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        content
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .fixedSize(horizontal: false, vertical: true)
                            .background {
                                GeometryReader { panel in
                                    Color.clear.preference(key: PaywallPanelHeightKey.self,
                                                           value: panel.size.height)
                                }
                            }
                    }
                    .frame(maxWidth: isWide ? 400 : 440)
                    .padding(.top, topClearance)
                    .frame(minHeight: geometry.size.height, alignment: .bottom)
                    .frame(maxWidth: .infinity, alignment: isWide ? .trailing : .center)
                    .padding(.horizontal, isWide ? 40 : 0)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .scrollDisabled(!needsScrolling)
                .onPreferenceChange(PaywallPanelHeightKey.self) { panelHeight = $0 }

                BaseButton(style: .plain, onSelect: { container.send(.close) }) {
                    Image(.WallpaperPaywall.close)
                        .resizable().scaledToFit().frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                        .background(Color(.WallpaperPaywall.closeSurface), in: Circle())
                }
                .frame(minWidth: 44, minHeight: 44)
                .padding(.leading, 14)
                .accessibilityLabel("Close preview")
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background {
                background(isWide: isWide, scrimHeight: min(panelHeight + 80, geometry.size.height)
                           + geometry.safeAreaInsets.bottom)
                    .ignoresSafeArea()
            }
        }
        .background(Color(.WallpaperPaywall.surface))
        .preferredColorScheme(.dark)
        .alert("UI preview", isPresented: Binding(
            get: { container.state.notice != nil },
            set: { if !$0 { container.send(.dismissNotice) } }
        )) {
            Button("OK") { container.send(.dismissNotice) }
        } message: {
            Text(container.state.notice ?? "")
        }
        .onChange(of: container.state.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss { onClose() }
        }
    }

    private func background(isWide: Bool, scrimHeight: CGFloat) -> some View {
        // An overlay cannot enlarge its owner. Clip to the proposed full-screen
        // bounds, not the scaled image's intrinsic overflow, during dismissal.
        Color(.WallpaperPaywall.surface)
            .overlay {
                GeometryReader { viewport in
                    ZStack {
                        Image(.WallpaperPaywall.texture)
                            .resizable().scaledToFill().opacity(0.32)
                            .frame(width: viewport.size.width, height: viewport.size.height)
                            .clipped()
                        WallpaperPaywallArtwork()
                        if isWide {
                            LinearGradient(stops: [
                                .init(color: Color(.color000000).opacity(0), location: 0),
                                .init(color: Color(.color000000).opacity(0.4), location: 0.3),
                                .init(color: Color(.color000000), location: 0.52)
                            ], startPoint: .leading, endPoint: .trailing)
                        } else {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                LinearGradient(stops: [
                                    .init(color: Color(.color000000).opacity(0), location: 0),
                                    .init(color: Color(.color000000), location: 0.14)
                                ], startPoint: .top, endPoint: .bottom)
                                .frame(height: min(scrimHeight, viewport.size.height))
                            }
                            // Decorations cover lateral safe areas too; controls
                            // keep the asymmetric insets supplied by the device.
                            .frame(width: viewport.size.width, height: viewport.size.height)
                        }
                    }
                    .frame(width: viewport.size.width, height: viewport.size.height)
                    .clipped()
                }
            }
            .clipped()
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }

    private var content: some View {
        VStack(spacing: 0) {
            BaseText("Save Without Limits", font: .plusJakartaSansBold,
                     textColor: Color(.QuickCreate.card), size: 28, lineSpacing: 0)
                .tracking(0.42)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            benefits
                .padding(.top, 12)
                .padding(.bottom, 28)

            VStack(spacing: 12) {
                plan(.weekly)
                plan(.yearly)
            }

            BaseText("Secured with Apple Store. Cancel anytime", font: .plusJakartaSansRegular,
                     textColor: Color(.WallpaperPaywall.caption), size: 12, lineSpacing: 0)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.bottom, 8)

            // Figma: CTA bottom 66, legal bottom 28 + height 24 => 14pt gap.
            // This is sibling spacing; the legal container has no top padding.
            VStack(spacing: 14) {
                BaseButton(style: .plain, onSelect: { container.send(.continuePreview) }) {
                    BaseText("Continue", font: .plusJakartaSansSemiBold,
                             textColor: Color(.WallpaperPaywall.surface), size: 18, lineSpacing: 0)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color(.WallpaperPaywall.primary), in: Capsule())
                }
                .accessibilityHint("Sample prices. Opens a preview notice; no purchase is made.")

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 24) { legalLinks }
                    VStack(spacing: 0) { legalLinks }
                }
            }
        }
    }

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 8) {
            benefit("All Premium Wallpapers") {
                Image(.WallpaperPaywall.wallpaper).resizable().scaledToFit().frame(width: 14, height: 14)
            }
            benefit("Stunning 4K Quality") {
                BaseText("4K", font: .plusJakartaSansSemiBold, textColor: Color(.QuickCreate.card), size: 10, lineSpacing: 0)
            }
            benefit("Exclusive Funny Smile Designs") {
                Image(.WallpaperPaywall.smile).resizable().scaledToFit().frame(width: 14, height: 8.47)
            }
            benefit("100% No Ads") {
                Image(.WallpaperPaywall.noAds).resizable().scaledToFit().frame(width: 12.25, height: 12.25)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func benefit<Icon: View>(_ title: String, @ViewBuilder icon: () -> Icon) -> some View {
        HStack(spacing: 8) {
            icon()
                .frame(width: 24, height: 24)
                .background(Color(.WallpaperPaywall.panel), in: Circle())
                .accessibilityHidden(true)
            BaseText(title, font: .plusJakartaSansRegular,
                     textColor: Color(.WallpaperPaywall.body), size: 14, lineSpacing: 0)
        }
        .accessibilityElement(children: .combine)
    }

    private func plan(_ plan: WallpaperPaywallPlan) -> some View {
        let isSelected = container.state.selectedPlan == plan
        return BaseButton(style: .plain, onSelect: { container.send(.select(plan)) }) {
            HStack(spacing: 12) {
                Image(isSelected ? .WallpaperPaywall.selected : .WallpaperPaywall.unselected)
                    .resizable().scaledToFit().frame(width: 24, height: 24)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    BaseText(plan.samplePrice, font: .plusJakartaSansSemiBold,
                             textColor: Color(.WallpaperPaywall.headline), size: 16, lineSpacing: 0)
                    BaseText(plan.samplePeriod, font: .plusJakartaSansRegular,
                             textColor: Color(.WallpaperPaywall.body), size: 14, lineSpacing: 0)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(Color(.WallpaperPaywall.panel), in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color(isSelected ? .WallpaperPaywall.primary : .WallpaperPaywall.border), lineWidth: 1)
            }
            .overlay(alignment: .topTrailing) {
                if plan == .weekly {
                    BaseText("Best Deal", font: .plusJakartaSansSemiBold,
                             textColor: Color(.WallpaperPaywall.surface), size: 12, lineSpacing: 0)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.WallpaperPaywall.primary), in: RoundedRectangle(cornerRadius: 7))
                        .padding(.trailing, 16)
                        .offset(y: -12)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(plan.samplePeriod), \(plan.samplePrice), sample price")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }

    @ViewBuilder
    private var legalLinks: some View {
        legalLink("Terms of Use") { container.send(.legalPreview("Terms of Use")) }
        legalLink("Restore") { container.send(.restorePreview) }
        legalLink("Privacy Policy") { container.send(.legalPreview("Privacy Policy")) }
    }

    private func legalLink(_ title: String, action: @escaping () -> Void) -> some View {
        // BaseButton adds a 40pt minimum, incompatible with this 24pt Figma row.
        Button(action: action) {
            Text(title)
                .font(.custom(AppFont.plusJakartaSansRegular.rawValue, size: 12))
                .foregroundStyle(Color(.WallpaperPaywall.legal))
                .underline()
                .fixedSize()
                .frame(minWidth: 88, minHeight: legalLineHeight)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct PaywallPanelHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview("Compact paywall", traits: .fixedLayout(width: 390, height: 844)) {
    WallpaperPaywallView(container: WallpaperPaywallContainer(), onClose: {})
}

#Preview("Wide paywall", traits: .fixedLayout(width: 1024, height: 768)) {
    WallpaperPaywallView(container: WallpaperPaywallContainer(), onClose: {})
}
