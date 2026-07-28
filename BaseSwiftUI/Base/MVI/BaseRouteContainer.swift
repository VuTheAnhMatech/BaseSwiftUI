//
//  BaseRouteContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 13/4/26.
//

import Combine
import Factory
import SwiftUI

open class BaseRouteContainer<F: MVIFeature, R: AppRoute>: BaseContainer<F> {
    public weak var router: AppRouter<R>.StackController!
    public var updateCurrentSheetPresentation: ((Set<PresentationDetent>) -> Void)?
}
