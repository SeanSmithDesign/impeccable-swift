import XCTest
import SwiftParser
import SwiftSyntax
@testable import ImpeccableLint

final class MultilineFrameOnTextRuleTests: XCTestCase {
    private func run(_ source: String, file: String = "Test.swift") -> [Violation] {
        let tree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: file, tree: tree)
        let rule = MultilineFrameOnTextRule(path: file, converter: converter)
        rule.walk(tree)
        return rule.violations
    }

    func testFixedFrameOnTextSameLineFlags() {
        let v = run(Fixtures.frameOnTextSameLine)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testFixedFrameOnTextMultilineFlags() {
        let v = run(Fixtures.frameOnTextMultiline)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testMaxWidthIsClean() {
        let v = run(Fixtures.frameOnTextMaxWidth)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }

    func testFrameOnImageIsClean() {
        let v = run(Fixtures.frameOnImage)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }
}
