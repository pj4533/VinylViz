//
//  AudioInputMonitor+Mapping.swift
//  VinylViz
//
//  Created by PJ Gray on 2/18/24.
//

import Foundation

extension AudioInputMonitor {
    /// Maps the current audio level to a target range with optional non-linear scaling
    /// - Parameters:
    ///   - minTarget: Minimum value in the target range
    ///   - maxTarget: Maximum value in the target range
    ///   - exponentValue: Controls the steepness of the mapping curve
    /// - Returns: A mapped value in the target range
    func mapAudioLevelAdaptively(minTarget: Double, maxTarget: Double, exponentValue: Double) -> Double {
        return AudioAnalyzer.mapLevelAdaptively(
            level: self.inputLevel,
            maxObservedLevel: self.maxObservedLevel,
            minTarget: minTarget,
            maxTarget: maxTarget,
            exponentValue: exponentValue
        )
    }
}