//
//  Frontmatterpasertests.swift
//  SSG
//
//  Created by Michał Rudnicki on 20/03/2026.
//

import Testing
@testable import SSGCore

@Suite("FrontMatterParser")
struct FrontMatterParserTests {
    @Test("Poprawny front matter ze wszystkimi standardowymi polami")
    func fullFrontMatter() throws {
        let input = """
        ---
        title: Hello World
        description: Opis strony dla SEO
        date: 2026-03-20
        layout: post
        draft: false
        slug: hello-world
        ---
        # Treść artykułu

        Paragraf tekstu.
        """
        let (metadata, content) = try FrontMatterParser.parse(input, filePath: "test.md")
        #expect(metadata.title == "Hello World")
        #expect(metadata.description == "Opis strony dla SEO")
        #expect(metadata.date == "2026-03-20")
        #expect(metadata.layout == "post")
        #expect(metadata.draft == false)
        #expect(metadata.slug == "hello-world")
        #expect(content.hasPrefix("# Treść artykułu"))
        #expect(!content.contains("---"))
    }
    @Test("Plik bez '---' — brak front matter, cała zawartość jako Markdown")
    func noFrontMatter() throws {
        let input = """
        # Zwykły artykuł

        Bez metadanych.
        """
        let (metadata, content) = try FrontMatterParser.parse(input, filePath: "no-fm.md")
        #expect(metadata.title == "")
        #expect(metadata.layout == "page")
        #expect(metadata.draft == false)
        #expect(content == input)
    }
    @Test("Niezamknięty front matter rzuca frontMatterInvalid")
    func unclosedFrontMatter() throws {
        let input = """
        ---
        title: Bez zamknięcia
        date: 2026-03-20
        """
        #expect(throws: SSGError.self) {
            try FrontMatterParser.parse(input, filePath: "broken.md")
        }
    }
    @Test("Pusta wartość ('title:') daje pusty String, nie błąd")
    func emptyValues() throws {
        let input = """
        ---
        title:
        description:
        date:
        ---
        Treść.
        """
        let (metadata, content) = try FrontMatterParser.parse(input, filePath: "empty.md")
        #expect(metadata.title == "empty")
        #expect(metadata.description == "")
        #expect(metadata.date == "")
        #expect(content == "Treść.")
    }
    @Test("Wartość zawierająca dwukropek ('description: http://example.com')")
    func valueWithColon() throws {
        let input = """
        ---
        title: Mój artykuł
        description: Więcej na http://example.com/about
        ---
        Treść.
        """
        let (metadata, _) = try FrontMatterParser.parse(input, filePath: "colon.md")
        #expect(metadata.description == "Więcej na http://example.com/about")
    }
    @Test("draft: true parsowane jako Bool true")
    func draftTrue() throws {
        let input = """
        ---
        title: Szkic
        draft: true
        ---
        Treść.
        """
        let (metadata, _) = try FrontMatterParser.parse(input, filePath: "draft.md")
        #expect(metadata.draft == true)
    }

    @Test("draft: false parsowane jako Bool false")
    func draftFalse() throws {
        let input = """
        ---
        title: Opublikowany
        draft: false
        ---
        Treść.
        """
        let (metadata, _) = try FrontMatterParser.parse(input, filePath: "published.md")
        #expect(metadata.draft == false)
    }
    @Test("Nieznane klucze trafiają do metadata.extra")
    func unknownKeysGoToExtra() throws {
        let input = """
        ---
        title: Artykuł
        author: Jan Kowalski
        category: Swift
        ---
        Treść.
        """
        let (metadata, _) = try FrontMatterParser.parse(input, filePath: "extra.md")
        #expect(metadata.extra["author"] == "Jan Kowalski")
        #expect(metadata.extra["category"] == "Swift")
        #expect(metadata.extra["title"] == nil)
    }
    @Test("Markdown po front matter jest poprawnie oddzielony i przycięty")
    func markdownSeparation() throws {
        let input = """
        ---
        title: Test
        ---

        # Nagłówek

        Paragraf.
        """
        let (_, content) = try FrontMatterParser.parse(input, filePath: "sep.md")
        #expect(content.hasPrefix("# Nagłówek"))
        #expect(content.contains("Paragraf."))
    }
    @Test("Pole 'tags' jest ignorowane w Fazie 1 (nie trafia do extra)")
    func tagsIgnored() throws {
        let input = """
        ---
        title: Post z tagami
        tags: swift, cli, tools
        ---
        Treść.
        """
        let (metadata, _) = try FrontMatterParser.parse(input, filePath: "tags.md")
        #expect(metadata.extra["tags"] == nil)
    }
}
