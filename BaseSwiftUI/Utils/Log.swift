// Created by Vu The Anh

import OSLog
import Foundation

enum Log {
    static func debug(_ message: String, category: String = "app") {
        logger(category).debug("\(message, privacy: .private)")
    }
    static func info(_ message: String, category: String = "app") {
        logger(category).info("\(message, privacy: .private)")
    }
    static func error(_ message: String, category: String = "app") {
        logger(category).error("\(message, privacy: .private)")
    }
    private static func logger(_ category: String) -> Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "BaseSwiftUI", category: category)
    }
}
