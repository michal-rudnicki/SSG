//
//  SiteBuilder.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Foundation

public struct SiteBuilder: Sendable {
    public let config: Config
    
    public init(config: Config) {
        self.config = config
    }

    public func build() throws {
        let validationErrors = ConfigLoader.validate(config)
        guard validationErrors.isEmpty else { throw SSGError.configInvalid(errors: validationErrors) }
        let startTime = Date()
        let fm = FileManager.default
        print("Budowanie strony...")
        try prepareOutputDirectory(fm: fm)
        let mdFiles = fm.findFiles(in: config.contentDir, extension: "md")
        var pages: [Page] = []
        for filePath in mdFiles {
            if let page = try parsePage(at: filePath) { pages.append(page) }
        }
        print("Znaleziono \(pages.count) stron")
        for page in pages { try renderPage(page) }
        if fm.fileExists(atPath: config.assetsDir) {
            let assetsOutput = (config.outputDir as NSString).appendingPathComponent("assets")
            try fm.copyDirectory(from: config.assetsDir, to: assetsOutput)
        }
        let elapsed = Date().timeIntervalSince(startTime)
        print(String(format: "Gotowe! \(pages.count) stron w %.2fs → \(config.outputDir)/", elapsed))
    }
    private func prepareOutputDirectory(fm: FileManager) throws {
        if config.clean && fm.fileExists(atPath: config.outputDir) {
            do { try fm.removeItem(atPath: config.outputDir) }
            catch { throw SSGError.fileWriteError(path: config.outputDir, underlying: error) }
        }
        if !fm.fileExists(atPath: config.outputDir) {
            do { try fm.createDirectory(atPath: config.outputDir, withIntermediateDirectories: true) }
            catch { throw SSGError.fileWriteError(path: config.outputDir, underlying: error) }
        }
    }
    private func parsePage(at filePath: String) throws -> Page? {
        let rawContent: String
        do { rawContent = try String(contentsOfFile: filePath, encoding: .utf8) }
        catch { throw SSGError.fileReadError(path: filePath, underlying: error) }
        let (metadata, markdownContent) = try FrontMatterParser.parse(rawContent, filePath: filePath)
        if metadata.draft && !config.drafts {
            if config.verbose { print("\(filePath): draft: true, pomijam") }
            return nil
        }
        let slug       = computeSlug(for: filePath, metadata: metadata)
        let outputPath = computeOutputPath(slug: slug)
        let url        = config.site.baseURL + "/" + slug
        return Page(metadata: metadata, markdownContent: markdownContent, sourcePath: filePath, outputPath: outputPath, slug: slug, url: url)
    }
    private func renderPage(_ page: Page) throws {
        let contentHTML     = MarkdownParser.toHTML(page.markdownContent)
        let templateContent = try loadTemplate(for: page)
        var context: [String: String] = [:]
        context["content"] = contentHTML
        context["title"] = page.metadata.title
        context["description"] = page.metadata.description
        context["date"] = page.metadata.date
        context["slug"] = page.slug
        context["url"] = page.url
        context["site.title"] = config.site.title
        context["site.description"] = config.site.description
        context["site.baseURL"] = config.site.baseURL
        context["site.language"] = config.site.language
        for (key, value) in page.metadata.extra { context[key] = value }
        let html = TemplateEngine.render(template: templateContent, context: context)
        let fm = FileManager.default
        try fm.createParentDirectories(for: page.outputPath)
        do { try html.write(toFile: page.outputPath, atomically: true, encoding: .utf8) }
        catch { throw SSGError.fileWriteError(path: page.outputPath, underlying: error) }
        if config.verbose { print("\(page.sourcePath) → \(page.outputPath)") }
    }
    private func loadTemplate(for page: Page) throws -> String {
        let fm  = FileManager.default
        let layoutName = page.metadata.layout
        let tmplPath = (config.templatesDir as NSString).appendingPathComponent("\(layoutName).html")
        if fm.fileExists(atPath: tmplPath) {
            do { return try String(contentsOfFile: tmplPath, encoding: .utf8) }
            catch { throw SSGError.fileReadError(path: tmplPath, underlying: error) }
        }
        print("\(page.sourcePath): szablon \"\(layoutName)\" nie istnieje, używam \"page\"")
        let fallbackPath = (config.templatesDir as NSString).appendingPathComponent("page.html")
        guard fm.fileExists(atPath: fallbackPath) else { throw SSGError.templateNotFound(name: layoutName) }
        do { return try String(contentsOfFile: fallbackPath, encoding: .utf8) }
        catch { throw SSGError.fileReadError(path: fallbackPath, underlying: error) }
    }
    private func computeSlug(for filePath: String, metadata: PageMetadata) -> String {
        if let slug = metadata.slug, !slug.isEmpty { return slug }
        var relative = filePath
        if relative.hasPrefix(config.contentDir) { relative = String(relative.dropFirst(config.contentDir.count)) }
        while relative.hasPrefix("/") { relative = String(relative.dropFirst()) }
        if relative.hasSuffix(".md") { relative = String(relative.dropLast(3)) }
        let nsRelative = relative as NSString
        let directory = nsRelative.deletingLastPathComponent
        let filename = nsRelative.lastPathComponent
        let slugFilename: String
        let datePrefixPattern = #"^\d{4}-\d{2}-\d{2}-"#
        if let prefixRange = filename.range(of: datePrefixPattern, options: .regularExpression) {
            slugFilename = String(filename[prefixRange.upperBound...])
        } else {
            slugFilename = filename
        }
        if directory.isEmpty || directory == "." { return slugFilename }
        return directory + "/" + slugFilename
    }
    private func computeOutputPath(slug: String) -> String {
        if slug == "index" { return (config.outputDir as NSString).appendingPathComponent("index.html") }
        let slugDir = (config.outputDir as NSString).appendingPathComponent(slug)
        return (slugDir as NSString).appendingPathComponent("index.html")
    }
}
