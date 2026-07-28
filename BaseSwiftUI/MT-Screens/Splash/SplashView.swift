//
//  SplashView.swift
//  BaseSwiftUI
//
//  Created by Codex on 28/7/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isPresented = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.accentColor,
                    Color.accentColor.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "swift")
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 112, height: 112)
                    .background(.white, in: RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.16), radius: 24, y: 12)

                VStack(spacing: 8) {
                    Text("BaseSwiftUI")
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    Text("Build beautifully. Move quickly.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .opacity(0.8)
                }
                .foregroundStyle(.white)
            }
            .scaleEffect(isPresented ? 1 : 0.88)
            .opacity(isPresented ? 1 : 0)

            VStack {
                Spacer()

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.1)
                    .padding(.bottom, 44)
            }
            .opacity(isPresented ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.72)) {
                isPresented = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("BaseSwiftUI is starting")
    }
}

#Preview {
    SplashView()
}
