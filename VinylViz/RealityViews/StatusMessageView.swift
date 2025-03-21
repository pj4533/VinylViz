//
//  StatusMessageView.swift
//  VinylViz
//
//  Created by Claude on 3/21/25.
//

import SwiftUI

struct StatusMessageView: View {
    let audioMonitor: AudioInputMonitor
    let sessionError: Error?
    
    var body: some View {
        Group {
            if let message = audioMonitor.statusString {
                audioStatusMessage(message)
            } else if sessionError != nil {
                arkitErrorMessage()
            }
        }
    }
    
    private func audioStatusMessage(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .padding(12)
            .font(.title)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
            .opacity(audioMonitor.statusString != nil ? 1 : 0)
            .animation(.easeInOut, value: audioMonitor.statusString != nil)
    }
    
    private func arkitErrorMessage() -> some View {
        Label("ARKit error occurred", systemImage: "xmark.circle")
            .padding(12)
            .font(.title3)
            .foregroundColor(.red)
            .glassBackgroundEffect(in: .rect(cornerRadius: 50))
    }
}

#Preview {
    StatusMessageView(
        audioMonitor: {
            let monitor = AudioInputMonitor()
            monitor.statusString = "Test audio status message"
            return monitor
        }(),
        sessionError: nil
    )
}