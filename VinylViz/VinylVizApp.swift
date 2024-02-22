//
//  VinylVizApp.swift
//  VinylViz
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI

@main
struct VinylVizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.5, height: 1.5, depth: 1.5, in: .meters)
    }
}
