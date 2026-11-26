// Created by Vu The Anh

import SwiftUI

struct HomeView: View {
    @StateObject var container: HomeContainer

    var body: some View {
        Text(container.state.title)
            .font(.largeTitle.bold())
            .accessibilityAddTraits(.isHeader)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .attachContainer(container)
    }
}

#Preview {
    HomeView(container: HomeContainer())
}
