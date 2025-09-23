//
//  ContentView.swift
//  VinylViz
//
//  Created by PJ Gray on 9/23/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = "live"

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Live Listening", systemImage: "waveform.circle", value: "live") {
                LiveListeningView()
            }

            Tab("Suggestions", systemImage: "sparkles.rectangle.stack", value: "suggestions") {
                SuggestionsView()
            }

            Tab("Settings", systemImage: "gearshape", value: "settings") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
