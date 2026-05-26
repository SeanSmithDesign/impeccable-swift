# distill

Strip a SwiftUI interface to its essence. Remove anything that doesn't earn its place: redundant elements, repeated information, decorative noise, cosmetic complexity.

---

## Assess Current State

Analyze what makes the interface feel complex or cluttered:

1. **Identify complexity sources**:
   - **Too many elements**: Competing buttons, redundant information, visual clutter
   - **Excessive variation**: Too many colors, fonts, sizes, styles without purpose
   - **Information overload**: Everything visible at once, no progressive disclosure
   - **Visual noise**: Unnecessary borders, shadows, backgrounds, decorations
   - **Confusing hierarchy**: Unclear what matters most
   - **Feature creep**: Too many options, actions, or paths forward

2. **Find the essence**:
   - What's the primary user goal? (There should be ONE)
   - What's actually necessary vs nice-to-have?
   - What can be removed, hidden, or combined?
   - What's the 20% that delivers 80% of value?

If any of these are unclear from the codebase, stop and call the AskUserQuestion tool to clarify.

Simplicity is not about removing features. It's about removing obstacles between users and their goals. Every element must justify its existence.

## Plan Simplification

Create a ruthless editing strategy:

- **Core purpose**: What's the ONE thing this should accomplish?
- **Essential elements**: What's truly necessary to achieve that purpose?
- **Progressive disclosure**: What can be hidden until needed?
- **Consolidation opportunities**: What can be combined or integrated?

Simplification is hard. It requires saying no to good ideas to make room for great execution. Be ruthless.

## Simplify the Design

Systematically remove complexity across these dimensions:

### Information Architecture

- **Reduce scope**: Remove secondary actions, optional features, redundant information
- **Progressive disclosure**: Hide complexity behind clear entry points (`DisclosureGroup`, sheets, step-through flows)
- **Combine related actions**: Merge similar buttons, consolidate forms, group related content
- **Clear hierarchy**: ONE primary action, few secondary actions, everything else tertiary or hidden
- **Remove redundancy**: If it's said elsewhere, don't repeat it here

### Visual Simplification

- **Reduce color palette**: Use 1-2 colors plus neutrals, not 5-7 colors
- **Limit typography**: One font family, 3-4 sizes maximum, 2-3 weights
- **Remove decorations**: Eliminate borders, shadows, backgrounds that don't serve hierarchy or function
- **Flatten structure**: Reduce nesting, remove unnecessary containers; never nest cards inside cards
- **Remove unnecessary cards**: Cards aren't needed for basic layout; use spacing and alignment instead
- **Consistent spacing**: Use one spacing scale, remove arbitrary gaps
- **Reduce visual weight via materials**: Prefer `.ultraThinMaterial` and system fills over heavy backgrounds; see [`materials.md`](materials.md)

### Layout Simplification

- **Linear flow**: Replace complex grids with simple `VStack` where possible
- **Remove sidebars**: Move secondary content inline or behind a sheet
- **Full-width**: Use available space generously instead of complex multi-column layouts
- **Consistent alignment**: Pick leading or center; stick with it
- **Generous white space**: Let content breathe, don't pack everything tight

### Interaction Simplification

- **Reduce choices**: Fewer buttons, fewer options, clearer path forward (paradox of choice is real)
- **Smart defaults**: Make common choices automatic; only ask when necessary
- **Inline actions**: Replace modal flows with inline editing where possible
- **Remove steps**: Can sign-up be one step instead of three? Can the flow be simplified?
- **Clear CTAs**: ONE obvious next step, not five competing actions
- **Flatten navigation depth**: Collapse deeply nested stacks; see [`navigation.md`](navigation.md)

### Content Simplification

- **Shorter copy**: Cut every sentence in half, then do it again
- **Active voice**: "Save changes" not "Changes will be saved"
- **Remove jargon**: Plain language always wins
- **Scannable structure**: Short paragraphs, bullet points, clear headings
- **Essential information only**: Remove marketing fluff, legalese, hedging
- **Remove redundant copy**: No headers restating intros, no repeated explanations, say it once

### Code Simplification

- **Remove unused code**: Dead modifiers, unused views, orphaned files
- **Flatten view trees**: Reduce nesting depth; prefer `@ViewBuilder` functions over deeply nested `if`/`else` blocks
- **Consolidate styles**: Merge similar modifiers, use `ViewModifier` conformances consistently
- **Reduce variants**: Does that component need 12 variations, or can 3 cover 90% of cases?
- **Trim modifier chains**: A chain of 8 modifiers on one `Text` is almost always a sign that responsibilities need redistributing

**NEVER**:

- Remove necessary functionality (simplicity is not feature-less)
- Sacrifice accessibility for simplicity (clear labels and accessibility traits still required)
- Make things so simple they're unclear (mystery is not minimalism)
- Remove information users need to make decisions
- Eliminate hierarchy completely (some things should stand out)
- Oversimplify complex domains (match complexity to actual task complexity)

## SwiftUI Examples

**Before: bloated modifier chain**

```swift
Text(item.title)
    .font(.system(size: 16, weight: .semibold, design: .default))
    .foregroundColor(Color(uiColor: .label))
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color(uiColor: .secondarySystemBackground))
    .cornerRadius(8)
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
```

**After: distilled**

```swift
Text(item.title)
    .font(.headline)
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(.secondarySystemBackground, in: .rect(cornerRadius: 8))
```

---

**Before: nested Groups and redundant if/else**

```swift
Group {
    if showHeader {
        Group {
            if isAdmin {
                AdminHeaderView()
            } else {
                StandardHeaderView()
            }
        }
    }
}
```

**After: @ViewBuilder function**

```swift
@ViewBuilder
private var header: some View {
    if showHeader {
        if isAdmin { AdminHeaderView() } else { StandardHeaderView() }
    }
}
```

---

**Before: nested cards adding visual weight**

```swift
VStack {
    RoundedRectangle(cornerRadius: 16)
        .fill(.background)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .fill(.secondarySystemBackground)
                .overlay(content)
                .padding(8)
        )
        .padding(16)
}
```

**After: spacing and alignment alone**

```swift
content
    .padding(16)
```

## Verify Simplification

Ensure simplification improves usability:

- **Faster task completion**: Can users accomplish goals more quickly?
- **Reduced cognitive load**: Is it easier to understand what to do?
- **Still complete**: Are all necessary features still accessible?
- **Clearer hierarchy**: Is it obvious what matters most?
- **Better performance**: Does simpler view composition reduce layout passes?

## Document Removed Complexity

If you removed features or options:

- Document why they were removed
- Consider if they need alternative access points
- Note any user feedback to monitor

As Antoine de Saint-Exupery wrote: "Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away."
