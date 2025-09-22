//
//  AudioEngineController.swift
//  VinylViz
//
//  Created by Claude on 3/21/25.
//

import AVFoundation
import Foundation
import OSLog

/// Handles the AVAudioEngine setup, configuration and lifecycle
class AudioEngineController {
    /// The core audio engine
    private var audioEngine: AVAudioEngine?
    
    /// Whether the engine is currently running
    private(set) var isRunning = false
    
    /// Callback for audio analysis
    var onAudioBufferReceived: ((AVAudioPCMBuffer) -> Void)?
    
    /// Requests microphone permission and sets up the audio engine if granted
    /// - Parameter completion: Called when permission process completes
    func requestPermissionAndSetup(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupAudioSessionAndEngine()
                    completion(true)
                } else {
                    Logger.Level.warning("Microphone permission not granted", log: Logger.audio)
                    completion(false)
                }
            }
        }
    }
    
    /// Sets up the audio session and engine for recording
    private func setupAudioSessionAndEngine() {
        Logger.Level.debug("setupAudioSessionAndEngine()", log: Logger.audio)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [])
            try audioSession.setActive(true)
            
            setupAudioEngine()
        } catch {
            Logger.Level.error("Failed to set up the audio session: \(error)", log: Logger.audio)
        }
    }
    
    /// Configures the audio engine and installs a tap for analysis
    private func setupAudioEngine() {
        Logger.Level.debug("setupAudioEngine()", log: Logger.audio)
        audioEngine = AVAudioEngine()
        
        guard let inputNode = audioEngine?.inputNode else {
            Logger.Level.error("Failed to get the audio input node", log: Logger.audio)
            return
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.onAudioBufferReceived?(buffer)
        }
    }
    
    /// Starts the audio engine
    /// - Returns: Success or failure
    func start() -> Bool {
        Logger.Level.debug("startEngine()", log: Logger.audio)
        do {
            try audioEngine?.start()
            isRunning = true
            return true
        } catch {
            isRunning = false
            Logger.Level.error("Error starting audio engine: \(error.localizedDescription)", log: Logger.audio)
            return false
        }
    }
    
    /// Stops the audio engine and cleans up resources
    func stop() {
        Logger.Level.debug("stopEngine()", log: Logger.audio)
        audioEngine?.stop()
        isRunning = false
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            Logger.Level.error("Failed to deactivate audio session: \(error.localizedDescription)", log: Logger.audio)
        }
    }
}