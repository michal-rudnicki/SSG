//
//  Models.swift
//  SSG
//
//  Created by Michał Rudnicki on 19/03/2026.
//

import Foundation

public struct PageMetadata: Sendable {
    public var title: String = ""
    public var description: String = ""
    public var date: String = ""
    public var layout: String = "page"
    public var draft: Bool = false
    public var slug: String? = nil
    public var extra: [String: String] = [:]
    
    public init(title: String = "",
                description: String = "",
                date: String = "",
                layout: String = "page",
                draft: Bool = false,
                slug: String? = nil,
                extra: [String: String] = [:]) {
        self.title = title
        self.description = description
        self.date = date
        self.layout = layout
        self.draft = draft
        self.slug = slug
        self.extra = extra
    }
}

public struct Page: Sendable {
    public let metadata: PageMetadata
    public let markdownContent: String
    public let sourcePath: String
    public let outputPath: String
    public let slug: String
    public let url: String
    
    public init(metadata: PageMetadata,
                markdownContent: String,
                sourcePath: String,
                outputPath: String,
                slug: String,
                url: String) {
        self.metadata = metadata
        self.markdownContent = markdownContent
        self.sourcePath = sourcePath
        self.outputPath = outputPath
        self.slug = slug
        self.url = url
    }
}

public struct SiteConfig: Sendable {
    public var title: String = ""
    public var description: String = ""
    public var baseURL: String = ""
    public var language: String = "pl"
    
    public init (title: String = "",
          description: String = "",
          baseURL: String = "",
          language: String = "pl") {
        self.title = title
        self.description = description
        self.baseURL = baseURL
        self.language = language
    }
}

public struct Config: Sendable {
    public var contentDir: String = "content"
    public var outputDir: String = "public"
    public var templatesDir: String = "templates"
    public var assetsDir: String = "assets"
    public var drafts: Bool = false
    public var clean: Bool = true
    public var verbose: Bool = false
    public var site: SiteConfig = SiteConfig()
    
    public init(contentDir: String = "content",
                outputDir: String = "public",
                templatesDir: String = "templates",
                assetsDir: String = "assets",
                drafts: Bool = false,
                clean: Bool = true,
                verbose: Bool = false,
                site: SiteConfig = SiteConfig()) {
        self.contentDir = contentDir
        self.outputDir = outputDir
        self.templatesDir = templatesDir
        self.assetsDir = assetsDir
        self.drafts = drafts
        self.clean = clean
        self.verbose = verbose
        self.site = site
    }
}

public enum SSGError: Error, Sendable {
    case configNotFound(path: String)
    case configInvalid(errors: [String])
    case directoryNotFound(path: String)
    case templateNotFound(name: String)
    case fileReadError(path: String, underlying: Error)
    case fileWriteError(path: String, underlying: Error)
    case frontMatterInvalid(file: String, reason: String)
}

extension SSGError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .configNotFound(let path):
            return "Nie znaleziono pliku konfiguracyjnego: \(path)"
        case .configInvalid(let errors):
            return "Błędy konfiguracji:\n" + errors.map { "  • \($0)" }.joined(separator: "\n")
        case .directoryNotFound(let path):
            return "Katalog nie istnieje: \(path)"
        case .templateNotFound(let name):
            return "Nie znaleziono szablonu: templates/\(name).html"
        case .fileReadError(let path, let error):
            return "Błąd odczytu pliku \(path): \(error.localizedDescription)"
        case .fileWriteError(let path, let error):
            return "Błąd zapisu pliku \(path): \(error.localizedDescription)"
        case .frontMatterInvalid(let file, let reason):
            return "Nieprawidłowy front matter w \(file): \(reason)"
        }
    }
}
