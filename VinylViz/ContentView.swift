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
            print("AUDIO LEVEL: \(self.audioMonitor.inputLevel)")
            for effect in self.effects {
                effect.configure(content: content, using: self.audioMonitor)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
