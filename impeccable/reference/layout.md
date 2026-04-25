# Layout

Assess and improve layout and spacing that feels monotonous, crowded, or structurally weak: turning generic arrangements into intentional, rhythmic compositions.

For the foundational vocabulary (the `Space` enum, 4pt grid, 44pt tap targets, concentric corners, point vs. pixel): see [`spatial-design.md`](spatial-design.md). This doc builds on that baseline without repeating it.

---

## Register

**Brand:** asymmetric compositions, intentional grid-breaking, fluid gutters for hero sections, overlapping cards, generous negative space used as a design material. Rhythm through contrast: tight groupings paired with generous separations. See [`brand.md`](brand.md).

**Product:** predictable grids, uniform card gutters, consistent density per screen type, scannable rhythm. Consistency IS an affordance. Responsive behavior is structural (collapse sidebar, adapt column count) not decorative. See [`product.md`](product.md).

---

## Assess Current Layout

Before improving, name what is structurally weak:

1. **Spacing**: Is it consistent or arbitrary? Are related elements grouped tightly with generous space between groups, or is everything equidistant?
2. **Visual hierarchy**: Apply the squint test: blur your eyes and check whether the most important element, second most important, and groupings are still legible. Space and weight alone can be enough hierarchy.
3. **Grid and structure**: Is there a clear underlying structure, or does the layout feel random? Are identical card stacks used everywhere?
4. **Rhythm and variety**: Does the layout have a beat of tight and generous spacing? Or is every section structured identically?
5. **Density**: Does density match the content type? Data-dense utility screens need tighter spacing; onboarding surfaces and brand hero screens need more air.

**CRITICAL:** Layout problems are often the root cause of interfaces feeling "off" even when colors and fonts are correct. Space is a design material. Use it with intention.

---

## SwiftUI Layout Primitives: Choose the Right Tool

SwiftUI layout is stack-first, not grid-first. The primary axis of composition is `HStack`, `VStack`, and `ZStack`. Grid structures are the second tier, reached for when 2D coordination across rows and columns is genuinely needed.

### Stack Composition (Primary Tier)

**`VStack(alignment:spacing:)`** is the default layout primitive for vertical sequences: rows in a list, content sections on a screen, stacked cards.

**`HStack(alignment:spacing:)`** is for horizontal sequences: button groups, icon-label pairs, nav bar items, side-by-side metadata, row controls.

**`ZStack(alignment:)`** is for layering: overlaid badges, floating labels on images, card overlays. Reach for it explicitly; don't let implicit `overlay` and `background` modifiers pile up undocumented.

```swift
// Product: scannable item row with tight internal grouping
HStack(alignment: .top, spacing: Space.sm) {
    Image(systemName: "doc.text")
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())

    VStack(alignment: .leading, spacing: Space.xxs) {
        Text("Document title").font(.headline)
        Text("Modified today").font(.caption).foregroundStyle(.secondary)
    }

    Spacer()

    Image(systemName: "chevron.right")
        .foregroundStyle(.tertiary)
}
.padding(.horizontal, Space.md)
.padding(.vertical, Space.sm)
```

The `spacing:` parameter on each stack drives sibling rhythm. Use `Space` values from [`spatial-design.md`](spatial-design.md) directly rather than numeric literals. The project's `AppSpacing` typealias re-exports `Space` if one is established; otherwise `Space` is the canonical name.

### Grid (Second Tier: True 2D Layouts)

Use `Grid` (iOS 16+, macOS 13+) when rows and columns must align across cells. It gives you explicit `GridRow` control with `gridCellColumns(_:)` for spanning.

```swift
// Align labels and values across rows: Grid, not repeated HStack
Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: Space.lg, verticalSpacing: Space.sm) {
    GridRow {
        Text("Status").gridColumnAlignment(.trailing).foregroundStyle(.secondary)
        Text(item.status.label)
    }
    GridRow {
        Text("Modified").gridColumnAlignment(.trailing).foregroundStyle(.secondary)
        Text(item.modifiedDate, style: .date)
    }
    GridRow {
        Text("Owner").gridColumnAlignment(.trailing).foregroundStyle(.secondary)
        Text(item.ownerName)
    }
}
```

`Grid` is not a drop-in replacement for `VStack`-of-`HStack`. Each row in a `Grid` aligns to shared column widths across all rows. Use it for metadata tables, form-style displays, stat summaries. Don't use it for simple card content where `VStack` is clearer.

### LazyVGrid / LazyHGrid (Large Collections)

`LazyVGrid` and `LazyHGrid` are for large collections where cells must not all be instantiated up front. The `columns:` parameter takes an array of `GridItem` definitions.

```swift
let columns = [
    GridItem(.adaptive(minimum: 160, maximum: 200), spacing: Space.sm)
]

LazyVGrid(columns: columns, spacing: Space.sm) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
.padding(.horizontal, Space.md)
```

