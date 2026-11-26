// Created by Vu The Anh

import SwiftUI

struct ContentView: View {
    let diFactory: AppDIFactory

    var body: some View {
        AppNavigationHost(diFactory: diFactory)
    }
}

#Preview {
    ContentView(diFactory: AppDIFactory())
}
