//
//  AudioEffect.swift
//  ParticleVolumeTest
//
//  Created by PJ Gray on 2/20/24.
//

import SwiftUI
import RealityKit

protocol AudioEffect {
    func configure(content: RealityViewContent, using audioMonitor: AudioInputMonitor)
}
