import Foundation
import SwiftSyntax

/// Flags `.frame(width:)` or `.frame(height:)` with numeric literals applied
/// to a `Text(...)`. Fixed pixel sizing on text breaks Dynamic Type. The
/// SwiftLint regex only catches the same-line case; this walks the full chain
/// so multi-line chains are caught too.
final class MultilineFrameOnTextRule: SyntaxVisitor {
    static let name = "multiline_frame_on_text"

    let path: String
    let converter: SourceLocationConverter
    private(set) var violations: [Violation] = []
    private var reportedChains: Set<SyntaxIdentifier> = []

    init(path: String, converter: SourceLocationConverter) {
        self.path = path
        self.converter = converter
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard ModifierChain.initializerName(of: node) == "Text" else {
            return .visitChildren
        }

        // Find the outermost call in this chain so we only report once even if
        // we see nested Text calls.
        let outer = ModifierChain.outermostCall(startingAt: ExprSyntax(node))
        if reportedChains.contains(outer.id) { return .visitChildren }

        for modCall in ModifierChain.modifierCalls(containing: ExprSyntax(node)) {
            guard
                let member = modCall.calledExpression.as(MemberAccessExprSyntax.self),
                member.declName.baseName.text == "frame"
            else { continue }

            if let badArg = firstFixedSizeArgument(of: modCall) {
                let loc = modCall.startLocation(converter: converter)
                violations.append(Violation(
                    path: path,
                    line: loc.line,
                    column: loc.column,
                    ruleName: Self.name,
                    message: "Fixed \(badArg) on Text breaks Dynamic Type; use .frame(maxWidth:) / alignment or remove it."
                ))
                reportedChains.insert(outer.id)
                break
            }
        }
        return .visitChildren
    }

    /// If the frame call contains a numeric literal for `width:` or `height:`,
    /// returns the offending label. Otherwise nil.
    private func firstFixedSizeArgument(of call: FunctionCallExprSyntax) -> String? {
        for arg in call.arguments {
            guard let label = arg.label?.text else { continue }
            guard label == "width" || label == "height" else { continue }
            if arg.expression.is(IntegerLiteralExprSyntax.self) ||
               arg.expression.is(FloatLiteralExprSyntax.self) {
                return label
            }
        }
        return nil
    }
}
