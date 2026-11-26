// Created by Vu The Anh

import SwiftUI

/// Decorative canvas: four Figma tracks, 24 images, 1,290pt travel per 30s loop.
/// Drawing only the visible cards avoids a hierarchy of continuously moving Views.
struct WallpaperPaywallArtwork: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var startedAt = Date()

    private let images: [Image] = [
        Image(.WallpaperPaywall.art00), Image(.WallpaperPaywall.art01),
        Image(.WallpaperPaywall.art02), Image(.WallpaperPaywall.art03),
        Image(.WallpaperPaywall.art04), Image(.WallpaperPaywall.art05),
        Image(.WallpaperPaywall.art06), Image(.WallpaperPaywall.art07),
        Image(.WallpaperPaywall.art08), Image(.WallpaperPaywall.art09),
        Image(.WallpaperPaywall.art10), Image(.WallpaperPaywall.art11),
        Image(.WallpaperPaywall.art12), Image(.WallpaperPaywall.art13),
        Image(.WallpaperPaywall.art14), Image(.WallpaperPaywall.art15),
        Image(.WallpaperPaywall.art16), Image(.WallpaperPaywall.art17),
        Image(.WallpaperPaywall.art18), Image(.WallpaperPaywall.art19),
        Image(.WallpaperPaywall.art20), Image(.WallpaperPaywall.art21),
        Image(.WallpaperPaywall.art22), Image(.WallpaperPaywall.art23)
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion || scenePhase != .active)) { timeline in
            Canvas { context, size in
                let elapsed = reduceMotion ? 0 : timeline.date.timeIntervalSince(startedAt)
                let distance = CGFloat(elapsed.truncatingRemainder(dividingBy: 30) * 43)
                let columns = max(4, Int(ceil(size.width / 104)))
                let originX = (size.width - CGFloat(columns * 104 - 8)) / 2
                let starts: [CGFloat] = [-227, -90.5, -194, -122]
                for column in 0..<columns {
                    let track = column % 4
                    let direction: CGFloat = track.isMultiple(of: 2) ? 1 : -1
                    for row in 0..<6 {
                        let initial = starts[track] + CGFloat(row * 215)
                        let phase = (initial + direction * distance + 287).truncatingRemainder(dividingBy: 1290)
                        let y = (phase < 0 ? phase + 1290 : phase) - 287
                        let rect = CGRect(x: originX + CGFloat(column * 104), y: y, width: 96, height: 207)
                        guard rect.maxY > 0, rect.minY < size.height else { continue }
                        let path = RoundedRectangle(cornerRadius: 16).path(in: rect)
                        var tile = context
                        tile.clip(to: path)
                        tile.draw(images[track * 6 + row], in: rect)
                        context.stroke(path, with: .color(Color(.WallpaperPaywall.artworkBorder)), lineWidth: 1)
                    }
                }
            }
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
