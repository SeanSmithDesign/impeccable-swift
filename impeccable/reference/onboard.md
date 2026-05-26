> **Additional context needed**: the "aha moment" you want users to reach, and users' experience level.

Get users to first value as fast as possible. Onboarding's job is not to teach the product. Its job is to get people to the moment that proves the product is worth their time.

## Assess Onboarding Needs

Understand what users need to learn and why before writing any code:

1. **Identify the challenge**:
   - What are users trying to accomplish?
   - What's confusing or unclear about current experience?
   - Where do users get stuck or drop off?
   - What's the "aha moment" we want users to reach?

2. **Understand the users**:
   - What's their experience level? (Beginners, power users, mixed?)
   - What's their motivation? (Excited and exploring? Required by work?)
   - What's their time commitment? (5 minutes? 30 minutes?)
   - What alternatives do they know? (Coming from competitor? New to category?)

3. **Define success**:
   - What's the minimum users need to learn to be successful?
   - What's the key action we want them to take? (First project? First invite?)
   - How do we know onboarding worked? (Completion rate? Time to value?)

**CRITICAL**: Onboarding should get users to value as quickly as possible, not teach everything possible.

## Onboarding Principles

### Show, Don't Tell
- Demonstrate with working examples, not just descriptions
- Provide real functionality in onboarding, not separate tutorial mode
- Use progressive disclosure, teach one thing at a time

### Make It Optional (When Possible)
- Let experienced users skip onboarding
- Don't block access to product
- Provide "Skip" or "I'll explore on my own" options

### Time to Value
- Get users to their "aha moment" ASAP
- Front-load most important concepts
- Teach 20% that delivers 80% of value
- Save advanced features for contextual discovery

### Context Over Ceremony
- Teach features when users need them, not upfront
- Empty states are onboarding opportunities
- Tooltips and hints at point of use

### Respect User Intelligence
- Don't patronize or over-explain
- Be concise and clear
- Assume users can figure out standard patterns

## Design Onboarding Experiences

### Initial Product Onboarding

**Welcome Screen**:
- Clear value proposition (what is this product?)
- What users will learn/accomplish
- Time estimate (honest about commitment)
- Option to skip (for experienced users)

**Account Setup**:
- Minimal required information (collect more later)
- Explain why you're asking for each piece of information
- Smart defaults where possible
- Sign in with Apple when appropriate

