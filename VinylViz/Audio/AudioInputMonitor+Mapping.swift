//
//  AudioInputMonitor+Mapping.swift
//  ParticleVolumeTest
//
//  Created by PJ Gray on 2/18/24.
//

import Foundation

extension AudioInputMonitor {
    
    func mapAudioLevelAdaptively(minTarget: Double, maxTarget: Double, exponentValue: Double) -> Double {
        // Normalize the current level based on the maximum observed level
        let normalizedLevel = Double(self.inputLevel) / Double(maxObservedLevel)

        // Apply an exponential transformation for a very steep curve
        // Adjust the exponent as needed to control the steepness of the curve
        let exponent = exponentValue // Increase for a steeper curve
        let expTransform = pow(normalizedLevel, exponent)

        // Scale and shift the exponential output to the target range
        let scaledValue = minTarget + (maxTarget - minTarget) * expTransform

        return scaledValue
    }
}
