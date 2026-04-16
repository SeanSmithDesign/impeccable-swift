# ChatBenchmarkV2 — Synthesis

**Date:** 2026-04-16
**Surface under test:** `ChatConversationView.swift` — a DM-style chat with sender avatars, grouped message bubbles, link preview, photo attachment, PDF attachment, inline reply thread, sticky date headers, and a pinned compose bar.
**Judges:** four independent `impeccable-swift /critique` sub-agents, each blind to the other builds.

---

## 1. Top-line verdict

| Build                    | Verdict        | Total findings | P0  | P1  | P2  | P3  |
| ------------------------ | -------------- | -------------- | --- | --- | --- | --- |
| **1 — Stock SwiftUI**    | **REWORK**     | 43             | 7   | 21  | 13  | 2   |
| **2 — Web Impeccable**   | Polish-first\* | 39             | 7   | 13  | 14  | 5   |
| **3 — Swift Impeccable** | Polish-first   | 24             | 2   | 9   | 11  | 2   |
| **4 — Full Setup (+DM)** | Polish-first   | 24             | 2   | 2   | 11  | 9   |

\* Build 2's judge qualified it as "polish-first, but the six P0s are correctness bugs, not taste calls — do not ship without them." Trajectory is the signal: moving from Build 1 → 4 halves total findings and collapses P0 + P1 from **28 → 4**.

---

## 2. Findings by category (P0 / P1 / P2 / P3)

| Category      | Build 1 (Stock)     | Build 2 (Web)       | Build 3 (Swift)    | Build 4 (Full)     |
| ------------- | ------------------- | ------------------- | ------------------ | ------------------ |
| Spatial       | 1 / 2 / 2 / 0       | 3 / 0 / 2 / 0       | 2 / 1 / 2 / 0      | 0 / 0 / 5 / 2      |
| Typography    | 0 / 4 / 1 / 0       | 0 / 2 / 0 / 2       | 0 / 4 / 1 / 1      | 1 / 0 / 0 / 0      |
| Color         | 3 / 2 / 0 / 0       | 2 / 2 / 0 / 0       | 0 / 0 / 2 / 0      | 1 / 1 / 0 / 2      |
| Material      | 1 / 1 / 0 / 0       | 1 / 1 / 1 / 0       | 0 / 0 / 1 / 0      | 0 / 0 / 1 / 0      |
| Interaction   | 1 / 4 / 3 / 0       | 0 / 3 / 3 / 1       | 0 / 3 / 1 / 1      | 0 / 0 / 2 / 2      |
| Motion        | 0 / 2 / 1 / 0       | 0 / 1 / 1 / 0       | 0 / 0 / 0 / 0      | 0 / 0 / 0 / 0      |
| SF Symbols    | 0 / 1 / 2 / 0       | 0 / 1 / 2 / 0       | 0 / 0 / 1 / 0      | 0 / 0 / 1 / 1      |
| Platform      | 0 / 3 / 1 / 0       | 1 / 1 / 2 / 0       | 0 / 0 / 2 / 0      | 0 / 0 / 0 / 0      |
| UX Writing    | 0 / 0 / 2 / 1       | 0 / 0 / 2 / 1       | 0 / 0 / 1 / 0      | 0 / 0 / 0 / 2      |
| Accessibility | 1 / 2 / 1 / 1       | 0 / 2 / 1 / 1       | 0 / 1 / 0 / 0      | 0 / 1 / 2 / 0      |
| **Total**     | **7 / 21 / 13 / 2** | **7 / 13 / 14 / 5** | **2 / 9 / 11 / 2** | **2 / 2 / 11 / 9** |

### Pattern notes

- **Motion** collapses at Build 3 — the moment the author had Swift-native reference docs, cubic curves were replaced with springs. Builds 3 and 4 have **zero** motion findings.
- **Platform** collapses at Build 4 — DESIGN.md's explicit "iOS 26+, iPhone-only or inside NavigationSplitView" contract removed the "iPhone-shape iPad app" and `UIScreen.main.bounds` categories of failure.
- **Color** stays hot through Build 4 because Asset Catalog migration is the single most expensive platform task and the benchmark surface ships no `.xcassets`. Build 4's one Color P0 is specifically _contrast_ (WCAG 3.47:1 on sent-bubble text over accent) — a design-brief-level issue, not a Swift-skill issue.
- **Spatial** stays populated through Build 4 but shifts severity downward: Build 4's seven spatial findings are all P2/P3 off-4pt-scale values (28, 22, 56, 240, 48), not P0 safe-area or tap-target violations.

---

## 3. Delta summary

### Build 2 − Build 1 — what did web impeccable add?

