# Polish

> **Additional context needed**: quality bar (MVP vs flagship).

Perform a meticulous final pass to catch all the small details that separate good work from great work. The difference between shipped and polished.

Detector and automated QA output are defect evidence only. A clean tool result is never proof that the design is strong; gather device evidence and inspect the real interaction path.

**Scope**: Polish is tightening, not rewriting. One concern per edit. If a fix requires splitting a view, renaming a model, or changing a data flow, polish refuses and defers: _"This needs architectural change: outside polish scope. Deferring to you."_

## Design System Discovery

Aligning the feature to the design system is **not optional**. Polish without alignment is decoration on top of drift, and it makes the next person's job harder. Discovery comes before any other polish work.

1. **Find the design system**: Run the context loader, then read `PRODUCT.md` and `DESIGN.md`. Look for color token enums (`AppColor`, `AccentColor`), spacing constants (`AppSpacing`), and custom `ViewModifier` / `ButtonStyle` types.

   ```bash
   node .claude/skills/impeccable-swift/scripts/load-context.mjs
   ```

2. **Note the conventions**: How are shared components imported? What spacing scale is in use? Which colors come from the asset catalog vs hard-coded literals? What animation patterns are established? What flow shapes are used for comparable actions (sheet vs full-screen cover, inline vs navigation push, save-on-blur vs explicit submit)?

3. **Identify drift, then name the root cause**: For every deviation, classify it as a **missing token** (the value should exist in the system but doesn't), a **one-off implementation** (a shared component already exists but wasn't used), or a **conceptual misalignment** (the feature's flow or hierarchy doesn't match neighboring features). The fix differs by category: patch the value, swap to the shared component, or rework the flow. Fixing the symptom without naming the cause is how drift compounds.

If a design system exists, polish **must** align the feature with it. If none exists, polish against the conventions visible in the codebase. **If anything about the system is ambiguous, ask. Never guess at design system principles.**

## Pre-Polish Assessment

Understand the current state and goals before touching anything:

1. **Review completeness**:
   - Is it functionally complete?
   - Are there known issues to preserve (mark with `// TODO:`)?
   - What is the quality bar? (MVP vs flagship feature?)
   - When does it ship? (How much time for polish?)

2. **Think experience-first**: Who actually uses this, and what's the best possible experience for them? Effective design beats decorative polish; a feature that looks beautiful but fights the user's flow is not polished. Walk the path from their perspective before opening Instruments.

3. **Identify polish areas**:
   - Visual inconsistencies
   - Spacing and alignment issues
   - Interaction state gaps (`.disabled`, `.loading`, `.error`)
   - Copy inconsistencies
   - Edge cases and error states
   - Transition smoothness
   - Information architecture and flow drift (does this feature reveal complexity the way neighboring features do?)

