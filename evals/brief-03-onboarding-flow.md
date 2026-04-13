# Brief 03 — Onboarding Flow

**Prompt:**

> Build a 3-step SwiftUI onboarding flow with a page indicator, a Next button that advances through the steps, and a Get Started button on the final step. Target iOS 26+.

**Exercises:**

- `motion-design` (step transitions, `@Environment(\.accessibilityReduceMotion)`)
- `interaction-design` (primary button states across steps, focus behavior on step change)
- `spatial-design` (page padding, safe-area insets, button-to-edge rhythm)
- `typography` (headline → body hierarchy on each step, Dynamic Type)
- `responsive-design` (`ViewThatFits` or size-class handling for short heights / landscape)
- `materials` (card or surface treatment on each step's content)

**Expected signals in the "with" output:**

- `TabView` with `.tabViewStyle(.page)` (or a state-driven switch) — **not** three hand-rolled `ZStack`s with manual offsets
- Transitions between steps honor `@Environment(\.accessibilityReduceMotion)` — fades/slides are disabled or swapped for a crossfade when reduce-motion is on
- Primary button (`Next` / `Get Started`) uses `.buttonStyle(.borderedProminent)` with `.controlSize(.large)`; full-width via `.frame(maxWidth: .infinity)` inside safe-area, not a hardcoded width
- Page indicator driven by `.indexViewStyle(.page(backgroundDisplayMode: .always))` or a custom indicator that reads from the same state source as the button — no duplicated step state
- Headline hierarchy uses `.largeTitle` / `.title` for the step title and `.body` / `.subheadline` for the description, with `@ScaledMetric` for any custom spacing that needs to scale
- Content respects `.safeAreaInset(edge: .bottom)` for the button, or uses `.safeAreaPadding()`; spacing values all sit on the 4pt scale (8, 16, 24, 32)
- `ViewThatFits` or size-class check to keep the layout readable in landscape / small heights
- Each step's hero content uses a `Material` or semantic background for its card surface — not `Color.white.opacity(0.8)`
- `#Preview` includes at least one non-default variant (Dynamic Type `.accessibility3`, dark mode, or landscape)

**Known failure modes in the "without" output:**

- Three `if step == 0 { ... } else if step == 1 { ... }` branches in a single `VStack` — no `TabView`
- Animations with hardcoded `.animation(.easeInOut(duration: 0.3))` and no reduce-motion check
- Next button styled as `Text("Next").padding().background(Color.blue).cornerRadius(10).foregroundColor(.white)` — no button style, no role, no `.continuous` corner
- Step state duplicated between the button logic and the page indicator, leading to drift
- Fixed button width (`.frame(width: 300, height: 50)`) instead of safe-area-aware full-width
- Magic padding values (`.padding(20)`, `.padding(.top, 37)`) not on the 4pt scale
- Single `#Preview` in default configuration, no accessibility variants
