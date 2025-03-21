//
//  SessionManager+PlaneDetection.swift
//  VinylViz
//
//  Created by PJ Gray on 3/1/24.
//

import ARKit
import RealityKit
import UIKit
import OSLog

extension SessionManager {
    func processPlaneDetectionUpdates() async {
        for await update in planeDetection.anchorUpdates {
            let planeAnchor = update.anchor
            
            switch update.event {
            case .added:
                Logger.Level.info("Plane detected: \(planeAnchor.classification) [\(planeAnchor.id)]", log: Logger.session)
                
                var meshResource: MeshResource? = nil
                do {
                    let contents = MeshResource.Contents(planeGeometry: planeAnchor.geometry)
                    meshResource = try MeshResource.generate(from: contents)
                } catch {
                    Logger.Level.error("Failed to create a mesh resource for a plane anchor: \(error)", log: Logger.session)
                }
                
                if let meshResource {
                    let modelEntity = ModelEntity(mesh: meshResource, materials: [OcclusionMaterial()])
                    modelEntity.transform = Transform(matrix: planeAnchor.originFromAnchorTransform)
                    modelEntity.name = "Plane"
                    if let customMaterial = customMaterial {
                        modelEntity.components[ModelComponent.self]?.materials = [customMaterial]
                    }
                        
                    planeEntities[planeAnchor.id] = modelEntity
                    if planeAnchor.classification == .ceiling {
                        contentEntity.addChild(modelEntity)
                    }
                }
            case .updated:
                Logger.Level.debug("Plane updated: \(planeAnchor.classification) [\(planeAnchor.id)]", log: Logger.session)
                guard let entity = planeEntities[planeAnchor.id] else { 
                    Logger.Level.warning("Tried to update nonexistent plane entity [\(planeAnchor.id)]", log: Logger.session)
                    continue 
                }
                if let customMaterial = customMaterial {
                    entity.components[ModelComponent.self]?.materials = [customMaterial]
                }
                entity.transform = Transform(matrix: planeAnchor.originFromAnchorTransform)
            case .removed:
                Logger.Level.info("Plane removed: [\(planeAnchor.id)]", log: Logger.session)
                planeEntities[planeAnchor.id]?.removeFromParent()
                planeEntities.removeValue(forKey: planeAnchor.id)
            }
        }
    }
}
