// SwiftLintFixtures.swift — impeccable-swift intentional-violations fixture.
//
// NOT MEANT TO COMPILE. This file is lint-input only. SwiftLint's custom_rules
// match content via regex, so the intentional `UIColor(...)` call does not need
// a working import to produce its violation. The `#if canImport(UIKit)` guard
// below quiets Xcode's SourceKit red squiggles for humans browsing the file.
//
// Purpose: documentation-as-code. Every line labeled `// VIOLATION: <rule>`
// should produce exactly one violation of the named custom rule when
// `swiftlint lint --config ../.swiftlint.yml` runs against this file.
// Every line labeled `// OK: ...` is a clean counterexample and should
// produce zero violations.
//
// This file is listed in `excluded:` of the shipping config because
// otherwise every `included:` scan in a downstream project would flag
// these intentional violations. Verification runs pass the file as a
// positional argument, which bypasses `excluded:` for explicit inputs.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Violations

struct FixtureViolations: View {
    @State private var flag = false

    var body: some View {
        VStack {
            // Typography
            Text("hello")
                .font(.system(size: 15)) // VIOLATION: no_fixed_system_font_size

            // Color — SwiftUI
            Text("hex")
                .foregroundColor(Color(red: 0.8, green: 0.5, blue: 0.2)) // VIOLATION: no_hardcoded_hex_color

            Text("literal")
                .foregroundColor(.blue) // VIOLATION: no_literal_system_color

            // Color — UIKit/AppKit
            Text("uikit").background(makeUIColorBackground()) // helper below

            // Spacing
            Text("padding")
                .padding(13) // VIOLATION: no_magic_spacing_padding

            Text("frame")
                .frame(width: 37, height: 24) // VIOLATION: no_magic_spacing_frame

            // Corner
            RoundedRectangle(cornerRadius: 12) // VIOLATION: continuous_corner_required
                .frame(width: 64, height: 64)

            // Material misuse (line-regex tier doesn't own this; AST tier does).

            // SF Symbols
            Image(systemName: "star.fill").frame(width: 24, height: 24) // VIOLATION: no_framed_sf_symbol

            Image("icon.png") // VIOLATION: prefer_sf_symbols_comment

            // Debug leak
            Button("log") {
                print("tapped") // VIOLATION: no_print_in_production
            }
        }
    }

    // Using a helper keeps the VIOLATION marker on the right line.
    func makeUIColorBackground() -> Color {
        _ = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1) // VIOLATION: no_uikit_nskit_color_literal
        return Color.clear
    }
}

// MARK: - Clean counterexamples

struct FixtureClean: View {
    @ScaledMetric private var iconSize: CGFloat = 20

    var body: some View {
        VStack {
            Text("semantic type")
                .font(.body) // OK: uses semantic Dynamic Type style

            Text("semantic color")
                .foregroundColor(.primary) // OK: semantic system color, not a literal palette entry

            Text("on-scale spacing")
                .padding(16) // OK: on the 4pt scale

            Text("on-scale frame")
                .frame(width: 44, height: 44) // OK: on-scale (Apple HIG min tap target)

            RoundedRectangle(cornerRadius: 12, style: .continuous) // OK: continuous corner style present
                .frame(width: 64, height: 64)

            Image(systemName: "star.fill")
                .font(.title2) // OK: SF Symbol sized via .font(), not .frame()

            Image("logo-vector") // OK: not a .png/.jpg literal — could be a PDF/SVG asset

            Color(.label) // OK: Asset Catalog / UIColor semantic initializer, no red:/hex:
        }
    }
}
