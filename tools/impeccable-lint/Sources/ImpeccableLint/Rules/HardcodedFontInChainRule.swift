import Foundation
import SwiftSyntax

/// Flags `.font(.system(size:))` anywhere in a modifier chain. `.system(size:)`
/// without `relativeTo:` ignores Dynamic Type. The SwiftLint regex only catches
/// single-line occurrences; this walks the AST so multi-line chains match too.
final class HardcodedFontInChainRule: SyntaxVisitor {
    static let name = "hardcoded_font_in_chain"

    let path: String
    let converter: SourceLocationConverter
    private(set) var violations: [Violation] = []

    init(path: String, converter: SourceLocationConverter) {
        self.path = path
        self.converter = converter
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        // Match `.font(<arg>)` calls.
        guard
            let member = node.calledExpression.as(MemberAccessExprSyntax.self),
            member.declName.baseName.text == "font",
            let firstArg = node.arguments.first
        else {
            return .visitChildren
        }

        // The argument should be `.system(size: ...)` as a nested call.
        guard let inner = firstArg.expression.as(FunctionCallExprSyntax.self),
              let innerMember = inner.calledExpression.as(MemberAccessExprSyntax.self),
              innerMember.declName.baseName.text == "system"
        else {
            return .visitChildren
        }

        // If it has `relativeTo:`, Dynamic Type is respected — skip.
        let hasRelativeTo = inner.arguments.contains { $0.label?.text == "relativeTo" }
        if hasRelativeTo { return .visitChildren }

        // Only flag when `size:` is passed — that's the anti-pattern. Bare
        // `.system(.title)` (a text-style shorthand) is fine.
        let hasSize = inner.arguments.contains { $0.label?.text == "size" }
        guard hasSize else { return .visitChildren }

        let loc = node.startLocation(converter: converter)
        violations.append(Violation(
            path: path,
            line: loc.line,
            column: loc.column,
            ruleName: Self.name,
            message: ".font(.system(size:)) ignores Dynamic Type; use a text style (.body, .headline) or .system(size:relativeTo:)."
        ))
        return .visitChildren
    }
}
