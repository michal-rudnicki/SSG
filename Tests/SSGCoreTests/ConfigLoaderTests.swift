//
//  ConfigLoaderTests.swift
//  SSG
//
//  Created by Michał Rudnicki on 20/03/2026.
//

import Foundation
import Testing
@testable import SSGCore

struct ConfigLoaderTests {
    @Test func validYAMLParsesCorrectly() throws {
        let fixture = TestFixtures.url(for: "minimal-site")
        let yamlPath = fixture.appending(path: "ssg.yaml").path()
        let config = try ConfigLoader.load(configPath: yamlPath, overrides: CLIOverrides())
        #expect(config.contentDir == "content")
        #expect(config.outputDir == "public")
        #expect(config.templatesDir == "templates")
        #expect(config.site.title == "Test Site")
        #expect(config.site.baseURL == "https://example.com")
        #expect(config.site.language == "pl")
    }
    @Test func missingFilethrowsConfigNotFound() {
        let fakePath = "/tmp/nie-istnieje-\(UUID().uuidString).yaml"
        #expect(throws: SSGError.self) { try ConfigLoader.load(configPath: fakePath, overrides: CLIOverrides()) }
    }
    @Test func validConfigPassesValidation() throws {
        let fixture = TestFixtures.url(for: "minimal-site")
        var config = Config()
        config.contentDir   = fixture.appending(path: "content").path()
        config.templatesDir = fixture.appending(path: "templates").path()
        config.site.baseURL = "https://example.com"
        let errors = ConfigLoader.validate(config)
        #expect(errors.isEmpty)
    }
    @Test func missingDirectoriesReturnsTwoErrors() {
        var config = Config()
        config.contentDir   = "/nie/istnieje/content"
        config.templatesDir = "/nie/istnieje/templates"
        let errors = ConfigLoader.validate(config)
        #expect(errors.count == 2)
        #expect(errors[0].contains("contentDir"))
        #expect(errors[1].contains("templatesDir"))
    }
    @Test func baseURLWithTrailingSlashReturnsError() {
        var config = Config()
        config.contentDir   = "/tmp"
        config.templatesDir = "/tmp"
        config.site.baseURL = "https://example.com/"
        let errors = ConfigLoader.validate(config)
        #expect(errors.count == 1)
        #expect(errors[0].contains("baseURL"))
    }
    @Test func cliOverridesWinOverYAML() throws {
        // given
        let fixture = TestFixtures.url(for: "minimal-site")
        let yamlPath = fixture.appending(path: "ssg.yaml").path()
        var overrides = CLIOverrides()
        overrides.contentDir = "custom-content"
        overrides.verbose    = true
        let config = try ConfigLoader.load(configPath: yamlPath, overrides: overrides)
        #expect(config.contentDir == "custom-content")
        #expect(config.verbose == true)
        #expect(config.site.title == "Test Site")
    }
    @Test func emptyOverridesKeepYAMLValues() throws {
        let fixture = TestFixtures.url(for: "minimal-site")
        let yamlPath = fixture.appending(path: "ssg.yaml").path()
        let config = try ConfigLoader.load(configPath: yamlPath, overrides: CLIOverrides())
        #expect(config.contentDir == "content")
        #expect(config.verbose == false)
    }
}
