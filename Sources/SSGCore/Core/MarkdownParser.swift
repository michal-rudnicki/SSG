//
//  Untitled.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Foundation

public struct MarkdownParser: Sendable {
    public static func toHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: "\n")
        var html = ""
        var i = 0
        while i < lines.count {
            let line  = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                i += 1
                continue
            }
            if trimmed.hasPrefix("```") {
                let lang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                i += 1
                var codeLines: [String] = []
                while i < lines.count {
                    if lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        i += 1
                        break
                    }
                    codeLines.append(lines[i])
                    i += 1
                }
                let escaped = escapeCode(codeLines.joined(separator: "\n"))
                if lang.isEmpty {
                    html += "<pre><code>\(escaped)</code></pre>\n"
                } else {
                    html += "<pre><code class=\"language-\(lang)\">\(escaped)</code></pre>\n"
                }
                continue
            }
            if trimmed.hasPrefix("#") {
                let level = trimmed.prefix(while: { $0 == "#" }).count
                let afterHashes = String(trimmed.dropFirst(level))
                if level <= 6 && (afterHashes.isEmpty || afterHashes.first == " ") {
                    let text = afterHashes.trimmingCharacters(in: .whitespaces)
                    let id   = slugify(text)
                    html += "<h\(level) id=\"\(id)\">\(renderInline(text))</h\(level)>\n"
                    i += 1
                    continue
                }   }
            if trimmed == "---" {
                html += "<hr>\n"
                i += 1
                continue
            }
            if trimmed.hasPrefix("> ") || trimmed == ">" {
                var quoteLines: [String] = []
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    if t.hasPrefix("> ") {
                        quoteLines.append(String(t.dropFirst(2)))
                        i += 1
                    } else if t == ">" {
                        i += 1
                    } else {
                        break
                }   }
                let quoteText = quoteLines.joined(separator: " ")
                html += "<blockquote><p>\(renderInline(quoteText))</p></blockquote>\n"
                continue
            }
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                var items: [String] = []
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    if t.hasPrefix("- ") {
                        items.append(String(t.dropFirst(2)))
                        i += 1
                    } else if t.hasPrefix("* ") {
                        items.append(String(t.dropFirst(2)))
                        i += 1
                    } else {
                        break
                }   }
                html += "<ul>\n"
                for item in items { html += "<li>\(renderInline(item))</li>\n" }
                html += "</ul>\n"
                continue
            }
            if trimmed.range(of: #"^\d+\. "#, options: .regularExpression) != nil {
                var items: [String] = []
                while i < lines.count {
                    let t = lines[i].trimmingCharacters(in: .whitespaces)
                    guard t.range(of: #"^\d+\. "#, options: .regularExpression) != nil else { break }
                    let content = t.replacingOccurrences(
                        of: #"^\d+\. "#, with: "", options: .regularExpression
                    )
                    items.append(content)
                    i += 1
                }
                html += "<ol>\n"
                for item in items { html += "<li>\(renderInline(item))</li>\n" }
                html += "</ol>\n"
                continue
            }
            var paraLines: [String] = []
            while i < lines.count {
                let t = lines[i].trimmingCharacters(in: .whitespaces)
                if t.isEmpty { break }
                if isBlockStart(t) { break }
                paraLines.append(lines[i])
                i += 1
            }
            if !paraLines.isEmpty {
                var parts: [String] = []
                for (idx, pLine) in paraLines.enumerated() {
                    let isLast = idx == paraLines.count - 1
                    if !isLast && pLine.hasSuffix("  ") {
                        parts.append(renderInline(String(pLine.dropLast(2))) + "<br>")
                    } else {
                        parts.append(renderInline(pLine))
                    }   }
                html += "<p>\(parts.joined(separator: "\n"))</p>\n"
            }   }
        return html
    }
    static func isBlockStart(_ trimmed: String) -> Bool {
        if trimmed.hasPrefix("```") { return true }
        if trimmed.hasPrefix("> ") || trimmed == ">" { return true }
        if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") { return true }
        if trimmed == "---" { return true }
        if trimmed.range(of: #"^\d+\. "#, options: .regularExpression) != nil { return true }
        if trimmed.hasPrefix("#") {
            let level = trimmed.prefix(while: { $0 == "#" }).count
            if level <= 6 {
                let after = trimmed.dropFirst(level)
                if after.isEmpty || after.first == " " { return true }
        }   }
        return false
    }
    static func escapeCode(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
    static func slugify(_ text: String) -> String {
        var result = ""
        for char in text.lowercased() {
            if char == " " {
                result.append("-")
            } else if (char >= "a" && char <= "z") || (char >= "0" && char <= "9") || char == "-" {
                result.append(char)
        }   }
        return result
    }
    static func renderInline(_ text: String) -> String {
        var result = text
        var codeSpans: [String] = []
        result = extractCodeSpans(result, into: &codeSpans)
        result = result.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"__(.+?)__"#, with: "<strong>$1</strong>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\*(.+?)\*"#, with: "<em>$1</em>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"_(.+?)_"#, with: "<em>$1</em>", options: .regularExpression)
        result = result.replacingOccurrences(of: #"!\[([^\]]*)\]\(([^)]+)\)"#, with: "<img src=\"$2\" alt=\"$1\">", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\[([^\]]+)\]\(([^)]+)\)"#, with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        for (index, span) in codeSpans.enumerated() {
            result = result.replacingOccurrences(of: "\u{0002}CODE\(index)\u{0003}", with: span)
        }
        return result
    }
    private static func extractCodeSpans(_ text: String, into spans: inout [String]) -> String {
        var result = ""
        var remaining = text[text.startIndex...]  // Substring — nie kopiuje danych

        while let backtickStart = remaining.firstIndex(of: "`") {
            result += remaining[remaining.startIndex..<backtickStart]

            let contentStart = remaining.index(after: backtickStart)

            if let backtickEnd = remaining[contentStart...].firstIndex(of: "`") {
                let code = String(remaining[contentStart..<backtickEnd])
                let placeholder = "\u{0002}CODE\(spans.count)\u{0003}"
                spans.append("<code>\(escapeCode(code))</code>")
                result += placeholder
                remaining = remaining[remaining.index(after: backtickEnd)...]
            } else {
                result += "`"
                remaining = remaining[contentStart...]
        }   }
        result += remaining
        return result
    }
}
