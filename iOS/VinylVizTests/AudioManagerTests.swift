//
//  AudioManagerTests.swift
//  VinylVizTests
//
//  Tests for AudioManager state transitions and functionality
//

import Testing
import AVFoundation
@testable import VinylViz

struct AudioManagerTests {

    @Test("AudioManager initializes with correct default state")
    @MainActor
    func audioManagerInitializesCorrectly() async throws {
        let audioManager = AudioManager()
        #expect(audioManager.state == .idle, "Should start in idle state")
        #expect(!audioManager.isListening, "Should not be listening initially")
        #expect(audioManager.currentMatch == nil, "Should have no current match initially")
        #expect(audioManager.errorMessage == nil, "Should have no error message initially")
    }

    @Test("AudioManager state transitions from idle to listening")
    @MainActor
    func audioManagerStartListening() async throws {
        let audioManager = AudioManager()

        // Initial state
        #expect(audioManager.state == .idle, "Should start in idle state")

        // Start listening
        audioManager.startListening()

        // Should transition to listening state
        #expect(audioManager.isListening, "Should be listening after start")
        #expect(audioManager.state == .listening, "State should be listening")
    }

    @Test("AudioManager state transitions from listening to idle")
    @MainActor
    func audioManagerStopListening() async throws {
        let audioManager = AudioManager()

        // Start listening first
        audioManager.startListening()
        #expect(audioManager.isListening, "Should be listening after start")

        // Stop listening
        audioManager.stopListening()

        // Should transition back to idle
        #expect(!audioManager.isListening, "Should not be listening after stop")
        #expect(audioManager.state == .idle, "State should be idle after stop")
    }

    @Test("AudioManager prevents duplicate start calls")
    @MainActor
    func audioManagerPreventsDuplicateStart() async throws {
        let audioManager = AudioManager()

        // Start listening
        audioManager.startListening()
        let firstState = audioManager.state

        // Try to start again
        audioManager.startListening()

        // State should remain the same
        #expect(audioManager.state == firstState, "State should not change on duplicate start")
        #expect(audioManager.isListening, "Should still be listening")
    }

    @Test("AudioManager prevents duplicate stop calls")
    @MainActor
    func audioManagerPreventsDuplicateStop() async throws {
        let audioManager = AudioManager()

        // Stop without starting (should be safe)
        audioManager.stopListening()

        // Should remain in idle state
        #expect(!audioManager.isListening, "Should not be listening")
        #expect(audioManager.state == .idle, "State should remain idle")
    }

    @Test("AudioManager handles audio route changes")
    @MainActor
    func audioManagerHandlesRouteChanges() async throws {
        let audioManager = AudioManager()

        // Create route change notification
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification,
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
            ]
        )

        // Start listening
        audioManager.startListening()
        #expect(audioManager.isListening, "Should be listening")

        // Handle route change
        audioManager.handleRouteChange(notification: notification)

        // Should stop listening when device unavailable
        #expect(!audioManager.isListening, "Should stop listening when device unavailable")
        #expect(audioManager.errorMessage != nil, "Should have error message")
    }

    @Test("AudioManager handles audio interruptions")
    @MainActor
    func audioManagerHandlesInterruptions() async throws {
        let audioManager = AudioManager()

        // Create interruption began notification
        let beganNotification = Notification(
            name: AVAudioSession.interruptionNotification,
            object: nil,
            userInfo: [
                AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue
            ]
        )

        // Start listening
        audioManager.startListening()
        #expect(audioManager.isListening, "Should be listening")

        // Handle interruption began
        audioManager.handleInterruption(notification: beganNotification)

        // Should stop listening when interrupted
        #expect(!audioManager.isListening, "Should stop listening when interrupted")
    }
}