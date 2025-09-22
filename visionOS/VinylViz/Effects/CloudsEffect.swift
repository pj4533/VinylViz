//
//  CloudsEffect.swift
//  ParticleVolumeTest
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI
import RealityKit

struct CloudsEffect: AudioEffect {
    func configure(content: RealityViewContent, using audioMonitor: AudioInputMonitor) {
        let newCloudSpeed = audioMonitor.mapAudioLevelAdaptively(minTarget: 0.4, maxTarget: 1.0, exponentValue: 4.0)
        let newColorValue = audioMonitor.mapAudioLevelAdaptively(minTarget: 0.0, maxTarget: 1.0, exponentValue: 4.0)
        let newScale = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 0.0, maxTarget: 10.0, exponentValue: 4.0))
        let newSpawnVelocity = audioMonitor.mapAudioLevelAdaptively(minTarget: 1.0, maxTarget: 10.0, exponentValue: 4.0)
//            let newScale = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 0.0, maxTarget: 10.0, exponentValue: 4.0))
//            let birthRate = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 40.0, maxTarget: 400.0, exponentValue: 4.0))
        let cloudParticleSize = Float(audioMonitor.mapAudioLevelAdaptively(minTarget: 0.5, maxTarget: 1.5, exponentValue: 10.0))
        if let entity = content.entities.first?.findEntity(named: "Clouds") {
            entity.transform.scale = SIMD3(x: newScale, y: newScale, z: newScale)
            if var particleEmitterComponent = entity.components[ParticleEmitterComponent.self] {
                particleEmitterComponent.mainEmitter.color = ParticleEmitterComponent.ParticleEmitter.ParticleColor.constant(ParticleEmitterComponent.ParticleEmitter.ParticleColor.ColorValue.single(UIColor(red: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, green: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, blue: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, alpha: 0.1)))

                //                    particleEmitterComponent.mainEmitter.color = ParticleEmitterComponent.ParticleEmitter.ParticleColor.evolving(start: ParticleEmitterComponent.ParticleEmitter.ParticleColor.ColorValue.single(UIColor(red: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, green: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, blue: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, alpha: 1.0)), end: ParticleEmitterComponent.ParticleEmitter.ParticleColor.ColorValue.single(UIColor(red: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, green: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, blue: [newColorValue, 0.0, 1.0-newColorValue].randomElement() ?? 0.0, alpha: 0.07)))

                //CGColor(red: newColorValue, green: 0.0, blue: 0.0, alpha: 1.0)
                particleEmitterComponent.speed = Float(newCloudSpeed)
                particleEmitterComponent.spawnVelocityFactor = Float(newSpawnVelocity)
//                    particleEmitterComponent.mainEmitter.birthRate = birthRate
                particleEmitterComponent.mainEmitter.size = cloudParticleSize / 100.0
                particleEmitterComponent.isEmitting = audioMonitor.audioOn
                entity.components[ParticleEmitterComponent.self] = particleEmitterComponent
            }
        }
    }
}
