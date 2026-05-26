# live

The upstream `live` sub-command is an interactive, browser-based variant generator: select an element in the running browser dev server, pick a design action (bolder, distill, colorize, etc.), and receive AI-generated HTML+CSS variants hot-swapped via HMR without a page reload.

**The Swift fork does not port this workflow.** SwiftUI variants are declared as `#Preview` blocks and cycled in Xcode Canvas, not injected over a live HTTP connection. The 7 browser `.mjs` runtime scripts are not ported; there is no element picker.

This file exists for sub-command parity and documents the native equivalent.

---

## Native Variant Surface: Xcode Previews

Xcode Canvas with `#Preview` (Xcode 15+) is the variant-cycling surface for SwiftUI. Declare multiple preview blocks in the same file; Xcode Canvas shows them in a grid.

### Basic variant grid

```swift
#Preview("Light") {
    ContentCard(item: .mock)
        .environment(\.colorScheme, .light)
}

#Preview("Dark") {
    ContentCard(item: .mock)
        .environment(\.colorScheme, .dark)
}

#Preview("Large Text", traits: .dynamicTypeSize(.accessibility5)) {
    ContentCard(item: .mock)
}
```

Use Canvas Grid mode (the grid icon in the Canvas toolbar) to see all three side by side without switching.

### Trait-based variants (iOS 17+)

Pass traits to `#Preview` directly:

```swift
#Preview("Light", traits: .colorScheme(.light)) {
    SettingsRow(label: "Notifications", value: "On")
}

#Preview("Dark", traits: .colorScheme(.dark)) {
    SettingsRow(label: "Notifications", value: "On")
}

#Preview("AX5 Type", traits: .dynamicTypeSize(.accessibility5)) {
    SettingsRow(label: "Notifications", value: "On")
}
```

### PreviewVariants (SnapshotPreviews)

For a single preview that sweeps all meaningful axes at once, use `.previewVariants` from the SnapshotPreviews package:

```swift
import SnapshotPreviewsCore

#Preview("SettingsRow", traits: .previewVariants) {
    SettingsRow(label: "Notifications", value: "On")
}
```

`.previewVariants` covers light/dark, LTR/RTL, Dynamic Type sizes, and landscape in one trait. This is the recommended default for any view you want thorough visual coverage on.

### Interactive Canvas mode

In Xcode Canvas, toggle the **Live** button (play icon) to enter interactive mode. Tap, drag, and scroll inside the preview without rebuilding. Use it to verify gesture recognizers, scroll momentum, swipe actions, and animation timing. It is not a design-picker like upstream's browser element selector, but it lets you explore states hands-on without launching a simulator.

---

## SnapshotPreviews Convention

The `snapshot-previews/` directory at the project root documents how `impeccable-swift` expects previews to be wired for visual regression review.

Key conventions:

- Every shipped view needs at least one `#Preview` covering default, empty, loading, and error states.
- Each test target (`iOSSnapshotTests`, `iPadSnapshotTests`, `macOSSnapshotTests`) runs `swift test --filter SnapshotPreviewsTests` to produce PNG snapshots.
- The critique skill reads those PNGs when it finds a SnapshotPreviews bundle; without it, analysis is code-only and the gap is reported.

See [`snapshot-previews/README.md`](../../snapshot-previews/README.md) for the convention spec and [`snapshot-previews/example-setup.md`](../../snapshot-previews/example-setup.md) for copy-pasteable `Package.swift` additions.

---

## Inspection Analog: View Debugger

The closest equivalent to upstream's browser element picker is **Xcode View Debugger**.

In a running app or simulator session: Debug ▸ View Debugging ▸ Capture View Hierarchy. This gives you a 3D exploded view of the live view tree: layer ordering, clipping regions, frame values, and constraint conflicts. Unlike upstream's picker, it requires an active simulator or device session, not a static preview.

For most design-iteration work, Canvas interactive mode is sufficient. Reach for the View Debugger when the visual output differs from what the code implies or when layer ordering is ambiguous.

---

## Out of Scope

The following upstream features are explicitly not ported. Do not implement them in v0.2.0.

- **Browser-style element picker**: No SwiftUI equivalent is ergonomic enough to ship. The View Debugger is the closest analog but is a different interaction model.
- **HMR variant injection**: Xcode Previews recompile on source change is the substitute. There is no hot-swap without recompile in SwiftUI.
- **Hosted runtime .mjs scripts**: `live-server.mjs`, `element-picker.mjs`, and the five supporting modules are not ported. A separate Mac or iOS app could offer something similar, but that is out of scope for v0.2.0.

---

## Composition with Other Sub-commands

`live` is intended to run alongside other sub-commands: apply a command (e.g., `/impeccable bolder`, `/impeccable colorize`) then iterate variants in Canvas to validate the change holds across light/dark, Dynamic Type, and layout sizes.

Suggested workflow:

1. Run a sub-command such as [`bolder.md`](bolder.md) or [`distill.md`](distill.md) to apply a targeted change.
2. Open the affected views in Xcode Canvas.
3. Cycle through `#Preview` blocks for light, dark, and AX5 Dynamic Type.
4. Toggle Canvas interactive mode to verify gesture and animation behavior.
5. Run `swift test --filter SnapshotPreviewsTests` if the change is significant enough to warrant a snapshot diff.
