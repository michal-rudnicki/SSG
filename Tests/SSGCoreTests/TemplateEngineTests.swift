//
//  TemplateEngineTests.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Testing
@testable import SSGCore

@Suite("TemplateEngine")
struct TemplateEngineTests {
    @Test("Podstawienie jednego klucza")
    func singleKey() {
        let result = TemplateEngine.render(template: "<h1>{{title}}</h1>", context: ["title": "Hello World"])
        #expect(result == "<h1>Hello World</h1>")
    }
    @Test("Podstawienie wielu różnych kluczy")
    func multipleKeys() {
        let result = TemplateEngine.render(template: "<title>{{title}}</title><p>{{content}}</p>", context: ["title": "Strona", "content": "Treść"])
        #expect(result == "<title>Strona</title><p>Treść</p>")
    }
    @Test("Brakujący klucz daje pusty string")
    func missingKeyGivesEmptyString() {
        let result = TemplateEngine.render(template: "<p>{{nieistniejacy}}</p>", context: [:])
        #expect(result == "<p></p>")
    }
    @Test("{{key}} bez spacji działa")
    func keyWithoutSpaces() {
        let result = TemplateEngine.render(template: "{{title}}", context: ["title": "Test"])
        #expect(result == "Test")
    }
    @Test("{{ key }} ze spacjami działa tak samo")
    func keyWithSpaces() {
        let result = TemplateEngine.render(template: "{{ title }}", context: ["title": "Test"])
        #expect(result == "Test")
    }
    @Test("Wiele wystąpień tego samego klucza — wszystkie zastąpione")
    func multipleOccurrencesOfSameKey() {
        let result = TemplateEngine.render(template: "{{site.title}} | {{site.title}}", context: ["site.title": "Mój Blog"])
        #expect(result == "Mój Blog | Mój Blog")
    }
    @Test("Case-sensitivity: {{Title}} i {{title}} to różne klucze")
    func caseSensitivity() {
        let result = TemplateEngine.render(template: "{{Title}} {{title}}", context: ["title": "małe", "Title": "DUŻE"])
        #expect(result == "DUŻE małe")
    }
    @Test("Case-sensitivity: brakujący klucz z inną wielkością liter daje pusty string")
    func caseSensitivityMissingKey() {
        let result = TemplateEngine.render(template: "{{TITLE}}", context: ["title": "Test"])
        #expect(result == "")
    }
    @Test("Pusta wartość w kontekście daje pusty string (nie nil)")
    func emptyValueInContext() {
        let result = TemplateEngine.render(template: "<p>{{description}}</p>", context: ["description": ""])
        #expect(result == "<p></p>")
    }
    @Test("Brak placeholderów — szablon zwrócony bez zmian")
    func noPlaceholders() {
        let template = "<h1>Statyczny nagłówek</h1>"
        let result = TemplateEngine.render(template: template, context: ["title": "Test"])
        #expect(result == template)
    }
    @Test("Wartość zawierająca HTML nie jest escapowana")
    func htmlValueNotEscaped() {
        let result = TemplateEngine.render(template: "{{content}}", context: ["content": "<p>Treść</p>"])
        #expect(result == "<p>Treść</p>")
    }
    @Test("Mieszane spacje: {{key}}, {{ key }}, {{  key  }}")
    func mixedSpacing() {
        let context = ["key": "wartość"]
        #expect(TemplateEngine.render(template: "{{key}}", context: context) == "wartość")
        #expect(TemplateEngine.render(template: "{{ key }}", context: context) == "wartość")
        #expect(TemplateEngine.render(template: "{{  key  }}", context: context) == "wartość")
    }
}
