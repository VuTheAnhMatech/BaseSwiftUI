//
//  BaseFlowView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 14/7/26.
//

import SwiftUI

struct BaseFlowView<
    Item,
    Content: View,
    DataSourceType: BaseDataSource<Item>
>: View where Item: Identifiable {
    @ObservedObject var dataSource: DataSourceType
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let onSelect: ((Item) -> Void)?
    let content: (Item) -> Content

    init(
        dataSource: DataSourceType,
        horizontalSpacing: CGFloat = 8,
        verticalSpacing: CGFloat = 8,
        onSelect: ((Item) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.dataSource = dataSource
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.onSelect = onSelect
        self.content = content
    }

    var body: some View {
        FlowLayout(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
            ForEach(Array(dataSource.listItem.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dataSource.selectedItem(at: IndexPath(row: index, section: 0))
                        onSelect?(item)
                    }
                    .onAppear {
                        dataSource.itemDidAppear(at: IndexPath(row: index, section: 0))
                    }
            }
        }
    }
}

private struct FlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        layout(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = layout(in: bounds.width, subviews: subviews).rows

        for row in rows {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.origin.x, y: bounds.minY + item.origin.y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private func layout(in maxWidth: CGFloat, subviews: Subviews) -> (rows: [FlowRow], size: CGSize) {
        var rows: [FlowRow] = []
        var currentRow = FlowRow(items: [], width: 0, height: 0)

        for index in subviews.indices {
            let itemSize = subviews[index].sizeThatFits(.unspecified)
            let nextWidth = currentRow.items.isEmpty ? itemSize.width : currentRow.width + horizontalSpacing + itemSize.width

            if currentRow.items.isEmpty == false && nextWidth > maxWidth {
                rows.append(currentRow)
                currentRow = FlowRow(items: [], width: 0, height: 0)
            }

            let originX = currentRow.items.isEmpty ? 0 : currentRow.width + horizontalSpacing
            currentRow.items.append(FlowItem(index: index, origin: CGPoint(x: originX, y: 0), size: itemSize))
            currentRow.width = currentRow.items.isEmpty ? itemSize.width : originX + itemSize.width
            currentRow.height = max(currentRow.height, itemSize.height)
        }

        if currentRow.items.isEmpty == false {
            rows.append(currentRow)
        }

        var y: CGFloat = 0
        for rowIndex in rows.indices {
            for itemIndex in rows[rowIndex].items.indices {
                rows[rowIndex].items[itemIndex].origin.y = y
            }
            y += rows[rowIndex].height
            if rowIndex < rows.count - 1 {
                y += verticalSpacing
            }
        }

        let width = rows.map(\.width).max() ?? 0
        return (rows, CGSize(width: width, height: y))
    }
}

private struct FlowRow {
    var items: [FlowItem]
    var width: CGFloat
    var height: CGFloat
}

private struct FlowItem {
    let index: Int
    var origin: CGPoint
    let size: CGSize
}
