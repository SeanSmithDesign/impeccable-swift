import XCTest
import SwiftParser
import SwiftSyntax
@testable import ImpeccableLint

final class HardcodedFontInChainRuleTests: XCTestCase {
    private func run(_ source: String, file: String = "Test.swift") -> [Violation] {
        let tree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: file, tree: tree)
        let rule = HardcodedFontInChainRule(path: file, converter: converter)
        rule.walk(tree)
        return rule.violations
    }

    func testSameLineSystemFontFlags() {
        let v = run(Fixtures.hardcodedFontSameLine)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testMultilineSystemFontFlags() {
        let v = run(Fixtures.hardcodedFontMultiline)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testSemanticFontIsClean() {
        let v = run(Fixtures.semanticFont)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }

    func testCustomFontWithRelativeToIsClean() {
        let v = run(Fixtures.customFontWithRelativeTo)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }
}
