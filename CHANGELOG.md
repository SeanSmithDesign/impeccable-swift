# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] — 2026-04-26

**BREAKING:** `/critique` and `/polish` skills removed. Invoke as `/impeccable-swift critique` and `/impeccable-swift polish`.

- **Added:** Single `/impeccable-swift` skill with 23 sub-commands via 3.0 router pattern
  - craft: shape, audit, critique
  - render: animate, bolder, colorize, delight, layout, overdrive, quieter, typeset
  - fix: adapt, clarify, distill
  - ship: harden, onboard, optimize, polish
  - reference: teach, document, extract, live
- **Added:** Register system — reads `PRODUCT.md` and `DESIGN.md` from project root via `load-context.mjs` for context-aware output on every invocation
- **Added:** 27 reference docs (up from 12): all 23 sub-command refs + brand.md, product.md, personas.md, cognitive-load.md, heuristics-scoring.md
- **Added:** `pin.mjs` shortcut shim — `node .claude/skills/impeccable-swift/scripts/pin.mjs pin|unpin <command>`
- **Eval:** ChatBenchmarkV2 Phase 3.0 — P0+P1 gradient preserved (B1=23, B2=20, B3=10, B4=10). B4 increase from v0.1.0 (was 4) explained by newly added material-misuse + accessibilityHidden criteria.
- **Upstream:** Pinned at `f5e82162` (Impeccable 3.0, 2026-04-24)

## [0.1.0-poc] — 2026-04-16

- 12 reference docs: 8 ported from upstream (typography, color-and-contrast, spatial-design, motion-design, interaction-design, responsive-design, ux-writing, craft) + 4 Swift-native (sf-symbols, materials, navigation, ios-vs-macos) + 1 accessibility doc from HIG gap analysis
- 3 skills: impeccable-swift (umbrella), critique (evaluate + score), polish (tighten generated code)
- Three-tool detector stack: SwiftLint custom_rules (10 line-regex rules), impeccable-lint SwiftSyntax CLI (4 AST checks), asset-catalog-checker
- SnapshotPreviews convention docs and per-platform setup guide
- A/B evals: 4 briefs + ChatBenchmark V2 (4-condition, independent judges) — P0+P1 findings drop from 28 (stock) → 4 (impeccable-swift + DESIGN.md)
- Upstream pinned at `00d485659` (2026-04-12); no upstream drift at launch
