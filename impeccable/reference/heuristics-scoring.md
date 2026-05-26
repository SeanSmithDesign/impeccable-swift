# Heuristics Scoring Guide

Score each of Nielsen's 10 Usability Heuristics on a 0–4 scale. Be honest: a 4 means genuinely excellent, not "good enough."

This is the rubric the Swift port uses inside `/impeccable-swift critique` and `/impeccable-swift audit`. The 0–4 bands and P0–P3 severity tiers below are platform-agnostic. The examples are Apple-specific: SwiftUI views, Liquid Glass materials, SF Symbols, Dynamic Type, Dark Mode, VoiceOver. When in doubt, ask whether the issue would survive a HIG review.

## Nielsen's 10 Heuristics

### 1. Visibility of System Status

Keep users informed about what's happening through timely, appropriate feedback.

**Check for**:

- Loading indicators (`ProgressView`, `.refreshable`) during async operations
- Confirmation of user actions (save, submit, delete) with `.sensoryFeedback`
- Progress indicators for multi-step processes
- Current location in navigation (selected tab, navigation title, breadcrumb-like back chevrons)
- Form validation feedback inline, not just on submit
- `ContentUnavailableView` (or equivalent) for empty, search-empty, and error states

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | No feedback. User is guessing what happened. |
| 1 | Rare feedback. Most actions produce no visible response. |
| 2 | Partial. Some states communicated, major gaps remain. |
| 3 | Good. Most operations give clear feedback, minor gaps. |
| 4 | Excellent. Every action confirms, progress is always visible. |

### 2. Match Between System and Real World

Speak the user's language. Follow real-world conventions. Information appears in natural, logical order.

**Check for**:

