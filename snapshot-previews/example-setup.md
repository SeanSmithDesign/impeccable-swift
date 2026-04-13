# SnapshotPreviews — example setup

A complete, copy-pasteable setup for wiring EmergeTools/SnapshotPreviews v0.11 into a Swift package. If your project is an Xcode project (not a `Package.swift`), the broad strokes are the same but the target wiring happens in the project inspector — see Emerge's docs for the project-file dance. Everything below assumes a Swift package.

## 1. Add SnapshotPreviews to your package

In your `Package.swift`, add the dependency:

```swift
dependencies: [
    .package(
        url: "https://github.com/EmergeTools/SnapshotPreviews",
        from: "0.11.0"
    ),
    // ...your other dependencies
],
```

Then add the product to each snapshot test target's `dependencies` list (see next section).

## 2. Create per-platform test targets

Each platform needs its own test target. This is an Xcode constraint, not an Emerge one. Paste into your `Package.swift` `targets:` array:

```swift
.testTarget(
    name: "iOSSnapshotTests",
    dependencies: [
        "YourAppModule",
        .product(name: "SnapshottingTests", package: "SnapshotPreviews"),
    ],
    path: "Tests/iOSSnapshotTests"
),
.testTarget(
    name: "iPadSnapshotTests",
    dependencies: [
        "YourAppModule",
        .product(name: "SnapshottingTests", package: "SnapshotPreviews"),
    ],
    path: "Tests/iPadSnapshotTests"
),
.testTarget(
    name: "macOSSnapshotTests",
    dependencies: [
        "YourAppModule",
        .product(name: "SnapshottingTests", package: "SnapshotPreviews"),
    ],
    path: "Tests/macOSSnapshotTests"
),
```

Replace `YourAppModule` with whatever library target contains your views.

> **Xcode-project users:** the package step is the same (add SnapshotPreviews via Swift Package Manager in the project inspector). The three test targets must be created manually in the project — File ▸ New ▸ Target ▸ _Unit Testing Bundle_, one per destination platform. Set the destination on each target's _General_ tab. Emerge's README has screenshots.

## 3. Write a snapshot test

In each test target create a single file — e.g. `Tests/iOSSnapshotTests/SnapshotPreviewsTests.swift`:

```swift
import XCTest
import SnapshottingTests

final class SnapshotPreviewsTests: PreviewTest {
    override func getPreviewFactories() -> [any PreviewFactory.Type] {
        // SnapshotPreviews auto-discovers #Preview macros in the app target.
        // Leave this empty to snapshot every preview; return a subset to narrow.
        []
    }
}
```

That one subclass is enough. SnapshotPreviews walks every `#Preview` it can see from this test target and produces a PNG per preview, per variant.

## 4. Write a `#Preview` with `PreviewVariants`

In any view file in your app module:

```swift
import SwiftUI
import SnapshotPreviewsCore  // for the `.previewVariants` trait

struct SettingsScreen: View {
    var body: some View {
        // ...
    }
}

#Preview("Settings", traits: .previewVariants) {
    SettingsScreen(/* mock state */)
}

#Preview("Settings — empty", traits: .previewVariants) {
    SettingsScreen(/* empty-state mock */)
}

#Preview("Settings — error", traits: .previewVariants) {
    SettingsScreen(/* error-state mock */)
}
```

`.previewVariants` sweeps light/dark, left-to-right/right-to-left, Dynamic Type sizes, and landscape in one trait. That's the default — drop it only when a preview is intentionally narrow.

## 5. Run the snapshots

From the package root:

```sh
swift test --filter SnapshotPreviewsTests
```

Or select any of the three snapshot test targets in Xcode's Test Explorer and run it. SnapshotPreviews drops the generated PNGs into the test bundle's output directory:

```
<DerivedData>/<YourProject>-<hash>/Build/Products/Debug/<TestBundle>.xctest/Contents/Resources/Snapshots/
```

On CI the exact path depends on your runner's `DerivedData` location, but the structure (a `Snapshots/` folder inside the `.xctest` bundle) is stable.

## 6. CI integration (deferred)

v1 of impeccable-swift does not prescribe a CI setup. Each project decides whether to run snapshots on every PR, nightly, or only locally. When you are ready, Emerge ships a [GitHub Action](https://github.com/EmergeTools/SnapshotPreviews) that runs the test target and diffs the PNGs against a baseline.

A few project-level decisions worth making before you wire CI up:

- **Where do baselines live?** In-repo as committed PNGs, or in an S3/Emerge-hosted artifact store.
- **Which platforms block a PR?** Usually iOS always; iPad/macOS depending on whether the app actually ships on them.
- **Review workflow for diffs.** If your team is small, a GitHub check that posts the diff images inline is usually enough.

Defer all of that to each project's own CI doc — impeccable-swift's job is to tell you what's worth snapshotting, not how to host the results.
