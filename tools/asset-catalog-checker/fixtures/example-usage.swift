import SwiftUI

// Fixture file exercised by check.swift.
// The `gear` image reference below should be flagged (SF Symbol
// `gearshape` exists). The `custom-illustration` reference must not be
// flagged — it has no SF Symbol match and is a legitimate custom asset.

struct ExampleUsage: View {
    var body: some View {
        VStack {
            Image("gear")
            Image("custom-illustration")
        }
    }
}
