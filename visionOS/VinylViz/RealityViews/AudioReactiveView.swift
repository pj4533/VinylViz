//
//  AudioReactiveView.swift
//  VinylViz
//
//  Created by PJ Gray on 2/22/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import OSLog

struct AudioReactiveView: View {
    @ObservedObject var audioMonitor = AudioInputMonitor()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SessionManager.self) var model
    
    var effects: [AudioEffect] = [
        CloudsEffect(),
        MagicEffect()
    ]
    
    var body: some View {
        VStack {
            AudioSceneView(
                audioMonitor: audioMonitor, 
                model: model, 
                effects: effects
            )
            .opacity(audioMonitor.engineOn ? 1 : 0)
            .onChange(of: scenePhase, initial: true) { oldScenePhase, newScenePhase in
                handleScenePhaseChange(from: oldScenePhase, to: newScenePhase)
            }
            
            StatusMessageView(
                audioMonitor: audioMonitor,
                sessionError: model.sessionError
            )
        }
    }
    
    private func handleScenePhaseChange(from oldScenePhase: ScenePhase, to newScenePhase: ScenePhase) {
        switch newScenePhase {
        case .background:
            Logger.Level.info("App is in the background", log: Logger.app)
            Task {
                await model.stopSession()
            }
            self.audioMonitor.stopMonitoring()
        case .active:
            Logger.Level.info("App is active", log: Logger.app)
            self.audioMonitor.startMonitoring()
        case .inactive:
            Logger.Level.info("App is inactive", log: Logger.app)
            Task {
                await model.stopSession()
            }
            self.audioMonitor.stopMonitoring()
        @unknown default:
            Logger.Level.warning("Unknown scene phase detected", log: Logger.app)
        }
    }
}

#Preview {
    AudioReactiveView()
}