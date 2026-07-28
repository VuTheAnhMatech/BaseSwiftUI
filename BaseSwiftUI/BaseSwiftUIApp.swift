//
//  BaseSwiftUIApp.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import SwiftUI

@main
struct BaseSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
