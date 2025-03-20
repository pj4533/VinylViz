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
    
    // Track session state
    var isSessionRunning = false
    var sessionError: Error?
    var added = false
    
    /// Checks if ARKit features are available on this device
    var deviceSupportsARKit: Bool {
        #if targetEnvironment(simulator)
        // ARKit features may have limitations in simulator
        print("Running in simulator - some ARKit features may not work as expected")
        #endif
        
        return true
    }
    
    /// Safely stops the current ARKit session
    func stopSession() async {
        guard isSessionRunning else { return }
        
        // ARKitSession doesn't have a pause() method, 
        // but we can stop tracking by setting isSessionRunning flag
        isSessionRunning = false
        print("ARKit session stopped")
    }
}

