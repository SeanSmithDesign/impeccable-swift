# Extract

Identify reusable patterns, components, and design tokens, then extract and consolidate them into the design system for systematic reuse.

## Step 1: Discover the Design System

Find the shared UI layer: a `Components/` folder, a local Swift package, or a `Theme/` directory. Understand how it is structured: naming conventions, import strategy, how tokens are declared (enums, extensions, constants).

**CRITICAL**: If no design system exists, STOP and call the AskUserQuestion tool to clarify before creating one. Understand the preferred location and structure first: a `Theme/` folder inside the app target is common for smaller projects; a separate Swift package is the right call when the codebase grows beyond a single target.

## Step 2: Run the Detector

Before scanning manually, run `tools/impeccable-lint/` to surface extraction candidates automatically. Its SwiftSyntax pass flags:

```bash
swift run --package-path tools/impeccable-lint impeccable-lint <TargetDirectory>
```

**Candidates impeccable-lint flags:**

- **Repeated `ZStack(alignment:)` patterns**: Card-like structs appearing 3+ times with the same alignment axis. Candidates for a shared `CardView`.
- **Shadow + background combos**: `.shadow(color:radius:x:y:)` paired with `.background(.regularMaterial)` or a color literal, duplicated across files. Candidate for a `ShadowedSurface` modifier.
- **Hardcoded `Color` literals**: `Color(red:green:blue:)`, `Color(hex:)`, or `Color.rgb(...)` outside Asset Catalog Color Sets. Every hit is a theming candidate; severity P1 on user-visible surfaces.
- **Duplicate `ViewModifier` logic**: Identical or near-identical `body` implementations across separate `ViewModifier` conformances. Candidates for consolidation into a single modifier type.
- **Repeated `.frame()` + `.padding()` chains**: The same `(.frame(maxWidth: .infinity).padding(.horizontal, 16))` chain in 3+ places. Candidate for a layout modifier.

Treat every detector hit as a pre-confirmed finding. Do not re-verify by eye; jump straight to Step 3.

## Step 3: Identify Patterns Manually

Supplement detector output with a manual pass. Look for extraction opportunities the static analyzer cannot see:

- **Repeated `@State` boilerplate**: Multiple views each redeclaring `@State private var isExpanded = false` or the same toggle/binding pattern. Candidate for a shared `DisclosureState` or a generic `ToggleState` wrapper.
- **View composition patterns**: Recurring `HStack` + `VStack` arrangements (form rows, toolbar groups, empty states) with no meaningful variation. Candidates for a parameterized view type.
- **Custom `ViewModifier` duplicates**: The same modifier logic (for example, an `if` branch on `colorScheme` to pick a stroke color) copied across files. Merge into one named modifier.
- **Hardcoded `Font.custom(...)` invocations**: `Font.custom("SomeName-Regular", size: 17)` repeated outside a font extension. Candidate for a `Font` extension in `Theme/`.
- **Hardcoded `Color(hex:)` literals**: Color values not yet in the Asset Catalog. Candidate for a Color Set with dark-appearance variant.

**Assess value before extracting.** Only extract things used 3+ times with the same intent. Premature abstraction is worse than duplication.

## Step 4: Plan Extraction

Create a systematic plan before touching code:

- **Components to extract**: Which UI elements become a shared `View` type?
- **Modifiers to consolidate**: Which `ViewModifier` bodies collapse into one?
- **Tokens to promote**: Which literals become Color Sets, Font extensions, or spacing constants?
- **Naming conventions**: Match existing patterns in `Components/`, `Modifiers/`, `Theme/`.
- **Migration path**: Which call sites need updating after each extraction?

**IMPORTANT**: Design systems grow incrementally. Extract what is clearly reusable now, not everything that might someday be reusable.

## Step 5: Extract and Enrich

Build improved, reusable versions for each candidate category.

### Components

Extract repeated View compositions into named `View` types in `Components/`:

```swift
// Before: duplicated card pattern across 4 files
ZStack(alignment: .bottomLeading) {
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(.regularMaterial)
    content
}
.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

// After: Components/CardView.swift
struct CardView<Content: View>: View {
    var cornerRadius: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.regularMaterial)
            content()
        }
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
```

See [`materials.md`](materials.md) for surface-hierarchy guidance before hardcoding `.regularMaterial`.

### ViewModifiers

Consolidate duplicate modifier logic into named `ViewModifier` types in `Modifiers/`:

```swift
// Before: same stroke logic copied across 3 files
.overlay(
    RoundedRectangle(cornerRadius: 12, style: .continuous)
        .strokeBorder(.quaternary, lineWidth: 0.5)
)

// After: Modifiers/SubtleBorderModifier.swift
struct SubtleBorder: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        )
    }
}

extension View {
    func subtleBorder(cornerRadius: CGFloat = 12) -> some View {
        modifier(SubtleBorder(cornerRadius: cornerRadius))
    }
}
```

### Design Tokens

**Font extension:** Replace `Font.custom("Name-Regular", size: 17)` call sites with a `Font` extension in `Theme/Fonts.swift`:

```swift
extension Font {
    static let brandBody: Font = .custom("BrandName-Regular", size: 17)
        .leading(.standard)
}
```

**Color promotion:** Replace `Color(hex:)` literals with Asset Catalog Color Sets. Add both "Any Appearance" and "Dark Appearance" swatches; asset-catalog-checker flags missing dark variants. Reference the Color Set by name:

```swift
// Theme/Colors.swift
extension Color {
    static let surfaceElevated = Color("SurfaceElevated")
    static let labelSecondary  = Color("LabelSecondary")
}
```

**Spacing constants:** Replace repeated numeric padding/frame literals with a named token enum in `Theme/Spacing.swift`:

```swift
enum AppSpacing {
    static let xs: CGFloat  =  4
    static let sm: CGFloat  =  8
    static let md: CGFloat  = 16
    static let lg: CGFloat  = 24
    static let xl: CGFloat  = 32
}
```

## Step 6: Migrate

Replace existing uses with the new shared versions:

- **Find all instances**: Use `grep` or Xcode's global search to find the patterns you extracted.
- **Replace systematically**: Update each call site to consume the shared version.
- **Test thoroughly**: Ensure visual and functional parity: previews, snapshot tests if they exist, and a manual pass on device.
- **Delete dead code**: Remove the old inline implementations once all call sites are migrated.

## Step 7: Document

Update design system documentation:

- Add new components and modifiers to any component catalog or Storybook equivalent.
- Document token semantics: when to use `surfaceElevated` vs. `.regularMaterial`.
- Add examples and usage guidelines inline (doc comments on the type are sufficient; a separate doc is optional).

---

**Never:**

- Extract one-off, context-specific views without generalizing them.
- Create components so generic they require 10 parameters to be useful.
- Extract without respecting existing naming conventions in `Components/`, `Modifiers/`, `Theme/`.
- Skip Dark Appearance swatches when promoting Color literals to Color Sets.
- Create a token for every single value: tokens carry semantic meaning, not just numeric identity.
- Extract things that differ in intent: two card layouts that look alike but serve different purposes should stay separate.

Remember: a good design system is a living system. Extract patterns as they emerge, enrich them thoughtfully, and maintain them consistently.
