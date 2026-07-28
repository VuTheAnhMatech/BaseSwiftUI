//
//  BaseView.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 3/6/26.
//

import SwiftUI
import WebKit

struct BaseView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .onDisappear {

            }
    }
}

struct BaseLocalHTMLWebView: UIViewRepresentable {
    let fileName: String
    let subdirectory: String
    let fileExtension: String

    init(fileName: String, subdirectory: String, fileExtension: String = "html") {
        self.fileName = fileName
        self.subdirectory = subdirectory
        self.fileExtension = fileExtension
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
        webView.isOpaque = true

        if let fileURL = Bundle.main.url(
            forResource: fileName,
            withExtension: fileExtension,
            subdirectory: subdirectory
        ) ?? Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

extension View {
    func baseAlert(
        title: String,
        message: String,
        isPresented: Binding<Bool>,
        primaryTitle: String,
        primaryRole: ButtonRole? = nil,
        primaryAction: @escaping () -> Void,
        secondaryTitle: String,
        secondaryRole: ButtonRole? = nil,
        secondaryAction: @escaping () -> Void
    ) -> some View {
        alert(title, isPresented: isPresented) {
            Button(primaryTitle, role: primaryRole, action: primaryAction)
            Button(secondaryTitle, role: secondaryRole, action: secondaryAction)
        } message: {
            Text(message)
        }
    }
    
    func baseAlert(
        title: String,
        message: String,
        isPresented: Binding<Bool>,
        primaryTitle: String,
        primaryRole: ButtonRole? = nil,
        primaryAction: @escaping () -> Void
    ) -> some View {
        alert(title, isPresented: isPresented) {
            Button(primaryTitle, role: primaryRole, action: primaryAction)
        } message: {
            Text(message)
        }
    }
}
