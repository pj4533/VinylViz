//
//  SessionManager+SceneReconstruction.swift
//  VinylViz
//
//  Created by PJ Gray on 3/1/24.
//

import ARKit
import RealityKit
import UIKit

// This code will build a mesh entity from the mesh anchors, but I found it slowed things down too much
extension SessionManager {
    /// Updates the scene reconstruction meshes as new data arrives from ARKit.
    func processReconstructionUpdates() async {
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor

            switch update.event {
            case .added:
                let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.95)
                if let entity = try? self.generateModelEntity(geometry: meshAnchor.geometry, color: color) {
                    entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                    entity.name = "Mesh"
                    
                    if let customMaterial = customMaterial {
                        entity.components[ModelComponent.self]?.materials = [customMaterial]
                    }

                    meshEntities[meshAnchor.id] = entity
                    contentEntity.addChild(entity)
                }
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else { continue }
                if let customMaterial = customMaterial {
                    entity.components[ModelComponent.self]?.materials = [customMaterial]
                }
                entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
            case .removed:
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            }
        }
    }
    
    func generateModelEntity(geometry: MeshAnchor.Geometry, color: SimpleMaterial.Color) throws -> ModelEntity {
        // generate mesh
        var desc = MeshDescriptor()
        let posValues = geometry.vertices.asSIMD3(ofType: Float.self)
        desc.positions = .init(posValues)
        let normalValues = geometry.normals.asSIMD3(ofType: Float.self)
        desc.normals = .init(normalValues)
        do {
            desc.primitives = .polygons(
                // 应该都是三角形，所以这里直接写 3
                (0..<geometry.faces.count).map { _ in UInt8(3) },
                (0..<geometry.faces.count * 3).map {
                    geometry.faces.buffer.contents()
                        .advanced(by: $0 * geometry.faces.bytesPerIndex)
                        .assumingMemoryBound(to: UInt32.self).pointee
                }
            )
        }

        let meshResource = try MeshResource.generate(from: [desc])
        let material: Material = UnlitMaterial(color: color)
        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
        return modelEntity
    }
}