`.adaptive(minimum:maximum:)` fills available width with as many columns as fit. This is the correct responsive approach on Apple platforms, not a hardcoded column count. `.fixed(_:)` and `.flexible(_:)` are for when you need explicit column control.

**Anti-pattern:** using `LazyVGrid` with a hardcoded 2-column definition when `ViewThatFits` or `.adaptive` would adapt correctly across iPhone SE, iPad, and Mac.

### ViewThatFits (Adaptive Column Count)

`ViewThatFits` renders the first child view that fits the available space without truncation. Use it to offer a 2-column layout on wide surfaces and a single column on constrained ones.

```swift
ViewThatFits {
    // Two-column: offered first, used when space allows
    HStack(alignment: .top, spacing: Space.xl) {
        primaryColumn
        secondaryColumn
    }

    // Single column: fallback for compact horizontal space
    VStack(alignment: .leading, spacing: Space.lg) {
        primaryColumn
        secondaryColumn
    }
}
```

`ViewThatFits` does not require `@Environment(\.horizontalSizeClass)` branching. It measures layout pressure directly. Pair it with `GeometryReader` only when you need the measured value downstream; otherwise `ViewThatFits` is simpler and more correct. See [`responsive-design.md`](responsive-design.md) for size class branching when the decision must be explicit.

### NavigationSplitView (Sidebar + Detail)

`NavigationSplitView` is a layout primitive as much as a navigation one: it declares a list-detail structure that adapts to iPhone (collapsed stack), iPad (two-column or three-column), and Mac (sidebar + content + inspector). See [`navigation.md`](navigation.md) for full wiring details.

```swift
NavigationSplitView(columnVisibility: $visibility) {
    SidebarList(selection: $selectedItem)
} detail: {
    DetailView(item: selectedItem)
}
```

Don't use `HStack` to fake a sidebar-detail layout. `NavigationSplitView` handles safe areas, column sizing, collapse behavior, and keyboard navigation for free. A hand-rolled `HStack { sidebar; Divider(); detail }` is technically inferior on every Apple platform.

---

## Establish a Spacing System

Use the `Space` enum from [`spatial-design.md`](spatial-design.md) for every padding and spacing value. The valid scale: 4, 8, 12, 16, 20, 24, 32, 44, 64pt. Nothing between.

If the project defines `AppSpacing`, it should alias or extend `Space` rather than invent new values:

```swift
// Project-level alias: keeps impeccable-lint's named-scale check happy
typealias AppSpacing = Space
```

Use `spacing: Space.md` instead of `spacing: 16`. Use `.padding(.horizontal, Space.md)` instead of `.padding(.horizontal, 16)`. The names communicate intent; the numbers communicate nothing.

**Default `.padding()` is 16pt** (Space.md). That is the correct default for most content containers. Explicit `Space.md` is clearer than the implicit default because it signals the value was chosen, not defaulted into.

---

## Visual Rhythm

The 8pt baseline grid is the platform convention. The `Space` scale is 4pt-based, which gives you the fine increments needed for optical work within the 8pt rhythm: `Space.xxs` (4) and `Space.sm` (12) are the between-grid steps; they exist for optical centering, tight grouping, and typographic refinement. Not the default spacing step.

**Tight grouping:** related elements (icon and its label, a heading and its subheading, a field and its hint) sit 4-8pt apart. They form a visual unit.

**Section separation:** distinct content groups sit 24-32pt apart. The gap is generous enough that the eye reads a boundary without a divider line.

**Sparse moments:** brand surfaces and hero sections use 44-64pt gaps as punctuation: marking emphasis, giving a featured element room to breathe.

**Varied spacing within a section** is correct. Not every row needs the same gap. A card's internal content might be spaced at `Space.xxs` while cards in the grid are spaced at `Space.sm`.

**Anti-patterns:**

- Equal padding everywhere. Every-16pt feels like no decision was made.
- Random literals (13, 18, 22). They drift the layout off the grid and compound into visible misalignment. impeccable-lint catches these.
- Making all spacing the same to be "consistent." Variety creates hierarchy.

---

## Register Split: Brand vs. Product Layout

### Product Surfaces

Favor predictable, scannable rhythm. Uniform card grids, consistent gutters, familiar structure. The layout should disappear into the task.

- Prefer `LazyVGrid` with `.adaptive` columns over bespoke column geometry.
- Use consistent internal card padding: `Space.sm` or `Space.md` throughout.
- Section headers sit `Space.xl` below the preceding section's last item.
- Never nest cards inside cards. Use spacing and dividers for hierarchy within a container.
- Identical card structure (icon + heading + body, repeated) is a layout failure in product UI. Vary row types: mix full-width hero rows with compact item rows, interleave summaries with detail cells.

See [`product.md`](product.md) for the full product register stance.

### Brand Surfaces

