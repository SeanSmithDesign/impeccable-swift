# shape

Shape the UX and UI for a SwiftUI feature before any code is written. This command produces a **design brief**: a structured artifact that guides implementation through discovery, not guesswork.

**Scope**: Design planning only. This command does NOT write SwiftUI code. It produces the thinking that makes code good.

**Output**: A design brief that can be handed off to `/impeccable-swift craft`, or directly to `/impeccable-swift` for freeform implementation. When visual direction probes are used, the images are supporting artifacts, not the primary output.

## Philosophy

Most AI-generated SwiftUI fails not because of bad code, but because of skipped thinking. It jumps to "here's a `List` of cards" without asking "what is the user trying to accomplish, on which device, in what posture?" This command inverts that: understand deeply first, so implementation is precise.

## Phase 1: Discovery Interview

**Do NOT write any code or make any design decisions during this phase.** Your only job is to understand the feature deeply enough to make excellent design decisions later.

Ask these questions in conversation, adapting based on answers. Don't dump them all at once; have a natural dialogue. STOP and call the AskUserQuestion tool to clarify.

### Purpose & Context

- What is this feature for? What problem does it solve?
- Who specifically will use it? (Not "users"; be specific: role, context, frequency.) See [`personas.md`](personas.md) for archetypes worth probing here, and consider creating a project-specific persona from PRODUCT.md.
- What does success look like? How will you know this feature is working?
- What's the user's state of mind when they reach this feature? (Rushed? Exploring? Anxious? Focused?)
- **Register** (brand or product) is already known from setup, but reconfirm during shaping if the surface sits at the boundary (a marketing landing inside a product app, or a paywall inside a brand portfolio). See [`brand.md`](brand.md) and [`product.md`](product.md).

### Apple Platform Targeting

Force the device decision before the layout decision. SwiftUI feels different across idioms; the brief must say which.

- **Target idiom.** iPhone-only, iPhone + iPad (universal), iPad-first, Mac-also (Mac Catalyst, designed-for-iPad, or native Mac), watchOS, visionOS? Pick the primary device and name the secondary ones.
- **Posture.** One-handed thumb on iPhone? Two-thumb iPad in landscape? Mouse + keyboard on a 27" Mac? Glance at a 41mm Watch face? The posture sets the touch target size, the typography baseline, and the spatial budget.
- **Multitasking.** On iPad, does this need to survive Slide Over (320pt), Split View (50/50 and 70/30), and Stage Manager (resizable)? On Mac, what's the minimum window size?
- **Size class behavior.** What changes between compact and regular width? Does a tabbar become a sidebar (`NavigationSplitView`)? Does a sheet become an inspector? Does a stack become a split view?

### Content & Data

- What content or data does this feature display or collect?
- What are the realistic ranges? (Minimum, typical, maximum: 0 items, 5 items, 500 items.)
- What are the edge cases? (Empty state via `ContentUnavailableView`, error state, first-time use, power user.)
- Is any content dynamic? What changes and how often? (`@Observable`, async streams, push, iCloud sync.)
- Will the content be localized? Any languages with very long strings (German), RTL (Arabic, Hebrew), or complex scripts (Thai, Devanagari)? String Catalog assumed.

### Cognitive Load Baseline

Establish load before you build, not after. See [`cognitive-load.md`](cognitive-load.md) for the full framework.

