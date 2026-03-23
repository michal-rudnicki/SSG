//
//  SiteBuilderIntegrationTests.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Foundation
import Testing
@testable import SSGCore

@Suite("SiteBuilder — Integracja")
struct SiteBuilderIntegrationTests {
    @Test("Build minimal-site → index.html istnieje")
    func buildCreatesIndexHtml() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        let config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        try SiteBuilder(config: config).build()
        #expect(FileManager.default.fileExists(atPath: output.appending(path: "index.html").path()))
    }
    @Test("Build minimal-site → about/index.html istnieje")
    func buildCreatesAboutHtml() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        let config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        try SiteBuilder(config: config).build()
        #expect(FileManager.default.fileExists(atPath: output.appending(path: "about/index.html").path()))
    }
    @Test("Build minimal-site → assets/style.css skopiowany")
    func buildCopiesAssets() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        let config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        try SiteBuilder(config: config).build()
        #expect(FileManager.default.fileExists(atPath: output.appending(path: "assets/style.css").path()))
    }
    @Test("Post z draft: true pomijany gdy config.drafts = false")
    func draftPostSkippedByDefault() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        var config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        config.drafts = false
        try SiteBuilder(config: config).build()
        #expect(!FileManager.default.fileExists(atPath: output.appending(path: "posts/draft-post/index.html").path()))
    }
    @Test("Post z draft: true uwzględniany gdy config.drafts = true")
    func draftPostIncludedWithFlag() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        var config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        config.drafts = true
        try SiteBuilder(config: config).build()
        #expect(FileManager.default.fileExists(atPath: output.appending(path: "posts/draft-post/index.html").path()))
    }
    @Test("Nieistniejący contentDir → rzuca SSGError")
    func invalidContentDirThrows() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        var config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        config.contentDir = "/nie/istnieje/content"
        #expect(throws: SSGError.self) { try SiteBuilder(config: config).build() }
    }
    @Test("Wynikowy index.html zawiera wyrenderowany Markdown i zmienne szablonu")
    func indexHtmlContainsRenderedContent() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        let config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        try SiteBuilder(config: config).build()
        let html = try String( contentsOfFile: output.appending(path: "index.html").path(), encoding: .utf8)
        #expect(html.contains("<h1"))
        #expect(html.contains("Strona główna"))
        #expect(html.contains("<!DOCTYPE html>"))
    }
    @Test("config.clean = true usuwa i odtwarza outputDir")
    func cleanModeRemovesExistingOutput() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        let staleFile = output.appending(path: "stale-file.html")
        try "stary plik".write(to: staleFile, atomically: true, encoding: .utf8)
        var config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        config.clean = true
        try SiteBuilder(config: config).build()
        #expect(!FileManager.default.fileExists(atPath: staleFile.path()))
    }
    @Test("config.clean = false zachowuje istniejące pliki")
    func noCleanModePreservesExistingFiles() throws {
        let output = try TestFixtures.makeOutputDir()
        defer { try? FileManager.default.removeItem(at: output) }
        let preservedFile = output.appending(path: "preserved.html")
        try "zachowany plik".write(to: preservedFile, atomically: true, encoding: .utf8)
        var config = TestFixtures.makeConfig(fixture: "minimal-site", outputDir: output)
        config.clean = false
        try SiteBuilder(config: config).build()
        #expect(FileManager.default.fileExists(atPath: preservedFile.path()))
    }
}
