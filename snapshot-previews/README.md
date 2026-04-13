# SnapshotPreviews convention

This folder documents how `impeccable-swift` expects SwiftUI previews and snapshot tests to be wired up in the projects it reviews. It is a convention, not a library — nothing here is imported; these are the rules a project should follow so the critique/polish/audit skills can do their best work.

## What SnapshotPreviews is

[EmergeTools/SnapshotPreviews](https://github.com/EmergeTools/SnapshotPreviews) is a Swift package that auto-renders every `#Preview` macro declared in a test target into PNG snapshots. You write `#Preview` blocks as you normally would for Xcode previews, add SnapshotPreviews as a test dependency, and the next `swift test` run produces PNGs for every preview in the suite.

In impeccable-swift, SnapshotPreviews powers the visual half of the review loop. Code-level checks (SwiftLint, the asset-catalog checker, `critique`) read your source; SnapshotPreviews gives the same review pipeline something to _look_ at — a concrete rendered image of every state, theme, and size class the view declares.

**Version pin.** v1 of impeccable-swift targets **SnapshotPreviews v0.11+**. Later releases probably work, but verify against Emerge's release notes when upgrading. If the package's `.previewVariants` API changes shape, the conventions on this page may need a bump.

## The convention

Every SwiftUI view that ships in the app must have at least one `#Preview`. At minimum, cover:

- **Default state** — what the view looks like once loaded with representative data.
- **Empty state** — if the view can be empty (list, search results, inbox), cover it.
- **Loading state** — if the view has a loading phase, cover it.
- **Error state** — if the view can fail, cover it.

Each preview should use `PreviewVariants` so the snapshot renderer sweeps through the useful axes of variation for free:

```swift
#Preview("Default", traits: .previewVariants) {
    ProfileScreen(user: .mock)
}
```

`PreviewVariants` gives you dark mode, right-to-left, Dynamic Type, and landscape coverage in one trait. Use it as the default; drop it only when a specific preview is intentionally narrow (e.g., a dark-mode-only illustration).

## Per-platform test targets

SnapshotPreviews renders previews inside the test target that imports it. Because Xcode does not let a single test target span platforms, **each platform your app ships on needs its own test target**:

- `iOSSnapshotTests` — iPhone idioms.
- `iPadSnapshotTests` — iPad idioms (required even if the app is universal; the idiom context differs).
- `macOSSnapshotTests` — macOS idioms. **This is the one people forget.** If your app is Mac Catalyst or native macOS and you only set up an iOS snapshot target, none of your macOS-specific layouts are being snapshotted.

The `example-setup.md` file next to this one has the copy-pasteable `Package.swift` additions for all three.

## Integration with impeccable-swift

The critique skill looks for a `SnapshotPreviews` test bundle in the project when it runs. If it finds one:

1. It reads the generated PNG directory (see `example-setup.md` for the path).
2. It checks whether each shipped view has previews covering default, empty, loading, and error states (where relevant).
3. It looks for `PreviewVariants` coverage — a view with only a default-light-mode preview gets flagged.
4. It feeds the PNGs into its visual-variant analysis.

If SnapshotPreviews is not set up, critique falls back to code-only analysis and reports the gap in its output. You can still ship without SnapshotPreviews — the skill will just tell you, on every run, that you are missing half the review signal.

## See also

- `example-setup.md` in this folder — copy-pasteable `Package.swift` additions, target definitions, and a minimal working `#Preview`.
- [EmergeTools/SnapshotPreviews](https://github.com/EmergeTools/SnapshotPreviews) — upstream docs.
- [Emerge's GitHub Action](https://github.com/EmergeTools/SnapshotPreviews) — for CI integration, which is deferred out of v1 (each project decides).
