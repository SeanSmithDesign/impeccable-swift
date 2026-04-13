# Craft Flow

Impeccable SwiftUI is a process, not a style. Shape the design, load the right references, build, and iterate in #Preview until the result delights. Skip any step and you get AI slop.

## Shape Before You Build

**Never start in a `View` struct.** The canvas is not where design decisions happen — it's where design decisions get rendered. If you open a file and start typing `VStack`, you have no brief, no references, and no constraints, and the result will read as "a SwiftUI feature" instead of "this feature."

**Rule:** Run `/shape` against the user's feature description before writing any view code. Wait for the design brief to be confirmed. The brief is the blueprint — every type choice, spacing decision, and color token should trace back to a line in it.

If the user already has a confirmed brief, skip `/shape` and use the existing one. Do not re-shape without cause.

**Anti-pattern — "Generate a view then tweak in place."** A subagent spits out a `NavigationStack` with a `List` and some `.padding(16)`s. The designer says "make the cards feel more premium." The agent adds a shadow. The designer says "less blue." The agent changes the accent. Three iterations later the view has no coherent theory — just an accretion of small reactions. No shape, no reference, pure vibes.

## Load References, Don't Reinvent

**Before you build, pull the reference files that match the brief.** SwiftUI has enough surface area that an unguided implementation will recreate every mistake the platform has already solved. The references exist because the answers exist.

At minimum, always consult:

- `spatial-design.md` — layout, spacing, the 4/8/12/16/24/32/48/64 scale
- `typography.md` — type hierarchy, `Font.system` vs custom, Dynamic Type

Then add based on the brief:

- Complex forms, sheets, confirmation flows → `interaction-design.md`
- Animation, transitions, matched-geometry → `motion-design.md`
- Color-heavy or themed → `color-and-contrast.md`
- Adaptive layouts across size classes → `responsive-design.md`
- Heavy on copy, errors, empty states → `ux-writing.md`

**Rule:** If the brief names a concern, there is a reference for it. Read the reference before writing the view.

## Build In This Order

**SwiftUI rewards structure-first thinking.** Build in layers — structure, then layout, then finish, then states, then motion, then adaptation. Jumping ahead means re-doing work when the foundation shifts.

1. **Structure.** `VStack` / `HStack` / `Grid` / `List` / `ScrollView` — the skeleton of the primary state. No modifiers yet beyond what the structure requires.
2. **Layout and spacing.** Apply the spatial rhythm from the brief. Use the 4px base scale. No arbitrary `.padding(13)` values.
3. **Typography and color.** Apply semantic text styles (`.font(.headline)`, `.font(.body)`) and Asset Catalog color tokens. Never hardcode hex inline.
4. **Interactive states.** Hover (on iPad/Mac), `.pressed`, `.disabled`, focus. Every interactive element needs a visible state change.
5. **Edge case states.** Empty (`ContentUnavailableView`), loading (`ProgressView` with real copy), error, overflow, first-run.
6. **Motion.** `.matchedGeometryEffect`, `.transition(_:)`, spring timing. Purposeful only — if it doesn't communicate something, delete it.
7. **Adaptation.** Size classes, `.dynamicTypeSize`, landscape, iPad, Mac. Do not just shrink; redesign for the context.

### During Build

- Use real data in `#Preview`, not `"Lorem ipsum"`. Placeholder text hides density problems, truncation bugs, and hierarchy failures.
- Build and verify each state as you create it, not all at the end. State bugs compound.
- If a design question surfaces, stop and ask — do not guess. A guessed decision becomes a precedent you'll fight later.
- Every visual choice must trace back to the brief. If it doesn't, either the choice is wrong or the brief is incomplete.

**Anti-pattern — "The Modifier Pile."** A `Text` gets `.padding(.top, 12)`, `.padding(.horizontal, 16)`, `.padding(.bottom, 8)`, `.background(...)`, `.cornerRadius(10)`, `.shadow(...)`, `.padding(.vertical, 4)`. Each modifier was added in reaction to a specific visual problem. The stack has no structure, no tokens, and no way to maintain. Build in layers, not in reactions.

## Iterate In #Preview, Not In Production

**#Preview is the canvas.** Designers on the web work in the browser; designers on Apple platforms work in `#Preview`. You iterate faster, test more states, and catch problems earlier there than by running the app.

**Rule:** Every view ships with a `#Preview` that shows the primary state, plus at least one preview macro per non-trivial state (empty, loading, error, long content, Dynamic Type XL).

```swift
#Preview("Primary") {
    NoteDetail(note: .sample)
}

#Preview("Empty") {
    NoteDetail(note: .empty)
}

#Preview("Dynamic Type XL") {
    NoteDetail(note: .sample)
        .dynamicTypeSize(.accessibility3)
}

#Preview("Dark") {
    NoteDetail(note: .sample)
        .preferredColorScheme(.dark)
}
```

**Do not stop after the first implementation pass.** Iterate through these checks visually, in the preview canvas:

1. **Does it match the brief?** Walk every section of the brief against the preview. Fix discrepancies.
2. **Does it pass the AI slop test?** If a designer saw this and said "AI made this" — would they believe it immediately? If yes, it needs more intention.
3. **Check every state.** Click through empty, loading, error, long-content. Each should feel intentional, not like a fallback.
4. **Check Dynamic Type.** Ratchet from `.small` to `.accessibility5`. Layout must survive.
5. **Check light and dark.** Both are first-class. A view that only looks right in one is half-finished.
6. **Check the details.** Spacing rhythm, type hierarchy, contrast, interactive feedback, motion timing.

Repeat until you'd be proud to hand this to the user. The bar is not "it compiles." The bar is "this delights."

## Present, Then Listen

**Show the primary state, walk through the secondary states, name the decisions that connect back to the brief.** Then ask: "What's working? What isn't?" Good design is rarely right on the first pass. The iteration loop with the user is part of the craft, not a failure of it.

**Anti-pattern — "Ship and ghost."** Agent finishes a feature, hands it over, moves on. The user discovers three edge cases and two tone issues in actual use. Iteration is the job, not the reward.

---

**Avoid:** Starting in a view file without a brief. Skipping references because "I know SwiftUI." Placeholder data in `#Preview`. Building without checking dark mode. Shipping before Dynamic Type XL is tested. Stacking modifiers reactively instead of designing in layers.
