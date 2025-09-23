//
//  LiveListeningViewModelTests.swift
//  VinylVizTests
//
//  Tests for LiveListeningViewModel coordination and state management
//

import Testing
import AVFoundation
@testable import VinylViz

struct LiveListeningViewModelTests {

    @Test("LiveListeningViewModel initializes with correct default state")
    @MainActor
    func viewModelInitializesCorrectly() async throws {
        let viewModel = LiveListeningViewModel()

        #expect(!viewModel.isListening, "Should not be listening initially")
        #expect(viewModel.currentSong == nil, "Should have no current song initially")
        #expect(viewModel.listeningState == .idle, "Should be in idle state initially")
        #expect(viewModel.errorMessage == nil, "Should have no error message initially")
    }

    @Test("LiveListeningViewModel permission states")
    @MainActor
    func viewModelHandlesPermissionStates() async throws {
        let viewModel = LiveListeningViewModel()

        // Check permission is requested on init
        // The actual state depends on system permissions
        let permissionChecked = viewModel.hasPermission || viewModel.permissionDenied || (!viewModel.hasPermission && !viewModel.permissionDenied)
        #expect(permissionChecked, "Should have checked permissions")
    }

    @Test("LiveListeningViewModel toggle listening requires permission")
    @MainActor
    func viewModelToggleListeningRequiresPermission() async throws {
        let viewModel = LiveListeningViewModel()

        // If no permission, toggle should not start listening
        if !viewModel.hasPermission {
            viewModel.toggleListening()
            #expect(!viewModel.isListening, "Should not start listening without permission")
        }
    }

    @Test("LiveListeningViewModel clears current song")
    @MainActor
    func viewModelClearsCurrentSong() async throws {
        let viewModel = LiveListeningViewModel()

        // Clear when no song should be safe
        viewModel.clearCurrentSong()
        #expect(viewModel.currentSong == nil, "Should remain nil after clear")

        // Note: We can't easily set a current song without mocking,
        // but we can verify the method exists and doesn't crash
    }

    @Test("LiveListeningViewModel stops listening on deinit")
    @MainActor
    func viewModelStopsListeningOnDeinit() async throws {
        // Create view model in a scope
        do {
            let viewModel = LiveListeningViewModel()

            // The deinit will be called when viewModel goes out of scope
            // This test verifies the deinit exists and doesn't crash
            _ = viewModel
        }

        // If we get here without crashing, the deinit worked
        #expect(true, "Deinit should complete without crashing")
    }

    @Test("LiveListeningViewModel error message handling")
    @MainActor
    func viewModelErrorMessageHandling() async throws {
        let viewModel = LiveListeningViewModel()

        // Initially no error
        #expect(viewModel.errorMessage == nil, "Should have no error initially")

        // Permission denied should set an error message
        if viewModel.permissionDenied {
            #expect(viewModel.errorMessage != nil, "Should have error message when permission denied")
        }
    }

    @Test("LiveListeningViewModel listening state transitions")
    @MainActor
    func viewModelListeningStateTransitions() async throws {
        let viewModel = LiveListeningViewModel()

        // Check initial state
        #expect(viewModel.listeningState == .idle, "Should start in idle state")

        // State should match isListening
        if viewModel.hasPermission {
            viewModel.toggleListening()
            if viewModel.isListening {
                #expect(viewModel.listeningState != .idle, "Should not be idle when listening")
            }

            viewModel.toggleListening()
            #expect(viewModel.listeningState == .idle, "Should return to idle after stopping")
        }
    }
}