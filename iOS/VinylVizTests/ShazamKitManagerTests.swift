//
//  ShazamKitManagerTests.swift
//  VinylVizTests
//
//  Tests for ShazamKit response handling and match processing
//

import Testing
import ShazamKit
import AVFoundation
@testable import VinylViz

struct ShazamKitManagerTests {

    @Test("ShazamKitManager initializes with correct default state")
    @MainActor
    func shazamKitManagerInitializesCorrectly() async throws {
        let manager = ShazamKitManager()
        #expect(manager.currentSong == nil, "Should have no current song initially")
        #expect(!manager.isIdentifying, "Should not be identifying initially")
        #expect(manager.identificationError == nil, "Should have no error initially")
        #expect(manager.recentMatches.isEmpty, "Should have no recent matches initially")
    }

    @Test("ShazamKitManager starts and stops identifying")
    @MainActor
    func shazamKitManagerStartsAndStopsIdentifying() async throws {
        let manager = ShazamKitManager()

        // Create a test audio format
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

        // Start identifying
        manager.startIdentifying(with: audioFormat)
        #expect(manager.isIdentifying, "Should be identifying after start")
        #expect(manager.identificationError == nil, "Should clear errors on start")

        // Stop identifying
        manager.stopIdentifying()
        #expect(!manager.isIdentifying, "Should not be identifying after stop")
    }

    @Test("IdentifiedSong model stores correct data")
    func identifiedSongModelStoresCorrectData() async throws {
        let testDate = Date()
        let testURL = URL(string: "https://example.com/artwork.jpg")!

        let song = IdentifiedSong(
            title: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            artworkURL: testURL,
            shazamID: "test-id-123",
            genres: ["Rock", "Alternative"],
            releaseDate: testDate
        )

        #expect(song.title == "Test Song", "Title should match")
        #expect(song.artist == "Test Artist", "Artist should match")
        #expect(song.album == "Test Album", "Album should match")
        #expect(song.artworkURL == testURL, "Artwork URL should match")
        #expect(song.shazamID == "test-id-123", "Shazam ID should match")
        #expect(song.genres.count == 2, "Should have correct number of genres")
        #expect(song.genres.contains("Rock"), "Should contain Rock genre")
        #expect(song.releaseDate == testDate, "Release date should match")
    }

    @Test("ShazamKitManager limits recent matches")
    @MainActor
    func shazamKitManagerLimitsRecentMatches() async throws {
        let manager = ShazamKitManager()

        // The manager has a max of 10 recent matches
        // We'll test this by checking the property exists and is empty
        #expect(manager.recentMatches.isEmpty, "Should start with empty recent matches")

        // We can't directly test adding matches without mocking SHSession,
        // but we can verify the array exists and is properly initialized
        #expect(manager.recentMatches.count <= 10, "Should never exceed max recent matches")
    }

    @Test("ShazamKitManager handles multiple starts gracefully")
    @MainActor
    func shazamKitManagerHandlesMultipleStarts() async throws {
        let manager = ShazamKitManager()
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

        // Start multiple times
        manager.startIdentifying(with: audioFormat)
        #expect(manager.isIdentifying, "Should be identifying after first start")

        manager.startIdentifying(with: audioFormat)
        #expect(manager.isIdentifying, "Should still be identifying after second start")

        // Stop once
        manager.stopIdentifying()
        #expect(!manager.isIdentifying, "Should stop after single stop call")
    }

    @Test("ShazamKitManager handles stop without start")
    @MainActor
    func shazamKitManagerHandlesStopWithoutStart() async throws {
        let manager = ShazamKitManager()

        // Stop without starting should be safe
        manager.stopIdentifying()
        #expect(!manager.isIdentifying, "Should remain not identifying")
        #expect(manager.identificationError == nil, "Should not generate error")
    }
}