//
//  SuggestionsView.swift
//  VinylViz
//
//  AI-powered music recommendations and discovery
//

import SwiftUI

struct SuggestionsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)
                    .symbolEffect(.scale.up, isActive: true)

                Text("Suggestions")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("AI-powered music recommendations tailored to your taste")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Suggestions")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SuggestionsView()
}