Tolerate and actively use asymmetric, grid-breaking layouts. Overlapping cards (via `ZStack` with explicit offsets), fluid gutters, generous and varied whitespace. Rhythm through contrast, not uniformity.

- A hero section can use `offset(x:y:)` to break the column grid intentionally. Document the optical intent with a comment.
- Asymmetric horizontal padding is correct when the layout calls for it: left-heavy compositions feel more designed than centered ones.
- `Space.huge` (64pt) gaps between hero sections create the luxury whitespace that distinguishes brand from product.
- Overlapping elements use `ZStack` with explicit `alignment:` and `offset(x:y:)`. Not magic `.padding` values. Document the z-ordering.

```swift
// Brand: intentional offset for editorial hierarchy
ZStack(alignment: .bottomLeading) {
    HeroImageView()
        .frame(maxWidth: .infinity)

    VStack(alignment: .leading, spacing: Space.xs) {
        Text(article.category).font(.caption).foregroundStyle(.secondary)
        Text(article.headline).font(.title2).bold()
    }
    .padding(Space.md)
    .offset(y: Space.xl)  // optical: caption drops below image boundary
}
```

See [`brand.md`](brand.md) for the full brand register stance.

---

## Depth and Layering

Elevation reinforces hierarchy. Use materials from [`materials.md`](materials.md) for surfaces that float above content. Glass is the iOS 26+ vocabulary for elevated UI. Reserve `ZStack` layering for:

- Floating controls over content (pair with `.glassEffect()`)
- Overlay badges and status indicators
- Hero image treatments with editorial text overlay

Do not use arbitrary `shadow(radius:)` values to fake elevation. The shadow scale from [`spatial-design.md`](spatial-design.md) applies: subtle by default, explicit when earned.

---

## Inspect and Debug

### Xcode Layout Tools

Use the **Xcode Layout Inspector** (Debug > View Hierarchy, or the cube icon during a simulator run) to see the resolved frame of every view. This is the correct tool for diagnosing unexpected expansion, clipping, or misalignment. Not trial-and-error padding adjustments.

The **View Hierarchy debugger** shows 3D layer separation, which makes ZStack depth and material layering visible.

### Border Debug Pattern

The `.border(Color.red)` pattern is the fastest local diagnostic for unexpected frame expansion:

```swift
// Temporary: remove before commit
HStack(spacing: Space.sm) {
    leadingContent
    trailingContent
}
.border(Color.red)   // reveals true frame extent
.border(Color.blue)  // add on parent to see relationship
```

Stack borders outward from the suspect view. An HStack that expands past its parent's edge is usually missing a `Spacer()` constraint or has a `.frame(maxWidth: .infinity)` on an unintended child.

---

## Detector Wiring

**`tools/.swiftlint.yml`** flags hardcoded spacing values via the `hardcoded_spacing_literals` custom rule: numeric literals used directly in `.padding(_:)` and `.frame(width:height:)` that are not drawn from a named token enum. Every hit is a layout finding recommending migration to `Space` or `AppSpacing`.

```bash
swiftlint lint --config tools/.swiftlint.yml --reporter json
```

**`tools/impeccable-lint`** catches the same pattern at the SwiftSyntax level: numeric literals in `.padding(_:)`, `.frame(width:)`, `.frame(height:)`, and `spacing:` arguments. Run:

```bash
swift run --package-path tools/impeccable-lint impeccable-lint <TargetDirectory>
```

Both detectors produce JSON output. Paste hits into the audit report under the **Responsive Design** dimension (spacing scale drift) or **Theming** dimension (magic sizing constants). See [`audit.md`](audit.md) for the full detector integration flow.

---

## Verify Layout Improvements

- **Squint test:** primary element, secondary content, and groupings legible with blurred vision?
- **Rhythm:** a satisfying beat of tight and generous spacing, not uniform?
- **Hierarchy:** most important content obvious within 2 seconds?
- **Breathing room:** comfortable, not cramped or wasteful?
- **Scale compliance:** every padding and spacing value from the `Space` enum, no arbitrary literals?
- **Responsiveness:** layout adapts correctly with `ViewThatFits`, `.adaptive` grid columns, or size class branching?
- **Register correct:** brand surfaces are asymmetric and intentional; product surfaces are predictable and scannable?

**NEVER:**

- Use numeric literals for spacing or padding. `spacing: 16` fails the detector; `spacing: Space.md` passes.
- Make all spacing equal. Variety creates hierarchy.
- Wrap everything in cards. Not everything needs a container.
- Nest cards inside cards. Use spacing and dividers for internal hierarchy.
- Default to identical card grids everywhere (icon + heading + text, repeated). That's a layout failure.
- Center everything. Left-aligned with asymmetry feels more designed.
- Use `HStack` to fake `NavigationSplitView` when the content is list-detail.
- Use `LazyVGrid` with a hardcoded column count when `.adaptive` would adapt correctly.
