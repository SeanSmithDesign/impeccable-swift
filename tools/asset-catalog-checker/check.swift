#!/usr/bin/env swift
//
// asset-catalog-checker / check.swift
//
// Walks a project (or a specific .xcassets) and flags PNG-backed
// `Image("name")` references where a semantically similar SF Symbol exists.
//
// Usage:
//   swift tools/asset-catalog-checker/check.swift <path-to-project-or-xcassets>
//
// Exit codes:
//   0 — no findings (or no asset catalog found)
//   1 — one or more findings
//   2 — usage / input error
//
// This is a v1 POC. For Swift parsing it uses a regex — it will miss
// `Image(_ name:)` calls where `name` is a computed value. That's fine
// for now; SwiftSyntax-grade parsing is a separate tool's job.
//

import Foundation

// MARK: - SF Symbol mapping
//
// Maps a bundled-PNG asset name (as it would appear in an .xcassets
// catalog) to the closest semantically-equivalent SF Symbol.
// This is intentionally conservative: when in doubt, leave an entry
// out — false negatives are cheaper than false positives here.

let sfSymbolMap: [String: String] = [
    "gear":            "gearshape",
    "settings":        "gearshape",
    "star":            "star",
    "heart":           "heart",
    "plus":            "plus",
    "add":             "plus",
    "minus":           "minus",
    "close":           "xmark",
    "xmark":           "xmark",
    "x":               "xmark",
    "trash":           "trash",
    "delete":          "trash",
    "pencil":          "pencil",
    "edit":            "pencil",
    "arrow-up":        "arrow.up",
    "arrow-down":      "arrow.down",
    "chevron-right":   "chevron.right",
    "search":          "magnifyingglass",
    "magnifyingglass": "magnifyingglass",
    "bell":            "bell",
    "notification":    "bell",
    "person":          "person",
    "user":            "person",
    "profile":         "person",
    "house":           "house",
    "home":            "house",
    "folder":          "folder",
    "doc":             "doc",
    "document":        "doc",
    "file":            "doc",
    "envelope":        "envelope",
    "mail":            "envelope",
    "phone":           "phone",
    "camera":          "camera",
    "mic":             "mic",
    "microphone":      "mic",
    "speaker":         "speaker.wave.2",
    "volume":          "speaker.wave.2",
    "play":            "play",
    "pause":           "pause",
    "stop":            "stop",
    "forward":         "forward",
    "backward":        "backward",
    "gauge":           "gauge",
    "bookmark":        "bookmark",
    "cart":            "cart",
    "basket":          "cart",
]

// MARK: - CLI

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write(Data("usage: check.swift <path>\n".utf8))
    exit(2)
}

let rootPath = args[1]
let fm = FileManager.default

var isDir: ObjCBool = false
guard fm.fileExists(atPath: rootPath, isDirectory: &isDir), isDir.boolValue else {
    // Non-existent or non-directory root → treat as "no asset catalog found"
    print("no asset catalog found")
    exit(0)
}

// MARK: - Walk the tree

func enumerate(_ path: String) -> [String] {
    var results: [String] = []
    guard let en = fm.enumerator(atPath: path) else { return results }
    while let rel = en.nextObject() as? String {
        results.append((path as NSString).appendingPathComponent(rel))
    }
    return results
}

let allPaths = enumerate(rootPath)

// Find every .xcassets directory, whether the root is an .xcassets itself
// or the root contains one or more.
var assetCatalogs: [String] = []
if rootPath.hasSuffix(".xcassets") {
    assetCatalogs.append(rootPath)
}
assetCatalogs.append(contentsOf: allPaths.filter { $0.hasSuffix(".xcassets") })

if assetCatalogs.isEmpty {
    print("no asset catalog found")
    exit(0)
}

// Collect imagesets and symbolsets per catalog.
var pngNames = Set<String>()     // names that exist as *.imageset
var symbolNames = Set<String>()  // names that exist as *.symbolset

func stem(_ dirName: String, suffix: String) -> String? {
    guard dirName.hasSuffix(suffix) else { return nil }
    return String(dirName.dropLast(suffix.count))
}

for catalog in assetCatalogs {
    guard let en = fm.enumerator(atPath: catalog) else { continue }
    while let rel = en.nextObject() as? String {
        let last = (rel as NSString).lastPathComponent
        if let name = stem(last, suffix: ".imageset") {
            pngNames.insert(name)
        } else if let name = stem(last, suffix: ".symbolset") {
            symbolNames.insert(name)
        }
    }
}

// MARK: - Scan Swift files

let swiftFiles = allPaths.filter { $0.hasSuffix(".swift") }

// Regex: Image("name")
let imageRegex = try! NSRegularExpression(
    pattern: #"Image\s*\(\s*"([^"]+)"\s*\)"#
)

struct Finding {
    let file: String
    let line: Int
    let name: String
    let suggestion: String
}

var findings: [Finding] = []

for file in swiftFiles {
    guard let data = try? String(contentsOfFile: file, encoding: .utf8) else { continue }
    let lines = data.components(separatedBy: "\n")
    for (idx, line) in lines.enumerated() {
        let ns = line as NSString
        let matches = imageRegex.matches(
            in: line, range: NSRange(location: 0, length: ns.length)
        )
        for m in matches where m.numberOfRanges >= 2 {
            let name = ns.substring(with: m.range(at: 1))
            // Only consider names that resolve to a PNG imageset in the catalog.
            guard pngNames.contains(name) else { continue }
            // If the project also ships a symbolset with that exact name,
            // the user made the choice intentionally — stay silent.
            guard !symbolNames.contains(name) else { continue }
            // Look up a semantic match in the SF Symbol map.
            guard let suggestion = sfSymbolMap[name.lowercased()] else { continue }
            findings.append(
                Finding(file: file, line: idx + 1, name: name, suggestion: suggestion)
            )
        }
    }
}

// MARK: - Report

for f in findings {
    print("\(f.file):\(f.line): consider SF Symbol \"\(f.suggestion)\" in place of bundled PNG \"\(f.name)\"")
}

exit(findings.isEmpty ? 0 : 1)
