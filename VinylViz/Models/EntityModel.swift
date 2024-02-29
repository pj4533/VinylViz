//
//  EntityModel.swift
//  VinylViz
//
//  Created by PJ Gray on 2/29/24.
//

import ARKit
import RealityKit
import UIKit

extension GeometrySource {
    @MainActor func asArray<T>(ofType: T.Type) -> [T] {
        assert(MemoryLayout<T>.stride == stride, "Invalid stride \(MemoryLayout<T>.stride); expected \(stride)")
        return (0..<self.count).map {
            buffer.contents().advanced(by: offset + stride * Int($0)).assumingMemoryBound(to: T.self).pointee
        }
    }

    // SIMD3 has the same storage as SIMD4.
    @MainActor  func asSIMD3<T>(ofType: T.Type) -> [SIMD3<T>] {
        return asArray(ofType: (T, T, T).self).map { .init($0.0, $0.1, $0.2) }
    }
}

/// A model type that holds app state and processes updates from ARKit.
@Observable
@MainActor
class EntityModel {
    let session = ARKitSession()
    private var meshEntities = [UUID: ModelEntity]()

    var contentEntity = Entity()

    let sceneReconstruction = SceneReconstructionProvider()

    func configure(using audioMonitor: AudioInputMonitor) {
        for entity in meshEntities {
            let newTransformOffset = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 1.0, maxTarget: 1.04, exponentValue: 4.0))
            let newScale = SIMD3<Float>(
                [newTransformOffset, Float(1.0)].randomElement() ?? 1.0,
                [newTransformOffset, Float(1.0)].randomElement() ?? 1.0,
                [newTransformOffset, Float(1.0)].randomElement() ?? 1.0
            )
            
            var newTransform = entity.value.transform
            newTransform.scale = newScale
            
            entity.value.move(to: newTransform, relativeTo: entity.value.parent, duration: 0.25, timingFunction: .easeInOut)
        }
    }
    
    /// Updates the scene reconstruction meshes as new data arrives from ARKit.
    func processReconstructionUpdates() async {
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor

            switch update.event {
            case .added:
                let color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.9)
                if let entity = try? self.generateModelEntity(geometry: meshAnchor.geometry, color: color) {
                    entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                    entity.name = "Mesh"

                    meshEntities[meshAnchor.id] = entity
                    contentEntity.addChild(entity)
                }
            case .updated:
                guard let entity = meshEntities[meshAnchor.id] else { continue }
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
        var material = UnlitMaterial(color: color)
        material.triangleFillMode = .lines
        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
        return modelEntity
    }

}

