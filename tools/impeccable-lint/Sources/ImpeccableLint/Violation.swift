import Foundation

/// A single lint violation reported by a rule.
public struct Violation: Equatable, Hashable, Sendable {
    public let path: String
    public let line: Int
    public let column: Int
    public let ruleName: String
    public let message: String

    public init(path: String, line: Int, column: Int, ruleName: String, message: String) {
        self.path = path
        self.line = line
        self.column = column
        self.ruleName = ruleName
        self.message = message
    }

    /// Formatted as `<path>:<line>:<col>: <rule-name>: <message>`.
    public var formatted: String {
        "\(path):\(line):\(column): \(ruleName): \(message)"
    }
}
