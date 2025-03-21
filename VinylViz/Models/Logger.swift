//
//  Logger.swift
//  VinylViz
//
//  Created by Claude on 3/21/25.
//

import Foundation
import OSLog

/// Centralized logging system for VinylViz using Apple's unified logging (OSLog)
enum Logger {
    /// Logger for audio subsystem (input monitoring, engine, etc.)
    static let audio = OSLog(subsystem: "com.saygoodnight.VinylViz", category: "Audio")
    
    /// Logger for AR/VR session management
    static let session = OSLog(subsystem: "com.saygoodnight.VinylViz", category: "Session")
    
    /// Logger for visual effects (clouds, magic, etc.)
    static let effects = OSLog(subsystem: "com.saygoodnight.VinylViz", category: "Effects")
    
    /// Logger for UI components
    static let ui = OSLog(subsystem: "com.saygoodnight.VinylViz", category: "UI")
    
    /// Logger for general app lifecycle events
    static let app = OSLog(subsystem: "com.saygoodnight.VinylViz", category: "App")
    
    /// Extension methods for easier logging
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