- How many decisions does the user have to make on this surface? (Hick's Law.)
- How many distinct elements compete for attention? (Miller's number.)
- Is there progressive disclosure available, or is everything flat? (`DisclosureGroup`, secondary screens, sheets stacked deliberately.)
- What's the working-memory cost across steps in a multi-step flow? Does the user need to remember things from earlier screens?

If the answers point to "heavy" before any code is written, the brief should propose load reductions explicitly, not leave them to implementation.

### Design Direction

Force a visual decision on three fronts. Skip anything PRODUCT.md or DESIGN.md already answers; ask only what's missing.

- **Color strategy for this surface.** Pick one: Restrained / Committed / Full palette / Drenched. Can override the project default if the surface earns it (e.g. a Drenched hero inside an otherwise Restrained product).
- **Theme via scene sentence.** Write one sentence of physical context for this surface: who uses it, where, on what device, under what ambient light, in what mood. The sentence forces dark vs light. If it doesn't, add detail until it does. Dark Mode coverage is non-negotiable on Apple platforms; the default appearance is still a deliberate choice.
- **Two or three named anchor references.** Specific products, brands, objects, not adjectives like "modern" or "clean." Apple's own apps are fair game (Things 3, Mercury Weather, Reeder, Linear's Mac app).

### Accessibility Baseline

Set the floor before designing, not after. SwiftUI gives the right answer for free if the layout is built to flex.

- **Dynamic Type baseline.** What's the largest size class the layout must survive intact? (Default: at least AX3. Glance surfaces may target XXL.)
- **VoiceOver flow.** Linear by default? Custom reading order via `.accessibilitySortPriority`? Anything decorative that should be `.accessibilityHidden(true)`?
- **Reduce Motion.** Are there motion choices that need a degraded path?
- **Reduce Transparency.** Liquid Glass and `.ultraThinMaterial` collapse to opaque tints; does the layout still hold?

### Scope

Always ask. Sketch quality and shipped quality are different outputs; don't guess between them.

- **Fidelity.** Sketch / mid-fi / high-fi / production-ready?
- **Breadth.** One view / a flow / a whole surface (tab, sidebar destination, sheet stack)?
- **Interactivity.** Static visual / Xcode Previews interactive / shipped-quality component?
- **Time intent.** Quick exploration, or polish until it ships?

Scope answers are task-scoped. Don't write them to PRODUCT.md or DESIGN.md: carry them through the design brief only.

### Constraints

- Are there technical constraints? (iOS 26+ minimum, SwiftData vs. Core Data, performance budget, no third-party deps?)
- Are there content constraints? (String Catalog, dynamic text length, user-generated content with emoji and mixed scripts.)
- Multitasking and window-size requirements (covered in Apple Platform Targeting above; surface again here if the constraint is hard).
- Accessibility requirements beyond WCAG AA? (Voice Control, Switch Control, AX5 Dynamic Type as a hard target.)
- Are there HIG conformance requirements (App Store review, design partner spec, Apple Design Award ambition)?

### Anti-Goals

- What should this NOT be? What would be a wrong direction?
- What's the biggest risk of getting this wrong?
- Which of the absolute bans in SKILL.md are most tempting on this surface? (Side-stripe borders on rows, glassmorphism-by-default backgrounds, identical-card grids in `LazyVGrid`, modal-as-first-thought via `.sheet`.) Name them so the brief can pre-empt them.

## Phase 1.5: Visual Direction Probe (Capability-Gated)

After the discovery interview, generate a small set of visual direction probes **before** writing the final brief when all of these are true:

- The work is **net-new** or directionally ambiguous enough that visual exploration will clarify the brief.
- The requested fidelity is **mid-fi, high-fi, or production-ready**. Skip for sketch-only planning.
- The current harness has **built-in image generation capability** (for example, Codex with a native image tool). Do **not** ask the user to set up external APIs, shell scripts, or one-off tooling just to do this.

When those conditions are met, this step is the default. Use it to explore visual lanes, not to replace the brief.

### What to generate

Generate **2 to 4** distinct direction probes based on the discovery answers, especially:

- Color strategy
- Theme scene sentence
- Named anchor references
- Target idiom (iPhone vs. iPad vs. Mac framing changes the probe aspect ratio)
- Scope and fidelity

The probes should differ in primary visual direction (hierarchy, topology, density, typographic voice, color strategy, or material posture), not just palette tweaks.

### How to use the probes

- Treat them as **direction tests**, not final designs.
- Use them to pressure-test whether the brief is pointing at the right lane.
- Ask the user which direction feels closest, what feels off, and what should carry forward.
- If the probes reveal a mismatch, revise the brief inputs before finalizing the brief.

### Important limits

- Do **not** skip discovery because image generation is available.
- Do **not** treat generated imagery as final UX specification, final copy, or final accessibility behavior.
- Do **not** use this step for minor refinements of existing work. It's for shaping a new surface or clarifying a big directional choice.

If image generation is unavailable, or the task doesn't benefit from it, skip this phase and proceed directly to the design brief.

## Phase 2: Design Brief

After the interview, synthesize everything into a structured design brief. Present it to the user for confirmation before considering this command complete.

### Brief Structure

**1. Feature Summary** (2-3 sentences)
What this is, who it's for, what it needs to accomplish. Note the register (brand or product) explicitly.

**2. Primary User Action**
The single most important thing a user should do or understand here.

**3. Target Surface**

- **Idiom**: iPhone-only / iPhone + iPad / iPad-first / Mac-also / watchOS / visionOS.
- **Posture**: thumb / two-thumb / mouse + keyboard / glance.
- **Size classes**: what changes between compact and regular width (e.g., tabbar becomes `NavigationSplitView` sidebar).
- **Multitasking**: iPad Slide Over / Split View / Stage Manager behavior; Mac minimum window size.
- **Dynamic Type baseline**: largest supported size class (default AX3).

**4. Design Direction**
Color strategy (Restrained / Committed / Full palette / Drenched) + the theme scene sentence + 2 or 3 named anchor references. Reference PRODUCT.md and DESIGN.md where they already answer, and note any per-surface overrides. Cite the matching register reference ([`brand.md`](brand.md) or [`product.md`](product.md)).

If you ran the Visual Direction Probe step, name which probe direction won and what changed in the brief because of it.

**5. Scope**
Fidelity, breadth, interactivity, and time intent from the Scope section of the interview. Task-scoped: these don't persist beyond the brief.

**6. Layout Strategy**
High-level spatial approach: what gets emphasis, what's secondary, how information flows. Describe the visual hierarchy and rhythm, not specific points or modifier chains. Name the SwiftUI primitives in play (`NavigationStack`, `NavigationSplitView`, `TabView`, `ScrollView` + `LazyVStack`, `Form`, `List`, custom `Layout`) without committing to view code.

**7. Key States**
List every state the feature needs: default, empty (`ContentUnavailableView` with what guidance?), loading (skeleton, redacted, spinner?), error (recoverable how?), success, edge cases. For each, note what the user needs to see and feel.

**8. Interaction Model**
How users interact with this feature. What happens on tap, long-press (`.contextMenu`), swipe (`.swipeActions`), drag, scroll, hover (Mac/iPad pointer), keyboard? What sensory feedback (`.sensoryFeedback`)? What's the flow from entry to completion? What gets undone how?

**9. Content Requirements**
What copy, labels, empty-state guidance, error messages, and microcopy are needed. Note any dynamic content and its realistic ranges. Call out String Catalog needs, accessibility labels for symbol-only buttons, and any localization edge cases.

**10. Recommended References**
Based on the brief, list which `impeccable-swift` reference files would be most valuable during implementation. Common picks:

- [`navigation.md`](navigation.md) for stack vs. split vs. tab decisions, and for the wireframe-to-interaction-prototype scope split.
- [`spatial-design.md`](spatial-design.md) for layout rhythm and spacing scale.
- [`materials.md`](materials.md) for Liquid Glass and material posture (anchor references and visual direction often live here).
- [`motion-design.md`](motion-design.md) for animated features.
- [`interaction-design.md`](interaction-design.md) for form-heavy or gesture-heavy features.
- [`sf-symbols.md`](sf-symbols.md) when the surface leans on iconography.
- [`ios-vs-macos.md`](ios-vs-macos.md) when the brief targets multiple idioms.
- [`accessibility.md`](accessibility.md) when the accessibility baseline is non-trivial.
- [`cognitive-load.md`](cognitive-load.md) when load is the central design risk.

**11. Open Questions**
Anything unresolved that the implementer should resolve during build.

---

STOP and call the AskUserQuestion tool to clarify. Get explicit confirmation of the brief before finishing. If the user disagrees with any part, revisit the relevant discovery questions.

Once confirmed, the brief is complete. The user can now hand it to `/impeccable-swift`, or use it to guide any other implementation approach. (If the user wants the full discovery-then-build flow in one step, they should use `/impeccable-swift craft` instead, which runs this command internally.)

## SwiftUI Shaping Examples

The discovery interview adapts to the surface. A few common SwiftUI shapes and the questions that matter most:

- **Settings sheet** (`.sheet` from a toolbar gear). Idiom: usually iPhone + iPad with a Mac variant in `Settings { }`. Key questions: how many sections, what's the persistence layer (`@AppStorage`, SwiftData, server), does it need search at the top, does Mac get a separate window or a `Form` in a sheet, does it survive Dynamic Type at AX3 with grouped insets.
- **Content list with swipe actions** (`List` + `.swipeActions`). Idiom: iPhone-first, iPad gets multi-column. Key questions: what are the leading vs. trailing swipe actions, does edit mode support multi-select, what's the empty state, does it sync, what's the delete confirmation model (immediate with undo toast vs. confirmation dialog).
- **Tabbed interface** (`TabView`). Idiom: iPhone-first, iPad gets `TabView` + sidebar (iPadOS 18+). Key questions: how many tabs (5 max on iPhone before "More"), what becomes a sidebar destination on iPad and Mac, does any tab need a badge, what's the deep-link entry per tab.
- **Mac sidebar layout** (`NavigationSplitView` with three columns). Idiom: Mac-first or iPad-first that scales down. Key questions: sidebar / content / detail breakdown, what shows in the toolbar at each level, how does the layout collapse to two columns on iPad portrait or compact width, what's the keyboard nav model, does the sidebar support drag-and-drop reorder.
- **iPad split view** (`NavigationSplitView` two-column). Idiom: iPad-first, scales down to iPhone via size-class adaptation. Key questions: what's the compact-width fallback (push the detail onto a `NavigationStack`?), how does it behave under Slide Over and Stage Manager, does the sidebar stay visible in landscape and hide in portrait by default.

These are starting points, not templates. Adapt the questions to the surface.
