//
//  AudioInputMonitor.swift
//  VinylViz
//
//  Created by PJ Gray on 2/17/24.
//

import AVFoundation
import Foundation
import OSLog

/// Monitors audio input from the microphone and publishes audio levels and state
class AudioInputMonitor: ObservableObject {
    // MARK: - Dependencies
    
    private let engineController = AudioEngineController()
    
    // MARK: - Audio Processing State
    
    /// Tracks the maximum observed audio level for adaptive scaling
    var maxObservedLevel: Float = 0.00001
    
    /// Tracks consecutive audio samples below the quiet threshold
    var numberOfQuietUpdates = 10
    
    // MARK: - Published Properties
    
    /// The current audio input level from 0 to 1
    @Published var inputLevel: Float = 0
    
    /// Whether audio is currently detected (based on thresholds)
    @Published var audioOn: Bool = false
    
    /// Status message to display in the UI
    @Published var statusString: String? = nil
    
    /// Whether the audio engine is currently running
    @Published var engineOn: Bool = false
    
    // MARK: - Initialization
    
    init() {
        engineController.onAudioBufferReceived = { [weak self] buffer in
            self?.processAudioBuffer(buffer)
        }
    }
    
    // MARK: - Public Methods
    
    /// Starts audio monitoring if not already running
    func startMonitoring() {
        Logger.Level.debug("startMonitoring()", log: Logger.audio)
        if !engineController.isRunning {
            statusString = "Initializing audio engine..."
            engineController.requestPermissionAndSetup { [weak self] success in
                guard let self = self, success else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if self.engineController.start() {
                        self.engineOn = true
                        self.statusString = nil
                    }
                }
            }
        }
    }

    /// Stops audio monitoring
    func stopMonitoring() {
        Logger.Level.debug("stopMonitoring()", log: Logger.audio)
        engineController.stop()
        engineOn = false
    }
    
    // MARK: - Private Methods
    
    /// Processes an audio buffer to extract and publish audio metrics
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let normalizedLevel = AudioAnalyzer.extractLevel(from: buffer) else { return }
        
        DispatchQueue.main.async {
            self.updateAudioLevel(normalizedLevel)
        }
    }
    
    /// Updates audio level and state based on the normalized level
    private func updateAudioLevel(_ level: Float) {
        self.inputLevel = level
        
        // Log significant audio level changes
        if level > 0.7 {
            Logger.Level.debug("High audio level detected: \(level)", log: Logger.audio)
        }
        
        updateAudioActivity(level)
        updateMaxLevel(level)
    }
    
    /// Updates the audio activity state based on current level
    private func updateAudioActivity(_ level: Float) {
        // Determine if audio is quiet based on threshold
        if level < 0.1 {
            numberOfQuietUpdates += 1
            
            if numberOfQuietUpdates == 5 {
                Logger.Level.info("Audio appears to have stopped (quiet for 5 updates)", log: Logger.audio)
            }
        } else {
            if numberOfQuietUpdates > 5 {
                Logger.Level.info("Audio detected after period of quiet", log: Logger.audio)
            }
            numberOfQuietUpdates = 0
        }
        
        // Update audioOn state
        let wasAudioOn = audioOn
        audioOn = numberOfQuietUpdates <= 5
        
        // Log state changes
        if audioOn != wasAudioOn {
            Logger.Level.info("Audio state changed: \(audioOn ? "ON" : "OFF")", log: Logger.audio)
        }
    }
    
    /// Updates the maximum observed level for adaptive scaling
    private func updateMaxLevel(_ level: Float) {
        // Reset max if level is very low
        if level < 0.02 {
            maxObservedLevel = 0.00001
        }
        
        // Update max observed level
        maxObservedLevel = max(maxObservedLevel, level)
    }
}