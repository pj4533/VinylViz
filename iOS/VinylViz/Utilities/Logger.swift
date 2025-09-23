//
//  Logger.swift
//  VinylViz
//
//  Created for iOS implementation of VinylViz
//

import Foundation
import OSLog

/// Centralized logging system for VinylViz iOS using Apple's unified logging (OSLog)
enum Logger {
    /// Logger for audio subsystem (engine, buffer processing, session management)
    static let audio = OSLog(subsystem: "com.saygoodnight.VinylViz.iOS", category: "Audio")

    /// Logger for ShazamKit integration (song identification, match processing)
    static let shazamKit = OSLog(subsystem: "com.saygoodnight.VinylViz.iOS", category: "ShazamKit")

    /// Logger for UI components (view updates, user interactions)
    static let ui = OSLog(subsystem: "com.saygoodnight.VinylViz.iOS", category: "UI")

    /// Logger for general app lifecycle events and permissions
    static let app = OSLog(subsystem: "com.saygoodnight.VinylViz.iOS", category: "App")

    /// Extension methods for easier logging with appropriate levels
    enum Level {
        /// For debug information during development
        static func debug(_ message: String, log: OSLog) {
            os_log(.debug, log: log, "%{public}@", message)
        }

        /// For standard info that might be useful in understanding app flow
        static func info(_ message: String, log: OSLog) {
            os_log(.info, log: log, "%{public}@", message)
        }

        /// For important events that aren't errors
        static func notice(_ message: String, log: OSLog) {
            os_log(.default, log: log, "%{public}@", message)
        }

        /// For issues that don't prevent functionality but may indicate problems
        static func warning(_ message: String, log: OSLog) {
            os_log(.error, log: log, "⚠️ %{public}@", message)
        }

        /// For errors that may impact functionality
        static func error(_ message: String, log: OSLog) {
            os_log(.error, log: log, "❌ %{public}@", message)
        }

        /// For critical errors that prevent core functionality
        static func fault(_ message: String, log: OSLog) {
            os_log(.fault, log: log, "🔥 %{public}@", message)
        }
    }
}