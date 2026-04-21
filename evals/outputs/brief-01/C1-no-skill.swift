// C1 — no-skill
// Condition: vanilla Claude with no skills loaded, no personal preferences, no project context.
// Expect: generic SwiftUI, typical AI defaults (hardcoded colors, fixed fonts, minimal a11y).

import SwiftUI

struct Brief01_C1: View {
    @State private var notifications: Bool = true
    @State private var darkMode: Bool = false
    @State private var sound: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white)

            VStack(spacing: 12) {
                HStack {
                    Text("Notifications")
                        .font(.system(size: 16))
                    Spacer()
                    Toggle("", isOn: $notifications)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)

                HStack {
                    Text("Dark Mode")
                        .font(.system(size: 16))
                    Spacer()
                    Toggle("", isOn: $darkMode)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)

                HStack {
                    Text("Sound")
                        .font(.system(size: 16))
                    Spacer()
                    Toggle("", isOn: $sound)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
            }
            .padding(20)

            Spacer()

            Button(action: {}) {
                Text("Logout")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(20)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

#Preview {
    Brief01_C1()
}
