# impeccable-lint

SwiftSyntax-based linter for SwiftUI anti-patterns the SwiftLint regex engine can't reliably express. Catches AST-level violations across multi-line modifier chains.

## Rules

| Rule                      | What it catches                                                                                                                                                 |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `accessibility_label`     | Icon-only `Button { Image(systemName:) }`, standalone `Image(systemName:)`, and `.onTapGesture { }` without an `.accessibilityLabel(...)` in the modifier chain |
| `multiline_frame_on_text` | `Text(...)` with a numeric `.frame(width:)` or `.frame(height:)` anywhere in its modifier chain (breaks Dynamic Type)                                           |
| `hardcoded_font_in_chain` | `.font(.system(size:))` without `relativeTo:`, on any line of the chain                                                                                         |
| `continuous_corner`       | `RoundedRectangle(cornerRadius:)` without `style: .continuous`, or the `.cornerRadius(_:)` modifier (always square corners)                                     |

## Build & run

From this directory:

```bash
swift build
swift test
swift run impeccable-lint <file-or-directory>
```

First build pulls `swift-syntax` (~2 minutes). Subsequent builds are fast.

## CLI contract

```
swift run impeccable-lint <file-or-directory> [--json]
```

- Recurses `.swift` files if given a directory.
- Output format: `<path>:<line>:<col>: <rule-name>: <message>`, one per line.
- Exit code `0` on zero violations, `1` otherwise (matches standard lint-tool convention).
- `--json` emits a pretty-printed JSON array (SARIF-lite) instead of the line format.

Example:

```
$ swift run impeccable-lint Sources/MyApp
Sources/MyApp/ProfileView.swift:42:13: accessibility_label: Button with only an SF Symbol needs an .accessibilityLabel(...) so VoiceOver can announce it.
Sources/MyApp/Card.swift:18:9: continuous_corner: RoundedRectangle(cornerRadius:) renders square corners; add style: .continuous.
```

## Integration with the critique skill

The `critique` skill can invoke this tool as part of its SwiftUI review pass. Recommended call pattern:

```bash
swift run --package-path tools/impeccable-lint impeccable-lint <path-under-review>
```

Pipe output into the skill's findings collector. Exit code `1` with non-empty stdout signals violations to surface; exit `0` means the file is clean on the four rules we enforce.

## swift-syntax version

Pinned via `Package.swift` to `510.0.0+`. Resolved version in this tree: **510.0.3**.

## Architecture notes

- Each rule is a `SyntaxVisitor` subclass owning its own `[Violation]` accumulator. They're composable and ordered in `main.swift`.
- `ModifierChain.swift` provides helpers for walking SwiftUI-style chains (`Foo().bar().baz()` parses as nested `FunctionCallExpr`/`MemberAccessExpr`, so the utilities find the outermost call and enumerate modifier names).
- Tests use short source-string fixtures in `Tests/ImpeccableLintTests/Fixtures/Fixtures.swift` — no resource bundling required.
- Malformed Swift is tolerated: `SwiftParser.Parser.parse` always returns a tree; visitors run over whatever the parser recovered.
