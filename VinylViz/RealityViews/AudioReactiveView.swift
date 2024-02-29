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
    @Environment(EntityModel.self) var model

    var effects: [AudioEffect] = [
        CloudsEffect(),
        MagicEffect()
    ]
    
    var body: some View {
        VStack {
            RealityView { content in
                if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                    content.add(scene)
                }
                content.add(model.contentEntity)
            } update: { content in
                for effect in self.effects {
                    effect.configure(content: content, using: self.audioMonitor)
                }
                model.configure(using: self.audioMonitor)
            }
            .task {
                do {
                    try await model.session.run([model.sceneReconstruction])
                } catch {
                    print("Failed to start session: \(error)")
                }
            }
            .task { //}(priority: .low) {
                await model.processReconstructionUpdates()
            }
            .opacity(audioMonitor.engineOn ? 1 : 0)
            .onChange(of: scenePhase, initial: true) { oldScenePhase, newScenePhase in
                switch newScenePhase {
                case .background:
                    // Code to run when the app is sent to the background
                    print("App is in the background.")
                    // Add your code here
                case .active:
                    // Code to run when the app becomes active
                    print("App is active.")
                    self.audioMonitor.startMonitoring()
                case .inactive:
                    // Code to run when the app becomes inactive
                    print("App is inactive.")
                    self.audioMonitor.stopMonitoring()
                @unknown default:
                    // A fallback for future cases not covered by the current enumeration
                    print("Unknown scene phase.")
                }
            }
//            .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
//                print("TAPPED")
//            })
            if let message = audioMonitor.statusString {
                Label(message, systemImage: "exclamationmark.triangle")
                    .padding(12)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .glassBackgroundEffect(in: .rect(cornerRadius: 50))
                    .opacity(audioMonitor.statusString != nil ? 1 : 0)
                    .animation(.easeInOut, value: audioMonitor.statusString != nil)
            }
        }
    }
}

#Preview {
    AudioReactiveView()
}
