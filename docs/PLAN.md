---
title: impeccable-swift — Swift/SwiftUI Design Quality Skill Family
type: feat
status: active
date: 2026-04-12
origin: docs/brainstorms/2026-04-12-impeccable-swift-requirements.md
---

# impeccable-swift — Implementation Plan

**Target repo:** `SeanSmithDesign/impeccable-swift` (new, to be created — private during build, public at POC flip).

## Overview

Faithful Swift/SwiftUI port of Paul Bakaus's [impeccable](https://github.com/pbakaus/impeccable) design-quality skill family, scoped to iOS 26+ and macOS 26+ with Liquid Glass as first-class vocabulary. Ships as a flat-verbs skill repository distributable via `npx skills add SeanSmithDesign/impeccable-swift`.

Full-scope v1: 12 reference docs (8 ported + 4 Swift-specific), three skills (`impeccable-swift`, `critique`, `polish`), full anti-pattern detection stack (SwiftLint custom rules + SwiftSyntax CLI + asset-catalog checker), `SnapshotPreviews` visual-review wiring, evals directory, `UPSTREAM.md` surveillance, `CHANGELOG.md`, and a `transformers/claude-code/` scaffold for future multi-harness support.

Timeline: ~10–14 days calendar, parallelized across subagents. Launch posture: proof of concept, not production-grade release. Dogfood on Brakus (fka Pico Focus) before public flip.

## Problem Frame

Sean builds SwiftUI apps for iOS and macOS with Claude as technical collaborator. Paul's impeccable produces measurably better web UI when installed — through opinionated reference docs, anti-pattern detection, and a critique-and-iterate workflow — but its content is CSS/React/Tailwind-flavored and its JS detector doesn't apply to Apple platforms. No Swift-native fork exists among impeccable's 834 forks (confirmed by repo research), and no signal that Paul is planning one himself (confirmed by backwards-plan research). The `DESIGN-SWIFT.md.template` at `docs/DESIGN-SWIFT.md.template` already solves the per-project token half of the problem; what's missing is the universal-principles half. See origin: `docs/brainstorms/2026-04-12-impeccable-swift-requirements.md`.

## Requirements Trace

All 23 origin requirements carried forward. Referenced per-unit below.

- R1–R5 (Content & Philosophy): faithful port preserving Paul's voice/structure, 8 upstream topics + 4 new, operational clarity
- R6–R8 (Platform): iOS 26+/macOS 26+ floor, 4pt scale, Dynamic Type non-negotiable
- R9–R11 (Architecture): two-layer (universal principles fork + per-project DESIGN.md)
- R12–R14 (Packaging): `SeanSmithDesign/impeccable-swift`, Apache 2.0 + NOTICE.md, `npx skills`, `/impeccable-swift:<verb>` namespace
- R15–R18 (Upstream Surveillance): `UPSTREAM.md` + diff-not-merge + pin + review cadence
- R19–R21 (Launch): private build → Brakus dogfood → public POC flip
- R22–R23 (Tooling): SwiftLint custom rules + SnapshotPreviews

## Scope Boundaries

- **Not** porting upstream's JS anti-pattern CLI — replaced by three-tool Swift-native detector stack.
- **Not** replacing `DESIGN-SWIFT.md.template` — two-layer architecture preserves it.
- **Not** prescribing aesthetic taste (accent colors, brand tone) — technical discipline only.
- **Not** supporting iOS <26 / macOS <26 in v1.
- **Not** a production-grade release — explicitly positioned as proof of concept.
- **Not** rebranding — faithful port, credits Paul prominently.
- **Not** contributing upstream — fork stays downstream.
- **Not** integrating Dialkit-iOS as a runtime companion — planning-time precedent only.

### Deferred to Separate Tasks

