//
//  EntityModel.swift
//  VinylViz
//
//  Created by PJ Gray on 2/29/24.
//

import ARKit
import RealityKit
import UIKit

/// A model type that holds app state and processes updates from ARKit.
@Observable
@MainActor
class SessionManager {
    let session = ARKitSession()
    var meshEntities = [UUID: ModelEntity]()
    var planeEntities = [UUID: ModelEntity]()

    var contentEntity = Entity()
    var customMaterial: ShaderGraphMaterial?
    
    let sceneReconstruction = SceneReconstructionProvider()
    let planeDetection = PlaneDetectionProvider(alignments: [PlaneAnchor.Alignment.horizontal])

    var added = false
}

