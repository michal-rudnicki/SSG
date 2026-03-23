//
//  FileManager+extensions.swift
//  SSG
//
//  Created by Michał Rudnicki on 23/03/2026.
//

import Foundation

extension FileManager {
    func findFiles(in directory: String, extension ext: String) -> [String] {
        guard let enumerator = self.enumerator(atPath: directory) else { return [] }
        var result: [String] = []
        while let relativePath = enumerator.nextObject() as? String {
            if (relativePath as NSString).pathExtension == ext { result.append((directory as NSString).appendingPathComponent(relativePath)) }
        }
        return result.sorted()
    }
    func createParentDirectories(for path: String) throws {
        let parent = (path as NSString).deletingLastPathComponent
        guard !parent.isEmpty, !fileExists(atPath: parent) else { return }
        try createDirectory(atPath: parent, withIntermediateDirectories: true)
    }
    func copyDirectory(from source: String, to destination: String) throws {
        if !fileExists(atPath: destination) { try createDirectory(atPath: destination, withIntermediateDirectories: true) }
        let contents = try contentsOfDirectory(atPath: source)
        for item in contents {
            let srcPath = (source as NSString).appendingPathComponent(item)
            let dstPath = (destination as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            _ = fileExists(atPath: srcPath, isDirectory: &isDir)
            if isDir.boolValue {
                try copyDirectory(from: srcPath, to: dstPath)
            } else {
                if fileExists(atPath: dstPath) {
                    try removeItem(atPath: dstPath)
                }
                try copyItem(atPath: srcPath, toPath: dstPath)
    }   }   }
}
