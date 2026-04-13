import XCTest
import SwiftParser
import SwiftSyntax
@testable import ImpeccableLint

final class ContinuousCornerRuleTests: XCTestCase {
    private func run(_ source: String, file: String = "Test.swift") -> [Violation] {
        let tree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: file, tree: tree)
        let rule = ContinuousCornerRule(path: file, converter: converter)
        rule.walk(tree)
        return rule.violations
    }

    func testRoundedRectWithoutStyleFlags() {
        let v = run(Fixtures.roundedRectNoStyle)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testRoundedRectWithContinuousIsClean() {
        let v = run(Fixtures.roundedRectContinuous)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }

    func testCornerRadiusModifierFlags() {
        let v = run(Fixtures.cornerRadiusModifier)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testClipShapeContinuousIsClean() {
        let v = run(Fixtures.clipShapeContinuous)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }
}
