//
//  FrontMatterParser.swift
//  SSG
//
//  Created by Michał Rudnicki on 20/03/2026.
//

import Foundation

public struct FrontMatterParser: Sendable {
    public static func parse(_ rawContent: String, filePath: String) throws -> (PageMetadata, String) {
        let lines = rawContent.components(separatedBy: .newlines)
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            return (PageMetadata(), rawContent)
        }
        var closingIndex: Int? = nil
        for i in 1..<lines.count {
            if lines[i].trimmingCharacters(in: .whitespaces) == "---" {
                closingIndex = i
                break
        }   }
        guard let closing = closingIndex else {
            throw SSGError.frontMatterInvalid(file: filePath, reason: "Brak zamykającego separatora '---'")
        }
        let frontMatterLines = Array(lines[1..<closing])
        var metadata = PageMetadata()
        for line in frontMatterLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            guard let colonIndex = trimmed.firstIndex(of: ":") else { continue }
            let key = String(trimmed[trimmed.startIndex..<colonIndex])
                .trimmingCharacters(in: .whitespaces)
            let afterColon = trimmed.index(after: colonIndex)
            let value = String(trimmed[afterColon...])
                .trimmingCharacters(in: .whitespaces)
            switch key {
            case "title":
                metadata.title = value
            case "description":
                metadata.description = value
            case "date":
                metadata.date = value
            case "layout":
                if !value.isEmpty { metadata.layout = value }
            case "draft":
                metadata.draft = (value == "true")
            case "slug":
                metadata.slug = value.isEmpty ? nil : value
            case "tags":
                break
            default:
                metadata.extra[key] = value
        }   }
        if metadata.title.isEmpty {
            let filename = URL(fileURLWithPath: filePath)
                .deletingPathExtension()
                .lastPathComponent
            print("\(filePath): brak pola \"title\", używam nazwy pliku: \(filename)")
            metadata.title = filename
        }
        let markdownLines = Array(lines[(closing + 1)...])
        let markdownContent = markdownLines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (metadata, markdownContent)
    }
}
