//
//  ContentView.swift
//  VinylViz
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @ObservedObject var audioMonitor = AudioInputMonitor()
    @Environment(\.scenePhase) private var scenePhase
    
    var effects: [AudioEffect] = [
        CloudsEffect(),
        MagicEffect()
    ]
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
//            print("AUDIO LEVEL: \(self.audioMonitor.inputLevel)")
            for effect in self.effects {
                effect.configure(content: content, using: self.audioMonitor)
            }
        }
        .onChange(of: scenePhase, initial: false) { newScenePhase, _ in
            switch newScenePhase {
            case .background:
                // Code to run when the app is sent to the background
                print("App is in the background.")
                // Add your code here
            case .active:
                // Code to run when the app becomes active
                print("App is active.")
            case .inactive:
                // Code to run when the app becomes inactive
                print("App is inactive.")
                self.audioMonitor.toggleMonitoring()
            @unknown default:
                // A fallback for future cases not covered by the current enumeration
                print("Unknown scene phase.")
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                print("STARTING MONITOR")
                self.audioMonitor.startMonitoring()
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            print("TAPPED")
        })
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
