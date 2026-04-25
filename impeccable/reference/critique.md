# critique

Evaluate SwiftUI design from a UX perspective. Assess visual hierarchy, information architecture, emotional resonance, cognitive load, and overall quality using quantitative scoring, persona-based testing, deterministic detector output, and actionable feedback.

Use when the user asks to review, critique, evaluate, or give feedback on a SwiftUI view, screen, or component.

**Scope**: Critique reports. It does not fix. When the user says "fix it," hand off to `/impeccable-swift polish`.

---

## Context Gathering

Run the shared loader before any assessment:

```bash
node .claude/skills/impeccable-swift/scripts/load-context.mjs
```

Apply two-layer read precedence: project `DESIGN.md` and `PRODUCT.md` tokens override universal defaults where explicit; universal rules apply where the project is silent; Apple HIG is the final tiebreaker.

If `DESIGN.md` is missing, run universal-only. If unparseable, warn once and continue.

> **Additional context needed**: what the interface is trying to accomplish.

---

## Gather Assessments

Launch two independent assessments. **Neither may see the other's output.** This isolation makes the combined score honest. Running both in one pass silently anchors them to each other; do not shortcut for cost, speed, or context-size reasons.

Delegate each to a separate sub-agent (Claude Code's `Agent` tool). Each returns structured findings as text. Do NOT output findings to the user yet.

Fall back to sequential in-head work only if the environment genuinely cannot spawn sub-agents.

---

### Assessment A: LLM Design Review

Read the relevant Swift source files and SwiftUI view code. Think like a design director reviewing a PR. Evaluate:

#### AI Slop Detection (CRITICAL)

Does this look like every other AI-generated SwiftUI interface? Check for:

**Layout tells**:

- Identical Card grids (every item same height, same shadow, same corner radius, uniform spacing)
- Hero metric template (big centered number, two-line label, chevron)
- Modal-as-first-thought (sheets launched immediately; no in-place interaction considered)
- Lists with no visual differentiation between item types

**Visual tells**:

- Glassmorphism overuse: `.ultraThinMaterial` or `.regularMaterial` applied to every surface, not just floating chrome
- Gradient text via `.foregroundStyle(LinearGradient(...))` as decoration, not legibility
- Dark glows (`.shadow(color: .purple.opacity(0.4), radius: 30)` or similar)
- Bland or AI-default color palette: no color from the project's `DESIGN.md`, falling back to system blue everywhere

**SF Symbol tells**:

- Generic icon combos that signal zero creative investment: `gear` + `bell` + `house` with no variation
- Every glyph at `.body` weight regardless of context
- Mixed SF Symbols and custom PNG assets on the same surface (see [`sf-symbols.md`](sf-symbols.md))

**Platform personality misses**:

- No Liquid Glass usage on iOS 26+ surfaces where a translucent floating container is the platform-native answer
- No Dynamic Type support (hardcoded `font(.system(size: 17))` instead of text styles)
- SF Symbol names that aren't semantic (e.g. `arrow.right` used as a "continue" button instead of `chevron.forward`)
- Missing `.scenePadding()` or safe area respect on edge-to-edge layouts

**The test**: If someone said "AI made this," would you believe them immediately? Cite specific line numbers or view names.

#### Holistic SwiftUI Review

- **Visual hierarchy**: Does the eye land on the primary action first? Is `Label` hierarchy enforced through font text styles, not hardcoded sizes?
- **Information architecture**: Is the navigation structure appropriate to the platform? Refer to [`navigation.md`](navigation.md) for iOS vs macOS idioms (`NavigationStack` vs `NavigationSplitView`, tab bar vs sidebar).
- **Emotional resonance**: Does the interface match the register (brand vs product)? Consult [`brand.md`](brand.md) and [`product.md`](product.md).
- **Discoverability**: Are interactive controls obvious? Does anything look tappable that isn't, or vice versa?
- **Composition**: Balance, whitespace, rhythm. Are spacing values from a consistent scale (multiples of 4 or 8)?
- **Typography**: Is Dynamic Type used throughout? Are numeric formats localized? See [`typography.md`](typography.md).
- **Color and materials**: Are colors semantic or hardcoded hex? Do materials match the platform surface tier? See [`materials.md`](materials.md) and `color-and-contrast.md`.

#### State Coverage

A SwiftUI view that only handles the "happy path" is not complete. Evaluate all four states:

- **Empty state**: Is `ContentUnavailableView` used, or is the empty list just invisible?
- **Loading state**: Is there a `ProgressView` or skeleton, or does content just appear from nothing?
- **Error state**: Is there a user-facing error with a recovery action, or a silent fail?
- **Success/full state**: Does the layout hold when content is at realistic maximum (500 rows, 40-char names, 3-line descriptions)?

Flag any state that is unhandled or visually broken.

#### View Hierarchy Depth

Deeply nested SwiftUI view trees signal copy-paste composition, not design thinking. Flag:

- `VStack` inside `VStack` inside `VStack` (more than 3 layers without a semantic component boundary)
- Modifier chains longer than 8 modifiers on a single view
- Inline layout logic that belongs in a named `ViewModifier` or extracted subview

#### Keyboard and Focus Order

On iOS 26+ and macOS, keyboard navigation matters beyond accessibility compliance:

- Does `Tab` move focus in the intended reading order?
- Are `@FocusState` bindings present for multi-field forms?
- Does each interactive element have a `.accessibilityLabel` that makes sense read aloud by VoiceOver?

Consult [`accessibility.md`](accessibility.md) for the full checklist.

#### Cognitive Load

Consult [`cognitive-load.md`](cognitive-load.md). Run the 8-item cognitive load checklist. Report failure count: 0-1 = low (good), 2-3 = moderate, 4+ = critical. Count visible options at each decision point: if more than 4, flag it. Check for progressive disclosure.

#### Emotional Journey

- What emotion does this interface evoke? Is that intentional?
- **Peak-end rule**: Is the most intense moment positive? Does the experience end well?
- **Emotional valleys**: Check for anxiety spikes at high-stakes moments (payment, delete, destructive action). Are there design interventions (progress indicators, reassurance copy, undo via `.sensoryFeedback` + confirm dialog)?

#### Nielsen's Heuristics

Consult [`heuristics-scoring.md`](heuristics-scoring.md). Score each of the 10 heuristics 0-4. This scoring will be presented in the report.

Return structured findings: AI slop verdict, heuristic scores, cognitive load assessment, state coverage gaps, what's working (2-3 items), priority issues (3-5 with what/why/fix), minor observations, and provocative questions.

---

### Assessment B: Deterministic Detector

Run all three detectors in order. Each is independent; a missing tool degrades gracefully. Report the missing tool, continue with the others.

#### 1. SwiftLint

```bash
swiftlint lint --config tools/.swiftlint.yml <target>
```

If `swiftlint` is not installed, report `swiftlint not found: skipping structural scan` and continue.

#### 2. impeccable-lint (SwiftSyntax CLI)

```bash
swift run --package-path tools/impeccable-lint impeccable-lint <target>
```

`impeccable-lint` flags 25 specific SwiftUI anti-patterns including:

- Bland or hardcoded colors (no project token, no semantic color)
- Generic Card grid layouts (identical `RoundedRectangle` containers at every row)
- Missing state variants (no `ContentUnavailableView` branch, no `ProgressView`)
- Glassmorphism stacking (multiple `.material` layers on the same surface)
- Hardcoded font sizes instead of text style constants

If the package fails to build or the Swift toolchain is unavailable, report the failure in one line and continue.

#### 3. asset-catalog-checker

```bash
swift tools/asset-catalog-checker/check.swift <path-to-xcassets>
```

Flags unused Color Sets and Material assets in `.xcassets` that were defined but are never referenced in SwiftUI code. Orphaned tokens inflate the asset catalog and mislead future maintainers.

If no `.xcassets` exists in the target, skip silently.

Return: detector findings per tool (counts, file locations, pattern names), and any false positives worth flagging.

---

## Generate Combined Critique Report

Synthesize both assessments into a single report. Do NOT simply concatenate. Weave findings together, noting where the LLM review and detector agree, where the detector caught issues the LLM missed, and where detector findings are false positives.

Structure feedback as a design director would.

---

### Design Health Score

> Consult [`heuristics-scoring.md`](heuristics-scoring.md)

Present Nielsen's 10 heuristics scores as a table:

| #         | Heuristic                       | Score     | Key Issue                            |
| --------- | ------------------------------- | --------- | ------------------------------------ |
| 1         | Visibility of System Status     | ?         | [specific finding or "n/a" if solid] |
| 2         | Match System / Real World       | ?         |                                      |
| 3         | User Control and Freedom        | ?         |                                      |
| 4         | Consistency and Standards       | ?         |                                      |
| 5         | Error Prevention                | ?         |                                      |
| 6         | Recognition Rather Than Recall  | ?         |                                      |
| 7         | Flexibility and Efficiency      | ?         |                                      |
| 8         | Aesthetic and Minimalist Design | ?         |                                      |
| 9         | Error Recovery                  | ?         |                                      |
| 10        | Help and Documentation          | ?         |                                      |
| **Total** |                                 | **??/40** | **[Rating band]**                    |

Be honest with scores. A 4 means genuinely excellent. Most real interfaces score 20-32.

---

### Anti-Patterns Verdict

**Start here.** Does this look AI-generated?

**LLM assessment**: Your evaluation of AI slop tells. Cover overall aesthetic feel, layout sameness, generic composition, missed platform personality (no Liquid Glass, no Dynamic Type, generic SF Symbol naming). Call out specific views and line numbers.

**Deterministic scan**: Summarize what `impeccable-lint` and SwiftLint found, with counts and file locations. Note any issues the detector caught that the LLM missed. Flag false positives explicitly.

**Asset catalog health**: Summarize `asset-catalog-checker` results. List unused Color Sets and Material assets by name.

---

### Overall Impression

A brief gut reaction: what works, what doesn't, and the single biggest opportunity.

---

### What's Working

Highlight 2-3 things done well. Be specific about why they work. Do not manufacture praise to soften the report.

---

### Priority Issues

The 3-5 most impactful design problems, ordered by importance.

For each issue, tag with **P0-P3 severity** (consult [`heuristics-scoring.md`](heuristics-scoring.md) for severity definitions):

- **[P?] What**: Name the problem clearly
- **Why it matters**: How this hurts users or undermines goals
- **Fix**: What to do about it (be concrete, cite the SwiftUI API)
- **Suggested command**: Which command could address this (from: `/impeccable-swift adapt`, `/impeccable-swift animate`, `/impeccable-swift audit`, `/impeccable-swift bolder`, `/impeccable-swift clarify`, `/impeccable-swift colorize`, `/impeccable-swift delight`, `/impeccable-swift distill`, `/impeccable-swift harden`, `/impeccable-swift layout`, `/impeccable-swift onboard`, `/impeccable-swift optimize`, `/impeccable-swift overdrive`, `/impeccable-swift polish`, `/impeccable-swift quieter`, `/impeccable-swift shape`, `/impeccable-swift typeset`)

---

### Persona Red Flags

> Consult [`personas.md`](personas.md)

Auto-select 2-3 personas most relevant to this interface type using the selection table in the reference. If `PRODUCT.md` contains audience or brand personality fields from `/impeccable-swift teach`, generate 1-2 project-specific personas from that context.

For each selected persona, walk through the primary user action and list specific red flags found. Name the exact views and interactions that fail each persona:

**Alex (Power User)**: No `@FocusState` tab order. Primary action requires 8 taps. Keyboard shortcut absent on macOS target. High abandonment risk.

**Jordan (First-Timer)**: Icon-only tab bar with no label. Technical error message ("keyNotFound"). No empty state guidance on first launch. Will abandon at onboarding step 2.

Be specific. Do not write generic persona descriptions. Write what broke for them in this interface.

Register context: if the interface is a brand-register surface (marketing shell, portfolio, hero onboarding), evaluate against the delight and storytelling expectations from [`brand.md`](brand.md). If it's a product-register surface (authenticated app, data views, forms), evaluate against utility and efficiency expectations from [`product.md`](product.md).

---

### State Variant Summary

Report all four states with a pass/fail:

| State       | Present | Notes                                 |
| ----------- | ------- | ------------------------------------- |
| Empty       |         | `ContentUnavailableView` used?        |
| Loading     |         | `ProgressView` or skeleton?           |
| Error       |         | Recovery action present?              |
| Full/loaded |         | Layout holds at realistic data scale? |

A view that passes only "Full/loaded" is not shippable.

---

### Minor Observations

Quick notes on smaller issues worth addressing but not blocking.

---

### Questions to Consider

Provocative questions that might unlock better solutions:

- "What if the primary action were more prominent?"
- "Does this need to feel this complex?"
- "What would a confident, platform-native version of this look like?"
- "Is this glassmorphism adding depth, or covering up a layout that hasn't been designed?"

---

## Ask the User

**After presenting findings**, use targeted questions based on what was actually found. STOP and call the AskUserQuestion tool to clarify. These answers shape the action plan.

Ask questions along these lines (adapt to specific findings; do NOT ask generic questions):

1. **Priority direction**: Based on the issues found, which category matters most right now? For example: "I found problems with state coverage, SF Symbol discipline, and view hierarchy depth. Which area should we tackle first?" Offer the top 2-3 issue categories as options.

2. **Design intent**: If the critique found a tonal mismatch, ask whether it was intentional. For example: "The interface defaults to system blue and generic icons. Is that the intended personality, or should it feel more distinctive?" Offer 2-3 directions based on what would fix the issues found.

3. **Scope**: Ask how much to take on. For example: "I found N issues. Want to address everything, or focus on the top 3?" Offer scope options like "Top 3 only," "All issues," "Critical only."

4. **Constraints** (only if relevant): If findings touch many areas, ask if anything is off-limits to preserve.

**Rules for questions**:

- Every question must reference specific findings from this report. Never ask generic "who is your audience?" questions.
- Keep to 2-4 questions maximum.
- Offer concrete options, not open-ended prompts.
- If findings are straightforward (1-2 clear issues), skip questions and go directly to Recommended Actions.

---

## Recommended Actions

**After receiving the user's answers**, present a prioritized action summary reflecting their priorities and scope.

### Action Summary

List recommended commands in priority order:

1. **`/impeccable-swift [command]`**: Brief description of what to fix (specific context from critique findings)
2. **`/impeccable-swift [command]`**: Brief description (specific context)

**Rules for recommendations**:

- Order by the user's stated priorities first, then by impact
- Each item's description should carry enough context that the command knows what to focus on
- Map each Priority Issue to the appropriate command
- Skip commands that would address zero issues
- If the user chose limited scope, only include items within that scope
- If the user marked areas as off-limits, exclude commands that would touch those areas
- End with `/impeccable-swift polish` as the final step if any fixes were recommended

After presenting the summary, tell the user:

> You can ask me to run these one at a time, all at once, or in any order you prefer.
>
> Re-run `/impeccable-swift critique` after fixes to see your score improve.
