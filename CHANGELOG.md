# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0-poc] — 2026-04-16

- 12 reference docs: 8 ported from upstream (typography, color-and-contrast, spatial-design, motion-design, interaction-design, responsive-design, ux-writing, craft) + 4 Swift-native (sf-symbols, materials, navigation, ios-vs-macos) + 1 accessibility doc from HIG gap analysis
- 3 skills: impeccable-swift (umbrella), critique (evaluate + score), polish (tighten generated code)
- Three-tool detector stack: SwiftLint custom_rules (10 line-regex rules), impeccable-lint SwiftSyntax CLI (4 AST checks), asset-catalog-checker
- SnapshotPreviews convention docs and per-platform setup guide
- A/B evals: 4 briefs + ChatBenchmark V2 (4-condition, independent judges) — P0+P1 findings drop from 28 (stock) → 4 (impeccable-swift + DESIGN.md)
- Upstream pinned at `00d485659` (2026-04-12); no upstream drift at launch
