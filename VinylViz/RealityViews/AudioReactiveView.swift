//
//  AudioReactiveView.swift
//  VinylViz
//
//  Created by PJ Gray on 2/22/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

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
            print("App is in the background.")
            Task {
                await model.stopSession()
            }
            self.audioMonitor.stopMonitoring()
        case .active:
            print("App is active.")
            self.audioMonitor.startMonitoring()
        case .inactive:
            print("App is inactive.")
            Task {
                await model.stopSession()
            }
            self.audioMonitor.stopMonitoring()
        @unknown default:
            print("Unknown scene phase.")
        }
    }
}

#Preview {
    AudioReactiveView()
}