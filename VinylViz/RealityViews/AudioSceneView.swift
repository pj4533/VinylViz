//
//  AudioSceneView.swift
//  VinylViz
//
//  Created by Claude on 3/21/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct AudioSceneView: View {
    let audioMonitor: AudioInputMonitor
    let model: SessionManager
    let effects: [AudioEffect]
    
    var body: some View {
        RealityView { content in
            initializeScene(content: content)
        } update: { content in
            applyEffects(content: content)
            updatePlaneEntities()
        }
        .task {
            await startARSession()
        }
        .task {
            await model.processReconstructionUpdates()
        }
        .task {
            await model.processPlaneDetectionUpdates()
        }
    }
    
    private func initializeScene(content: RealityViewContent) {
        Task {
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
            
            if let entity = content.entities.first?.findEntity(named: "CustomMaterialCube") {
                if let modelComponent = entity.components[ModelComponent.self] {
                    model.customMaterial = modelComponent.materials.first as? ShaderGraphMaterial
                } else {
                    print("could not find component")
                }
            } else {
                print("could not find geometry material cube")
            }
            
            content.add(model.contentEntity)
        }
    }
    
    private func applyEffects(content: RealityViewContent) {
        for effect in self.effects {
            effect.configure(content: content, using: self.audioMonitor)
        }
    }
    
    private func updatePlaneEntities() {
        guard audioMonitor.engineOn else { return }
        
        for entity in model.planeEntities {
            guard let modelComponent = entity.value.components[ModelComponent.self] else {
                print("could not find component")
                continue
            }
            
            guard var material = modelComponent.materials.first as? ShaderGraphMaterial else {
                print("No material")
                continue
            }
            
            do {
                try material.setParameter(name: "audioLevel", value: .float(Float(self.audioMonitor.inputLevel)))
                entity.value.components[ModelComponent.self]?.materials = [material]
            } catch {
                print("Error setting param on material")
            }
        }
    }
    
    private func startARSession() async {
        do {
            // Request world sensing authorization
            let authorizationResult = await model.session.requestAuthorization(for: [.worldSensing])
            
            // Check authorization status
            for (authorizationType, authorizationStatus) in authorizationResult {
                if authorizationStatus != .allowed {
                    print("Authorization not granted for \(authorizationType): \(authorizationStatus)")
                    return
                }
            }
            
            // Try to start the ARKit session with better error handling
            do {
                try await model.session.run([model.planeDetection])
                model.isSessionRunning = true
                print("ARKit session started successfully")
            } catch {
                print("Failed to start ARKit session: \(error)")
                model.sessionError = error
            }
        } catch {
            print("Failed to request authorization: \(error)")
        }
    }
}

#Preview {
    AudioSceneView(
        audioMonitor: AudioInputMonitor(),
        model: SessionManager(),
        effects: [CloudsEffect(), MagicEffect()]
    )
}