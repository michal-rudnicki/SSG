# ssg — Static Site Generator

Konsolowy generator stron statycznych.

## Wymagania

- Swift 6.2.4+
- macOS 26+

## Instalacja

### Jako narzędzie (executable)

```bash
git clone https://github.com/michal-rudnicki/SSG.git
cd SSG
swift build -c release
cp .build/release/SSG /usr/local/bin/ssg
```

### Jako biblioteka w innym projekcie (Package.swift)

```swift
.package(url: "https://github.com/michal-rudnicki/SSG.git", from: "0.1.0")
```

```swift
import SSGCore

let html = MarkdownParser.toHTML("# Hello World")
```

## Quick start

```bash
# 1. Utwórz strukturę projektu ręcznie lub skopiuj example-site/
mkdir my-blog && cd my-blog

# 2. Zbuduj stronę
ssg build

# 3. Sprawdź wynik
open public/index.html
```

## Struktura projektu

```
my-site/
├── ssg.yaml              # konfiguracja
├── content/              # pliki Markdown
│   ├── index.md
│   └── posts/
│       └── 2026-01-01-hello.md
├── templates/            # szablony HTML
│   └── page.html
└── assets/               # kopiowane 1:1 do output
    └── style.css
```

## Komendy

| Komenda | Opis |
|---|---|
| `ssg build` | Jednorazowe zbudowanie strony |
| `ssg version` | Wyświetla wersję |
| `ssg help` | Wyświetla pomoc |

### Flagi `ssg build`

| Flaga | Skrót | Domyślnie | Opis |
|---|---|---|---|
| `--config` | `-c` | `ssg.yaml` | Ścieżka do pliku konfiguracyjnego |
| `--source` | `-s` | wartość z config | Katalog z plikami `.md` |
| `--output` | `-o` | wartość z config | Katalog wyjściowy |
| `--templates` | `-t` | wartość z config | Katalog szablonów |
| `--drafts` | — | `false` | Uwzględniaj posty z `draft: true` |
| `--verbose` | `-v` | `false` | Szczegółowe logi |
| `--no-clean` | — | — | Nie czyść output dir przed buildem |

## Konfiguracja (`ssg.yaml`)

```yaml
contentDir:   content
outputDir:    public
templatesDir: templates
assetsDir:    assets

site:
  title:       Moja strona
  description: Opis dla SEO
  baseURL:     https://example.com
  language:    pl
```

## Front matter

```yaml
---
title:       Tytuł strony
description: Opis dla SEO
date:        2026-03-19
layout:      page       # nazwa szablonu bez .html
draft:       false      # true = pomijaj w build
slug:        custom-url # nadpisuje slug z nazwy pliku
---
```

## Szablony

Dostępne zmienne w szablonach:

| Zmienna | Opis |
|---|---|
| `{{content}}` | Treść strony (Markdown → HTML) |
| `{{title}}` | Tytuł z front matter |
| `{{description}}` | Opis z front matter |
| `{{date}}` | Data z front matter |
| `{{slug}}` | URL slug strony |
| `{{url}}` | Pełny URL (`baseURL` + ścieżka) |
| `{{site.title}}` | Tytuł strony z `ssg.yaml` |
| `{{site.baseURL}}` | Bazowy URL z `ssg.yaml` |
| `{{site.language}}` | Język z `ssg.yaml` |

Przykład szablonu:

```html
<!DOCTYPE html>
<html lang="{{ site.language }}">
<head>
  <meta charset="UTF-8">
  <title>{{ title }} — {{ site.title }}</title>
</head>
<body>
  {{ content }}
</body>
</html>
```
