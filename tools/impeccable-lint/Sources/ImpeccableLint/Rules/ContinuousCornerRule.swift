import Foundation
import SwiftSyntax

/// Flags corner-radius APIs that render square (G1) corners:
///   - `RoundedRectangle(cornerRadius:)` without `style: .continuous`
///   - `.cornerRadius(...)` modifier (always square)
/// iOS apps should use continuous (squircle) curvature to match the system.
final class ContinuousCornerRule: SyntaxVisitor {
    static let name = "continuous_corner"

    let path: String
    let converter: SourceLocationConverter
    private(set) var violations: [Violation] = []

    init(path: String, converter: SourceLocationConverter) {
        self.path = path
        self.converter = converter
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Case 1: RoundedRectangle(cornerRadius:) — flag unless style: .continuous is passed.
        if ModifierChain.initializerName(of: node) == "RoundedRectangle" {
            let hasCornerRadius = node.arguments.contains { $0.label?.text == "cornerRadius" }
            let hasContinuousStyle = node.arguments.contains { arg in
                arg.label?.text == "style" &&
                (arg.expression.description.contains(".continuous"))
            }
            if hasCornerRadius && !hasContinuousStyle {
                let loc = node.startLocation(converter: converter)
                violations.append(Violation(
                    path: path,
                    line: loc.line,
                    column: loc.column,
                    ruleName: Self.name,
                    message: "RoundedRectangle(cornerRadius:) renders square corners; add style: .continuous."
                ))
            }
            return .visitChildren
        }

        // Case 2: .cornerRadius(n) modifier — always square; suggest replacement.
        if let member = node.calledExpression.as(MemberAccessExprSyntax.self),
           member.declName.baseName.text == "cornerRadius" {
            let loc = node.startLocation(converter: converter)
            violations.append(Violation(
                path: path,
                line: loc.line,
                column: loc.column,
                ruleName: Self.name,
                message: ".cornerRadius(_:) uses square corners; use .clipShape(RoundedRectangle(cornerRadius:style: .continuous))."
            ))
        }

        return .visitChildren
    }
}
