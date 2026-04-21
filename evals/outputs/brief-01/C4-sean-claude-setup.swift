// C4 — Sean's personal Claude setup (no impeccable skill)
// Condition: global ~/.claude/CLAUDE.md + ~/Code/docs/DESIGN-SWIFT.md.template +
// design-quality preset `refined-minimal`. SF Pro + terracotta accent (#c97350).
// NO impeccable/impeccable-swift skill loaded — no Liquid Glass vocabulary,
// no @ScaledMetric reflex, no custom detector rules (no `.continuous`, no
// `ContentUnavailableView`, no #Preview Dynamic Type variants).
//
// Expect: competent Swift with Sean's personal aesthetic baseline —
// semantic tokens, sentence-case copy, 4pt spacing scale, two shadow levels,
// 8pt corner radius, 44pt tap targets. But flatter on the Apple-native
// idioms the fork adds.

import SwiftUI

// Design tokens pulled from Sean's refined-minimal preset.
// In a real project these would live in Assets.xcassets + a Color extension,
// not inline — but this is a single-file eval snippet.
private enum AppColor {
    static let background = Color(red: 1.00, green: 1.00, blue: 1.00)
    static let surface = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let textPrimary = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let textSecondary = Color(red: 0.42, green: 0.42, blue: 0.42)
    static let accent = Color(red: 0.79, green: 0.45, blue: 0.31) // #c97350 terracotta
    static let border = Color(red: 0.90, green: 0.90, blue: 0.88)
    static let destructive = Color(red: 0.86, green: 0.21, blue: 0.27) // #dc3545
}

private enum AppSpacing {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let screenHorizontal: CGFloat = 20
}

struct Brief01_C4: View {
    @State private var notifications: Bool = true
    @State private var darkMode: Bool = false
    @State private var sound: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                Text("Settings")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.xl)

                // Preferences card — follows the card pattern in DESIGN-SWIFT.md.template
                VStack(spacing: 0) {
                    settingRow(title: "Notifications", isOn: $notifications)
                    Divider().background(AppColor.border)
                    settingRow(title: "Dark mode", isOn: $darkMode)
                    Divider().background(AppColor.border)
                    settingRow(title: "Sound", isOn: $sound)
                }
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColor.border.opacity(0.3))
                )
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)

                Spacer(minLength: AppSpacing.xl)

                Button {
                    // Log out
                } label: {
                    Text("Log out")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColor.destructive)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.background)
    }

    @ViewBuilder
    private func settingRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColor.accent)
        }
        .padding(.horizontal, AppSpacing.lg)
        .frame(minHeight: 44)
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview {
    Brief01_C4()
}
