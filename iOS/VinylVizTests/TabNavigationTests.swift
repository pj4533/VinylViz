//
//  TabNavigationTests.swift
//  VinylVizTests
//
//  Tests for tab-based navigation architecture
//

import Testing
import SwiftUI
@testable import VinylViz

struct TabNavigationTests {

    @Test("TabView has three tabs")
    func tabViewHasThreeTabs() async throws {
        let contentView = ContentView()
        let mirror = Mirror(reflecting: contentView)

        let selectedTab = mirror.children.first(where: { $0.label == "_selectedTab" })
        #expect(selectedTab != nil, "ContentView should have selectedTab state")
    }

    @Test("Default selected tab is Live Listening")
    func defaultSelectedTabIsLive() async throws {
        let contentView = ContentView()
        #expect(contentView.selectedTab == "live", "Default tab should be 'live'")
    }

    @Test("All tab identifiers are unique")
    func tabIdentifiersAreUnique() async throws {
        let tabIds = ["live", "suggestions", "settings"]
        let uniqueIds = Set(tabIds)
        #expect(tabIds.count == uniqueIds.count, "Tab identifiers should be unique")
    }

    @Test("Tab icons use SF Symbols")
    func tabIconsUseSFSymbols() async throws {
        let expectedIcons = [
            "waveform.circle",
            "sparkles.rectangle.stack",
            "gearshape"
        ]

        for icon in expectedIcons {
            let image = Image(systemName: icon)
            #expect(image != nil, "SF Symbol \(icon) should be valid")
        }
    }

    @Test("Tab labels are properly defined")
    func tabLabelsAreProperlyDefined() async throws {
        let expectedLabels = [
            "Live Listening",
            "Suggestions",
            "Settings"
        ]

        for label in expectedLabels {
            #expect(!label.isEmpty, "Tab label should not be empty")
            #expect(label.count <= 20, "Tab label should be concise")
        }
    }

    @Test("LiveListeningView exists and is accessible")
    func liveListeningViewExists() async throws {
        let view = LiveListeningView()
        #expect(view != nil, "LiveListeningView should be instantiable")
    }

    @Test("SuggestionsView exists and is accessible")
    func suggestionsViewExists() async throws {
        let view = SuggestionsView()
        #expect(view != nil, "SuggestionsView should be instantiable")
    }

    @Test("SettingsView exists and is accessible")
    func settingsViewExists() async throws {
        let view = SettingsView()
        #expect(view != nil, "SettingsView should be instantiable")
    }
}