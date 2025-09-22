//
//  MagicEffect.swift
//  ParticleVolumeTest
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI
import RealityKit

struct MagicEffect: AudioEffect {
    // Is there a world where this gets more abstracted. Down to a set of property changes? Meaning like I'd store
    // the name of the entity to find (Magic), and the min/max/exp values for each property change, and which property they affect?
    // and it would keep the code to actually make these changes generic. Each effect would have to have a type in that case though
    // cause the properties would be different. Where this way, I can just write the code. Dont necessarily see the benefit
    // in abstracting more? Maybe I will...
    func configure(content: RealityViewContent, using audioMonitor: AudioInputMonitor) {
        let newSpawnVelocity = audioMonitor.mapAudioLevelAdaptively(minTarget: 1.0, maxTarget: 10.0, exponentValue: 4.0)
        let newColorValue = audioMonitor.mapAudioLevelAdaptively(minTarget: 0.0, maxTarget: 1.0, exponentValue: 4.0)
        let newSpeed = audioMonitor.mapAudioLevelAdaptively(minTarget: 0.06, maxTarget: 0.8, exponentValue: 16.0)
        let newScale = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 0.0, maxTarget: 10.0, exponentValue: 4.0))
        let birthRate = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 40.0, maxTarget: 400.0, exponentValue: 4.0))
        let particleSize = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 5.0, maxTarget: 25.0, exponentValue: 8.0))
        if let entity = content.entities.first?.findEntity(named: "Magic") {
            entity.transform.scale = SIMD3(x: newScale, y: newScale, z: newScale)
            if var particleEmitterComponent = entity.components[ParticleEmitterComponent.self] {
                particleEmitterComponent.mainEmitter.color = ParticleEmitterComponent.ParticleEmitter.ParticleColor.evolving(start: ParticleEmitterComponent.ParticleEmitter.ParticleColor.ColorValue.single(UIColor(red: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, green: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, blue: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, alpha: 1.0)), end: ParticleEmitterComponent.ParticleEmitter.ParticleColor.ColorValue.single(UIColor(red: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, green: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, blue: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, alpha: 1.0)))

                particleEmitterComponent.speed = Float(newSpeed)
                particleEmitterComponent.spawnVelocityFactor = Float(newSpawnVelocity)
                particleEmitterComponent.mainEmitter.birthRate = birthRate
                particleEmitterComponent.mainEmitter.size = particleSize / 100.0
                particleEmitterComponent.isEmitting = audioMonitor.audioOn
                entity.components[ParticleEmitterComponent.self] = particleEmitterComponent
            }
        }
    }
}
