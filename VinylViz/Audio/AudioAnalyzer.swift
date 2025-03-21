//
//  AudioAnalyzer.swift
//  VinylViz
//
//  Created by Claude on 3/21/25.
//

import AVFoundation
import OSLog

/// Responsible for analyzing audio data and extracting useful metrics
class AudioAnalyzer {
    /// Extracts level information from an audio buffer
    /// - Parameter buffer: The audio buffer to analyze
    /// - Returns: Normalized audio level from 0 to 1, or nil if analysis fails
    static func extractLevel(from buffer: AVAudioPCMBuffer) -> Float? {
        guard let channelData = buffer.floatChannelData else {
            Logger.Level.warning("No channel data available in audio buffer", log: Logger.audio)
            return nil
        }
        
        let channelDataValue = channelData.pointee
        let channelDataValues = stride(from: 0,
                                      to: Int(buffer.frameLength),
                                      by: buffer.stride).map { channelDataValue[$0] }
        
        let rms = sqrt(channelDataValues.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        // Use -50 dB as a floor and normalize to 0...1
        let adjustedPower = max(avgPower, -50.0)
        let normalizedLevel = (adjustedPower + 50.0) / 50.0
        
        return normalizedLevel
    }
    
    /// Maps an audio level to a target range with exponential scaling
    /// - Parameters:
    ///   - level: Current audio level
    ///   - maxObservedLevel: Maximum observed level for adaptive scaling
    ///   - minTarget: Minimum value in the target range
    ///   - maxTarget: Maximum value in the target range
    ///   - exponentValue: Exponent to control curve steepness
    /// - Returns: A mapped value in the target range
    static func mapLevelAdaptively(level: Float, maxObservedLevel: Float, 
                                  minTarget: Double, maxTarget: Double, 
                                  exponentValue: Double) -> Double {
        // Normalize the current level based on the maximum observed level
        let normalizedLevel = Double(level) / Double(maxObservedLevel)

        // Apply an exponential transformation for a steep curve
        let expTransform = pow(normalizedLevel, exponentValue)

        // Scale and shift the exponential output to the target range
        let scaledValue = minTarget + (maxTarget - minTarget) * expTransform

        return scaledValue
    }
    
    /// Determines if audio is considered active based on volume level
    /// - Parameters:
    ///   - level: Current audio level
    ///   - quietThreshold: Threshold below which audio is considered quiet
    ///   - requiredQuietUpdates: Number of consecutive quiet samples needed to consider audio off
    ///   - currentQuietUpdateCount: Current count of consecutive quiet samples
    /// - Returns: Tuple containing (isAudioActive, updatedQuietCount)
    static func determineAudioActivity(level: Float, quietThreshold: Float = 0.1,
                                      requiredQuietUpdates: Int = 5, 
                                      currentQuietUpdateCount: Int) -> (Bool, Int) {
        let isQuiet = level < quietThreshold
        let updatedQuietCount = isQuiet ? currentQuietUpdateCount + 1 : 0
        let isActive = updatedQuietCount <= requiredQuietUpdates
        
        return (isActive, updatedQuietCount)
    }
}