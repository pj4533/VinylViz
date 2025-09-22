//
//  VinylVizApp.swift
//  VinylViz
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI

@main
@MainActor
struct VinylVizApp: App {
    @State private var immersionStyle: ImmersionStyle = .mixed
    @State private var model = SessionManager()

    var body: some Scene {
        ImmersiveSpace {
            AudioReactiveView()
                .environment(model)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed)
    }
}
