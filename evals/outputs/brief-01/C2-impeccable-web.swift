// C2 — impeccable (web)
// Condition: upstream web impeccable skill loaded, asked to produce SwiftUI.
// Expect: design-quality principles applied (hierarchy, spacing rhythm, tokens)
// but with web-centric instincts — pixel units, opacity stacks instead of Material,
// no Dynamic Type / @ScaledMetric, ratio-based rather than 4pt-grid spacing.

import SwiftUI

struct Brief01_C2: View {
    @State private var notifications: Bool = true
    @State private var darkMode: Bool = false
    @State private var sound: Bool = true

    // Web-ish design tokens (hex -> Color, pixel-valued spacing scale)
    private let bg = Color(red: 0.98, green: 0.98, blue: 0.98)
    private let surface = Color.white
    private let border = Color.black.opacity(0.08)
    private let textPrimary = Color(red: 0.07, green: 0.07, blue: 0.09)
    private let textSecondary = Color(red: 0.38, green: 0.40, blue: 0.45)
    private let destructive = Color(red: 0.86, green: 0.24, blue: 0.27)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — web-style page hero spacing
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(textPrimary)
                Text("Manage your preferences")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 20)

            // Card-style grouped list, but hand-rolled (no Form/List)
            VStack(spacing: 0) {
                settingRow(title: "Notifications", subtitle: "Push, email, in-app", isOn: $notifications)
                Divider().background(border).padding(.leading, 20)
                settingRow(title: "Dark Mode", subtitle: "Follow system or override", isOn: $darkMode)
                Divider().background(border).padding(.leading, 20)
                settingRow(title: "Sound", subtitle: "Haptics and alerts", isOn: $sound)
            }
            .background(surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 2)

            Spacer()

            // Destructive button — web-styled, hand-colored
            Button(action: {}) {
                HStack(spacing: 8) {
                    Text("Logout")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(destructive)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(destructive.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(destructive.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(bg)
    }

    @ViewBuilder
    private func settingRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(textPrimary)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(textSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(red: 0.07, green: 0.07, blue: 0.09))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

#Preview {
    Brief01_C2()
}
