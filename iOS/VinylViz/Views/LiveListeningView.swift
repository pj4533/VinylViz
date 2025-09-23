//
//  LiveListeningView.swift
//  VinylViz
//
//  Audio-reactive visualization and real-time music experience
//

import SwiftUI

struct LiveListeningView: View {
    @StateObject private var viewModel = LiveListeningViewModel()
    @State private var showingPermissionAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Listening Status Section
                        listeningStatusView

                        // Control Button
                        controlButton

                        // Current Song Display
                        if let song = viewModel.currentSong {
                            songInfoView(song: song)
                        }

                        // Error Message
                        if let error = viewModel.errorMessage {
                            errorView(message: error)
                        }

                        // Permission Message
                        if viewModel.permissionDenied {
                            permissionDeniedView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Live Listening")
            .navigationBarTitleDisplayMode(.large)
            .alert("Microphone Access Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Open Settings") {
                    viewModel.openSettings()
                }
            } message: {
                Text("VinylViz needs microphone access to identify music. Please enable it in Settings.")
            }
        }
        .onAppear {
            Logger.Level.info("LiveListeningView: View appeared", log: Logger.ui)
        }
    }

    // MARK: - View Components

    /// Listening status indicator
    private var listeningStatusView: some View {
        VStack(spacing: 15) {
            // Animated waveform icon
            Image(systemName: viewModel.isListening ? "waveform" : "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(viewModel.isListening ? .blue : .gray)
                .symbolEffect(.variableColor.iterative, value: viewModel.isListening)
                .animation(.easeInOut, value: viewModel.isListening)

            // Status text
            Text(stateText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.isListening ? .primary : .secondary)
                .animation(.easeInOut, value: viewModel.listeningState)
        }
        .padding(.vertical, 20)
    }

    /// Main control button
    private var controlButton: some View {
        Button(action: {
            if viewModel.permissionDenied {
                showingPermissionAlert = true
            } else {
                viewModel.toggleListening()
            }
        }) {
            HStack {
                Image(systemName: viewModel.isListening ? "stop.fill" : "play.fill")
                    .font(.title2)
                Text(viewModel.isListening ? "Stop Listening" : "Start Listening")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isListening ? Color.red : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.hasPermission && !viewModel.permissionDenied)
    }

    /// Song information display
    private func songInfoView(song: IdentifiedSong) -> some View {
        VStack(spacing: 15) {
            // Song card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(song.title)
                            .font(.headline)
                            .lineLimit(2)

                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let album = song.album {
                            Text(album)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()

                    // Artwork placeholder
                    if song.artworkURL != nil {
                        AsyncImage(url: song.artworkURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // Genres
                if !song.genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(song.genres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            // Clear button
            Button(action: {
                viewModel.clearCurrentSong()
            }) {
                Text("Clear")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(), value: viewModel.currentSong?.shazamID)
    }

    /// Error message view
    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// Permission denied view
    private var permissionDeniedView: some View {
        VStack(spacing: 10) {
            Image(systemName: "mic.slash.fill")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Microphone Access Required")
                .font(.headline)

            Text("Enable microphone access to identify music")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Open Settings") {
                viewModel.openSettings()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    /// Get state text based on current state
    private var stateText: String {
        switch viewModel.listeningState {
        case .idle:
            return "Ready to Listen"
        case .listening:
            return "Listening..."
        case .identifying:
            return "Identifying Song..."
        case .identified:
            return "Song Identified!"
        }
    }
}

#Preview {
    LiveListeningView()
}