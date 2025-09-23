//
//  LiveListeningView.swift
//  VinylViz
//
//  Audio-reactive visualization and real-time music experience
//

import SwiftUI

struct LiveListeningView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)
                    .symbolEffect(.pulse)

                Text("Live Listening")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Audio-reactive visualization and real-time music experience")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Live Listening")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    LiveListeningView()
}