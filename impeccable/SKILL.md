---
name: impeccable-swift
description: Build SwiftUI interfaces with impeccable design quality. Use when writing SwiftUI views, building Apple-platform UI, or when the user asks for design polish on a Swift/SwiftUI project.
user-invocable: true
argument-hint: "[craft|teach]"
license: Apache 2.0. Based on Paul Bakaus's impeccable. See NOTICE.md.
---

`impeccable-swift` is the Apple-platform port of Paul Bakaus's `impeccable`. It generates and defends SwiftUI code that looks native on iOS, iPadOS, macOS, visionOS, and watchOS — not the beige, rounded-rect "AI SwiftUI" that every model reaches for by default. This is a POC: same philosophy as upstream impeccable, retuned for points-not-pixels, Liquid Glass materials, SF Symbols, Dynamic Type, and Apple HIG defaults. Licensed Apache 2.0. See `NOTICE.md` for attribution.

## Context Gathering Protocol

Before writing or reviewing any SwiftUI, you MUST load the project's design context in this order. Skipping this step is how you produce generic output.

### Step 1: Read the 13 reference docs

All thirteen live under `impeccable/reference/`. Read each before acting — they are the universal rules this skill enforces:

- `accessibility.md` — VoiceOver labels, traits, Reduce Motion, Reduce Transparency, Switch Control.
- `color-and-contrast.md` — system colors, semantic roles, Dark Mode, accessibility contrast.
- `craft.md` — the shape → reference → build → iterate loop; tone and voice for this skill.
- `interaction-design.md` — gestures, haptics, focus, loading and empty states.
- `ios-vs-macos.md` — platform divergences that must not be glossed over.
- `materials.md` — Liquid Glass, `.ultraThinMaterial` through `.thick`, when each is correct.
- `motion-design.md` — spring presets, reduced motion, respectful animation.
- `navigation.md` — `NavigationStack`, split views, tab patterns, modal discipline.
- `responsive-design.md` — size classes, Dynamic Type, orientation, iPad multitasking.
- `sf-symbols.md` — one symbol set per surface, weight and scale consistency, variants.
- `spatial-design.md` — points not pixels, 4/8/16/24 rhythm, safe areas, optical alignment.
- `typography.md` — system fonts, text styles, Dynamic Type tiers, numeric styles.
- `ux-writing.md` — labels, errors, empty states, sentence-case, Apple-voice phrasing.

### Step 2: Read the project's `DESIGN.md`

Look at the repo root for `DESIGN.md`. This is where each project declares its own tokens — accent color, type family, radii, spacing values, shadow scale, motion preferences.

### Step 3: Apply two-layer read precedence

**Project `DESIGN.md` tokens override universal defaults where explicit; universal rules (structure, anti-patterns, principles) apply where the project is silent. Non-conflict composition is the common case.**

- If `DESIGN.md` sets `accent = #c97350`, use that color — the reference docs define _how_ to apply accent, not _which_ accent.
- If `DESIGN.md` is silent on navigation pattern, the reference docs decide.
- If both layers are silent on a specific question, default to Apple HIG.
- If `DESIGN.md` is missing, proceed in universal-only mode. No error, no warning.
- If `DESIGN.md` exists but is unparseable, log a one-line warning and continue with universal rules.

## Principles in one page

- **Points, not pixels.** Everything scales. Dynamic Type and `@ScaledMetric` or it doesn't ship.
- **Liquid Glass by default on modern OSes.** Reach for materials before custom backgrounds.
- **One symbol set per surface.** Mixing SF Symbols weights or swapping in third-party icon packs is a tell.
- **Named anti-patterns beat generic advice.** The reference docs call violations by name — cite them.
- **Apple HIG is the tiebreaker.** When in doubt, do what the system does.

## The SwiftUI Reflex Check

The model's natural failure mode in SwiftUI is identical to its failure mode in web design: it reaches for trained defaults and produces output that looks like every beginner tutorial. The following procedure forces enumeration before generation.

