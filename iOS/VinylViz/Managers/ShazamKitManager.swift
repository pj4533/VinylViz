//
//  ShazamKitManager.swift
//  VinylViz
//
//  Handles ShazamKit integration for music identification
//

import Foundation
import ShazamKit
import AVFoundation
import Combine

/// Model for simplified song information
struct IdentifiedSong: Equatable {
    let title: String
    let artist: String
    let album: String?
    let artworkURL: URL?
    let shazamID: String
    let genres: [String]
    let releaseDate: Date?
}

/// Manages ShazamKit session and song identification
@MainActor
class ShazamKitManager: NSObject, ObservableObject {
    /// Published properties for UI binding
    @Published var currentSong: IdentifiedSong?
    @Published var isIdentifying = false
    @Published var identificationError: String?
    @Published var recentMatches: [IdentifiedSong] = []

    /// ShazamKit components
    private var session: SHSession?
    private var audioFormat: AVAudioFormat?
    private var signatureGenerator: SHSignatureGenerator?

    /// Batch processing
    private var audioBufferQueue: [AVAudioPCMBuffer] = []
    private let maxBufferCount = 10
    private var isProcessingBatch = false

    /// Retry logic
    private var retryCount = 0
    private let maxRetries = 3
    private var retryTimer: Timer?

    /// Recent matches cache
    private let maxRecentMatches = 10
    private var matchCache: [String: IdentifiedSong] = [:]

    override init() {
        super.init()
        setupShazamSession()
    }

    /// Initialize ShazamKit session
    private func setupShazamSession() {
        Logger.Level.info("ShazamKitManager: Setting up ShazamKit session", log: Logger.shazamKit)

        session = SHSession()
        session?.delegate = self

        Logger.Level.debug("ShazamKitManager: ShazamKit session initialized", log: Logger.shazamKit)
    }

    /// Start identifying music
    func startIdentifying(with audioFormat: AVAudioFormat) {
        Logger.Level.info("ShazamKitManager: Starting music identification", log: Logger.shazamKit)

        self.audioFormat = audioFormat
        signatureGenerator = SHSignatureGenerator()
        isIdentifying = true
        identificationError = nil
        retryCount = 0

        Logger.Level.notice("ShazamKitManager: Ready to identify music", log: Logger.shazamKit)
    }

    /// Stop identifying music
    func stopIdentifying() {
        Logger.Level.info("ShazamKitManager: Stopping music identification", log: Logger.shazamKit)

        isIdentifying = false
        audioBufferQueue.removeAll()
        signatureGenerator = nil
        retryTimer?.invalidate()
        retryTimer = nil

        Logger.Level.notice("ShazamKitManager: Stopped identifying music", log: Logger.shazamKit)
    }

    /// Process audio buffer from AudioManager
    private func processAudioBufferInternal(_ buffer: AVAudioPCMBuffer) {
        guard isIdentifying else { return }

        // Add buffer to queue for batch processing
        audioBufferQueue.append(buffer)

        // Process batch when we have enough buffers
        if audioBufferQueue.count >= maxBufferCount && !isProcessingBatch {
            processBatchedAudio()
        }
    }

    /// Process batched audio buffers for efficiency
    private func processBatchedAudio() {
        guard !isProcessingBatch, !audioBufferQueue.isEmpty else { return }

        Logger.Level.debug("ShazamKitManager: Processing batch of \(audioBufferQueue.count) audio buffers", log: Logger.shazamKit)
        isProcessingBatch = true

        Task {
            do {
                // Generate signature from audio buffers
                for buffer in audioBufferQueue {
                    try await signatureGenerator?.append(buffer, at: nil)
                }

                // Get signature and match
                if let signature = signatureGenerator?.signature() {
                    Logger.Level.info("ShazamKitManager: Generated signature, matching...", log: Logger.shazamKit)
                    session?.match(signature)
                }

                // Clear processed buffers
                audioBufferQueue.removeAll()
                isProcessingBatch = false

            } catch {
                Logger.Level.error("ShazamKitManager: Failed to process audio: \(error.localizedDescription)", log: Logger.shazamKit)
                identificationError = "Failed to process audio"
                isProcessingBatch = false
            }
        }
    }

    /// Convert SHMatch to IdentifiedSong
    private func createSong(from match: SHMatch) -> IdentifiedSong {
        let mediaItem = match.mediaItems.first

        let title = mediaItem?.title ?? "Unknown Title"
        let artist = mediaItem?.artist ?? "Unknown Artist"
        let album = mediaItem?.title
        let artworkURL = mediaItem?.artworkURL
        let shazamID = mediaItem?.shazamID ?? UUID().uuidString
        let genres = mediaItem?.genres ?? []
        let releaseDate: Date? = nil // releaseDate not available in SHMatchedMediaItem

        Logger.Level.info("ShazamKitManager: Created song object - \(title) by \(artist)", log: Logger.shazamKit)

        return IdentifiedSong(
            title: title,
            artist: artist,
            album: album,
            artworkURL: artworkURL,
            shazamID: shazamID,
            genres: genres,
            releaseDate: releaseDate
        )
    }

    /// Add song to recent matches
    private func addToRecentMatches(_ song: IdentifiedSong) {
        // Check if already in cache
        if matchCache[song.shazamID] != nil {
            Logger.Level.debug("ShazamKitManager: Song already in cache, skipping", log: Logger.shazamKit)
            return
        }

        // Add to cache and recent list
        matchCache[song.shazamID] = song
        recentMatches.insert(song, at: 0)

        // Limit recent matches size
        if recentMatches.count > maxRecentMatches {
            recentMatches.removeLast()
        }

        Logger.Level.info("ShazamKitManager: Added to recent matches (total: \(recentMatches.count))", log: Logger.shazamKit)
    }

    /// Retry failed identification
    private func retryIdentification() {
        guard retryCount < maxRetries else {
            Logger.Level.warning("ShazamKitManager: Max retries reached, giving up", log: Logger.shazamKit)
            identificationError = "Could not identify song after \(maxRetries) attempts"
            return
        }

        retryCount += 1
        Logger.Level.info("ShazamKitManager: Retrying identification (attempt \(retryCount)/\(maxRetries))", log: Logger.shazamKit)

        // Retry after delay
        retryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.processBatchedAudio()
            }
        }
    }
}

// MARK: - SHSessionDelegate
extension ShazamKitManager: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        Logger.Level.notice("ShazamKitManager: Match found!", log: Logger.shazamKit)

        Task { @MainActor in
            let song = createSong(from: match)
            currentSong = song
            addToRecentMatches(song)
            identificationError = nil
            retryCount = 0

            Logger.Level.info("ShazamKitManager: Successfully identified: \(song.title) by \(song.artist)", log: Logger.shazamKit)
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        Logger.Level.warning("ShazamKitManager: No match found", log: Logger.shazamKit)

        Task { @MainActor in
            if let error = error {
                Logger.Level.error("ShazamKitManager: Identification error: \(error.localizedDescription)", log: Logger.shazamKit)
                identificationError = error.localizedDescription
            }

            // Retry if appropriate
            if retryCount < maxRetries {
                retryIdentification()
            } else {
                identificationError = "Could not identify the song"
            }
        }
    }
}

// MARK: - ShazamKitManagerDelegate
extension ShazamKitManager: ShazamKitManagerDelegate {
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        processAudioBufferInternal(buffer)
    }
}