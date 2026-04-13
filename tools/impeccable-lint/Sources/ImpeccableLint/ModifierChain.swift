import Foundation
import SwiftSyntax

/// Helpers for reasoning about SwiftUI view modifier chains.
///
/// In SwiftSyntax, `Foo().bar().baz()` parses as nested `FunctionCallExpr`s
/// wrapping `MemberAccessExpr`s:
///
///     FunctionCallExpr( called=MemberAccessExpr( base=FunctionCallExpr(...), name=baz ) )
///
/// Walking upward from the base expression lets us collect every modifier name
/// attached to the same chain, and descending the base finds the root call.
enum ModifierChain {
    /// Walk up from `expr` through its parent chain and return the outermost
    /// call in the same modifier chain. Given `Foo()` in `Foo().bar().baz()`,
    /// returns the call for `baz`.
    static func outermostCall(startingAt expr: ExprSyntax) -> ExprSyntax {
        var current: Syntax = Syntax(expr)
        while let parent = current.parent {
            // We're a call; check if our parent is a MemberAccessExpr whose
            // base is us, and whose parent is another FunctionCallExpr. That
            // means we're the base of a `.modifier()` call, so continue up.
            if let member = parent.as(MemberAccessExprSyntax.self),
               member.base?.id == current.id,
               let grandparent = member.parent,
               let outer = grandparent.as(FunctionCallExprSyntax.self),
               outer.calledExpression.id == Syntax(member).id {
                current = Syntax(outer)
                continue
            }
            break
        }
        return ExprSyntax(current) ?? expr
    }

    /// Return the set of modifier names applied to the chain that contains
    /// `anchorCall`. For `Image(...).foo().bar()` this returns `["foo", "bar"]`.
    static func modifierNames(containing anchorCall: ExprSyntax) -> Set<String> {
        let outer = outermostCall(startingAt: anchorCall)
        var names: Set<String> = []
        var cursor: ExprSyntax? = outer
        while let call = cursor?.as(FunctionCallExprSyntax.self) {
            if let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                names.insert(member.declName.baseName.text)
                cursor = member.base
            } else {
                // Reached the root (e.g. `Image(systemName:)` itself).
                break
            }
        }
        return names
    }

    /// Return every `FunctionCallExprSyntax` in the modifier chain containing
    /// `anchorCall`, from outermost down to (but not including) the root call.
    /// For `Image(...).foo().bar()` returns the call nodes for `.bar()` and `.foo()`.
    static func modifierCalls(containing anchorCall: ExprSyntax) -> [FunctionCallExprSyntax] {
        let outer = outermostCall(startingAt: anchorCall)
        var calls: [FunctionCallExprSyntax] = []
        var cursor: ExprSyntax? = outer
        while let call = cursor?.as(FunctionCallExprSyntax.self) {
            if let member = call.calledExpression.as(MemberAccessExprSyntax.self) {
                calls.append(call)
                cursor = member.base
            } else {
                break
            }
        }
        return calls
    }

    /// Returns true if `expr` is structurally nested within any argument of a
    /// `FunctionCallExpr` whose callee has the given simple name (e.g.
    /// `"Label"`). Used to exclude `Image(systemName:)` that is being used as
    /// the icon argument of a `Label(_:systemImage:)`.
    static func isInsideCallNamed(_ name: String, expr: ExprSyntax) -> Bool {
        var node: Syntax? = expr.parent
        while let n = node {
            if let call = n.as(FunctionCallExprSyntax.self) {
                if let declRef = call.calledExpression.as(DeclReferenceExprSyntax.self),
                   declRef.baseName.text == name {
                    return true
                }
                if let member = call.calledExpression.as(MemberAccessExprSyntax.self),
                   member.declName.baseName.text == name {
                    return true
                }
            }
            node = n.parent
        }
        return false
    }

    /// Return the base identifier name of a call expression, if it is a simple
    /// `Name(...)` initializer. For `Image(systemName: "x")`, returns "Image".
    /// For chained calls like `Foo().bar()`, returns nil.
    static func initializerName(of call: FunctionCallExprSyntax) -> String? {
        if let declRef = call.calledExpression.as(DeclReferenceExprSyntax.self) {
            return declRef.baseName.text
        }
        return nil
    }

    /// Check if `call` matches `Name(firstLabel: ...)` where the first argument
    /// uses `firstLabel`. Used to distinguish `Image(systemName:)` from
    /// `Image(decorative:)`.
    static func firstArgumentLabel(of call: FunctionCallExprSyntax) -> String? {
        call.arguments.first?.label?.text
    }
}
