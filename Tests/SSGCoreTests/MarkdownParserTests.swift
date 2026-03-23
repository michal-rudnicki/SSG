//
//  MarkdownParserTests.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Testing
@testable import SSGCore

@Suite("Nagłówki")
struct HeadingTests {
    @Test("H1 — tag i id")
    func h1() {
        #expect(MarkdownParser.toHTML("# Hello World!") == "<h1 id=\"hello-world\">Hello World!</h1>\n")
    }
    @Test("H2")
    func h2() {
        #expect(MarkdownParser.toHTML("## Drugi poziom") == "<h2 id=\"drugi-poziom\">Drugi poziom</h2>\n")
    }
    @Test("H3")
    func h3() {
        let out = MarkdownParser.toHTML("### Trzeci")
        #expect(out == "<h3 id=\"trzeci\">Trzeci</h3>\n")
    }
    @Test("H4")
    func h4() {
        let out = MarkdownParser.toHTML("#### Czwarty")
        #expect(out == "<h4 id=\"czwarty\">Czwarty</h4>\n")
    }
    @Test("H5")
    func h5() {
        let out = MarkdownParser.toHTML("##### Piąty")
        #expect(out == "<h5 id=\"pity\">Piąty</h5>\n")
    }
    @Test("H6 — maksymalny poziom")
    func h6() {
        #expect(MarkdownParser.toHTML("###### Six") == "<h6 id=\"six\">Six</h6>\n")
    }
    @Test("Siedem hashy — NIE jest nagłówkiem, trafia jako paragraf")
    func sevenHashesIsParagraph() {
        let out = MarkdownParser.toHTML("####### Not a heading")
        #expect(out.contains("<p>"))
        #expect(!out.contains("<h7"))
    }
    @Test("Hash bez spacji — NIE jest nagłówkiem (#tag)")
    func hashWithoutSpace() {
        let out = MarkdownParser.toHTML("#swift")
        #expect(out.contains("<p>"))
        #expect(!out.contains("<h1"))
    }
    @Test("Nagłówek z linkiem w tekście")
    func headingWithLink() {
        let out = MarkdownParser.toHTML("## [Swift](https://swift.org)")
        #expect(out.contains("<h2"))
        #expect(out.contains("<a href=\"https://swift.org\">Swift</a>"))
        #expect(out.contains("</h2>"))
    }
    @Test("Nagłówek z cyframi w tekście — id poprawne")
    func headingWithNumbers() {
        let out = MarkdownParser.toHTML("# Swift 6.2")
        #expect(out.contains("id=\"swift-62\""))
    }
}
@Suite("Fenced code block")
struct CodeBlockTests {
    @Test("Z nazwą języka — class language-X")
    func withLanguage() {
        let md = """
        ```swift
        let x = 1
        ```
        """
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<pre><code class=\"language-swift\">let x = 1</code></pre>\n")
    }
    @Test("Bez nazwy języka — brak atrybutu class")
    func withoutLanguage() {
        let md = """
        ```
        code here
        ```
        """
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<pre><code>code here</code></pre>\n")
    }
    @Test("Wieloliniowy blok kodu")
    func multiline() {
        let md = "```\nline one\nline two\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<pre><code>line one\nline two</code></pre>\n")
    }
    @Test("Escapowanie < w bloku kodu")
    func escapeLt() {
        let md = "```\n<tag>\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("&lt;tag&gt;"))
        #expect(!out.contains("<tag>"))
    }
    @Test("Escapowanie > w bloku kodu")
    func escapeGt() {
        let md = "```\na > b\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("a &gt; b"))
    }
    @Test("Escapowanie & w bloku kodu")
    func escapeAmp() {
        let md = "```\na & b\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("a &amp; b"))
    }
    @Test("& escapowany przed < > — brak double-escape")
    func escapeOrder() {
        let md = "```\n&lt;\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("&amp;lt;"))
        #expect(!out.contains("&lt;&lt;"))
    }
    @Test("Pusty blok kodu")
    func emptyCodeBlock() {
        let md = "```\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<pre><code></code></pre>\n")
    }
}
@Suite("Blockquote")
struct BlockquoteTests {
    @Test("Podstawowy blockquote")
    func basic() {
        let out = MarkdownParser.toHTML("> Hello")
        #expect(out == "<blockquote><p>Hello</p></blockquote>\n")
    }
    @Test("Blockquote z formatowaniem inline")
    func withInline() {
        let out = MarkdownParser.toHTML("> **bold** text")
        #expect(out.contains("<strong>bold</strong>"))
        #expect(out.contains("<blockquote>"))
    }
    @Test("Wieloliniowy blockquote — scalany w jeden paragraf")
    func multiline() {
        let md = "> Linia pierwsza\n> Linia druga"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<blockquote>"))
        #expect(out.contains("Linia pierwsza"))
        #expect(out.contains("Linia druga"))
    }
}
@Suite("Listy")
struct ListTests {
    @Test("Nieuporządkowana lista z myślnikami")
    func unorderedDash() {
        let md = "- Alpha\n- Beta\n- Gamma"
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<ul>\n<li>Alpha</li>\n<li>Beta</li>\n<li>Gamma</li>\n</ul>\n")
    }
    @Test("Nieuporządkowana lista z gwiazdkami")
    func unorderedAsterisk() {
        let md = "* One\n* Two"
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<ul>\n<li>One</li>\n<li>Two</li>\n</ul>\n")
    }
    @Test("Uporządkowana lista")
    func ordered() {
        let md = "1. First\n2. Second\n3. Third"
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<ol>\n<li>First</li>\n<li>Second</li>\n<li>Third</li>\n</ol>\n")
    }
    @Test("Lista uporządkowana — numery nie muszą być kolejne (10. item)")
    func orderedNonSequential() {
        let md = "1. One\n10. Ten"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<ol>"))
        #expect(out.contains("<li>One</li>"))
        #expect(out.contains("<li>Ten</li>"))
    }
    @Test("Element listy z formatowaniem inline")
    func listItemWithInline() {
        let md = "- **bold** item"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<strong>bold</strong> item"))
    }
    @Test("Lista jednoelementowa")
    func singleItem() {
        let out = MarkdownParser.toHTML("- Jedyny")
        #expect(out == "<ul>\n<li>Jedyny</li>\n</ul>\n")
    }
}
@Suite("Pozioma linia")
struct HorizontalRuleTests {
    @Test("Samotna linia --- to <hr>")
    func basic() {
        #expect(MarkdownParser.toHTML("---") == "<hr>\n")
    }
    @Test("--- w środku dokumentu")
    func inDocument() {
        let md = "Tekst przed\n\n---\n\nTekst po"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<hr>"))
        #expect(out.contains("<p>Tekst przed</p>"))
        #expect(out.contains("<p>Tekst po</p>"))
    }
}
@Suite("Paragraf")
struct ParagraphTests {
    @Test("Podstawowy paragraf")
    func basic() {
        #expect(MarkdownParser.toHTML("Hello world") == "<p>Hello world</p>\n")
    }
    @Test("Dwa paragrafy oddzielone pustą linią")
    func twoParagraphs() {
        let md = "First\n\nSecond"
        let out = MarkdownParser.toHTML(md)
        #expect(out == "<p>First</p>\n<p>Second</p>\n")
    }
    @Test("Wieloliniowy paragraf — linie scalane")
    func multiline() {
        let md = "Linia pierwsza\nLinia druga"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<p>"))
        #expect(out.contains("Linia pierwsza"))
        #expect(out.contains("Linia druga"))
    }
    @Test("Puste wejście — pusty output")
    func emptyInput() {
        #expect(MarkdownParser.toHTML("") == "")
    }
    @Test("Tylko białe znaki — pusty output")
    func whitespaceOnly() {
        #expect(MarkdownParser.toHTML("   \n   \n   ") == "")
    }
}
@Suite("Bold")
struct BoldTests {
    @Test("**tekst** → <strong>")
    func doubleAsterisk() {
        let out = MarkdownParser.toHTML("**bold**")
        #expect(out == "<p><strong>bold</strong></p>\n")
    }
    @Test("__tekst__ → <strong>")
    func doubleUnderscore() {
        let out = MarkdownParser.toHTML("__bold__")
        #expect(out == "<p><strong>bold</strong></p>\n")
    }
    @Test("Dwa bold w tej samej linii")
    func twoBoldInOneLine() {
        let out = MarkdownParser.toHTML("**a** i **b**")
        #expect(out.contains("<strong>a</strong>"))
        #expect(out.contains("<strong>b</strong>"))
    }
    @Test("Bold w środku zdania")
    func boldInSentence() {
        let out = MarkdownParser.toHTML("To jest **ważne** zdanie")
        #expect(out.contains("To jest <strong>ważne</strong> zdanie"))
    }
}
@Suite("Italic")
struct ItalicTests {
    @Test("*tekst* → <em>")
    func singleAsterisk() {
        let out = MarkdownParser.toHTML("*italic*")
        #expect(out == "<p><em>italic</em></p>\n")
    }
    @Test("_tekst_ → <em>")
    func singleUnderscore() {
        let out = MarkdownParser.toHTML("_italic_")
        #expect(out == "<p><em>italic</em></p>\n")
    }
    @Test("Italic w środku zdania")
    func italicInSentence() {
        let out = MarkdownParser.toHTML("słowo _kursywa_ i więcej")
        #expect(out.contains("<em>kursywa</em>"))
    }
}
@Suite("Inline code")
struct InlineCodeTests {
    @Test("Podstawowy inline code")
    func basic() {
        let out = MarkdownParser.toHTML("`code`")
        #expect(out == "<p><code>code</code></p>\n")
    }
    @Test("Inline code escapuje < i >")
    func escapeLtGt() {
        let out = MarkdownParser.toHTML("`<b>`")
        #expect(out.contains("<code>&lt;b&gt;</code>"))
        #expect(!out.contains("<code><b></code>"))
    }
    @Test("Inline code escapuje &")
    func escapeAmpersand() {
        let out = MarkdownParser.toHTML("`a & b`")
        #expect(out.contains("&amp;"))
    }
    @Test("Inline code NIE parsuje **bold** w środku")
    func codeNotParsedAsBold() {
        let out = MarkdownParser.toHTML("`**not bold**`")
        #expect(out == "<p><code>**not bold**</code></p>\n")
    }
    @Test("Inline code NIE parsuje _italic_ w środku")
    func codeNotParsedAsItalic() {
        let out = MarkdownParser.toHTML("`_not italic_`")
        #expect(out == "<p><code>_not italic_</code></p>\n")
    }
    @Test("Niezamknięty backtick — traktowany literalnie")
    func unclosedBacktick() {
        let out = MarkdownParser.toHTML("tekst ` bez zamknięcia")
        #expect(out.contains("<p>"))
        #expect(!out.contains("<code>"))
    }
    @Test("Dwa inline code w tej samej linii")
    func twoCodeSpans() {
        let out = MarkdownParser.toHTML("`foo` i `bar`")
        #expect(out.contains("<code>foo</code>"))
        #expect(out.contains("<code>bar</code>"))
    }
}
@Suite("Linki i obrazki")
struct LinkImageTests {
    @Test("Podstawowy link")
    func link() {
        let out = MarkdownParser.toHTML("[Click](https://example.com)")
        #expect(out == "<p><a href=\"https://example.com\">Click</a></p>\n")
    }
    @Test("Link z tekstem otaczającym")
    func linkInText() {
        let out = MarkdownParser.toHTML("Odwiedź [stronę](https://example.com) dziś")
        #expect(out.contains("<a href=\"https://example.com\">stronę</a>"))
    }
    @Test("Podstawowy obrazek")
    func image() {
        let out = MarkdownParser.toHTML("![alt text](https://example.com/img.png)")
        #expect(out == "<p><img src=\"https://example.com/img.png\" alt=\"alt text\"></p>\n")
    }
    @Test("Obrazek z pustym alt")
    func imageEmptyAlt() {
        let out = MarkdownParser.toHTML("![](https://example.com/img.png)")
        #expect(out.contains("<img src=\"https://example.com/img.png\" alt=\"\">"))
    }
    @Test("Obrazek nie jest parsowany jako link")
    func imageNotParsedAsLink() {
        let out = MarkdownParser.toHTML("![alt](url.png)")
        #expect(out.contains("<img"))
        #expect(!out.contains("<a href"))
    }
    @Test("Link i obrazek w tej samej linii")
    func linkAndImageTogether() {
        let out = MarkdownParser.toHTML("[link](https://a.com) i ![img](b.png)")
        #expect(out.contains("<a href=\"https://a.com\">link</a>"))
        #expect(out.contains("<img src=\"b.png\""))
    }
}
@Suite("Line break")
struct LineBreakTests {
    @Test("Dwie spacje na końcu linii → <br>")
    func twoTrailingSpaces() {
        let md = "Linia jedna  \nLinia dwa"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("Linia jedna<br>"))
        #expect(out.contains("Linia dwa"))
    }
    @Test("Jedna spacja na końcu — NIE generuje <br>")
    func oneTrailingSpace() {
        let md = "Linia jedna \nLinia dwa"
        let out = MarkdownParser.toHTML(md)
        #expect(!out.contains("<br>"))
    }
    @Test("Ostatnia linia paragrafu — nigdy nie dostaje <br>")
    func lastLineNoBr() {
        let md = "Jedyna linia  "
        let out = MarkdownParser.toHTML(md)
        #expect(!out.contains("<br>"))
    }
}
@Suite("slugify")
struct SlugifyTests {
    @Test("Spacje → myślniki")
    func spacesToDashes() {
        #expect(MarkdownParser.slugify("Hello World") == "hello-world")
    }
    @Test("Znaki specjalne usuwane")
    func specialCharsRemoved() {
        #expect(MarkdownParser.slugify("Hello World!") == "hello-world")
    }
    @Test("Cyfry zachowane")
    func numbersKept() {
        #expect(MarkdownParser.slugify("Swift 6") == "swift-6")
    }
    @Test("Wszystko lowercase")
    func lowercase() {
        #expect(MarkdownParser.slugify("ABC") == "abc")
    }
    @Test("Pusty string → pusty slug")
    func emptyInput() {
        #expect(MarkdownParser.slugify("") == "")
    }
    @Test("Tylko znaki specjalne → pusty slug")
    func onlySpecialChars() {
        #expect(MarkdownParser.slugify("!!!") == "")
    }
}
@Suite("escapeCode")
struct EscapeCodeTests {
    @Test("& → &amp;")
    func ampersand() {
        #expect(MarkdownParser.escapeCode("a & b") == "a &amp; b")
    }
    @Test("< → &lt;")
    func lessThan() {
        #expect(MarkdownParser.escapeCode("<tag>") == "&lt;tag&gt;")
    }
    @Test("> → &gt;")
    func greaterThan() {
        #expect(MarkdownParser.escapeCode("a > b") == "a &gt; b")
    }
    @Test("Kolejność: & escapowany przed < i > — brak double-escape")
    func order() {
        #expect(MarkdownParser.escapeCode("&lt;") == "&amp;lt;")
    }
    @Test("Tekst bez znaków specjalnych — bez zmian")
    func noSpecialChars() {
        #expect(MarkdownParser.escapeCode("hello world") == "hello world")
    }
}
@Suite("Edge cases")
struct EdgeCaseTests {
    @Test("Raw HTML w Markdown — przepuszczany bez zmian")
    func rawHtmlPassthrough() {
        let md = "<div class=\"foo\">content</div>"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<div class=\"foo\">content</div>"))
    }
    @Test("Bold z italic zagnieżdżonym — oba renderowane")
    func boldAndItalicMixed() {
        let out = MarkdownParser.toHTML("**bold** i *italic*")
        #expect(out.contains("<strong>bold</strong>"))
        #expect(out.contains("<em>italic</em>"))
    }
    @Test("Nagłówek po paragrafie oddzielony pustą linią")
    func headingAfterParagraph() {
        let md = "Paragraf tekstu\n\n# Nagłówek"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<p>Paragraf tekstu</p>"))
        #expect(out.contains("<h1"))
    }
    @Test("Lista po paragrafie bez pustej linii — lista zaczyna nowy blok")
    func listBreaksParagraph() {
        let md = "Tekst\n- Item"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("<p>Tekst</p>"))
        #expect(out.contains("<ul>"))
    }
    @Test("Kod blokowy po kodzie blokowym")
    func twoCodeBlocks() {
        let md = "```\nfirst\n```\n\n```\nsecond\n```"
        let out = MarkdownParser.toHTML(md)
        #expect(out.contains("first"))
        #expect(out.contains("second"))
        let count = out.components(separatedBy: "<pre>").count - 1
        #expect(count == 2)
    }
}
