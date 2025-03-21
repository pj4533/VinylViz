//
//  AudioSceneView.swift
//  VinylViz
//
//  Created by Claude on 3/21/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import OSLog

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
                    Logger.Level.warning("Could not find model component for CustomMaterialCube", log: Logger.ui)
                }
            } else {
                Logger.Level.error("Could not find CustomMaterialCube entity", log: Logger.ui)
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
                Logger.Level.warning("Could not find ModelComponent for plane entity [\(entity.key)]", log: Logger.effects)
                continue
            }
            
            guard var material = modelComponent.materials.first as? ShaderGraphMaterial else {
                Logger.Level.warning("No ShaderGraphMaterial found for plane entity [\(entity.key)]", log: Logger.effects)
                continue
            }
            
            do {
                try material.setParameter(name: "audioLevel", value: .float(Float(self.audioMonitor.inputLevel)))
                entity.value.components[ModelComponent.self]?.materials = [material]
            } catch {
                Logger.Level.error("Error setting audioLevel parameter on material: \(error)", log: Logger.effects)
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
                    Logger.Level.error("Authorization not granted for \(authorizationType): \(authorizationStatus)", log: Logger.session)
                    return
                }
            }
            
            // Try to start the ARKit session with better error handling
            do {
                try await model.session.run([model.planeDetection])
                model.isSessionRunning = true
                Logger.Level.info("ARKit session started successfully", log: Logger.session)
            } catch {
                Logger.Level.error("Failed to start ARKit session: \(error)", log: Logger.session)
                model.sessionError = error
            }
        } catch {
            Logger.Level.error("Failed to request world sensing authorization: \(error)", log: Logger.session)
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