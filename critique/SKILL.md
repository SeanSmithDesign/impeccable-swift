---
name: impeccable-swift-critique
description: Review SwiftUI code for design quality, cite the reference doc each violation breaks, and return a scored summary. Use when the user asks to critique, review, audit, or score SwiftUI views for design quality.
user-invocable: true
argument-hint: "[file-or-directory]"
license: Apache 2.0. Based on Paul Bakaus's impeccable. See NOTICE.md.
---

Critique surfaces design violations in existing SwiftUI code with rule citations and a scored summary. It reports. It does not fix. Polish is the fixing skill.

## Context gathering

Follow the Context Gathering Protocol in `../impeccable/SKILL.md` before scanning. That means:

- Read all 13 reference docs under `impeccable/reference/`.
- Read the project's `DESIGN.md` at the repo root.
- Apply the two-layer precedence: project tokens override universal defaults where explicit; universal rules apply where the project is silent; Apple HIG is the final tiebreaker.
- If `DESIGN.md` is missing, run universal-only. If unparseable, warn once and continue.

## Detector invocation sequence

Run all three in order. Each detector is independent — a missing tool degrades gracefully. Report the missing tool, continue with the others.

1. **SwiftLint** — run with the project-local config:

   ```bash
   swiftlint lint --config tools/.swiftlint.yml <target>
   ```

   If `swiftlint` is not installed, report `swiftlint not found — skipping structural scan` and continue.

2. **impeccable-lint** — SwiftSyntax CLI:

   ```bash
   swift run --package-path tools/impeccable-lint impeccable-lint <target>
   ```

   If the package fails to build or Swift toolchain is unavailable, report the failure in one line and continue.

3. **asset-catalog-checker** — validates `.xcassets`:
   ```bash
   swift tools/asset-catalog-checker/check.swift <path-to-xcassets>
   ```
   If no `.xcassets` exists in the target, skip silently. If the script fails to run, report and continue.

Detector output feeds the finding table. Claude should also read the target files directly and add its own review — detectors catch patterns; a design director catches intent.

## Output format

### Findings table

| Finding                                | Rule                       | Severity | Reference               | Fix hint                                            |
| -------------------------------------- | -------------------------- | -------- | ----------------------- | --------------------------------------------------- |
| Uses fixed 17pt font                   | Dynamic Type required      | P1       | `typography.md`         | Switch to `.body` text style or `@ScaledMetric`     |
| Mixes SF Symbols with custom PNG icons | One symbol set per surface | P1       | `sf-symbols.md`         | Replace PNGs with SF Symbols or move all to one set |
| Custom `Color(hex: "#000000")`         | No hardcoded hex           | P2       | `color-and-contrast.md` | Use `.primary`, a named asset, or `DESIGN.md` token |

**Every finding must cite the reference doc it violates.** No citation means the finding does not ship.

### Summary score

Per-category counts:

- **Spatial** — spacing rhythm, safe areas, alignment. (`spatial-design.md`, `responsive-design.md`)
- **Typography** — text styles, Dynamic Type, numeric formatting. (`typography.md`)
- **Color** — semantic roles, contrast, Dark Mode. (`color-and-contrast.md`, `materials.md`)
- **Interaction** — gestures, haptics, focus, states. (`interaction-design.md`, `navigation.md`)
- **Motion** — animations, reduced motion. (`motion-design.md`)
- **Symbols & assets** — SF Symbols discipline, asset catalog health. (`sf-symbols.md`)
- **Platform fit** — iOS vs macOS divergences. (`ios-vs-macos.md`)
- **UX writing** — labels, errors, empty states. (`ux-writing.md`)

Report counts as `P0 / P1 / P2 / P3` per category, and a top-line verdict: _ship / polish-first / rework_.

## Termination

Critique does not edit files. Critique does not apply fixes. When the user says "fix it," hand off to `/impeccable-swift:polish`.
