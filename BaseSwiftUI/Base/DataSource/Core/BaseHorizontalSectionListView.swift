//
//  BaseHorizontalSectionListView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 28/5/26.
//

import SwiftUI

struct BaseHorizontalSectionListView<
    SectionItem,
    HorizontalItem,
    HeaderContent: View,
    ItemContent: View,
    DataSourceType: BaseDataSource<SectionItem>
>: View where SectionItem: Identifiable, HorizontalItem: Identifiable {

    @ObservedObject var dataSource: DataSourceType
    let sectionSpacing: CGFloat
    let headerToItemsSpacing: CGFloat
    let horizontalSpacing: CGFloat
    let verticalShowsIndicators: Bool
    let horizontalShowsIndicators: Bool
    let contentInsets: EdgeInsets
    let items: (SectionItem) -> [HorizontalItem]
    let header: (SectionItem) -> HeaderContent
    let itemContent: (HorizontalItem) -> ItemContent
    let onSelectItem: ((SectionItem, HorizontalItem) -> Void)?

    init(
        dataSource: DataSourceType,
        sectionSpacing: CGFloat = 0,
        headerToItemsSpacing: CGFloat = 16,
        horizontalSpacing: CGFloat = 8,
        verticalShowsIndicators: Bool = false,
        horizontalShowsIndicators: Bool = false,
        contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
        items: @escaping (SectionItem) -> [HorizontalItem],
        onSelectItem: ((SectionItem, HorizontalItem) -> Void)? = nil,
        @ViewBuilder header: @escaping (SectionItem) -> HeaderContent,
        @ViewBuilder itemContent: @escaping (HorizontalItem) -> ItemContent
    ) {
        self.dataSource = dataSource
        self.sectionSpacing = sectionSpacing
        self.headerToItemsSpacing = headerToItemsSpacing
        self.horizontalSpacing = horizontalSpacing
        self.verticalShowsIndicators = verticalShowsIndicators
        self.horizontalShowsIndicators = horizontalShowsIndicators
        self.contentInsets = contentInsets
        self.items = items
        self.onSelectItem = onSelectItem
        self.header = header
        self.itemContent = itemContent
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: verticalShowsIndicators) {
            LazyVStack(alignment: .leading, spacing: sectionSpacing) {
                ForEach(Array(dataSource.listItem.enumerated()), id: \.element.id) { sectionIndex, section in
                    VStack(alignment: .leading, spacing: headerToItemsSpacing) {
                        header(section)
                            .padding(.leading, contentInsets.leading)
                            .padding(.trailing, contentInsets.trailing)

                        ScrollView(.horizontal, showsIndicators: horizontalShowsIndicators) {
                            LazyHStack(spacing: horizontalSpacing) {
                                ForEach(items(section)) { item in
                                    itemContent(item)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            onSelectItem?(section, item)
                                        }
                                }
                            }
                            .padding(.leading, contentInsets.leading)
                            .padding(.trailing, contentInsets.trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onAppear {
                        dataSource.itemDidAppear(at: IndexPath(row: sectionIndex, section: 0))
                    }
                }
            }
            .padding(.bottom, contentInsets.bottom)
        }
    }
}
