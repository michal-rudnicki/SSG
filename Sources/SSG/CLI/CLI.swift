//
//  CLI.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Foundation
import SSGCore

struct BuildOptions {
    var configPath: String = "ssg.yaml"
    var overrides: CLIOverrides = CLIOverrides()
    var drafts: Bool = false
    var verbose: Bool = false
    var clean: Bool = true
}

struct CLI {
    static func run() {
        let args = Array(CommandLine.arguments.dropFirst()) // pomijamy nazwę procesu
        guard let command = args.first else {
            printHelp()
            exit(0)
        }
        switch command {
        case "build": runBuild(args: Array(args.dropFirst()))
        case "help", "--help", "-h":
            printHelp()
            exit(0)
        case "version", "--version":
            printVersion()
            exit(0)
        case "-v" where args.count == 1:
            printVersion()
            exit(0)
        default:
            printError("Nieznana komenda: \"\(command)\"")
            print("")
            printHelp()
            exit(1)
        }
    }
    
    private static func runBuild(args: [String]) {
        var options = BuildOptions()
        var i = 0
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--config", "-c":
                guard let value = nextValue(args: args, index: &i, flag: arg) else { exit(1) }
                options.configPath = value
            case "--source", "-s":
                guard let value = nextValue(args: args, index: &i, flag: arg) else { exit(1) }
                options.overrides.contentDir = value
            case "--output", "-o":
                guard let value = nextValue(args: args, index: &i, flag: arg) else { exit(1) }
                options.overrides.outputDir = value
            case "--templates", "-t":
                guard let value = nextValue(args: args, index: &i, flag: arg) else { exit(1) }
                options.overrides.templatesDir = value
            case "--drafts":
                options.drafts = true
                options.overrides.drafts = true
            case "--verbose", "-v":
                options.verbose = true
                options.overrides.verbose = true
            case "--clean":
                options.clean = true
            case "--no-clean":
                options.clean = false
            default:
                printError("Nieznana flaga: \"\(arg)\"")
                print("Użyj 'ssg help' aby zobaczyć dostępne opcje.")
                exit(1)
            }
            i += 1
        }
        do {
            var config = try ConfigLoader.load(configPath: options.configPath, overrides: options.overrides)
            config.clean = options.clean
            let builder = SiteBuilder(config: config)
            try builder.build()
            exit(0)
        } catch let error as SSGError {
            printError(error.description)
            exit(1)
        } catch {
            printError("Nieoczekiwany błąd: \(error.localizedDescription)")
            exit(1)
        }
    }
    private static func nextValue(args: [String], index: inout Int, flag: String) -> String? {
        index += 1
        guard index < args.count else {
            printError("Flaga \(flag) wymaga wartości.")
            return nil
        }
        return args[index]
    }

    private static func printError(_ message: String) {
        fputs("ERROR:\(message)\n", stderr)
    }

    // MARK: - Help i version

    private static func printVersion() {
        print("ssg \(SSGVersion.current)")
    }

    private static func printHelp() {
        print("""
        ssg — Static Site Generator

        UŻYCIE:
          ssg <komenda> [opcje]

        KOMENDY:
          build    Jednorazowe zbudowanie strony
          version  Pokaż wersję
          help     Pokaż tę wiadomość

        OPCJE (build):
          -c, --config    <ścieżka>   Plik konfiguracyjny    (domyślnie: ssg.yaml)
          -s, --source    <ścieżka>   Katalog z plikami .md
          -o, --output    <ścieżka>   Katalog wyjściowy HTML
          -t, --templates <ścieżka>   Katalog szablonów
              --drafts                Uwzględniaj posty z draft: true
          -v, --verbose               Szczegółowe logi
              --no-clean              Nie czyść output dir przed buildem

        PRZYKŁADY:
          ssg build
          ssg build --drafts --verbose
          ssg build -s ./src -o ./dist
          ssg build --config ./configs/production.yaml
        """)
    }
}
