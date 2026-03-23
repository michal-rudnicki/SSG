//
//  TemplateEngine.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Foundation

public struct TemplateEngine: Sendable {
    public static func render(template: String, context: [String: String]) -> String {
        let pattern = #"\{\{\s*([^}]+?)\s*\}\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return template }
        let mutable = NSMutableString(string: template)
        let matches = regex.matches(in: template,range: NSRange(template.startIndex..., in: template)).reversed()
        for match in matches {
            guard let keyRange = Range(match.range(at: 1), in: template) else { continue }
            let key = String(template[keyRange])
            let value = context[key] ?? ""
            let fullRange = match.range(at: 0)
            mutable.replaceCharacters(in: fullRange, with: value)
        }
        return mutable as String
    }
}
