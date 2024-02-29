//
//  VinylVizApp.swift
//  VinylViz
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI

@main
struct VinylVizApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        ImmersiveSpace {
            AudioReactiveView()
                .position(x: 700.0, y: -900)
                .offset(z: -900)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
