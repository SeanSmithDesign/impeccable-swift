import Foundation
import SwiftSyntax

/// Flags SwiftUI views that are visually silent to assistive tech: icon-only
/// buttons, standalone SF Symbol images, and tap-gesture surfaces that never
/// pick up an `.accessibilityLabel(...)` modifier in their chain.
final class AccessibilityLabelRule: SyntaxVisitor {
    static let name = "accessibility_label"

    let path: String
    let converter: SourceLocationConverter
    private(set) var violations: [Violation] = []

    // Once we flag a call site we track its SyntaxIdentifier to avoid double
    // reporting when the same node is hit through multiple entry points.
    private var reportedNodes: Set<SyntaxIdentifier> = []

    init(path: String, converter: SourceLocationConverter) {
        self.path = path
        self.converter = converter
        super.init(viewMode: .sourceAccurate)
    }

    // MARK: - Entry points

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let name = ModifierChain.initializerName(of: node) else {
            return .visitChildren
        }

        switch name {
        case "Button":
            checkButton(node)
        case "Image":
            checkImage(node)
        default:
            break
        }
        return .visitChildren
    }

    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        // Catch `.onTapGesture { }` calls by inspecting the enclosing call.
        if node.declName.baseName.text == "onTapGesture",
           let call = node.parent?.as(FunctionCallExprSyntax.self),
           call.calledExpression.id == Syntax(node).id {
            checkTapGesture(call)
        }
        return .visitChildren
    }

    // MARK: - Button { Image(systemName:) }

    private func checkButton(_ call: FunctionCallExprSyntax) {
        // Look for an `Image(systemName:)` anywhere inside the Button's label
        // content (the trailing closure or any argument closure).
        guard buttonContainsOnlySystemImage(call) else { return }

        let mods = ModifierChain.modifierNames(containing: ExprSyntax(call))
        guard !mods.contains("accessibilityLabel") else { return }

        report(at: call, message: "Button with only an SF Symbol needs an .accessibilityLabel(...) so VoiceOver can announce it.")
    }

    /// Returns true if the Button's label content consists only of a single
    /// `Image(systemName:)` with no visible text siblings.
    private func buttonContainsOnlySystemImage(_ call: FunctionCallExprSyntax) -> Bool {
        // Collect candidate closures: the trailing closure, any additional
        // trailing closure, and any closure passed as an argument.
        var closures: [ClosureExprSyntax] = []
        if let t = call.trailingClosure { closures.append(t) }
        for extra in call.additionalTrailingClosures {
            closures.append(extra.closure)
        }
        for arg in call.arguments {
            if let c = arg.expression.as(ClosureExprSyntax.self) {
                closures.append(c)
            }
        }
        guard !closures.isEmpty else { return false }

        // Heuristic v1: any of the button's closures contains an
        // `Image(systemName:)` call and no `Text(...)` call.
        let finder = ImageAndTextFinder()
        for closure in closures {
            finder.walk(closure)
        }
        return finder.hasSystemImage && !finder.hasText
    }

    // MARK: - Standalone Image(systemName:)

    private func checkImage(_ call: FunctionCallExprSyntax) {
        // Only care about `Image(systemName:)`; ignore `Image(decorative:)`,
        // `Image("asset")`, etc.
        guard ModifierChain.firstArgumentLabel(of: call) == "systemName" else { return }

        // Exclude images that sit inside another semantic container that
        // handles accessibility for them (Label, Button).
        if ModifierChain.isInsideCallNamed("Label", expr: ExprSyntax(call)) { return }
        if ModifierChain.isInsideCallNamed("Button", expr: ExprSyntax(call)) { return }

        let mods = ModifierChain.modifierNames(containing: ExprSyntax(call))
        if mods.contains("accessibilityLabel") { return }

        report(at: call, message: "Standalone Image(systemName:) needs an .accessibilityLabel(...) or use Image(decorative:) to hide it.")
    }

    // MARK: - .onTapGesture { }

    private func checkTapGesture(_ call: FunctionCallExprSyntax) {
        let mods = ModifierChain.modifierNames(containing: ExprSyntax(call))
        if mods.contains("accessibilityLabel") { return }
        // onTapGesture can't be VoiceOver-activated without a label; suggest
        // either adding one or switching to Button.
        report(at: call, message: ".onTapGesture without .accessibilityLabel is invisible to VoiceOver; prefer Button or add a label.")
    }

    // MARK: - Reporting

    private func report(at node: some SyntaxProtocol, message: String) {
        let id = node.id
        guard !reportedNodes.contains(id) else { return }
        reportedNodes.insert(id)

        let loc = node.startLocation(converter: converter)
        violations.append(Violation(
            path: path,
            line: loc.line,
            column: loc.column,
            ruleName: Self.name,
            message: message
        ))
    }
}

// MARK: - Internal helpers

/// Collects whether a subtree contains any `Image(systemName:)` and any
/// `Text(...)` initializer call.
private final class ImageAndTextFinder: SyntaxVisitor {
    var hasSystemImage = false
    var hasText = false

    init() { super.init(viewMode: .sourceAccurate) }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let name = ModifierChain.initializerName(of: node) else {
            return .visitChildren
        }
        if name == "Image",
           ModifierChain.firstArgumentLabel(of: node) == "systemName" {
            hasSystemImage = true
        }
        if name == "Text" {
            hasText = true
        }
        return .visitChildren
    }
}
