//
//  TestHelpers.swift
//  SSG
//
//  Created by Michał Rudnicki on 20/03/2026.
//

import Foundation
import Testing
@testable import SSGCore

struct TestFixtures {
    static var fixturesURL: URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "Fixtures")
    }
    static func url(for name: String) -> URL {
        fixturesURL.appending(path: name)
    }
    static func makeOutputDir() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "ssg-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
        return url
    }
    static func makeConfig(fixture: String, outputDir: URL) -> Config {
        let input = url(for: fixture)
        var config = Config()
        config.contentDir   = input.appending(path: "content").path()
        config.templatesDir = input.appending(path: "templates").path()
        config.assetsDir    = input.appending(path: "assets").path()
        config.outputDir    = outputDir.path()
        return config
    }
}
