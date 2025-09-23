//
//  LiveListeningViewModel.swift
//  VinylViz
//
//  ViewModel for coordinating audio capture and song identification
//

import Foundation
import SwiftUI
import AVFoundation
import AVFAudio
import Combine

/// ViewModel managing the Live Listening feature
@MainActor
class LiveListeningViewModel: ObservableObject {
    /// UI State
    @Published var isListening = false
    @Published var currentSong: IdentifiedSong?
    @Published var listeningState: AudioManager.ListeningState = .idle
    @Published var errorMessage: String?
    @Published var hasPermission = false
    @Published var permissionDenied = false

    /// Managers
    private let audioManager = AudioManager()
    private let shazamManager = ShazamKitManager()

    /// Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        setupNotifications()
        checkMicrophonePermission()
    }

    /// Setup data bindings between managers and view model
    private func setupBindings() {
        // Bind audio manager state
        audioManager.$state
            .receive(on: DispatchQueue.main)
            .assign(to: &$listeningState)

        audioManager.$isListening
            .receive(on: DispatchQueue.main)
            .assign(to: &$isListening)

        audioManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error
                }
            }
            .store(in: &cancellables)

        // Bind ShazamKit manager
        shazamManager.$currentSong
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentSong)

        shazamManager.$identificationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error
                }
            }
            .store(in: &cancellables)

        // Connect managers
        audioManager.shazamDelegate = shazamManager

        Logger.Level.debug("LiveListeningViewModel: Data bindings configured", log: Logger.ui)
    }

    /// Setup notification observers
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.audioManager.handleRouteChange(notification: notification)
            }
        }

        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.audioManager.handleInterruption(notification: notification)
            }
        }

        Logger.Level.debug("LiveListeningViewModel: Notifications configured", log: Logger.ui)
    }

    /// Check and request microphone permission
    func checkMicrophonePermission() {
        Logger.Level.info("LiveListeningViewModel: Checking microphone permission", log: Logger.app)

        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                hasPermission = true
                permissionDenied = false
                Logger.Level.info("LiveListeningViewModel: Microphone permission granted", log: Logger.app)

            case .denied:
                hasPermission = false
                permissionDenied = true
                errorMessage = "Microphone access denied. Please enable in Settings."
                Logger.Level.warning("LiveListeningViewModel: Microphone permission denied", log: Logger.app)

            case .undetermined:
                requestMicrophonePermission()

            @unknown default:
                hasPermission = false
                Logger.Level.error("LiveListeningViewModel: Unknown permission state", log: Logger.app)
            }
        } else {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                hasPermission = true
                permissionDenied = false
                Logger.Level.info("LiveListeningViewModel: Microphone permission granted", log: Logger.app)

            case .denied:
                hasPermission = false
                permissionDenied = true
                errorMessage = "Microphone access denied. Please enable in Settings."
                Logger.Level.warning("LiveListeningViewModel: Microphone permission denied", log: Logger.app)

            case .undetermined:
                requestMicrophonePermission()

            @unknown default:
                hasPermission = false
                Logger.Level.error("LiveListeningViewModel: Unknown permission state", log: Logger.app)
            }
        }
    }

    /// Request microphone permission from user
    private func requestMicrophonePermission() {
        Logger.Level.info("LiveListeningViewModel: Requesting microphone permission", log: Logger.app)

        if #available(iOS 17.0, *) {
            Task {
                let granted = await AVAudioApplication.requestRecordPermission()
                await MainActor.run {
                    self.hasPermission = granted
                    self.permissionDenied = !granted

                    if granted {
                        Logger.Level.notice("LiveListeningViewModel: Microphone permission granted by user", log: Logger.app)
                    } else {
                        self.errorMessage = "Microphone access required for song identification"
                        Logger.Level.warning("LiveListeningViewModel: Microphone permission denied by user", log: Logger.app)
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    self?.hasPermission = granted
                    self?.permissionDenied = !granted

                    if granted {
                        Logger.Level.notice("LiveListeningViewModel: Microphone permission granted by user", log: Logger.app)
                    } else {
                        self?.errorMessage = "Microphone access required for song identification"
                        Logger.Level.warning("LiveListeningViewModel: Microphone permission denied by user", log: Logger.app)
                    }
                }
            }
        }
    }

    /// Toggle listening state
    func toggleListening() {
        Logger.Level.info("LiveListeningViewModel: Toggle listening requested", log: Logger.ui)

        guard hasPermission else {
            Logger.Level.warning("LiveListeningViewModel: Cannot start - no permission", log: Logger.ui)
            checkMicrophonePermission()
            return
        }

        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    /// Start listening for audio
    private func startListening() {
        Logger.Level.info("LiveListeningViewModel: Starting listening", log: Logger.ui)

        errorMessage = nil
        audioManager.startListening()

        if let inputFormat = AVAudioEngine().inputNode.outputFormat(forBus: 0) as AVAudioFormat? {
            shazamManager.startIdentifying(with: inputFormat)
        }

        Logger.Level.notice("LiveListeningViewModel: Listening started", log: Logger.ui)
    }

    /// Stop listening
    private func stopListening() {
        Logger.Level.info("LiveListeningViewModel: Stopping listening", log: Logger.ui)

        audioManager.stopListening()
        shazamManager.stopIdentifying()
        currentSong = nil

        Logger.Level.notice("LiveListeningViewModel: Listening stopped", log: Logger.ui)
    }

    /// Open app settings
    func openSettings() {
        Logger.Level.info("LiveListeningViewModel: Opening app settings", log: Logger.ui)

        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    /// Clear current song
    func clearCurrentSong() {
        Logger.Level.info("LiveListeningViewModel: Clearing current song", log: Logger.ui)
        currentSong = nil
    }

    deinit {
        Task { @MainActor in
            Logger.Level.info("LiveListeningViewModel: Deinitializing", log: Logger.ui)
            stopListening()
        }
    }
}