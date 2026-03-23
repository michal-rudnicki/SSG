//
//  ConfigLoader.swift
//  SSG
//
//  Created by Michał Rudnicki on 20/03/2026.
//

import Foundation

public struct CLIOverrides: Sendable {
    public var contentDir: String?
    public var outputDir: String?
    public var templatesDir: String?
    public var assetsDir: String?
    public var drafts: Bool?
    public var verbose: Bool?
    
    public init() {}
}

public struct ConfigLoader: Sendable {
    public static func load(configPath: String, overrides: CLIOverrides) throws -> Config {
        guard FileManager.default.fileExists(atPath: configPath) else { throw SSGError.configNotFound(path: configPath) }
        let content: String
        do { content = try String(contentsOfFile: configPath, encoding: .utf8) }
            catch { throw SSGError.fileReadError(path: configPath, underlying: error) }
        let parsed = parseYAML(content)
        var config = buildConfig(from: parsed)
        applyOverrides(&config, overrides: overrides)
        return config
    }
    public static func validate(_ config: Config) -> [String] {
        var errors: [String] = []
        if !FileManager.default.fileExists(atPath: config.contentDir) { errors.append("contentDir \"\(config.contentDir)\" nie istnieje") }
        if !FileManager.default.fileExists(atPath: config.templatesDir) { errors.append("templatesDir \"\(config.templatesDir)\" nie istnieje") }
        if config.site.baseURL.hasSuffix("/") { errors.append("site.baseURL nie może kończyć się na \"/\"") }
        return errors
    }
    static func parseYAML(_ content: String) -> [String: String] {
        var result: [String: String] = [:]
        var currentSection: String? = nil
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            let isIndented = line.hasPrefix(" ") || line.hasPrefix("\t")
            if !isIndented {
                if trimmed.hasSuffix(":") && !trimmed.contains(": ") {
                    currentSection = String(trimmed.dropLast()) // usuń ":"
                    continue
                } else {
                    currentSection = nil
            }   }
            let parts = trimmed.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            let fullKey: String
            if let section = currentSection {
                fullKey = "\(section).\(key)"
            } else {
                fullKey = key
            }
            result[fullKey] = value
        }
        return result
    }
    static func buildConfig(from parsed: [String: String]) -> Config {
        var config = Config()
        if let v = parsed["contentDir"]   { config.contentDir   = v }
        if let v = parsed["outputDir"]    { config.outputDir    = v }
        if let v = parsed["templatesDir"] { config.templatesDir = v }
        if let v = parsed["assetsDir"]    { config.assetsDir    = v }
        if let v = parsed["drafts"]  { config.drafts  = v == "true" }
        if let v = parsed["clean"]   { config.clean   = v == "true" }
        if let v = parsed["verbose"] { config.verbose = v == "true" }
        if let v = parsed["site.title"]       { config.site.title       = v }
        if let v = parsed["site.description"] { config.site.description = v }
        if let v = parsed["site.baseURL"]     { config.site.baseURL     = v }
        if let v = parsed["site.language"]    { config.site.language    = v }
        return config
    }
    static func applyOverrides(_ config: inout Config, overrides: CLIOverrides) {
        if let v = overrides.contentDir   { config.contentDir   = v }
        if let v = overrides.outputDir    { config.outputDir    = v }
        if let v = overrides.templatesDir { config.templatesDir = v }
        if let v = overrides.assetsDir    { config.assetsDir    = v }
        if let v = overrides.drafts       { config.drafts       = v }
        if let v = overrides.verbose      { config.verbose      = v }
    }
}
