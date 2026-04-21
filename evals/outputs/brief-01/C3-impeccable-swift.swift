// C3 — impeccable-swift
// Condition: the fork's impeccable-swift + critique skills loaded.
// Expect: native Swift idioms — Form/List insetGrouped, Label with SF Symbols,
// @ScaledMetric for Dynamic Type-aware sizing, Material backgrounds (Liquid Glass on iOS 26+),
// role: .destructive + .buttonStyle(.borderedProminent), .continuous corner radius,
// semantic colors / Asset Catalog only, .accessibilityLabel on icon controls,
// #Preview variants (light/dark, Dynamic Type).

import SwiftUI

struct Brief01_C3: View {
    @State private var notifications: Bool = true
    @State private var darkMode: Bool = false
    @State private var sound: Bool = true
    @State private var showLogoutConfirmation: Bool = false

    @ScaledMetric(relativeTo: .body) private var rowVerticalPadding: CGFloat = 4
    @ScaledMetric(relativeTo: .title3) private var sectionSpacing: CGFloat = 8

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $notifications) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    Toggle(isOn: $darkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    Toggle(isOn: $sound) {
                        Label("Sound", systemImage: "speaker.wave.2.fill")
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Changes apply immediately.")
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityLabel("Log out of your account")
                    .accessibilityHint("Signs you out and returns to the welcome screen")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .confirmationDialog(
                "Log out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log out", role: .destructive) {}
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can sign back in anytime.")
            }
        }
    }
}

#Preview("Light") {
    Brief01_C3()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    Brief01_C3()
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    Brief01_C3()
        .environment(\.dynamicTypeSize, .accessibility2)
}