4. **Triage cosmetic vs functional**: Classify each issue as **cosmetic** (looks off, doesn't impede the user) or **functional** (breaks, blocks, or confuses the experience). When polish time is tight, functional issues ship first. Quality should be consistent; never perfect one corner while leaving another rough.

**CRITICAL**: Polish is the last step, not the first. Do not polish work that is not functionally complete.

## Polish Systematically

Work through these dimensions methodically:

### Visual Alignment and Spacing

- **Grid alignment**: Prefer `.frame(alignment:)` over magic-number offsets. If an element needs a 3pt nudge to sit visually centered, reach for `offset(x:y:)` paired with a comment explaining the optical intent, not a hardcoded constant buried in padding.
- **Optical centering**: Small negative spacing (`spacing: -2`) achieves visual balance between glyphs and containers without pixel offsets. Use sparingly and document with `// optical`.
- **Consistent spacing**: All gaps use the project spacing scale. No random 13pt gaps.
- **Modifier ordering matters**: `.padding().background()` clips differently from `.background().padding()`: the first gives a padded hit area with an inset background; the second extends the background into the padding zone. Verify intent before flipping.
- **Disable Canvas grid overlay during final pass**: The grid overlay hides subtle misalignments. Turn it off to see what ships.

**Check with `tools/.swiftlint.yml`**: The SwiftLint rules flag unsafe padding/frame combos and missing `.frame(alignment:)` consistency. Run before finalizing.

```swift
// Preferred: explicit alignment avoids accidental centering
Text(title)
    .frame(maxWidth: .infinity, alignment: .leading)

// Avoid: implicit centering from HStack default
HStack {
    Text(title)
}
```

### Information Architecture and Flow

Visual polish on a misshapen flow is wasted work. Match the shape of the experience to the system, not just the surface.

- **Progressive disclosure**: Match how much is revealed when, compared to neighboring features. A settings screen exposing 40 fields when the rest of the app reveals 5 at a time is drift, even if every field is perfectly styled.
- **Established user flows**: Multi-step actions follow the same shape as comparable flows elsewhere: sheet vs full-screen cover, inline edit vs separate navigation push, save-on-blur vs explicit submit, optimistic vs pessimistic updates.
- **Hierarchy and complexity**: The same conceptual weight gets the same visual weight throughout. Primary actions don't become tertiary in one corner of the product.
- **Empty, loading, and arrival transitions**: How content arrives, updates, and leaves matches how it does in adjacent features.
- **Naming and mental model**: The feature uses the same nouns and verbs as the rest of the system. A "Workspace" here shouldn't be a "Project" three screens away.

### Typography Refinement

- **Hierarchy consistency**: Same semantic elements use same Dynamic Type styles throughout. See [`typography.md`](typography.md).
- **Line length on iPad/Mac**: Body text reads best at 45-75 characters. Use `.frame(maxWidth: 600)` or similar to constrain in regular-width layouts.
- **Widows and orphans**: Single words on last line look unfinished. Adjust line limit or container width.
- **Kerning and tracking**: Adjust `.tracking()` where needed, especially on uppercase labels and headlines with `kerning: -0.5` for tight display sizes.

### Color and Contrast

- **Contrast ratios**: All text meets WCAG AA. Verify with Accessibility Inspector.
- **Consistent token usage**: No hard-coded hex literals. All colors reference asset catalog entries or system colors.
- **Dark Mode parity**: Every hard-coded `.white` or `.black` breaks in the opposite appearance. Use `.primary`, `.secondary`, or semantic asset catalog colors.
- **Tinted neutrals**: No pure gray or pure black. Add subtle color tint (0.01 chroma). In SwiftUI, prefer `.gray` over `Color(white: 0.5)` which carries no adaptive behavior.
- **Gray on color**: Never put `.gray` text on colored backgrounds. Use a shade of that color or a transparency.

**Check with `tools/asset-catalog-checker/`**: Flags unused and duplicate color variants in `Assets.xcassets`. Run to confirm no orphaned color sets exist after polish.

### Interaction States

Every interactive control needs all relevant states:

- **Default**: Resting state
- **Hover** (iPadOS pointer, macOS): Subtle feedback via `.hoverEffect()`
- **Pressed**: `.buttonStyle(.plain)` with manual `.scaleEffect(0.97)` on press if system style does not match design intent
- **Focused**: Keyboard and Digital Crown focus indicator; never suppress `.focused` without a replacement
- **Disabled**: `.disabled(true)` with reduced opacity or tint shift; clearly non-interactive
- **Loading**: Async action feedback via `ProgressView` or skeleton
- **Error**: Validation or network error state with recovery path
- **Success**: Confirmation of successful action (brief, then resolves)

**Missing states create confusion and broken experiences.**

### Micro-interactions and Transitions

- **Smooth transitions**: All state changes animated with `.animation(.easeOut(duration: 0.2), value:)`. Prefer 150-250ms for most state changes.
- **Consistent easing**: `.easeOut` or `.spring(response: 0.35, dampingFraction: 0.8)` for natural deceleration. Never `.interactiveSpring()` unless driven by an active gesture.
- **Animate opacity and offset, not layout**: Avoid animating `.padding()`, `.frame()`, or `.spacing()` directly. Animate `.opacity`, `.scaleEffect`, `.offset`, and `.foregroundStyle`. See [`motion-design.md`](motion-design.md).
- **Appropriate motion**: Motion serves purpose, not decoration.
- **Reduced motion**: Wrap any non-essential animation in `withAnimation(prefersReducedMotion ? nil : ...)`. Access via `@Environment(\.accessibilityReduceMotion)`.

```swift
@Environment(\.accessibilityReduceMotion) private var prefersReducedMotion

var body: some View {
    content
        .animation(
            prefersReducedMotion ? nil : .easeOut(duration: 0.2),
            value: isVisible
        )
}
```

### State Transition Polish

State transitions deserve the same care as initial render. See [`navigation.md`](navigation.md) for guidance on push/pop animation polish and error recovery UX.

- **Push/pop**: Match navigation transition timing to Liquid Glass material reveal timing.
- **Error recovery**: Error states must offer a clear action (retry, dismiss, or navigate back). Never a dead end.
- **Sheet dismiss**: Swipe-to-dismiss should feel consistent with the sheet's content weight.

### Visual Depth and Material Polish

Material usage drives perceived depth and spatial hierarchy. See [`materials.md`](materials.md) for visual alignment via depth and shadow guidance.

- **Consistent material tier**: Do not mix `.ultraThinMaterial` and `.regularMaterial` on the same elevation level.
- **Shadow consistency**: `.shadow(color: .black.opacity(0.08), radius: 8, y: 4)` as a baseline soft shadow. Tighten radius on smaller elements.
- **Liquid Glass surfaces**: On iOS 26 / macOS 26, `.glassEffect()` replaces custom blur-and-overlay patterns. Remove any manual `UIBlurEffect` equivalents and adopt the system primitive.

### Content and Copy

- **Consistent terminology**: Same things called same names throughout. See [`ux-writing.md`](ux-writing.md).
- **Consistent capitalization**: Title Case vs Sentence case applied consistently. Labels: Sentence case. Navigation titles: Title Case.
- **Punctuation consistency**: Periods on full sentences, not on labels (unless all labels use them).
- **Appropriate length**: Not too wordy, not too terse. Button labels are verbs, not nouns.

### SF Symbols and Images

- **Consistent weight and scale**: All SF Symbols on the same surface use the same `.fontWeight()` and `.imageScale()`. Mixing `.regular` and `.semibold` in the same toolbar looks unfinished. See [`sf-symbols.md`](sf-symbols.md).
- **Proper alignment**: Symbols align optically with adjacent text using `.alignmentGuide` or small offset, not raw `.padding`.
- **Alt descriptions**: All non-decorative symbols carry `.accessibilityLabel()`.
- **Retina support**: Custom image assets provide @2x and @3x in the asset catalog. Verify with `tools/asset-catalog-checker/`.

### Accessibility Label Completeness

- **All interactive controls**: Explicit `.accessibilityLabel()` and `.accessibilityHint()` where system inference is ambiguous.
- **Custom controls**: Custom `ViewModifier` that renders interactive surfaces must include `.accessibilityElement(children: .combine)` or explicit `.accessibilityLabel`.
- **Dynamic content**: Updates announced via `.accessibilityAddTraits(.updatesFrequently)` or `AccessibilityNotification.announcement`.
- **Minimum touch targets**: 44x44pt on iOS. Expand hit area with `.contentShape(Rectangle())` without expanding visual size.

```swift
Button(action: deleteItem) {
    Image(systemName: "trash")
        .imageScale(.medium)
}
.contentShape(Rectangle())
.frame(minWidth: 44, minHeight: 44)
.accessibilityLabel("Delete item")
.accessibilityHint("Removes this item permanently")
```

See [`accessibility.md`](accessibility.md) for the full accessibility audit protocol.

### Forms and Inputs

- **Label consistency**: All inputs carry `LabeledContent` or `TextField` with explicit prompt.
- **Required indicators**: Clear and consistent. Use trailing `.accessibilityLabel("required")` for screen readers.
- **Error messages**: Helpful and consistent. Appear inline adjacent to the offending field.
- **Validation timing**: Consistent: on submit unless the field has an explicit `onChange` validator.

### Edge Cases and Error States

- **Loading states**: All async actions have loading feedback. `ProgressView` for indeterminate, determinate for known progress.
- **Empty states**: `ContentUnavailableView` for iOS 17+. Helpful, not just blank space.
- **Error states**: Clear message with a recovery action. Never a dead end.
- **Long content**: Handles very long names with `.lineLimit()` or `.truncationMode()`.
- **Offline**: Appropriate offline handling where applicable. Do not silently fail.

### Responsiveness

- **All size classes**: Test compact (iPhone SE, iPhone 16, split-view iPad) and regular (iPad full, Mac).
- **Touch targets**: 44x44pt minimum on touch devices.
- **No horizontal scroll** (unless scroll is intentional and indicated).
- **Appropriate reflow**: Content adapts using `ViewThatFits` or conditional layout. See [`responsive-design.md`](responsive-design.md).

### Code Quality

- **Remove debug logging**: No `print()` statements in production views.
- **Remove commented code**: Clean up dead code blocks.
- **Remove unused imports**: Prune `import` statements not referenced.
- **No forced unwraps** in view body (use `guard let` or `if let` at call site).
- **Accessibility**: Proper `.accessibilityLabel` and `.accessibilityElement` usage.

## Edit Discipline

- **One concern per edit.** Do not rewrite a view to polish it. Touch only the lines that violate a rule.
- **Preserve working behavior.** If the view compiles before polish, it compiles after.
- **Name the rule.** Every non-obvious edit carries the reference-doc citation in a comment: `// impeccable-swift: polish.md: frame(alignment:) over magic offset`.
- **Re-read after editing.** Confirm no new violations were introduced. If an edit creates a new violation in an adjacent rule, back out and rethink.
- **Small diffs.** Prefer five two-line edits over one forty-line rewrite.

## Polish Checklist

Go through systematically:

- [ ] Visual alignment consistent at all size classes
- [ ] Spacing uses project tokens (no magic numbers)
- [ ] `.frame(alignment:)` used over magic-number offsets
- [ ] Modifier ordering verified (`.padding().background()` vs `.background().padding()`)
- [ ] Typography hierarchy consistent with `typography.md`
- [ ] All interactive states implemented (default, hover, pressed, focused, disabled, loading, error, success)
- [ ] All transitions animated at appropriate duration (150-250ms)
- [ ] Reduced motion respected via `accessibilityReduceMotion`
- [ ] Copy is consistent: terminology, capitalization, punctuation
- [ ] SF Symbols weight and scale consistent
- [ ] All non-decorative symbols have `.accessibilityLabel()`
- [ ] All interactive controls have 44x44pt minimum touch target
- [ ] Contrast ratios meet WCAG AA
- [ ] Keyboard and VoiceOver navigation verified
- [ ] No hard-coded color literals (asset catalog or system colors only)
- [ ] Dark Mode tested: no `.white` / `.black` literals
- [ ] Material tier consistent across elevation levels
- [ ] Error states have recovery paths
- [ ] Loading states present for all async actions
- [ ] Empty states use `ContentUnavailableView` or equivalent
- [ ] `tools/.swiftlint.yml` passes (unsafe padding/frame combos, `.frame(alignment:)` consistency)
- [ ] `tools/asset-catalog-checker/` passes (unused/duplicate color variants)
- [ ] No `print()` or commented-out code
- [ ] Canvas grid overlay disabled for final visual pass

**IMPORTANT**: Polish is about details. Zoom in. Squint at it. Use it yourself. The little things add up.

**NEVER**:

- Polish before it is functionally complete
- Polish without aligning to the design system; that's decoration on drift
- Guess at design system principles instead of asking when something is ambiguous
- Spend hours on polish if it ships in 30 minutes (triage)
- Introduce bugs while polishing (test thoroughly)
- Ignore systematic issues (if spacing is off everywhere, fix the system, not just one screen)
- Perfect one thing while leaving others rough (consistent quality level)
- Create new one-off components when design system equivalents exist
- Hard-code values that should reference design tokens
- Animate layout properties (`.padding`, `.frame`, `.spacing`) directly
- Introduce new patterns or flows that diverge from established ones

## Final Verification

Before marking as done:

- **Use it yourself**: Actually interact with the feature on device.
- **Test on real device**: Not just Xcode Canvas or Simulator.
- **Ask someone else to review**: Fresh eyes catch things.
- **Check all states**: Do not just test the happy path.
- **VoiceOver pass**: Navigate the entire surface with VoiceOver on.
- **Treat automation carefully**: Run `tools/.swiftlint.yml` and `tools/impeccable-lint/` when relevant, fix their defects, but never cite a clean result as proof that the work is polished.

## Clean Up

After polishing, ensure code quality:

- **Replace custom implementations**: If the design system provides a component you reimplemented, switch to the shared version.
- **Remove orphaned code**: Delete unused styles, custom `ViewModifier` types, or files made obsolete by polish.
- **Consolidate tokens**: If you introduced new values, check whether they belong in the asset catalog or a constants enum.
- **Verify DRYness**: Look for duplication introduced during polishing and consolidate.

Remember: Impeccable attention to detail and exquisite taste. Polish until it feels effortless, looks intentional, and works flawlessly. Sweat the details: they matter.
