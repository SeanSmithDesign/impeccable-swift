# Brief 01 — Settings Screen

**Prompt:**

> Build a SwiftUI Settings screen with three toggles (Notifications, Dark Mode, Sound) and a destructive Logout button at the bottom. Target iOS 26+.

**Exercises:**

- `color-and-contrast` (semantic colors, destructive tint)
- `spatial-design` (44pt tap targets, grouped list spacing, section insets)
- `sf-symbols` (trailing icons on toggle rows, logout glyph)
- `interaction-design` (toggle states, destructive button role)
- `typography` (Dynamic Type on row labels)
- `ux-writing` (sentence case, no "Please", clear destructive copy)

**Expected signals in the "with" output:**

- Uses `Form` or `List` with `.insetGrouped` / `.grouped` style rather than a hand-rolled `VStack`
- Toggle rows reach 44pt minimum tap-target height (via `Label` + default row height, not a custom `.frame`)
- SF Symbol on the logout control (e.g. `rectangle.portrait.and.arrow.right`) with a `Label` or explicit `.accessibilityLabel`
- Logout `Button` uses `.buttonStyle(.borderedProminent)` or similar with `role: .destructive` — **not** a hardcoded red background
- Text uses Dynamic Type text styles (`.body`, `.headline`) — no `.font(.system(size: N))`
- Semantic colors (`.primary`, `.secondary`, `Color(.systemBackground)`) or Asset Catalog references — no hardcoded hex
- Copy is sentence case and plain ("Log out", not "Please Log Out!")
- `#Preview` block included; ideally with light/dark variants

**Known failure modes in the "without" output:**

- Hardcoded `Color.gray` for separators and `Color.red` for the destructive button
- `.font(.system(size: 15))` on body text
- Manual `VStack` with arbitrary `.padding(20)` instead of a `Form`
- Logout button styled with `.background(Color.red).cornerRadius(8)` — no `.continuous`, no role
- Missing `#Preview` or a single unflavored preview
- Toggle labels as plain `Text`, no `Label`, no accessibility hint
