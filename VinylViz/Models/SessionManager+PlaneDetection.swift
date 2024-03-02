//
//  SessionManager+PlaneDetection.swift
//  VinylViz
//
//  Created by PJ Gray on 3/1/24.
//

import ARKit
import RealityKit
import UIKit

extension SessionManager {
    func processPlaneDetectionUpdates() async {
        for await update in planeDetection.anchorUpdates {
            let planeAnchor = update.anchor
            
            switch update.event {
            case .added:
                
                var meshResource: MeshResource? = nil
                do {
                    let contents = MeshResource.Contents(planeGeometry: planeAnchor.geometry)
                    meshResource = try MeshResource.generate(from: contents)
                } catch {
                    print("Failed to create a mesh resource for a plane anchor: \(error).")
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
                guard let entity = planeEntities[planeAnchor.id] else { continue }
                if let customMaterial = customMaterial {
                    entity.components[ModelComponent.self]?.materials = [customMaterial]
                }
                entity.transform = Transform(matrix: planeAnchor.originFromAnchorTransform)
            case .removed:
                planeEntities[planeAnchor.id]?.removeFromParent()
                planeEntities.removeValue(forKey: planeAnchor.id)
            }
        }
    }
}