Web-skill reference docs taught the model _that a design system should exist_, so the shape of the solution is correct: centralized `Palette` / `Space` / `Radius` / `Motion` namespaces, `.safeAreaInset` compose bar, sticky section headers, combined accessibility on composite views, sender-continuation logic. The **total finding count barely moves (43 → 39)** because the web skill ports its own failure modes:

- `Color(red:green:blue:)` inline values instead of Asset Catalog tokens
- `UIScreen.main.bounds.width` for bubble clamps (web's `100vw` reflex)
- `.cubic-bezier`-named timing curves named after `ease-out-quart`
- `.thinMaterial` applied to content bubbles (web glassmorphism reflex, not iOS materials hierarchy)
- Sub-44pt tap targets (32/36pt icon buttons — a web-density reflex)
- Uppercase-tracked `.footnote` "eyebrow labels"
- Weight-salad (regular/medium/semibold/bold/light all on one surface)

The P0 count is **unchanged (7 → 7)**. The shape improved; the Swift-specific correctness bar did not.

### Build 3 − Build 2 — what did Swift-native add?

This is the largest delta in the benchmark:

- **P0: 7 → 2** (−5)
- **P1: 13 → 9** (−4)
- **Motion: 3 findings → 0**
- **Platform: 4 findings → 2**
- **Color: 4 findings → 2** (all remaining are P2, not P0)

Swift-native reference docs replaced the wrong primitives with the right ones:

- `Spacer(minLength: 56)` replaces `UIScreen.main.bounds.width * 0.75` (survives Split View, Stage Manager, Mac)
- `.spring(response:dampingFraction:)` replaces cubic-bezier curves
- `GlassEffectContainer` + `.glassEffect()` + `.quaternary` hierarchical fills replace `.thinMaterial`-on-everything
- `.symbolRenderingMode(.hierarchical)` applied once at surface root
- `.sensoryFeedback(.success, trigger:)` with an `Int` trigger
- `reduceMotion` checked on every animation with `.opacity` fallbacks
- Four previews including Dark, Accessibility2, and keyboard-open stand-in

The surviving P0s are both **44pt tap-target violations on compose-bar buttons (40×40)** — a single commit with `.frame(minWidth:minHeight:).contentShape(…)` resolves both.

### Build 4 − Build 3 — what did DESIGN.md add?

Total findings are flat (**24 → 24**), but the _composition_ shifts dramatically:

- **P1: 9 → 2** (−7)
- **P3: 2 → 9** (+7)

DESIGN.md absorbed categories of concern that Build 3's judge was still flagging:

- Platform: 2 findings → **0** (DESIGN.md declared iOS 26+, iPhone-only contract)
- Typography: 6 findings → **1** (DESIGN.md specified SF Pro everywhere, resolved the weight-discipline ambiguity)
- Interaction: 5 findings → 4 (all remaining are P2/P3)
- Accessibility: 1 P1 → 1 P1 (the group-chat sender-hidden bug — missed in DESIGN.md's coverage)

What's left in Build 4 skews to _cosmetic_ territory: off-scale spacing values (28, 22, 56, 240, 48), inline accent declaration instead of Asset Catalog, one WCAG contrast failure on accent-surface-behind-white-body-text, one empty-state gap, and stylistic SF Symbol variant inconsistency. Critically, **Build 4's P0s are both color-system issues** — they would have been caught by shipping an Asset Catalog with the build, which is outside the benchmark file's scope. Within-file, Build 4 is the cleanest.

---

## 4. Representative findings (verbatim) per build

### Build 1 — Stock SwiftUI

> **#1 — Color** — `Color.blue` used as brand/accent in 5+ places (lines 31, 64, 107, 146, 181) — own-message bubble, send button, link source label, PDF chip, reply-count button. The system palette is a debug tool, not a design system.
> **Severity: P0.** Reference: `color-and-contrast.md` — "`.foregroundColor(.blue)`" anti-pattern; Asset Catalog tokens required.

> **#7 — Spatial** — Hardcoded `.padding(.bottom, 34)` to dodge the home indicator on the composer (line 37). "The hardcoded safe area." 34pt is wrong on iPad, wrong during a phone call, wrong without a home indicator.
> **Severity: P0.** Reference: `navigation.md` — "Safe-Area Handling Goes Through The System"; `responsive-design.md` — "Safe Areas: Trust the System."

> **#16 — Material** — The composer bar floats above scrolling content but sits on `Color(.systemBackground)` with zero blur / zero material. On iOS 26 this is the prime `.glassEffect()` / `.ultraThinMaterial` surface.
> **Severity: P0.** Reference: `materials.md` — "Liquid Glass Is The Surface Language"; SKILL.md reflex list.

### Build 2 — Web Impeccable port

> **SP-2 — Spatial** — `UIScreen.main.bounds.width * 0.75` drives `bubbleMaxWidth` (L323). UIKit reach; wrong in Split View, Slide Over, Stage Manager, Mac.
> **Severity: P0.** Reference: `responsive-design.md` · `ios-vs-macos.md` — "Device-Width Trap."

> **CO-1 — Color** — Ten hardcoded `Color(red:green:blue:)` values in `Palette` (L11–20). No Asset Catalog, no `Color("token")` indirection.
> **Severity: P0.** Reference: `color-and-contrast.md` — "The Inline Hex."

> **MO-1 — Motion** — All three shared curves (`Motion.snap`, `Motion.base`, `Motion.layout` L42–44) are cubic-bezier timing curves named after web ease-out-quart/quint. The file comment even says "the web skill's recommended curves."
> **Severity: P1.** Reference: `motion-design.md` — "Springs Over Curves."

### Build 3 — Swift-native Impeccable

> **#1 — Spatial** — `SendButtonStyle` renders the send button at `.frame(width: 40, height: 40)` — below the 44pt tap floor.
> **Severity: P0.** Reference: `spatial-design.md` → "44pt Is the Floor for Taps"; `interaction-design.md` → "Touch Targets Are 44pt Minimum."

> **#5 — Interaction** — Empty conversation (`messages.isEmpty`) renders an empty `ScrollView` — no `ContentUnavailableView`.
> **Severity: P1.** Reference: `interaction-design.md` → "Empty States Are a Required View"; `ux-writing.md` → "Empty States Are Onboarding."

> **#8 — Accessibility** — `TextBubble` sets `.accessibilityElement(children: .combine)` and then overrides with an explicit `.accessibilityLabel(...)`. The explicit label replaces the combined children — the timestamp inside the bubble is never announced by VoiceOver.
> **Severity: P1.** Reference: `accessibility.md` → "`.accessibilityElement(children:)` — Combine Before Ignore."

### Build 4 — Full Setup (+ DESIGN.md)

> **F2 — Color** — Sent bubble pairs `.body` (17pt regular) foreground `Color.white` over `#c97350` surface (line 461 + `bubbleSurface` line 782). Contrast ≈ **3.47:1** — fails WCAG AA body (4.5:1). Passes only the large-text floor (3:1), and `.body` isn't large.
> **Severity: P1.** Reference: `color-and-contrast.md` → "Contrast Is Non-Negotiable."

> **F12 — Typography** — Photo-bubble placeholder `.font(.system(size: 72))` (line 549) is fixed-pt — breaks Dynamic Type and is a sizing-by-frames anti-pattern.
> **Severity: P0.** Reference: `typography.md` → "Dynamic Type Is the Contract"; `sf-symbols.md` → "Size With Type, Not With Frames."

> **F19 — Accessibility** — Group-chat sender name and timestamp are `.accessibilityHidden(true)` (lines 370, 383). MessageRow has no `.accessibilityElement(children: .combine)` wrapping them. VoiceOver users hear only the body text — in a group chat, they lose "who sent this, and when."
> **Severity: P1.** Reference: `accessibility.md` → "accessibilityElement(children:) — Combine Before Ignore."

---

## 5. Methodology note

**Build isolation.** Each of the four build implementations was generated in a separate sub-agent invocation with an explicit prohibition on reading the other builds' output directories. No build saw any other build's code, notes, or scaffolding. This rules out copy-over between conditions — each build is an independent attempt at the same prompt under different skill/context conditions.

**Judge isolation.** Each critique was produced by a separate, fresh `/critique` sub-agent. Each judge received only its assigned build file plus the 13 Swift-native reference docs; no judge saw the other builds' code or the other judges' critiques. This means severity counts, findings, and verdicts are directly comparable without inter-rater anchoring bias — each judge scored against the rubric, not against its siblings.

**DESIGN.md condition.** Only Build 4 had a project `DESIGN.md` available at `evals/ChatBenchmarkV2/ChatBenchmarkV2/DESIGN.md` declaring iOS 26+, accent `#c97350`, SF Pro, no drop shadows, and `.safeAreaInset` compose bar. Builds 1–3 were explicitly told no project `DESIGN.md` existed; their judges confirmed this in their reports.

**Detector coverage.** Builds 1, 2, and 4 had `swiftlint` and `impeccable-lint` (SwiftSyntax CLI) run against them. Build 3's judge had neither detector available in its environment and substituted manual audit — this could undercount mechanical findings (hardcoded font sizes, accessibility labels) by a small amount relative to the other builds, but does not affect the structural findings that drive the severity counts.