- **Multi-harness transformer implementations** (Cursor, Codex, Copilot, etc.): transformers/ scaffold included in v1 with only `claude-code/` populated. Additional transformers land in v1.1+ if demand appears.
- **Chrome DevTools extension equivalent** (Paul's v2.0 shipped one; our equivalent would be an Xcode/Simulator overlay): flagged as v2 potential, not v1.
- **Backward compat for iOS <26**: deferred indefinitely; reconsider if real user demand appears.

## Context & Research

### Relevant Code and Patterns

- **Upstream precedent**: `pbakaus/impeccable` ([GitHub](https://github.com/pbakaus/impeccable)). Flat-verbs repo layout, each verb a top-level folder with `SKILL.md`. Reference docs live under the `impeccable` verb at `reference/`.
- **Installed reference**: `~/.agents/skills/impeccable/` — 8 reference docs already audited for port-effort tiers.
- **Frontmatter convention**: matches existing `impeccable/SKILL.md` — `name`, `description`, `user-invocable: true`, `argument-hint`, `license`.
- **Distribution manifest**: `~/Code/skills-lock.json` enumerates each verb as a separate `{source, sourceType, computedHash}` entry. Multi-skill repos are first-class.
- **Per-project template**: `docs/DESIGN-SWIFT.md.template` — stays unchanged per R10. Includes Agent Prompt Guide at bottom that skills will read.
- **Swift-project pattern precedent**: `Pico Focus/.claude/rules/{code-quality,testing,security}.md` — layered rules pattern, worth referencing in `craft.md`.
- **Brakus dogfood target**: Swift project on disk at `Brakus/` (formerly `Pico Focus/`). No `DESIGN.md` yet, no `.swiftlint.yml` yet — greenfield-ish integration point.

### Institutional Learnings

- **Marketplace cache staleness** (`docs/solutions/workflow-issues/claude-code-plugin-marketplace-cache-staleness.md`): installed plugins go stale because `claude plugin update` reads local git clones without `git fetch`. **Implication:** plan the public POC flip as a clean `npx skills add` install path, not an in-place rename. Do not rename the source repo post-launch.
- **No prior solution** for skill authoring conventions, Apache 2.0 fork workflow, two-layer config patterns, or Apple platform specifics. Treat these as greenfield and compound after v1 ships.

### External References

- **SwiftLint capabilities** ([realm/SwiftLint](https://github.com/realm/SwiftLint), [custom_rules docs](https://realm.github.io/SwiftLint/custom_rules.html)): `custom_rules` are regex-only, line-oriented, with optional `match_kinds`. No SPM-based extension path; analyzer_rules are not user-extensible. **Canonical split confirmed:** SwiftLint for line-local patterns, separate SwiftSyntax CLI for AST-level checks, direct JSON parsing for asset-catalog checks.
- **SwiftSyntax** ([swiftlang/swift-syntax](https://github.com/swiftlang/swift-syntax)): `SwiftSyntax` + `SwiftParser` packages. Thin `SyntaxVisitor` over `.swift` files invoked via SPM as `swift run impeccable-lint`.
- **SnapshotPreviews v0.11** ([EmergeTools/SnapshotPreviews](https://github.com/EmergeTools/SnapshotPreviews)): auto-renders `#Preview` macros per test target. `PreviewVariants` gives landscape/RTL/dark/Dynamic Type for free. **Mac rendering requires a separate macOS test target** — Xcode constraint, not tool limitation.
- **npx skills distribution** ([vercel-labs/skills](https://github.com/vercel-labs/skills)): CLI searches `skills/`, root, `.claude/skills/`, `.agents/skills/` recursively. Preferred layout for new repos: `<verb>/SKILL.md` at root.
- **Paul's trajectory** (via backwards-plan research): v1.0 was refs + 1 skill + 1 command, launched on HN Jan 2026. v2.0 added detection CLI + Chrome extension three months later. Our "v1 full scope" is closer to his v2 than v1 — accepted tradeoff.

## Key Technical Decisions

- **Three-tool detector stack over single SwiftLint config** — SwiftLint regex covers line-local patterns (hardcoded hex, `.font(.system(size:)`, magic spacing); SwiftSyntax CLI covers AST-level checks (missing `.accessibilityLabel`, multi-line `.frame` on Text); asset-catalog checker covers `SF Symbols over PNGs`. Rationale: SwiftLint cannot reliably express modifier-chain analysis or asset resolution — confirmed via framework-docs research and [Issue #5294](https://github.com/realm/SwiftLint/issues/5294).
- **Flat-verbs repo shape, not plugin marketplace shape** — matches impeccable upstream, `npx skills` convention, and the installed `~/.agents/skills/impeccable/` layout. No `commands/` folder, no `marketplace.json`.
- **Namespace via frontmatter, not folder rename** — `name: impeccable-swift-critique` in SKILL.md frontmatter; folder stays `critique/` to mirror upstream. Keeps filesystem diffs against upstream clean for UPSTREAM.md surveillance.
- **Reference docs shared under `impeccable/reference/`, not duplicated per skill** — mirrors upstream's pattern. Other verbs link by relative path.
- **Port-effort tiered sequencing**: tier-1 (port ~90%: ux-writing, craft, color-and-contrast), tier-2 (port ~50%: motion-design, typography, spatial-design), tier-3 (rewrite 60–80%: interaction-design, responsive-design). New docs (sf-symbols, materials, navigation, ios-vs-macos) are net-new authoring.
- **Two-layer read precedence**: project `DESIGN.md` overrides universal defaults where explicit; universal principles apply where the project is silent. Non-conflict composition is the common case (DESIGN.md sets a _value_, reference doc sets a _rule_ — they compose).
- **Pin v1 to a specific upstream SHA** captured at U1 scaffold time. README states _"Based on impeccable X.Y.Z by Paul Bakaus."_
- **Transformer scaffold included even though only claude-code is populated** — cheap insurance against multi-harness retrofit later. Matches Paul's day-one structural bet.
- **Evals directory with A/B protocol** — 3–5 SwiftUI briefs rendered with Claude with/without the skill installed. Gives POC credibility at launch without heavy ceremony.
- **Single dogfood project (Brakus) over multi-project** — confirmed iOS 26+ target. POC framing + informal self-validation compensates for reduced surface.

## Open Questions

### Resolved During Planning

- **Which Swift projects dogfood**: Brakus (fka Pico Focus), confirmed at iOS 26+/macOS 26+. Resolved during brainstorm refinement.
- **Which tool for AST-level checks**: standalone SwiftSyntax CLI (not SwiftLint analyzer_rules, which aren't user-extensible). Resolved via framework-docs research.
- **Cross-platform SnapshotPreviews strategy**: per-platform test targets + `PreviewVariants` for RTL/dark/accessibility. Resolved via framework-docs research.
- **Repo structure**: flat verbs at root, reference/ under `impeccable` verb, namespacing via frontmatter. Resolved via repo research.
- **Upstream collision risk on Swift**: zero signal from Paul. Resolved via backwards-plan research.

### Deferred to Implementation

- **Exact SwiftLint rule set** — target 8–12 regex rules, validated against fixture Swift files during U5. Count may adjust based on false-positive testing.
- **Exact SwiftSyntax rules** — target 4–6 AST checks (missing accessibilityLabel on Button/tap interactions, multi-line .frame on Text, hardcoded .font(.system(size:)) across method boundaries, .continuous corner style enforcement). Final set validated during U6.
- **Repo name availability** — verify `SeanSmithDesign/impeccable-swift` is not taken when repo is created in U1.
- **Upstream SHA to pin** — captured at U1 execution time, whatever is HEAD of `pbakaus/impeccable` main.
- **Voice-translation anti-patterns** — Paul's "Syne is an instant AI design tell" was earned from specific web exposure. Swift equivalents (e.g., which SF Symbols are AI tells, which Liquid Glass patterns feel cargo-culted) are discovered during U9 Brakus dogfood and captured in CHANGELOG or v1.1.
- **Eval brief specifics** — 3–5 SwiftUI brief prompts written during U8; exact prompts chosen to exercise the highest-signal reference docs.

## Output Structure

```
impeccable-swift/
├── LICENSE                             # Apache 2.0
├── NOTICE.md                           # Attribution to Paul Bakaus + Anthropic
├── README.md                           # POC framing, install, attribution
├── UPSTREAM.md                         # Surveillance log + pinned upstream SHA
├── CHANGELOG.md                        # Release notes
├── .gitignore
│
├── impeccable/                         # Umbrella skill (main entry)
│   ├── SKILL.md
│   └── reference/                      # Shared reference docs (all verbs read these)
│       ├── typography.md               # Dynamic Type, SF Pro, @ScaledMetric
│       ├── color-and-contrast.md       # Asset Catalog, semantic colors
│       ├── spatial-design.md           # 4pt scale (Apple: pt not px), 44pt floor
│       ├── motion-design.md            # Springs, reduceMotion
│       ├── interaction-design.md       # 8 states, focus, hover, pressed
│       ├── responsive-design.md        # Size classes, safeAreaInset
│       ├── ux-writing.md               # Voice, error messages (mostly 1:1 port)
│       ├── craft.md                    # Shape → reference → build → iterate
│       ├── sf-symbols.md               # [new] rendering modes, weight matching
│       ├── materials.md                # [new] Liquid Glass, .regularMaterial
│       ├── navigation.md               # [new] NavigationStack/Split, toolbars
│       └── ios-vs-macos.md             # [new] chrome, sidebar, pointer, menu bar
│
├── critique/                           # Critique skill (review & score)
│   └── SKILL.md
│
├── polish/                             # Polish skill (tighten generated code)
│   └── SKILL.md
│
├── tools/
│   ├── .swiftlint.yml                  # Drop-in custom_rules (regex tier)
│   ├── impeccable-lint/                # SwiftSyntax CLI (Swift package)
│   │   ├── Package.swift
│   │   ├── Sources/ImpeccableLint/
│   │   └── Tests/
│   └── asset-catalog-checker/          # JSON parser for .xcassets
│       └── check.swift                 # Single-file executable
│
├── snapshot-previews/
│   ├── README.md                       # #Preview convention doc
│   └── example-setup.md                # Per-platform test-target setup guide
│
├── evals/                              # A/B proof-of-effect briefs
│   ├── README.md                       # Protocol
│   ├── brief-01-settings-screen.md
│   ├── brief-02-list-with-empty-state.md
│   ├── brief-03-onboarding-flow.md
│   └── outputs/                        # Generated samples (with + without skill)
│
└── transformers/                       # Multi-harness scaffold
    └── claude-code/                    # Only populated transformer in v1
        └── README.md                   # Transformer contract (for future harnesses)
```

## High-Level Technical Design

> _This illustrates the intended approach and is directional guidance for review, not implementation specification. The implementing agent should treat it as context, not code to reproduce._

**Two-layer read + three-tool detector flow for `/impeccable-swift:critique`:**

```mermaid
sequenceDiagram
    participant User
    participant Critique as /impeccable-swift:critique
    participant Refs as impeccable/reference/*.md
    participant DesignMd as Project DESIGN.md
    participant SL as SwiftLint (regex)
    participant SX as impeccable-lint (SwiftSyntax)
    participant AC as asset-catalog-checker
    participant SP as SnapshotPreviews output

    User->>Critique: invoke on a SwiftUI file
    Critique->>Refs: read universal principles
    Critique->>DesignMd: read project tokens (if present)
    Note over Critique,DesignMd: Project DESIGN.md tokens<br/>override universal defaults;<br/>universal rules apply where silent
    Critique->>SL: run line-regex checks (hex, system-font-size, magic spacing)
    Critique->>SX: run AST checks (a11y label, multi-line .frame on Text)
    Critique->>AC: run asset-catalog resolution (SF Symbol vs PNG)
    Critique->>SP: read rendered #Preview PNGs (if available)
    SL-->>Critique: regex findings
    SX-->>Critique: AST findings
    AC-->>Critique: asset findings
    SP-->>Critique: visual variant coverage
    Critique-->>User: consolidated critique with rule citations
```

**Repo layout follows impeccable upstream** (flat verbs, shared reference/ under main verb). Does not follow the Claude Code plugin marketplace shape (no `commands/`, no `marketplace.json`).

## Implementation Units

- [ ] **Unit 1: Scaffold private repo + attribution + upstream pin**

**Goal:** Create the `impeccable-swift` private GitHub repo with the full directory skeleton, license/attribution files, frontmatter templates, and a pinned upstream reference.

**Requirements:** R12, R15, R16, R17

**Dependencies:** None (first unit)

**Files:**

- Create: `LICENSE` (Apache 2.0 verbatim from upstream)
- Create: `NOTICE.md` (attribution chain: this fork → Paul Bakaus → Anthropic frontend-design)
- Create: `README.md` (POC framing, install snippet, attribution line, pinned upstream SHA)
- Create: `UPSTREAM.md` (surveillance log template with pinned SHA + date of capture)
- Create: `CHANGELOG.md` (Keep-a-Changelog format, v0.1.0-poc entry empty for now)
- Create: `.gitignore` (Swift-flavored: DerivedData, xcuserdata, Packages, .build)
- Create: Empty directory stubs for all paths in Output Structure

**Approach:**

- Capture `git ls-remote https://github.com/pbakaus/impeccable main` SHA at execution time. Record in both README and UPSTREAM.md.
- README attribution text locked: _"impeccable-swift builds on [impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus (Apache 2.0). See NOTICE.md for full attribution chain."_
- POC framing locked in README: _"v0.1.0-poc — proof of concept, not production-grade. Faithful Swift/SwiftUI port."_
- Private repo on first push; `gh repo create SeanSmithDesign/impeccable-swift --private`.
- Verify repo name availability before creating.

**Patterns to follow:**

- `~/.agents/skills/impeccable/SKILL.md` — frontmatter structure
- Upstream `pbakaus/impeccable` README — license + attribution ordering

**Test scenarios:**

- Happy path: `gh repo view SeanSmithDesign/impeccable-swift` returns a private repo; README renders with attribution line visible.
- Edge case: repo name already taken → fall back to `impeccable-swiftui` or prompt user (this is a deferred question, resolve at runtime).
- Verification: UPSTREAM.md contains a 40-character SHA and a 2026-04-12 date; `LICENSE` text matches upstream's byte-for-byte.

**Verification:**

- Private repo exists and is cloneable by Sean
- All 6 top-level files present, no empty `README.md`
- Directory tree matches Output Structure section

---

- [ ] **Unit 2: Port 8 upstream reference docs (parallel subagent dispatch)**

**Goal:** Translate the eight upstream reference docs from CSS/React idiom to SwiftUI idiom, preserving Paul's voice (declare → why → rule → anti-pattern).

**Requirements:** R1, R2, R4, R5

**Dependencies:** Unit 1

**Files:**

- Create: `impeccable/reference/typography.md`
- Create: `impeccable/reference/color-and-contrast.md`
- Create: `impeccable/reference/spatial-design.md`
- Create: `impeccable/reference/motion-design.md`
- Create: `impeccable/reference/interaction-design.md`
- Create: `impeccable/reference/responsive-design.md`
- Create: `impeccable/reference/ux-writing.md`
- Create: `impeccable/reference/craft.md`

**Approach:**

- **Port-effort tiers** (from brainstorm audit):
  - **Tier 1 (~90% port):** `ux-writing.md`, `craft.md`, `color-and-contrast.md`. Adapt examples only; principles carry verbatim.
  - **Tier 2 (~50% port):** `motion-design.md`, `typography.md`, `spatial-design.md`. Swap units/APIs, keep philosophy and tables.
  - **Tier 3 (60–80% rewrite):** `interaction-design.md`, `responsive-design.md`. Native navigation/adaptation are different mental models.
- **Dispatch strategy:** spawn three parallel subagent batches, one per tier. Each subagent gets: (a) the upstream source doc at `~/.agents/skills/impeccable/reference/<name>.md`, (b) the port-effort target, (c) a voice-preservation checklist (declarations, anti-pattern tone, why-reasoning).
- **Voice checklist per doc:** at least two "declare" statements ("Stop using X"), at least one named anti-pattern, explicit why-reasoning for each rule, no educational wandering.
- **4pt vs 4px disambiguation:** `spatial-design.md` must open with an explicit statement that Apple uses points (pt), not pixels (px), to pre-empt Claude's web memory from regressing.
- Each doc maps web idiom → Swift idiom per the brainstorm audit's per-file port notes (OKLCH → SwiftUI Color; `clamp()` → Dynamic Type; `@container` → size classes; `prefers-reduced-motion` → `@Environment(\.accessibilityReduceMotion)`; etc.).

**Patterns to follow:**

- Upstream source docs at `~/.agents/skills/impeccable/reference/*.md`
- Voice conventions documented in R5

**Test scenarios:**

- Happy path: each doc passes the voice checklist (2+ declarations, named anti-pattern, why-reasoning)
- Edge case: any doc that regresses to educational tone (no declarations, no anti-pattern) gets sent back to subagent for rewrite
- Verification: spot-check 3 random docs against upstream — Swift examples should be idiomatic SwiftUI, not web-with-Swift-syntax-pasted-in

**Verification:**

- All 8 files exist, each 80–200 lines
- No mentions of `rem`, `clamp()`, `@container`, `className`, Tailwind, shadcn
- Each opens with a declarative principle statement

---

- [ ] **Unit 3: Author 4 new Swift-specific reference docs**

**Goal:** Write reference docs for Apple-specific domains that have no upstream equivalent.

**Requirements:** R3, R4, R5, R6, R8

**Dependencies:** Unit 1 (scaffold). Can run in parallel with Unit 2.

**Files:**

- Create: `impeccable/reference/sf-symbols.md`
- Create: `impeccable/reference/materials.md`
- Create: `impeccable/reference/navigation.md`
- Create: `impeccable/reference/ios-vs-macos.md`

**Approach:**

- **sf-symbols.md subtopics:** rendering modes (monochrome / hierarchical / palette / multicolor — pick one per surface); weight matching to surrounding text; sizing via `.font()` not `.frame()`; custom PNG icons mixed with SF Symbols = automatic fail; the "one symbol set per surface" rule.
- **materials.md:** `.regularMaterial` / `.thinMaterial` / `.ultraThinMaterial` as semantic surfaces; Liquid Glass via `.glassEffect()` and `GlassEffectContainer` as the iOS 26+/macOS 26+ default vocabulary; never stack `Color.white.opacity(0.3) + .blur()` (Swift equivalent of CSS backdrop-filter hacks); concentric corner rule (child radius = parent radius − padding).
- **navigation.md:** `NavigationStack` for drill-down vs. `NavigationSplitView` for list+detail; `ToolbarItem(placement:)` with `.primaryAction`/`.secondaryAction`/`.navigation` resolving differently per platform; `.navigationTitle` with deliberate `.navigationBarTitleDisplayMode`; safe-area handling via `.safeAreaInset`.
- **ios-vs-macos.md:** sidebar behavior (`NavigationSplitView` collapses on iOS portrait, full-height on macOS); toolbar placement per platform; pointer effects (`.hoverEffect()`, `.help()`); window chrome (`.windowStyle(.hiddenTitleBar)`, `.containerBackground(.regularMaterial, for: .window)`); context menus everywhere on macOS, sparingly on iOS; `MenuBarExtra` for menu-bar apps; popovers (macOS/iPad) vs sheets (iPhone).
- **Structure:** each doc follows R5's voice conventions same as ported docs. Declare → why → rule → anti-pattern.
- **iPadOS coverage:** folded into `navigation.md` and `ios-vs-macos.md` as appropriate — not a separate doc.

**Patterns to follow:**

- Tier-1 ported docs from Unit 2 as tone/voice exemplars (match the declarations style)
- Apple HIG 2026 edition for iOS 26 / macOS 26 specifics

**Test scenarios:**

- Happy path: each doc passes voice checklist, cites at least 3 specific Apple APIs, names at least 2 anti-patterns
- Edge case: `materials.md` must demonstrate Liquid Glass as first-class (not an afterthought) — if it reads as "also Liquid Glass exists," rewrite
- Verification: each doc defines its scope in one opening sentence; no overlap with ported docs (e.g., materials.md doesn't redundantly cover color)

**Verification:**

- All 4 files exist, 60–150 lines each
- Liquid Glass appears as default vocabulary in materials.md (not progressive enhancement)
- No @available iOS 25 or earlier references anywhere

---

- [ ] **Unit 4: Author SKILL.md files for three skills**

**Goal:** Create the three skill entry points (`impeccable-swift`, `critique`, `polish`) with correct frontmatter and the two-layer read logic.

**Requirements:** R9, R10, R11, R13, R14

**Dependencies:** Units 2 and 3 complete (references exist to link from SKILL.md)

**Files:**

- Create: `impeccable/SKILL.md`
- Create: `critique/SKILL.md`
- Create: `polish/SKILL.md`

**Approach:**

- **Frontmatter per file** (per repo-research confirmed convention):
  ```yaml
  ---
  name: impeccable-swift
  description: <trigger-rich one-liner>
  user-invocable: true
  argument-hint: "[craft|teach]"
  license: Apache 2.0. Based on Paul Bakaus's impeccable. See NOTICE.md.
  ---
  ```
- **`impeccable/SKILL.md` (umbrella)**: parallels upstream's main SKILL.md. Includes Context Gathering Protocol that instructs Claude to read all reference docs + read project-local `DESIGN.md` at `./DESIGN.md` if present. Documents the two-layer read precedence: project tokens override universal defaults where explicit; universal rules apply where silent.
- **`critique/SKILL.md`**: scoring-and-review skill. Reads both layers, invokes the three detectors (U5–U7), produces a critique with rule citations.
- **`polish/SKILL.md`**: applies tightening changes based on critique output. Reads both layers, makes targeted edits.
- **Namespace declaration**: all three frontmatters use `name: impeccable-swift-<verb>` so commands resolve as `/impeccable-swift:<verb>` — confirmed via repo research.

**Patterns to follow:**

- `~/.agents/skills/impeccable/SKILL.md` — overall structure, Context Gathering Protocol pattern
- `~/.agents/skills/critique/SKILL.md` — critique-and-score pattern (inherits from Paul's /critique)

**Test scenarios:**

- Happy path: each SKILL.md has valid YAML frontmatter with all 5 required fields; description ends with "Use when..." trigger phrase
- Edge case: when project `DESIGN.md` is missing, skill falls back to universal-only mode without erroring
- Edge case: when project `DESIGN.md` exists but is unparseable, skill logs a warning and proceeds with universal rules
- Integration: `/impeccable-swift:critique` invocation reads both layers and returns findings citing rules by name

**Verification:**

- `npx skills lint` (or equivalent) passes on all three SKILL.md files
- Frontmatter `name` fields use the namespaced form
- Context Gathering Protocol in impeccable/SKILL.md documents the two-layer read order

---

- [ ] **Unit 5: SwiftLint custom_rules `.swiftlint.yml`**

**Goal:** Ship a drop-in SwiftLint config covering the line-regex tier of anti-patterns.

**Requirements:** R22

**Dependencies:** Unit 1

**Files:**

- Create: `tools/.swiftlint.yml`
- Create: `tools/fixtures/SwiftLintFixtures.swift` (test fixtures with seeded violations)

**Approach:**

- **Target rules (line-regex tier, 8–12 total):**
  - `no_hardcoded_hex_color`: matches `Color\s*\(\s*red:` and `Color\s*\(\s*#`
  - `no_fixed_system_font_size`: matches `\.font\(\.system\(size:`
  - `no_magic_spacing`: matches numeric `.padding\(\s*(?!4|8|12|16|20|24|32|44|64)\d+\s*\)` (and similar for `.frame`, `.spacing`)
  - `continuous_corner_required`: matches `cornerRadius:` without adjacent `.continuous`
  - `no_literal_system_color`: matches `\.foregroundColor\(\.blue\)` etc. (should use tokens)
  - `no_uikit_nskit_color_literal`: `UIColor\(red:`, `NSColor\(red:`
  - `no_print_in_production`: `print\(` in non-test files
  - `prefer_sf_symbols_comment`: flags any `Image\(` with a PNG-extension asset name (line-level only; full resolution is Unit 7's job)
- **Config style:** one `custom_rules` section with each rule declaring `regex`, `message`, `severity` (warning for some, error for cardinal sins like hardcoded colors).
- **Validation:** run `swiftlint lint --config tools/.swiftlint.yml tools/fixtures/SwiftLintFixtures.swift` — expect N violations matching the seeded count.
- **Fixture file** contains intentional violations per rule; used both for dev-time validation and as documentation of what each rule catches.

**Patterns to follow:**

- [SwiftLint custom_rules docs](https://realm.github.io/SwiftLint/custom_rules.html)

**Test scenarios:**

- Happy path: running SwiftLint against the fixture file produces exactly the seeded violations, no false positives
- Edge case: hex color inside a string literal (e.g., in a comment describing the bug) should NOT trigger — use `match_kinds` to constrain to `identifier` or argument positions
- Edge case: regex spans a line break — regex rules don't match, deliberately. Callouts to Unit 6 belong here
- Verification: rule messages are clear and actionable ("Use Asset Catalog semantic color, not hardcoded hex")

**Verification:**

- `swiftlint lint --config tools/.swiftlint.yml tools/fixtures/SwiftLintFixtures.swift` returns expected violation count
- No false positives on a clean fixture file

---

- [ ] **Unit 6: SwiftSyntax-based `impeccable-lint` CLI**

**Goal:** Standalone Swift package providing AST-level anti-pattern checks that SwiftLint regex can't express.

**Requirements:** R22 (expanded per review findings)

**Dependencies:** Unit 1

**Files:**

- Create: `tools/impeccable-lint/Package.swift`
- Create: `tools/impeccable-lint/Sources/ImpeccableLint/main.swift`
- Create: `tools/impeccable-lint/Sources/ImpeccableLint/Rules/`
  - `AccessibilityLabelRule.swift` — flags interactive views (Button, tap gesture) without `.accessibilityLabel`
  - `MultilineFrameOnTextRule.swift` — flags `Text(...)` followed by `.frame(width: _, height: _)` across lines
  - `HardcodedFontInChainRule.swift` — catches `.font(.system(size:))` even when on separate lines from the Text
  - `ContinuousCornerRule.swift` — flags `RoundedRectangle(cornerRadius:)` without `style: .continuous`
- Create: `tools/impeccable-lint/Tests/ImpeccableLintTests/`
- Create: `tools/impeccable-lint/README.md`

**Approach:**

- **Stack:** Swift package using `swift-syntax` 510+ (`SwiftSyntax`, `SwiftParser`). Each rule is a `SyntaxVisitor` subclass.
- **CLI contract:** `swift run impeccable-lint <file-or-directory>` outputs violations in SARIF JSON or simple text format (decide during implementation — SARIF is better for CI integration, text is simpler for POC).
- **Rule structure:** each rule gets input `SourceFileSyntax` and emits `[Violation]` with line, column, rule name, message.
- **Integration with skills:** `/impeccable-swift:critique` invokes this CLI as a shell command and parses results into its findings output.
- **Testing:** each rule has a fixture `.swift` file with known violations; tests assert violation count and positions.

**Patterns to follow:**

- [swift-syntax examples](https://github.com/swiftlang/swift-syntax/tree/main/Examples)
- [Periphery source](https://github.com/peripheryapp/periphery) for SyntaxVisitor patterns at scale

**Test scenarios:**

- Happy path: fixture file with seeded violations produces expected rule firings at expected lines
- Edge case: multiline `Text(...).frame()` across 3+ lines with comments and whitespace — still caught
- Edge case: `.frame(width:height:)` on a non-Text view is NOT flagged (Image, Color, etc. legitimately use fixed frames)
- Error path: malformed Swift source — tool exits cleanly with parse-error message, not a crash
- Integration: critique skill can invoke `swift run impeccable-lint` and consume output

**Verification:**

- `swift test` passes in `tools/impeccable-lint/`
- Running against fixtures produces expected violation JSON/text
- Running against a clean SwiftUI file produces zero violations

**Execution note:** Add a failing test for `AccessibilityLabelRule` before implementing — this is the most complex rule (needs to distinguish interactive from decorative views) and benefits from test-first.

---

- [ ] **Unit 7: Asset-catalog checker + SnapshotPreviews wiring**

**Goal:** Complete the detection stack (asset-catalog check) and wire up visual review (SnapshotPreviews).

**Requirements:** R22, R23

**Dependencies:** Unit 1

**Files:**

- Create: `tools/asset-catalog-checker/check.swift` (single-file executable or Swift script)
- Create: `tools/asset-catalog-checker/README.md`
- Create: `snapshot-previews/README.md` (convention doc)
- Create: `snapshot-previews/example-setup.md` (per-platform test-target guide)

**Approach:**

- **Asset catalog checker:** walk `*.xcassets/*.imageset/Contents.json` and `*.symbolset/Contents.json`. For each `Image("name")` reference in the project's `.swift` files, check whether the asset is an imageset (PNG) or symbolset (SF Symbol). Flag imagesets when an equivalent SF Symbol exists in Apple's SF Symbols library. Input: project path. Output: list of `Image("name")` calls using PNGs where SF Symbols exist.
- **SnapshotPreviews convention doc:** state that v1 uses [EmergeTools/SnapshotPreviews](https://github.com/EmergeTools/SnapshotPreviews) v0.11+. Document: each project needs one test target per platform (iOS, macOS, iPadOS). `PreviewVariants` (default) gives RTL + dark + Dynamic Type + landscape for free. Mac previews require a separate macOS test target (Xcode constraint).
- **Example setup doc:** copy-paste Swift-package manifest additions, test-target structure, and a minimal `#Preview` with `PreviewVariants` annotation.
- **Don't wire SnapshotPreviews into Brakus here** — that's Unit 9. This unit just ships the convention docs and the skill's knowledge of the tool.

**Patterns to follow:**

- [EmergeTools/SnapshotPreviews README](https://github.com/EmergeTools/SnapshotPreviews)

**Test scenarios:**

- Happy path (asset checker): given a project with one PNG named `gear` where SF Symbol `gearshape` exists — flag it
- Edge case: custom illustration PNGs with no SF Symbol equivalent — do NOT flag
- Edge case: project without any `.xcassets` — return empty results, no error
- Happy path (SP docs): reader follows `example-setup.md` and produces a working `#Preview` that renders in `.accessibility3` Dynamic Type, RTL, dark mode

**Verification:**

- Asset checker runs against a fixture .xcassets directory and produces expected findings
- `snapshot-previews/example-setup.md` includes a complete, copy-pasteable test target setup
- Convention doc references current SnapshotPreviews v0.11 API

---

- [ ] **Unit 8: Evals directory + A/B protocol + sample briefs**

**Goal:** Provide measurable proof-of-effect material for the POC launch. Borrowed from Paul's playbook.

**Requirements:** New (added per backwards-plan research)

**Dependencies:** Units 2–4 (content must exist before evals reference it)

**Files:**

- Create: `evals/README.md`
- Create: `evals/brief-01-settings-screen.md`
- Create: `evals/brief-02-list-with-empty-state.md`
- Create: `evals/brief-03-onboarding-flow.md`
- Create: `evals/outputs/` (directory for generated samples)

**Approach:**

- **Protocol README:** document how to reproduce. (a) Open a fresh Claude session without impeccable-swift installed; paste brief; save output as `outputs/<brief>-without.swift`. (b) Install impeccable-swift; open fresh session; paste same brief; save as `outputs/<brief>-with.swift`. (c) Record model name and date.
- **Three briefs,** each 1–3 sentences, each exercising high-leverage reference docs:
  - Brief 01: "Build a SwiftUI Settings screen with 3 toggles and a logout button" (exercises color, spacing, SF Symbols, interaction)
  - Brief 02: "Build a list view of recent items with an empty state" (exercises navigation, typography, ux-writing)
  - Brief 03: "Build a 3-step onboarding flow with progress indicator" (exercises motion, interaction, navigation)
- **Sample outputs captured during Unit 9** (Brakus dogfood phase generates them organically).
- **README framing:** presents the A/B as directional evidence of skill effect, not a controlled experiment. POC-appropriate rigor.

**Patterns to follow:**

- Paul's private eval framework referenced in his v2.0 PR #56

**Test scenarios:**

- Happy path: running the protocol produces two distinct `outputs/` files that a reviewer can diff
- Edge case: Claude refuses to generate SwiftUI at all (unlikely but possible) — brief README notes how to retry
- Verification: README contains complete reproduction steps; anyone with a Claude account can run the protocol

**Verification:**

- 3 briefs committed, each exercising distinct reference docs
- README includes protocol steps
- `outputs/` directory exists (may be empty until Unit 9)

**Test expectation:** none — documentation unit; no code to test.

---

- [ ] **Unit 9: Brakus integration + dogfood cycle**

**Goal:** Scaffold Brakus as an impeccable-swift consumer, use the skill to build one real feature, capture eval outputs, surface gaps.

**Requirements:** R20

**Dependencies:** Units 2–8 (all build artifacts ready)

**Files:**

- Create in Brakus repo: `DESIGN.md` (copied from `~/Code/docs/DESIGN-SWIFT.md.template`, customized for Brakus brand)
- Create in Brakus repo: `.swiftlint.yml` (imports from impeccable-swift's `tools/.swiftlint.yml`)
- Create in Brakus repo: one new feature using `/impeccable-swift:critique` feedback loop
- Modify: `impeccable-swift/CHANGELOG.md` (add entries for dogfood learnings)
- Modify: `impeccable-swift/evals/outputs/` (populate from Brakus feature work)
- Modify: any impeccable-swift reference doc that dogfood reveals is wrong or incomplete

**Approach:**

- **Scaffold Brakus:** copy `DESIGN-SWIFT.md.template` → `DESIGN.md`, customize tokens (accent, typography, radius values). Add `.swiftlint.yml` that includes impeccable-swift's rules. Add SnapshotPreviews dependency + one per-platform test target.
- **Install impeccable-swift (still private):** `npx skills add SeanSmithDesign/impeccable-swift --private-token $GH_TOKEN` or equivalent. Confirm all three skills resolve.
- **Pick one real Brakus feature to build** — one that exercises at least 4 reference docs (e.g., a new settings pane, an onboarding flow, a focus-session report). Use `/impeccable-swift:critique` iteratively.
- **Capture outputs into evals:** save before-and-after snapshots, screenshots, and Claude's initial generation vs. post-critique revisions.
- **Surface gaps:** anything that trips up the skill (missing rules, voice-drift, false positives in detectors) logged to CHANGELOG.md and/or a `gaps.md` scratchpad. Fix blockers in-flight; defer polish.
- **Duration:** 3–5 days of active use (matches revised timeline).

**Patterns to follow:**

- None specific — first-of-its-kind integration

**Test scenarios:**

- Happy path: Brakus feature ships end-to-end using the skill's critique/polish loop, with visible improvements in the generated code
- Edge case: a reference doc's guidance contradicts Brakus's existing DESIGN.md — two-layer precedence rule resolves correctly (project DESIGN.md wins)
- Edge case: the SwiftSyntax CLI produces false positives on Brakus code — fix the rule or whitelist the case
- Integration: `/impeccable-swift:critique` + `/impeccable-swift:polish` + SwiftLint + SnapshotPreviews all invoke successfully against Brakus
- Verification: at least 3 distinct reference-doc principles are exercised in the feature code

**Verification:**

- Brakus ships at least one feature with impeccable-swift assistance
- At least one CHANGELOG.md entry documents a dogfood learning
- At least 2 outputs captured in `evals/outputs/`
- No blocker-severity gaps remain unfixed in impeccable-swift

---

- [ ] **Unit 10: Public POC flip + UPSTREAM review + release**

**Goal:** Flip the repo public, submit to `npx skills` if required, publish the v0.1.0-poc release.

**Requirements:** R21

**Dependencies:** Unit 9 (dogfood validation complete)

**Files:**

- Modify: `README.md` (update install snippet for public repo; confirm POC framing is prominent)
- Modify: `UPSTREAM.md` (review upstream changes since U1 pin; update review date)
- Modify: `CHANGELOG.md` (finalize v0.1.0-poc entry with dogfood-informed release notes)
- Create: `docs/SESSION_NOTES.md` entry (per Sean's convention)

**Approach:**

- **Upstream review:** `git fetch upstream && git log upstream/main --since="<U1 pin date>"` — read every commit message and major file change. Categorize each change as `incorporated` / `rejected with rationale` / `already covered`. Update UPSTREAM.md table.
- **Flip repo public:** `gh repo edit SeanSmithDesign/impeccable-swift --visibility public`. Verify README renders correctly on public URL.
- **`npx skills` submission:** consult `vercel-labs/skills` for submission mechanism (may be automatic via GitHub metadata or may require a listing PR). If listing PR required, open it.
- **Release announcement:** brief post framing this as POC. Optional: reference Paul's impeccable and credit explicitly. No HN / Product Hunt push in v0.1.0-poc.
- **Session notes:** document what shipped, key decisions, commits, next-iteration ideas.

**Patterns to follow:**

- Paul's v1.0 launch flow (HN post, site live, GitHub public) — adapted for POC framing
- `docs/SESSION_NOTES.md` convention (date-headed section with What We Built / New Files / Architecture / Key Decisions)

**Test scenarios:**

- Happy path: stranger can run `npx skills add SeanSmithDesign/impeccable-swift` and install all three skills from the public repo
- Edge case: repo is public but README attribution line is missing or broken — fix before any announcement
- Edge case: UPSTREAM.md review reveals a restructure in upstream (not just version bumps) — decide: rebase our port or ship as-is with a note (default: ship as-is, document in UPSTREAM.md)
- Verification: attribution chain in NOTICE.md is complete and accurate

**Verification:**

- Repo is public, installable via `npx skills`
- UPSTREAM.md reflects review conducted at flip time
- CHANGELOG.md has v0.1.0-poc entry
- Session notes committed

## System-Wide Impact

- **Interaction graph:** `/impeccable-swift:critique` and `/impeccable-swift:polish` invoke three external tools (SwiftLint binary, `impeccable-lint` Swift package, asset-catalog checker script). Failure of any tool should degrade gracefully (skill reports the missing tool, continues with the others).
- **Error propagation:** parse errors in user's Swift code should not crash the detectors — each tool catches and reports without aborting the critique flow.
- **State lifecycle risks:** none meaningful. No persistent state across invocations.
- **API surface parity:** `/impeccable-swift:<verb>` commands must not shadow `/impeccable:<verb>` upstream commands. Namespacing via frontmatter `name` field handles this; both skills can coexist. When both are installed, Swift work should route to impeccable-swift. Rule of thumb (document in README): if the current directory contains `.swift` files, prefer impeccable-swift.
- **Integration coverage:** Brakus dogfood (Unit 9) is the primary integration test — it's the only place the full critique → detector → polish loop runs end-to-end against real code.
- **Unchanged invariants:** `docs/DESIGN-SWIFT.md.template` is not modified by this plan (R10). Upstream `pbakaus/impeccable` is not touched. Existing installed skills at `~/.agents/skills/` are unaffected.

## Risks & Dependencies

| Risk                                                                                                       | Likelihood                                                    | Impact                    | Mitigation                                                                                                                                  |
| ---------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| SwiftSyntax rule complexity exceeds Unit 6 budget                                                          | Medium                                                        | Medium                    | Scope Unit 6 to 4–6 AST rules maximum; defer less-critical rules to v1.1. SwiftLint regex tier (Unit 5) already covers line-local patterns. |
| Voice drift across 12 parallel subagent-authored docs                                                      | High                                                          | High                      | Voice checklist enforced in U2/U3 prompts; tier-1 docs reviewed first as voice exemplars; U9 dogfood catches drift before flip.             |
| Upstream ships a major restructure during build window                                                     | Low (Paul's pace is frequent small commits, not restructures) | Medium                    | `UPSTREAM.md` pins a specific SHA; v1 releases against that SHA; restructure handling documented in UPSTREAM.md policy.                     |
| Brakus lacks a feature meaty enough to exercise the skill                                                  | Low (Brakus is actively developed per user context)           | Medium                    | Unit 9 scope includes "pick a feature that exercises ≥4 reference docs" — prompt-level requirement.                                         |
| Marketplace cache staleness for post-launch updates (per institutional learnings)                          | Medium                                                        | Low (POC framing absorbs) | Document clean `npx skills add` install path in README; avoid repo renames post-launch.                                                     |
| SwiftLint false positives annoy Brakus daily workflow                                                      | Medium                                                        | Low                       | U5 includes fixture-based false-positive testing; severity = warning for non-cardinal rules.                                                |
| SnapshotPreviews per-platform test target setup burden too high for v1                                     | Medium                                                        | Medium                    | Unit 7 ships convention docs only — actual Brakus wiring only targets one platform (iOS) for dogfood; macOS target can wait for v1.1.       |
| Two-layer read precedence (project wins / universal fills gaps) produces surprising behavior in edge cases | Medium                                                        | Low                       | Document precedence rule explicitly in `impeccable/SKILL.md`. U9 dogfood catches real conflicts.                                            |

## Alternative Approaches Considered

- **Upstream PR to `pbakaus/impeccable` for a `/platforms/swift/` contribution.** Rejected during brainstorm. Rationale: Paul hasn't solicited community contributions (site reads as "finished product, commercial consulting available"); Dialkit-iOS precedent shows clean forks land well; faster independent shipping. Cost of being wrong: if Paul would have accepted, we've paid the fork-maintenance tax unnecessarily. Acceptable.
- **Template-only approach (expand `DESIGN-SWIFT.md.template` instead of shipping a skill family).** Rejected during brainstorm. Rationale: ceiling too low, no critique loop, doesn't match Paul's structure, doesn't earn reusability. See origin doc Key Decisions.
- **Single-tool detector (SwiftLint-only).** Rejected during plan Phase 1 research. Rationale: SwiftLint custom_rules are regex-only; several success criteria (missing `.accessibilityLabel`, multi-line `.frame` on Text, SF Symbols-vs-PNG) require AST analysis or asset resolution. Three-tool split is the honest engineering answer.
- **Lean v1 (docs + skill only, defer tooling to v1.1) matching Paul's v1.0 scope.** Considered and rejected in plan Phase 2. User chose full v1 scope explicitly. Tradeoff documented: our v1 is closer to Paul's v2 than v1; accepted for POC ambition.
- **Public from day one vs. private build + dogfood + flip.** Rejected during brainstorm. Rationale: Brakus dogfood gives real-use evidence before public exposure; cheaper to iterate privately.

## Success Metrics

(Carried from origin doc Success Criteria, augmented.)

- **Code-level outcomes:** Claude generates SwiftUI with no hardcoded hex colors, no `.font(.system(size:))`, no fixed `.frame(width:height:)` on text-containing views, consistent `.continuous` corner style, SF Symbols over PNGs, `.accessibilityLabel` on interactive elements, when impeccable-swift is installed vs. not.
- **Dogfood outcome:** Brakus ships at least one feature built with impeccable-swift assistance before the public flip.
- **Surveillance outcome:** `UPSTREAM.md` shows at least one reviewed upstream release (likely several, given Paul's pace) between U1 and U10.
- **Compliance outcome:** `LICENSE` + `NOTICE.md` present; README attribution line intact; Apache 2.0 preserved.
- **Distribution outcome:** Someone other than Sean runs `npx skills add SeanSmithDesign/impeccable-swift` on a fresh machine and all three skills resolve.
- **Voice outcome:** A designer reading any reference doc recognizes the declare → why → rule → anti-pattern structure.
- **Eval outcome:** `evals/outputs/` contains at least 3 diff-able before/after samples.

## Phased Delivery

**Phase 1 — Scaffold (Day 1):** Unit 1 only. Critical path; no parallelism possible.

**Phase 2 — Content (Days 1–3):** Units 2 and 3 in parallel. Tier-1 reference docs dispatch first (serve as voice exemplars); tier-2 and tier-3 follow. New docs (Unit 3) run in parallel with Unit 2 since they have no content dependency on ported docs.

**Phase 3 — Skills (Day 3):** Unit 4, depends on Units 2+3 complete.

**Phase 4 — Tooling (Days 3–5, parallel):** Units 5, 6, 7 in parallel. Each has separate file scope.

**Phase 5 — Validation (Days 5–8):** Unit 8 (evals setup), then Unit 9 (Brakus dogfood, 3–5 days of real use).

**Phase 6 — Launch (Day 8–10):** Unit 10. Upstream review + public flip + release notes.

Total: ~10 days calendar at aggressive pace, ~14 days at realistic pace with review gates between phases.

## Documentation / Operational Notes

- **Session notes** (per `~/Code/CLAUDE.md` convention) written in Unit 10.
- **Post-launch:** compound three solutions to `docs/solutions/` after v1 ships (per institutional learnings): (a) two-layer skill config pattern, (b) Swift-native skill authoring conventions, (c) Apache 2.0 fork attribution workflow.
- **Marketplace cache awareness:** README should tell users to re-run `npx skills update` to pick up later versions; do not rely on in-place git updates (per institutional learnings).
- **UPSTREAM.md review cadence post-launch:** monthly during active upstream dev (Paul's current pace), quarterly if upstream slows. First review happens in Unit 10; second review ~1 month after flip.

## Sources & References

- **Origin document:** [docs/brainstorms/2026-04-12-impeccable-swift-requirements.md](../brainstorms/2026-04-12-impeccable-swift-requirements.md)
- **Upstream repo:** https://github.com/pbakaus/impeccable
- **Upstream site:** https://www.impeccable.style
- **Distribution tool:** https://github.com/vercel-labs/skills
- **SwiftLint:** https://github.com/realm/SwiftLint + [custom_rules docs](https://realm.github.io/SwiftLint/custom_rules.html)
- **SwiftSyntax:** https://github.com/swiftlang/swift-syntax
- **SnapshotPreviews:** https://github.com/EmergeTools/SnapshotPreviews
- **Paul's v2.0 PR** (reference point for v1 vs. v2 scope question): https://github.com/pbakaus/impeccable/pull/56
- **Dialkit-iOS precedent** (fork-pattern reference, not content source): https://github.com/mikelikesdesign/dialkit-ios
- **Institutional learnings:** `docs/solutions/workflow-issues/claude-code-plugin-marketplace-cache-staleness.md`
- **Related memory:** `~/.claude/projects/-Users-seansmith-Code/memory/reference_swift-conventions.md`, `reference_impeccable-skills.md`