**Core Concept Introduction**:
- Introduce 1-3 core concepts (not everything)
- Use simple language and examples
- Interactive when possible (do, don't just read)
- Progress indication (step 1 of 3)

**First Success**:
- Guide users to accomplish something real
- Pre-populated examples or templates
- Celebrate completion (but don't overdo it)
- Clear next steps

### SwiftUI Modal Patterns for Onboarding

Choose the right presentation surface before writing any code. The choice signals intent to the user.

**`.fullScreenCover()` for blocking onboarding flows**: Use when onboarding must be completed before the app is usable. Covers the entire screen, preventing dismissal by swipe. Appropriate for account creation, required permissions, or first-run experiences where the user cannot proceed without completing a step.

```swift
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        MainTabView()
            .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
                OnboardingFlow(isPresented: $hasCompletedOnboarding)
            }
    }
}
```

**`.sheet()` for non-blocking welcome moments**: Use for optional orientation, "what's new" announcements, or contextual feature introductions. The user can swipe to dismiss, which respects their autonomy and signals that the content is supplementary rather than mandatory.

```swift
struct HomeView: View {
    @State private var showWelcome = false

    var body: some View {
        NavigationStack {
            ContentList()
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .task {
            showWelcome = !UserDefaults.standard.bool(forKey: "welcomeSeen")
        }
    }
}
```

**`NavigationStack` for multi-step flows with route state**: Use for onboarding sequences with branching logic or more than two steps. Centralise navigation state as an enum to make the flow explicit and testable. See [`navigation.md`](navigation.md) for full modal and stack patterns.

```swift
enum OnboardingRoute: Hashable {
    case welcome
    case permissions
    case profile
    case complete
}

struct OnboardingFlow: View {
    @Binding var isPresented: Bool
    @State private var path: [OnboardingRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeStep {
                path.append(.permissions)
            }
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .welcome:
                    WelcomeStep { path.append(.permissions) }
                case .permissions:
                    PermissionsStep { path.append(.profile) }
                case .profile:
                    ProfileStep { path.append(.complete) }
                case .complete:
                    CompletionStep { isPresented = true }
                }
            }
        }
    }
}
```

**Progressively-disclosed views via `@State` step counters**: For simpler linear sequences where a full `NavigationStack` is unnecessary overhead, a step counter with conditional view rendering keeps the flow in a single view, reducing navigation chrome.

```swift
struct LinearOnboardingView: View {
    @State private var currentStep = 0
    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 32) {
            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .padding(.horizontal)

            switch currentStep {
            case 0: WelcomePanel()
            case 1: ConceptPanel()
            case 2: ActionPanel()
            default: EmptyView()
            }

            Button("Continue") {
                withAnimation(.easeInOut) {
                    currentStep += 1
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .animation(.easeInOut, value: currentStep)
    }
}
```

For modal presentation styling: materials, corner radius, and shadow choices for sheets and covers, see [`materials.md`](materials.md).

### Feature Discovery and Adoption

**Empty States**:
Instead of blank space, show:
- What will appear here (description + illustration or SF Symbol)
- Why it's valuable
- Clear CTA to create first item
- Example or template option

Use `ContentUnavailableView` (iOS 17+) for system-consistent empty states:

```swift
struct ProjectListView: View {
    @State private var projects: [Project] = []

    var body: some View {
        List(projects) { project in
            ProjectRow(project: project)
        }
        .overlay {
            if projects.isEmpty {
                ContentUnavailableView {
                    Label("No Projects Yet", systemImage: "folder.badge.plus")
                } description: {
                    Text("Projects help you organize your work and collaborate with your team.")
                } actions: {
                    Button("Create Your First Project") {
                        // create action
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
```

**Contextual Tooltips**:
- Appear at relevant moment (first time user sees feature)
- Point directly at relevant UI element
- Brief explanation plus benefit
- Dismissable (with "Don't show again" option)
- Optional "Learn more" link

**Feature Announcements**:
- Highlight new features when they're released
- Show what's new and why it matters
- Let users try immediately
- Dismissable

**Progressive Onboarding**:
- Teach features when users encounter them
- Badges or indicators on new/unused features
- Unlock complexity gradually (don't show all options immediately)

### Guided Tours and Walkthroughs

**When to use**:
- Complex interfaces with many features
- Significant changes to existing product
- Industry-specific tools needing domain knowledge

**How to design**:
- Spotlight specific UI elements (dim rest of interface)
- Keep steps short (3-7 steps max per tour)
- Allow users to move through the tour freely
- Include "Skip tour" option
- Make replayable (help menu)

**Best practices**:
- Interactive over passive (let users tap real controls)
- Focus on workflow, not features ("Create a project" not "This is the project button")
- Provide sample data so actions work

### Interactive Tutorials

**When to use**:
- Users need hands-on practice
- Concepts are complex or unfamiliar
- High stakes (better to practice in safe environment)

**How to design**:
- Sandbox environment with sample data
- Clear objectives ("Create a chart showing sales by region")
- Step-by-step guidance
- Validation (confirm they did it right)
- Graduation moment (you're ready!)

### Documentation and Help

**In-product help**:
- Contextual help links throughout interface
- Keyboard shortcut reference (Mac)
- Searchable help content
- Video tutorials for complex workflows

**Help patterns**:
- `?` icon near complex features
- "Learn more" links in contextual overlays
- Keyboard shortcut hints shown inline on Mac

## Empty State Design

Every empty state needs:

**What Will Be Here**: "Your recent projects will appear here"

**Why It Matters**: "Projects help you organize your work and collaborate with your team"

**How to Get Started**: [Create project] or [Import from template]

**Visual Interest**: SF Symbol or illustration (not just text on a blank background)

**Contextual Help**: "Need help getting started? [Watch 2-min tutorial]"

**Empty state types**:
- **First use**: Never used this feature (emphasize value, provide template)
- **User cleared**: Intentionally deleted everything (light touch, easy to recreate)
- **No results**: Search or filter returned nothing (suggest different query, clear filters)
- **No permissions**: Can't access (explain why, how to get access)
- **Error state**: Failed to load (explain what happened, retry option)

## Implementation Patterns

**Tooltip overlays**: Custom `ZStack` overlays with `matchedGeometryEffect` to anchor to the target view.
**Tour sequences**: `fullScreenCover` or overlay with dimmed background and spotlight cutout using `.blendMode(.destinationOut)`.
**Modal patterns**: System sheet with focus management; see [`navigation.md`](navigation.md).
**Progress tracking**: `@AppStorage` for persisting "seen" states across launches.
**Analytics**: Track completion and drop-off by posting `AnalyticsEvent` at each step transition.

**Storage patterns**:

```swift
// Track which onboarding steps the user has completed
@AppStorage("onboardingCompleted") var onboardingCompleted = false
@AppStorage("featureTooltipSeenReports") var featureTooltipSeenReports = false
```

**IMPORTANT**: Don't show the same onboarding twice. Persist completion state in `@AppStorage` or `UserDefaults` and respect dismissals.

**NEVER**:

- Force users through long onboarding before they can use the product
- Patronize users with obvious explanations
- Show the same tooltip repeatedly (respect dismissals)
- Block all UI during a tour (let users explore)
- Create a separate tutorial mode disconnected from the real product
- Overwhelm with information upfront (progressive disclosure!)
- Hide "Skip" or make it hard to find
- Forget about returning users (don't show initial onboarding again)

## Verify Onboarding Quality

Test with real users:

- **Time to completion**: Can users complete onboarding quickly?
- **Comprehension**: Do users understand after completing?
- **Action**: Do users take the desired next step?
- **Skip rate**: Are too many users skipping? (Maybe it's too long or not valuable)
- **Completion rate**: Are users completing? (If low, simplify)
- **Time to value**: How long until users get first value?

When users hit the aha moment fast and don't drop off, hand off to `impeccable polish` for the final pass.
