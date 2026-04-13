---
name: impeccable-swift-polish
description: Apply targeted design fixes to SwiftUI code based on critique findings or implicit review. Use when the user asks to polish, tighten, clean up, or apply design fixes to SwiftUI views.
user-invocable: true
argument-hint: "[file-or-critique-output]"
license: Apache 2.0. Based on Paul Bakaus's impeccable. See NOTICE.md.
---

Polish takes critique output — or a file plus an implicit critique — and makes targeted edits that follow the reference-doc rules. It tightens. It does not rewrite.

## Context gathering

Follow the Context Gathering Protocol in `../impeccable/SKILL.md`:

- Read all 12 reference docs under `impeccable/reference/`.
- Read the project's `DESIGN.md` at the repo root.
- Apply two-layer precedence: project tokens override universal defaults where explicit; universal rules fill the silence; Apple HIG is the final tiebreaker.
- Missing `DESIGN.md` → universal-only mode. Unparseable `DESIGN.md` → warn once and continue.

## Edit discipline

- **One concern per edit.** Don't rewrite a view to "polish" it. Touch only the lines that violate a rule.
- **Preserve working behavior.** Polish is tightening, not refactoring. If the view compiles and ships before polish, it compiles and ships after.
- **Name the rule.** Every edit carries the reference-doc citation in the commit message or an inline comment, e.g. `// impeccable-swift: typography.md — use .body for Dynamic Type`.
- **Re-read after editing.** Claude reads the file after each edit and confirms no new violations were introduced. If an edit creates a new violation in an adjacent rule, back out and rethink.
- **Small diffs.** Prefer five two-line edits over one forty-line rewrite.

## Non-scope

Polish does NOT:

- Add features. New behavior is out of scope.
- Refactor structure. View hierarchy, model layout, file organization stay as-is.
- Introduce new patterns. If the project uses `ObservableObject`, polish does not migrate to `@Observable`.
- Fix architectural problems. If the violation requires splitting a view, renaming a model, or changing a data flow, polish refuses and defers to human judgment with a one-line note: _"This needs architectural change — outside polish scope. Deferring to you."_

If the critique asks for something that crosses any of these lines, polish applies the edits it can, flags the rest, and stops.
