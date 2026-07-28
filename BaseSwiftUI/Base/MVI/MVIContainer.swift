//
//  MVIContainer.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 6/4/26.
//

import SwiftUI
import Combine

public protocol MVIContainer: ObservableObject {
    associatedtype F: MVIFeature
    
    var state: F.State { get }
    func send(_ intent: F.Intent)
}
