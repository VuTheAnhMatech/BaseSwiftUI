//
//  CommonDataSourceView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 2/4/26.
//

import SwiftUI

protocol CommonDataSourceView: View {
    associatedtype Item
    associatedtype DataSourceType: BaseDataSource<Item>

    var dataSource: DataSourceType { get }
}
