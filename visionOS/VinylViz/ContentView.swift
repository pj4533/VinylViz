//
//  ContentView.swift
//  VinylViz
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        AudioReactiveView()
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
