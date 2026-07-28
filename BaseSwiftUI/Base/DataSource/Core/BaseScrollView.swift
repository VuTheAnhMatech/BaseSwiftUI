//
//  BaseScrollView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 2/4/26.
//

import SwiftUI

struct BaseScrollView<
    Item,
    Content: View,
    DataSourceType: BaseDataSource<Item>
>: View where Item: Identifiable {

    enum AxisMode {
        case vertical
        case horizontal
    }

    @ObservedObject var dataSource: DataSourceType
    let axis: AxisMode
    let spacing: CGFloat
    let showsIndicators: Bool
    let contentInsets: EdgeInsets
    let scrollTargetId: Item.ID?
    let scrollTargetAnchor: UnitPoint?
    let content: (Item) -> Content
    let onSelect: ((Item) -> Void)?

    init(
        dataSource: DataSourceType,
        axis: AxisMode = .vertical,
        spacing: CGFloat = 12,
        showsIndicators: Bool = false,
        contentInsets: EdgeInsets = EdgeInsets(),
        scrollTargetId: Item.ID? = nil,
        scrollTargetAnchor: UnitPoint? = nil,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.dataSource = dataSource
        self.axis = axis
        self.spacing = spacing
        self.showsIndicators = showsIndicators
        self.contentInsets = contentInsets
        self.scrollTargetId = scrollTargetId
        self.scrollTargetAnchor = scrollTargetAnchor
        self.onSelect = onSelect
        self.content = content
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(axis == .vertical ? .vertical : .horizontal, showsIndicators: showsIndicators) {
                if axis == .vertical {
                    LazyVStack(spacing: spacing) {
                        cells
                    }
                    .padding(contentInsets)
                } else {
                    LazyHStack(spacing: spacing) {
                        cells
                    }
                    .padding(contentInsets)
                }
            }
            .scrollIndicators(showsIndicators ? .visible : .hidden)
            .scrollIndicatorsFlash(onAppear: showsIndicators)
            .onAppear {
                scrollToTarget(with: proxy, animated: false)
            }
            .onChange(of: scrollTargetId) { _, _ in
                scrollToTarget(with: proxy, animated: true)
            }
        }
    }

    @ViewBuilder
    private var cells: some View {
        ForEach(Array(dataSource.listItem.enumerated()), id: \.element.id) { index, item in
            content(item)
                .id(item.id)
                .contentShape(Rectangle())
                .onTapGesture {
                    let indexPath = IndexPath(row: index, section: 0)
                    dataSource.selectedItem(at: indexPath)
                    onSelect?(item)
                }
                .onAppear {
                    let indexPath = IndexPath(row: index, section: 0)
                    dataSource.itemDidAppear(at: indexPath)
                }
        }
    }

    private func scrollToTarget(with proxy: ScrollViewProxy, animated: Bool) {
        guard let scrollTargetId else { return }

        let action = {
            proxy.scrollTo(scrollTargetId, anchor: scrollTargetAnchor)
        }

        if animated {
            withAnimation(.smooth(duration: 0.24)) {
                action()
            }
        } else {
            action()
        }
    }
}
