//
//  AudioManager.swift
//  VinylViz
//
//  Core audio engine management for real-time audio processing
//

import Foundation
import AVFoundation
import Combine
import ShazamKit

/// Manages audio engine, session configuration, and buffer processing
@MainActor
class AudioManager: NSObject, ObservableObject {
    /// States for audio monitoring
    enum ListeningState {
        case idle
        case listening
        case identifying
        case identified
    }

    /// Published properties for UI binding
    @Published var state: ListeningState = .idle
    @Published var isListening = false
    @Published var currentMatch: SHMatch?
    @Published var errorMessage: String?

    /// Audio engine components
    private let engine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private let mixerNode = AVAudioMixerNode()

    /// ShazamKit session
    private var shazamSession: SHSession?

    /// Audio processing
    private let bufferSize: AVAudioFrameCount = 1024
    private var audioBuffers: [AVAudioPCMBuffer] = []

    /// Delegate for ShazamKit processing
    weak var shazamDelegate: ShazamKitManagerDelegate?

    override init() {
        super.init()
        setupAudioSession()
        setupAudioEngine()
    }

    /// Configure audio session for recording with mixing
    private func setupAudioSession() {
        Logger.Level.info("AudioManager: Setting up audio session", log: Logger.audio)

        do {
            try session.setCategory(.playAndRecord, options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true)
            Logger.Level.info("AudioManager: Audio session configured successfully", log: Logger.audio)
        } catch {
            Logger.Level.error("AudioManager: Failed to setup audio session: \(error.localizedDescription)", log: Logger.audio)
            errorMessage = "Failed to configure audio: \(error.localizedDescription)"
        }
    }

    /// Configure audio engine with mixer node for flexible routing
    private func setupAudioEngine() {
        Logger.Level.info("AudioManager: Setting up audio engine", log: Logger.audio)

        engine.attach(mixerNode)
        engine.connect(engine.inputNode, to: mixerNode, format: nil)
        engine.connect(mixerNode, to: engine.mainMixerNode, format: nil)

        Logger.Level.debug("AudioManager: Audio engine configured with mixer node", log: Logger.audio)
    }

    /// Start listening and capturing audio
    func startListening() {
        guard !isListening else {
            Logger.Level.warning("AudioManager: Already listening, ignoring start request", log: Logger.audio)
            return
        }

        Logger.Level.info("AudioManager: Starting audio listening", log: Logger.audio)

        do {
            if !engine.isRunning {
                try engine.start()
                Logger.Level.info("AudioManager: Audio engine started", log: Logger.audio)
            }

            installAudioTap()
            isListening = true
            state = .listening
            errorMessage = nil

            Logger.Level.notice("AudioManager: Now listening for audio", log: Logger.audio)
        } catch {
            Logger.Level.error("AudioManager: Failed to start audio engine: \(error.localizedDescription)", log: Logger.audio)
            errorMessage = "Failed to start listening: \(error.localizedDescription)"
            state = .idle
        }
    }

    /// Stop listening and audio capture
    func stopListening() {
        guard isListening else {
            Logger.Level.warning("AudioManager: Not listening, ignoring stop request", log: Logger.audio)
            return
        }

        Logger.Level.info("AudioManager: Stopping audio listening", log: Logger.audio)

        removeAudioTap()

        if engine.isRunning {
            engine.stop()
            Logger.Level.info("AudioManager: Audio engine stopped", log: Logger.audio)
        }

        isListening = false
        state = .idle
        audioBuffers.removeAll()

        Logger.Level.notice("AudioManager: Stopped listening", log: Logger.audio)
    }

    /// Install audio tap for buffer processing
    private func installAudioTap() {
        Logger.Level.debug("AudioManager: Installing audio tap", log: Logger.audio)

        let inputFormat = engine.inputNode.outputFormat(forBus: 0)

        engine.inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }

        Logger.Level.debug("AudioManager: Audio tap installed with buffer size \(bufferSize)", log: Logger.audio)
    }

    /// Remove audio tap
    private func removeAudioTap() {
        Logger.Level.debug("AudioManager: Removing audio tap", log: Logger.audio)
        engine.inputNode.removeTap(onBus: 0)
    }

    /// Process captured audio buffer
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Store buffer for batch processing
        audioBuffers.append(buffer)

        // Send to ShazamKit delegate for identification
        if let delegate = shazamDelegate {
            delegate.processAudioBuffer(buffer)
        }

        // Future: Send to visualization processor
        // visualizationProcessor?.processAudioBuffer(buffer)

        // Limit buffer queue size to prevent memory issues
        if audioBuffers.count > 50 {
            audioBuffers.removeFirst()
        }
    }

    /// Handle audio route changes
    func handleRouteChange(notification: Notification) {
        Logger.Level.info("AudioManager: Audio route changed", log: Logger.audio)

        guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let routeChangeReason = AVAudioSession.RouteChangeReason(rawValue: reason) else {
            return
        }

        switch routeChangeReason {
        case .newDeviceAvailable:
            Logger.Level.info("AudioManager: New audio device available", log: Logger.audio)
        case .oldDeviceUnavailable:
            Logger.Level.warning("AudioManager: Audio device disconnected", log: Logger.audio)
            if isListening {
                stopListening()
                errorMessage = "Audio device disconnected"
            }
        default:
            break
        }
    }

    /// Handle audio interruptions
    func handleInterruption(notification: Notification) {
        Logger.Level.info("AudioManager: Audio interruption received", log: Logger.audio)

        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            Logger.Level.warning("AudioManager: Audio interruption began", log: Logger.audio)
            if isListening {
                stopListening()
            }
        case .ended:
            Logger.Level.info("AudioManager: Audio interruption ended", log: Logger.audio)
            if let optionsValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    Logger.Level.info("AudioManager: Resuming audio after interruption", log: Logger.audio)
                    startListening()
                }
            }
        @unknown default:
            break
        }
    }

    deinit {
        Task { @MainActor in
            Logger.Level.info("AudioManager: Deinitializing", log: Logger.audio)
            stopListening()
        }
    }
}

/// Protocol for ShazamKit processing delegation
protocol ShazamKitManagerDelegate: AnyObject {
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer)
}