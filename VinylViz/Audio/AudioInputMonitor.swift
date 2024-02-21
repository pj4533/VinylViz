//
//  AudioInputMonitor.swift
//  ParticleVolumeTest
//
//  Created by PJ Gray on 2/17/24.
//

import AVFoundation
import Foundation

class AudioInputMonitor: ObservableObject {
    private var audioEngine: AVAudioEngine?
    
    var maxObservedLevel: Float = 0.00001
    var numberOfQuietUpdates = 10

    /// A float representing the current level of loudness of the audio
    @Published var inputLevel: Float = 0
    
    /// A boolean representing whether audio is on -- if a inputLevel of less than 0.1 is recorded 5 times in a row, this flips true
    @Published var audioOn: Bool = false

    init() {
        requestMicrophonePermission()
    }
    
    private func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setupAudioSessionAndEngine()
                } else {
                    print("Microphone permission not granted")
                    // Handle the case where permission is not granted
                }
            }
        }
    }
    
    private func setupAudioSessionAndEngine() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            self.setupAudioEngine()
        } catch {
            print("Failed to set up the audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        guard let inputNode = audioEngine?.inputNode else {
            print("Failed to get the audio input node")
            return
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.analyzeAudio(buffer: buffer)
        }
    }
    
    private func analyzeAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
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
            if self.inputLevel < 0.1 {
                self.numberOfQuietUpdates += 1
            } else {
                self.numberOfQuietUpdates = 0
            }

            if self.numberOfQuietUpdates <= 5 {
                self.audioOn = true
            } else {
                self.audioOn = false
            }

            // reset max if anything below 0.02 is heard -- not sure i like this
            if self.inputLevel < 0.02 {
                self.maxObservedLevel = 0.00001
            }
            self.maxObservedLevel = max(self.maxObservedLevel, self.inputLevel)
        }
    }
    
    func startMonitoring() {
        do {
            try audioEngine?.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopMonitoring() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