**Run this before writing any SwiftUI view — not after.**

**Step 1.** Write down 3 words for what this screen should feel like in use. Not "clean" or "modern" — those are dead words. Something like: "focused and unhurried and a little ceremonial", "fast and dense and dismissible", "warm and tactile and forgiving".

**Step 2.** List the first 3 layout and surface decisions you would make. Write them down explicitly. They are most likely from this list:

<reflex_swiftui_patterns_to_reject>
Surface defaults:

- `.background(Color(.systemBackground))` — no material, no depth declaration
- White card with `cornerRadius(10)` and `shadow(radius: 4)` — the AI SwiftUI card
- Flat `VStack` of identical rows with a `Divider()` between them

Layout defaults:

- `List` for every scrolling collection regardless of visual intent
- `VStack { ForEach { HStack { ... } } }` as the only layout pattern
- Every section uses the same padding value (no hierarchy through spacing)

Typography defaults:

- `.title` + `.body` + `.caption` at system weight defaults, no contrast variation
- Every header the same weight, every body the same style
- No numeric formatting (raw integers, not `.monospacedDigit()` for time/counts)

Color defaults:

- `.accentColor` as the only brand expression
- No semantic color tokens — hardcoded Color values everywhere
- Dark Mode never considered beyond system `.primary`/`.secondary`

Interaction defaults:

- No custom `ButtonStyle` — system default press behavior on every tappable element
- No `.sensoryFeedback` on any completion, error, or selection state
- No `ContentUnavailableView` — empty collections just show nothing

Material defaults:

- No `Material` on any surface, even floating overlays
- Custom `Color.white.opacity(0.8)` + `.blur()` instead of system materials
- No `GlassEffectContainer` for related floating controls on iOS 26+
  </reflex_swiftui_patterns_to_reject>

**Step 3.** For any item in your Step 2 list that matches the reflex list: stop and find the system alternative or a more intentional choice. The reflex choice is not always wrong — but it must be a deliberate decision, not a default.

**Step 4.** Cross-check the result. Ask: does this layout look like a SwiftUI tutorial screenshot? Does every card look the same? Is the only design decision "light background, SF Pro, blue accent"? If yes, go back to Step 3.

The goal is not to be weird. The goal is to be intentional. A plain `List` is correct when a plain `List` is the right choice — but the model must be able to name _why_, not just reach for it.

## Commands available

- `/impeccable-swift:craft` — shape, reference, build, iterate. The default flow for new SwiftUI work. Runs the full `craft.md` loop.
- `/impeccable-swift:critique` — review existing SwiftUI code, score it, surface findings with reference-doc citations. Does not fix.
- `/impeccable-swift:polish` — apply critique feedback and tighten generated code. Targeted edits only, no refactors.

### Craft mode

If invoked with the argument `craft` (e.g. `/impeccable-swift craft [feature description]`), follow `reference/craft.md`. Pass any additional arguments as the feature description.

### Teach mode

If invoked with `teach`, scan the project for existing design signal (Assets.xcassets, token files, existing views), ask only what you cannot infer (audience, brand voice, platform targets, accessibility posture), and write the synthesis to `DESIGN.md` at the repo root. If `DESIGN.md` already exists, update in place. Confirm and summarize the principles that will now guide future work.

## Sub-commands invoked by this skill

`/impeccable-swift:critique` runs three independent detectors. Each is tool-tolerant — a missing tool produces a one-line report and the rest of the run continues.

- **SwiftLint custom rules** — `tools/.swiftlint.yml`. Structural and anti-pattern matches.
- **`impeccable-lint`** — SwiftSyntax CLI at `tools/impeccable-lint/`. Run via `swift run impeccable-lint <target>`. Catches SwiftUI-specific violations that regex can't see.
- **Asset catalog checker** — `tools/asset-catalog-checker/check.swift`. Validates color sets, symbol overrides, and appearance coverage in `.xcassets`.

Based on impeccable by Paul Bakaus. See `NOTICE.md`.
