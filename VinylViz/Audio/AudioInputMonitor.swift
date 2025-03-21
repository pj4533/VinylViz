//
//  AudioInputMonitor.swift
//  ParticleVolumeTest
//
//  Created by PJ Gray on 2/17/24.
//

import AVFoundation
import Foundation
import OSLog

class AudioInputMonitor: ObservableObject {
    private var audioEngine: AVAudioEngine?
    
    var maxObservedLevel: Float = 0.00001
    var numberOfQuietUpdates = 10

    /// A float representing the current level of loudness of the audio
    @Published var inputLevel: Float = 0
    
    /// A boolean representing whether audio is on -- if a inputLevel of less than 0.1 is recorded 5 times in a row, this flips true
    @Published var audioOn: Bool = false
        
    /// A status string message to display in the UI
    @Published var statusString: String? = nil
    
    /// A simple bool for if the engine is on, so I don't need to publish the entire engine variable
    @Published var engineOn: Bool = false
    
    init() {
    }
    
    private func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setupAudioSessionAndEngine()
                } else {
                    Logger.Level.warning("Microphone permission not granted", log: Logger.audio)
                    // Handle the case where permission is not granted
                }
            }
        }
    }
    
    private func setupAudioSessionAndEngine() {
        Logger.Level.debug("setupAudioSessionAndEngine()", log: Logger.audio)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [])
            try audioSession.setActive(true)
            
            self.setupAudioEngine()
        } catch {
            Logger.Level.error("Failed to set up the audio session: \(error)", log: Logger.audio)
        }
    }
    
    private func setupAudioEngine() {
        Logger.Level.debug("setupAudioEngine()", log: Logger.audio)
        audioEngine = AVAudioEngine()
        
        guard let inputNode = audioEngine?.inputNode else {
            Logger.Level.error("Failed to get the audio input node", log: Logger.audio)
            return
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.analyzeAudio(buffer: buffer)
        }
    }
    
    private func analyzeAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { 
            Logger.Level.warning("No channel data available in audio buffer", log: Logger.audio)
            return 
        }
        
        let channelDataValue = channelData.pointee
        let channelDataValues = stride(from: 0,
                                       to: Int(buffer.frameLength),
                                       by: buffer.stride).map { channelDataValue[$0] }
        
        let rms = sqrt(channelDataValues.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)
        
        // playing with these numbers a bit...
        let adjustedPower = max(avgPower, -50.0) // Use -50 dB as a floor
        let normalizedLevel = (adjustedPower + 50.0) / 50.0 // Normalize to 0...1
        
        DispatchQueue.main.async {
            self.inputLevel = normalizedLevel
            
            // Log significant audio level changes at debug level
            if self.inputLevel > 0.7 {
                Logger.Level.debug("High audio level detected: \(self.inputLevel)", log: Logger.audio)
            }
            
            if self.inputLevel < 0.1 {
                self.numberOfQuietUpdates += 1
                
                if self.numberOfQuietUpdates == 5 {
                    Logger.Level.info("Audio appears to have stopped (quiet for 5 updates)", log: Logger.audio)
                }
            } else {
                if self.numberOfQuietUpdates > 5 {
                    Logger.Level.info("Audio detected after period of quiet", log: Logger.audio)
                }
                self.numberOfQuietUpdates = 0
            }

            if self.numberOfQuietUpdates <= 5 {
                let wasAudioOn = self.audioOn
                self.audioOn = true
                
                if !wasAudioOn {
                    Logger.Level.info("Audio state changed: ON", log: Logger.audio)
                }
            } else {
                let wasAudioOn = self.audioOn
                self.audioOn = false
                
                if wasAudioOn {
                    Logger.Level.info("Audio state changed: OFF", log: Logger.audio)
                }
            }

            // reset max if anything below 0.02 is heard -- not sure i like this
            if self.inputLevel < 0.02 {
                self.maxObservedLevel = 0.00001
            }
            self.maxObservedLevel = max(self.maxObservedLevel, self.inputLevel)
        }
    }
    
    private func startEngine() {
        Logger.Level.debug("startEngine()", log: Logger.audio)
        do {
            try audioEngine?.start()
            self.engineOn = true
        } catch {
            self.engineOn = false
            Logger.Level.error("Error starting audio engine: \(error.localizedDescription)", log: Logger.audio)
        }
    }

    func startMonitoring() {
        Logger.Level.debug("startMonitoring()", log: Logger.audio)
        if self.audioEngine == nil {
            self.statusString = "Initializing audio engine..."
            requestMicrophonePermission()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.startEngine()
                self.statusString = nil
            }
        }
    }

    func stopMonitoring() {
        Logger.Level.debug("stopMonitoring()", log: Logger.audio)
        audioEngine?.stop()
        self.engineOn = false
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            Logger.Level.error("Failed to deactivate audio session: \(error.localizedDescription)", log: Logger.audio)
        }
    }
}
