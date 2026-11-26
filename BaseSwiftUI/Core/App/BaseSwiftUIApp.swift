//
//  BaseSwiftUIApp.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 24/7/26.
//

import SwiftUI

@main
@MainActor
struct BaseSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    private let diFactory = AppDIFactory()

    var body: some Scene {
        WindowGroup {
            ContentView(diFactory: diFactory)
        }
        .onChange(of: scenePhase) { _, phase in
            Log.info("App scene phase: \(phase)", category: "app-lifecycle")
        }
    }
}