- Familiar terminology, no unexplained jargon
- Logical information order matching user expectations
- SF Symbols used with their conventional meaning (don't repurpose `trash` for archive, or `square.and.arrow.up` for download)
- Domain-appropriate language for the target audience
- Natural reading flow (left-to-right, top-to-bottom priority on LTR locales; mirror for RTL)
- System date, time, currency, and number formatters (never hand-rolled)

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Pure tech jargon, alien to users. Symbols repurposed against their meaning. |
| 1 | Mostly confusing. Requires domain expertise to navigate. |
| 2 | Mixed. Some plain language, some jargon leaks through. |
| 3 | Mostly natural. Occasional term needs context. |
| 4 | Speaks the user's language fluently throughout. |

### 3. User Control and Freedom

Users need a clear "emergency exit" from unwanted states without extended dialogue.

**Check for**:

- Cancel buttons on every modal (`.sheet`, `.fullScreenCover`, `.alert`)
- Swipe-down to dismiss on sheets where appropriate
- `NavigationStack` back chevron on every pushed view
- Undo support (`UndoManager` integration, `.onShake` for shake-to-undo on iPhone)
- Easy way to clear filters, search, selections
- Escape key, command-period, and trackpad swipes honored on macOS

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Users get trapped. No way out without force-quitting. |
| 1 | Difficult exits. Must find obscure paths to escape. |
| 2 | Some exits. Main flows have escape, edge cases don't. |
| 3 | Good control. Users can exit and undo most actions. |
| 4 | Full control. Undo, cancel, back, and escape everywhere. |

### 4. Consistency and Standards

Users shouldn't wonder whether different words, situations, or actions mean the same thing.

**Check for**:

- Consistent terminology across views, alerts, settings, and accessibility labels
- HIG-conformant layouts (toolbars, tab bars, navigation bars in their expected places)
- One SF Symbol set per surface, with consistent weight + scale
- Visual consistency (semantic Color Sets, SF Pro text styles, the 4/8/16/24 spacing scale)
- Same gesture produces the same result everywhere (tap, long-press, swipe-to-delete)
- Settings live in `Settings.app` (or the macOS Settings scene), not buried in custom in-app screens

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Inconsistent everywhere. Feels like different products stitched together. |
| 1 | Many inconsistencies. Similar things look or behave differently. |
| 2 | Partially consistent. Main flows match, details diverge. |
| 3 | Mostly consistent. Occasional deviation, nothing confusing. |
| 4 | Fully consistent. Cohesive system, predictable behavior. |

### 5. Error Prevention

Better than good error messages is a design that prevents problems in the first place.

**Check for**:

- Confirmation `.alert` (or `.confirmationDialog`) before destructive actions, with role: `.destructive`
- Constrained inputs (`DatePicker`, `Picker`, `Stepper`) over free-text where possible
- Smart defaults that reduce errors
- Clear labels that prevent misunderstanding
- Autosave (`@AppStorage`, `SwiftData`, document-based autosave) and draft recovery
- Disabled state on submit buttons until the form is valid

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Errors easy to make. No guardrails anywhere. |
| 1 | Few safeguards. Some inputs validated, most aren't. |
| 2 | Partial prevention. Common errors caught, edge cases slip. |
| 3 | Good prevention. Most error paths blocked proactively. |
| 4 | Excellent. Errors nearly impossible through smart constraints. |

### 6. Recognition Rather Than Recall

Minimize memory load. Make objects, actions, and options visible or easily retrievable.

**Check for**:

- Visible options, not buried inside `Menu` when a button would do
- Contextual help via `.help()` (macOS), inline hints, or tip-style affordances
- Recent items, history, and `@AppStorage`-backed last-used state
- Autocomplete and `.searchSuggestions`
- SF Symbols paired with text labels in primary nav (icon-only is reserved for toolbars where space forces it, and even then needs `.accessibilityLabel`)

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Heavy memorization. Users must remember paths and commands. |
| 1 | Mostly recall. Many hidden features, few visible cues. |
| 2 | Some aids. Main actions visible, secondary features hidden. |
| 3 | Good recognition. Most things discoverable, few memory demands. |
| 4 | Everything discoverable. Users never need to memorize. |

### 7. Flexibility and Efficiency of Use

Accelerators, invisible to novices, speed up expert interaction.

**Check for**:

- Keyboard shortcuts on macOS and iPad via `.keyboardShortcut()`
- `Menu` commands with command-key bindings
- `.contextMenu` on supported items
- Swipe actions (`.swipeActions`) on lists
- Drag-and-drop (`.draggable` / `.dropDestination`) where it makes sense
- Multi-select where it would save real time
- Spotlight (Core Spotlight) and Shortcuts (App Intents) integration on iOS / macOS

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | One rigid path. No shortcuts or alternatives. |
| 1 | Limited flexibility. Few alternatives to the main path. |
| 2 | Some shortcuts. Basic keyboard support, limited bulk actions. |
| 3 | Good accelerators. Keyboard nav, some customization. |
| 4 | Highly flexible. Multiple paths, power features, customizable. |

### 8. Aesthetic and Minimalist Design

Interfaces should not contain irrelevant or rarely needed information. Every element should serve a purpose.

**Check for**:

- Only necessary information visible at each step
- Clear visual hierarchy through scale + weight contrast (≥1.25 ratio)
- Purposeful use of color (Restrained / Committed / Full palette / Drenched, named on purpose)
- No decorative `.ultraThinMaterial` slapped on every surface for "depth"
- No identical card grids (`LazyVGrid` of same-sized boxes)
- No side-stripe accents, no gradient text via `.foregroundStyle(LinearGradient(...))`
- No `Color.black` / `Color.white` literals where a tinted neutral or `Color(.systemBackground)` belongs

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Overwhelming. Everything competes for attention equally. |
| 1 | Cluttered. Too much noise, hard to find what matters. |
| 2 | Some clutter. Main content clear, periphery noisy. |
| 3 | Mostly clean. Focused design, minor visual noise. |
| 4 | Perfectly minimal. Every element earns its pixel. |

### 9. Help Users Recognize, Diagnose, and Recover from Errors

Error messages should use plain language, precisely indicate the problem, and constructively suggest a solution.

**Check for**:

- Plain language error messages (no `NSError` codes leaked to users)
- Specific problem identification ("Email is missing @" not "Invalid input")
- Actionable recovery suggestions
- Errors displayed near the source of the problem (inline `Text` under the field, not a generic banner)
- Non-blocking error handling (don't wipe the form, preserve state)
- `ContentUnavailableView` with `.search` / `.error` configurations on iOS 17+
- Network failures handled with retry, not a dead screen

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | Cryptic errors. Codes, jargon, or no message at all. |
| 1 | Vague errors. "Something went wrong" with no guidance. |
| 2 | Clear but unhelpful. Names the problem but not the fix. |
| 3 | Clear with suggestions. Identifies problem and offers next steps. |
| 4 | Perfect recovery. Pinpoints issue, suggests fix, preserves user work. |

### 10. Help and Documentation

Even if the system is usable without docs, help should be easy to find, task-focused, and concise.

**Check for**:

- Onboarding flow that teaches by doing, not by reading
- Tip-style affordances (`TipKit` on iOS 17+) for non-obvious gestures
- `.help()` tooltips on macOS controls
- Settings explanations in `Section { } footer: { Text("…") }`
- Searchable help inside the app where the surface area justifies it
- Easy access without leaving current context (sheets, popovers, inline expansion)

**Scoring**:
| Score | Criteria |
|-------|----------|
| 0 | No help available anywhere. |
| 1 | Help exists but hard to find or irrelevant. |
| 2 | Basic help. FAQ or docs exist, not contextual. |
| 3 | Good documentation. Searchable, mostly task-focused. |
| 4 | Excellent contextual help. Right info at the right moment. |

---

## Score Summary

**Total possible**: 40 points (10 heuristics × 4 max)

| Score Range | Rating     | What It Means                                           |
| ----------- | ---------- | ------------------------------------------------------- |
| 36–40       | Excellent  | Minor polish only; ship it.                             |
| 28–35       | Good       | Address weak areas, solid foundation.                   |
| 20–27       | Acceptable | Significant improvements needed before users are happy. |
| 12–19       | Poor       | Major UX overhaul required; core experience broken.     |
| 0–11        | Critical   | Redesign needed; unusable in current state.             |

---

## Issue Severity (P0–P3)

Tag each individual issue found during scoring with a priority level.

| Priority | Name     | Description                                                            | Action                                  |
| -------- | -------- | ---------------------------------------------------------------------- | --------------------------------------- |
| **P0**   | Blocking | Prevents task completion, locks out users, or breaks accessibility     | Fix immediately; this is a showstopper. |
| **P1**   | Major    | Causes significant difficulty, confusion, or HIG violation             | Fix before release.                     |
| **P2**   | Minor    | Annoyance with workaround. Polish gap a careful designer would notice. | Fix in next pass.                       |
| **P3**   | Polish   | Nice-to-fix. No real user impact.                                      | Fix if time permits.                    |

**Tip**: If you're unsure between two levels, ask: "Would a user contact support about this, or would the App Store review team flag it?" If yes to either, it's at least P1.

### Apple-platform examples per severity

The general rule: anything that locks out a class of users (VoiceOver, Dynamic Type at AX sizes, Dark Mode, Reduce Motion) is P0. Anything that breaks the platform's design vocabulary (ignored materials, missing haptics, raw integers in numeric displays) is P1. Anything that misses a refinement opportunity is P2. Anything that's pure micro-polish is P3.

#### P0: Blocking

Examples that should always grade P0:

- Missing `.accessibilityLabel` on icon-only buttons (locks out VoiceOver users entirely).
- Hardcoded `Color(red: 0.1, green: 0.1, blue: 0.1)` or `Color.black` / `Color.white` for background/foreground that fail Dark Mode contrast.
- Text using a fixed `.font(.system(size: 14))` for body copy, breaking Dynamic Type.
- Tap targets below 44×44 points on iOS for primary actions.
- Modal stacking more than 2 deep on iPhone (`.sheet` over `.sheet` over `.sheet`) with no escape.
- Color used as the only signal for state (red = error, green = success) without an SF Symbol or text affordance, failing color-blind users.
- Crashing or empty state when the network is unavailable, with no retry path.
- Light-mode-only assets in an Asset Catalog with no Dark Mode variant.
- VoiceOver focus order that skips actionable elements or reads them in nonsense order.

#### P1: Major

Examples that should grade P1:

- Numeric displays (timers, counters, prices) without `.monospacedDigit()`, causing layout jitter as digits change.
- No `.sensoryFeedback` on completion, error, or selection states where it would be expected.
- `.ultraThinMaterial` applied as a baseline texture on full pages instead of reserved for floating overlays (glassmorphism-as-default).
- Side-stripe accents on cards or list rows (`.overlay(Rectangle().frame(width: 4))` on the leading edge).
- Gradient text via `.foregroundStyle(LinearGradient(...))` on `Text` for decoration.
- The hero-metric template ported into a SwiftUI dashboard (giant number, small label, gradient accent).
- `LazyVGrid` of identical cards with `Image(systemName:)` + heading + body, repeated endlessly with no rhythm variation.
- Mixed SF Symbol weights on the same surface (`.regular` next to `.bold` next to `.semibold` with no logic).
- `.foregroundColor(.black)` instead of `.foregroundStyle(.primary)` on body copy.
- Custom `Color.white.opacity(0.8) + .blur()` instead of system materials.
- Missing `Settings` scene on macOS, settings shoved into a custom sheet.
- App ignores the user's `@Environment(\.layoutDirection)`, breaking RTL.
- No `@ScaledMetric` on spacing tied to text, so layout collapses at AX sizes.
- Monoculture display fonts: `Font.custom("Fraunces-...")` or `Font.custom("GeistMono-...")` used as the primary display face with no brand rationale. Instant AI design tell. The `monoculture-display-font` detector (Phase 3) flags these by name.
- Italic serif for decorative emphasis on UI text: `Font.custom(...).italic()` applied to body copy or labels as an aesthetic gesture rather than a semantic one. The `italic-serif-misuse` detector (Phase 3) flags instances where an italic custom font is applied without a semantic reason.

#### P2: Minor

Examples that should grade P2:

- Empty collection state shows nothing instead of `ContentUnavailableView`.
- Animations don't honor `@Environment(\.accessibilityReduceMotion)`.
- Color Set has no Dark Mode variant in the Asset Catalog (defaulting to system mirror is fine, but if the brand color needs a dark adjustment, missing it is P2).
- Toolbar items use the right SF Symbol but the wrong `.symbolRenderingMode` (palette where hierarchical would read better).
- `List` used where a tuned `VStack` would honestly be clearer.
- One section uses the same padding value as every other section, no spatial hierarchy.
- A `GroupBox` or `Form` reached for by reflex when the content didn't justify a container.
- Accessibility label present but redundant with the visible text (creates double-read in VoiceOver).
- `.refreshable` missing on a content list that obviously updates.
- Missing `.help()` tooltips on macOS toolbar buttons.

#### P3: Polish

Examples that should grade P3:

- Padding monotony: every region uses `.padding(16)`, when varying across the 4/8/16/24 scale would build hierarchy.
- Weak weight contrast in the type scale (everything `.regular`, no `.semibold` accents).
- Spring animation could be a touch snappier (`.smooth` where `.snappy` would feel better).
- Section header could use `.headline` instead of `.subheadline` for a clearer break.
- An SF Symbol could be swapped for a more specific variant (`star` → `star.circle` on the empty state).
- Minor color tint adjustment: brand neutral could shift another 0.005 chroma toward the accent.
- A `Divider()` is doing work that white space would do better.

---

## How to use this in critique

When `/impeccable-swift critique` produces a report, every finding gets:

1. **A heuristic** (1–10 from above).
2. **A score impact** (would this finding alone drop the heuristic from 4 to 3? from 3 to 1?).
3. **A severity** (P0 / P1 / P2 / P3).
4. **A specific fix** (the SwiftUI modifier, the system color, the `.sensoryFeedback`, the `.accessibilityLabel`).

When `/impeccable-swift audit` runs the Swift detector arm (SwiftLint + `impeccable-lint` + asset-catalog-checker), every machine-flagged issue gets the same severity tag. The detectors are tuned so a P0 from a detector is genuinely a P0: they don't cry wolf.

A 4 on every heuristic and zero P0/P1 findings is the bar before shipping.

## Cross-references

- [reference/accessibility.md](accessibility.md): VoiceOver, Dynamic Type, Reduce Motion, color-as-only-signal, the full a11y checklist behind the P0 rules above.
- [reference/color-and-contrast.md](color-and-contrast.md): OKLCH reasoning, semantic Color Sets, Dark Mode variants, contrast ratios behind the P0 / P1 color findings.
- [reference/materials.md](materials.md): Liquid Glass vocabulary, when `.ultraThinMaterial` is right, when it's the glassmorphism-as-default failure mode.
- [reference/typography.md](typography.md): SF Pro text styles, `@ScaledMetric`, `.monospacedDigit()`, weight contrast.
- [reference/sf-symbols.md](sf-symbols.md): one set per surface, weight + scale consistency, semantic correctness.
