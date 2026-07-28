//
//  MVIFeature.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 7/4/26.
//

public protocol MVIFeature {
    associatedtype State: DefaultInitializable
    associatedtype Intent
}
