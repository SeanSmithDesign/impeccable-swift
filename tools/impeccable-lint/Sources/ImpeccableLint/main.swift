import Foundation
import SwiftParser
import SwiftSyntax

// MARK: - File discovery

func swiftFiles(under path: String) -> [String] {
    var isDir: ObjCBool = false
    let fm = FileManager.default
    guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return [] }

    if !isDir.boolValue {
        return path.hasSuffix(".swift") ? [path] : []
    }

    guard let enumerator = fm.enumerator(atPath: path) else { return [] }
    var results: [String] = []
    for case let sub as String in enumerator {
        if sub.hasSuffix(".swift") {
            results.append((path as NSString).appendingPathComponent(sub))
        }
    }
    return results.sorted()
}

// MARK: - Rule running

func lint(path: String) -> [Violation] {
    guard let data = FileManager.default.contents(atPath: path),
          let source = String(data: data, encoding: .utf8) else {
        FileHandle.standardError.write(Data("\(path): parse error: could not read file\n".utf8))
        return []
    }

    let tree = Parser.parse(source: source)
    let converter = SourceLocationConverter(fileName: path, tree: tree)

    var all: [Violation] = []

    let a11y = AccessibilityLabelRule(path: path, converter: converter)
    a11y.walk(tree)
    all.append(contentsOf: a11y.violations)

    let frame = MultilineFrameOnTextRule(path: path, converter: converter)
    frame.walk(tree)
    all.append(contentsOf: frame.violations)

    let font = HardcodedFontInChainRule(path: path, converter: converter)
    font.walk(tree)
    all.append(contentsOf: font.violations)

    let corner = ContinuousCornerRule(path: path, converter: converter)
    corner.walk(tree)
    all.append(contentsOf: corner.violations)

    return all
}

// MARK: - CLI entrypoint

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write(Data("usage: impeccable-lint <file-or-directory> [--json]\n".utf8))
    exit(2)
}

let jsonMode = args.contains("--json")
let targets = args.dropFirst().filter { !$0.hasPrefix("--") }

var allViolations: [Violation] = []
for target in targets {
    for file in swiftFiles(under: target) {
        allViolations.append(contentsOf: lint(path: file))
    }
}

if jsonMode {
    // Minimal SARIF-lite: an array of objects, one per violation.
    struct Out: Encodable {
        let path: String
        let line: Int
        let column: Int
        let ruleName: String
        let message: String
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let payload = allViolations.map { Out(path: $0.path, line: $0.line, column: $0.column, ruleName: $0.ruleName, message: $0.message) }
    if let data = try? encoder.encode(payload), let str = String(data: data, encoding: .utf8) {
        print(str)
    }
} else {
    for v in allViolations {
        print(v.formatted)
    }
}

exit(allViolations.isEmpty ? 0 : 1)
