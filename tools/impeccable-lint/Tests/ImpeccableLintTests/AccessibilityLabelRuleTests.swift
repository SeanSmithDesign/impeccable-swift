import XCTest
import SwiftParser
import SwiftSyntax
@testable import ImpeccableLint

final class AccessibilityLabelRuleTests: XCTestCase {
    private func run(_ source: String, file: String = "Test.swift") -> [Violation] {
        let tree = Parser.parse(source: source)
        let converter = SourceLocationConverter(fileName: file, tree: tree)
        let rule = AccessibilityLabelRule(path: file, converter: converter)
        rule.walk(tree)
        return rule.violations
    }

    func testButtonWithSystemImageMissingLabelFlags() {
        let v = run(Fixtures.a11yButtonIconNoLabel)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testButtonWithSystemImageAndLabelIsClean() {
        let v = run(Fixtures.a11yButtonIconWithLabel)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }

    func testStandaloneSystemImageFlags() {
        let v = run(Fixtures.a11yStandaloneIcon)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }

    func testImageInsideLabelIsClean() {
        let v = run(Fixtures.a11yLabelInit)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }

    func testDecorativeImageIsClean() {
        let v = run(Fixtures.a11yDecorativeImage)
        XCTAssertEqual(v.count, 0, "Expected zero violations, got \(v.map(\.formatted))")
    }

    func testTapGestureWithoutLabelFlags() {
        let v = run(Fixtures.a11yTapGestureNoLabel)
        XCTAssertEqual(v.count, 1, "Expected one violation, got \(v.map(\.formatted))")
    }
}
