//
//  ContentViewTests.swift
//  VinylVizTests
//
//  Tests for ContentView tab management and structure
//

import Testing
import SwiftUI
@testable import VinylViz

struct ContentViewTests {

    @Test("ContentView initializes with correct default state")
    func contentViewInitializesCorrectly() async throws {
        let contentView = ContentView()
        #expect(contentView.selectedTab == "live", "Should start with Live Listening tab selected")
    }

    @Test("Tab selection state can be modified")
    func tabSelectionStateCanBeModified() async throws {
        var contentView = ContentView()

        contentView.selectedTab = "suggestions"
        #expect(contentView.selectedTab == "suggestions", "Should be able to select Suggestions tab")

        contentView.selectedTab = "settings"
        #expect(contentView.selectedTab == "settings", "Should be able to select Settings tab")

        contentView.selectedTab = "live"
        #expect(contentView.selectedTab == "live", "Should be able to return to Live Listening tab")
    }

    @Test("Tab values match expected identifiers")
    func tabValuesMatchExpectedIdentifiers() async throws {
        let validTabIdentifiers = Set(["live", "suggestions", "settings"])
        var contentView = ContentView()

        for identifier in validTabIdentifiers {
            contentView.selectedTab = identifier
            #expect(validTabIdentifiers.contains(contentView.selectedTab),
                   "Tab identifier '\(identifier)' should be valid")
        }
    }

    @Test("Invalid tab identifier handling")
    func invalidTabIdentifierHandling() async throws {
        var contentView = ContentView()
        let initialTab = contentView.selectedTab

        contentView.selectedTab = "invalid"

        #expect(contentView.selectedTab == "invalid" || contentView.selectedTab == initialTab,
               "Should either accept the value or maintain previous state")
    }
}