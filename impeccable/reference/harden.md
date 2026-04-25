# Harden

Strengthen SwiftUI interfaces against edge cases, errors, internationalization issues, and real-world usage scenarios that break idealized designs. Hardening is what turns a screenshot-perfect Preview into something that survives Brazilian Portuguese, an iPhone SE in airplane mode, and a user with AX5 Dynamic Type.

## Assess Hardening Needs

Identify weaknesses and edge cases:

1. **Test with extreme inputs**:
   - Very long text (names, descriptions, titles, push notifications)
   - Very short text (empty, single character, single emoji)
   - Special characters (emoji, RTL text, accents, combining marks)
   - Large numbers (millions, billions, scientific notation)
   - Many items (1000+ rows in a `List`, 50+ options in a `Picker`)
   - No data (empty states, no permissions granted)

2. **Test error scenarios**:
   - Network failures (offline, slow, timeout, captive portal)
   - `URLError` cases (no connection, timeout, cancelled, cert failure)
   - HTTP status codes (400, 401, 403, 404, 429, 500)
   - Validation errors (form, input, business rule)
   - Permission denials (Photos, Camera, Location, Notifications)
   - Background task expiration and `Task` cancellation
   - Concurrent operations and race conditions

3. **Test internationalization**:
   - Long translations (German is often 30% longer than English)
   - RTL languages (Arabic, Hebrew) with `.environment(\.layoutDirection, .rightToLeft)`
   - Character sets (Chinese, Japanese, Korean, emoji, combining diacritics)
   - Date/time formats (`Date.FormatStyle` per locale)
   - Number formats (1,000 vs 1.000 vs 1 000)
   - Currency symbols and placement (prefix vs suffix)
   - Plural rules (zero, one, two, few, many, other)

**CRITICAL**: Designs that only work with perfect data aren't production-ready. Harden against reality, not against your favorite Preview fixture.

## Hardening Dimensions

Systematically improve resilience:

### Text Overflow & Wrapping

**Long text handling**:

```swift
// Single line with truncation
Text(title)
    .lineLimit(1)
    .truncationMode(.tail)

// Multi-line with clamp
Text(description)
    .lineLimit(3)
    .truncationMode(.tail)
    .multilineTextAlignment(.leading)

// Allow shrinking before truncating (useful for headlines that must fit)
Text(headline)
    .lineLimit(1)
    .minimumScaleFactor(0.7)
    .allowsTightening(true)
```

**Stack overflow prevention**:

```swift
// HStack: let trailing label wrap, keep leading icon fixed
HStack(spacing: 12) {
    Image(systemName: "envelope.fill")
        .frame(width: 24, height: 24)        // fixed slot
    Text(emailSubject)
        .lineLimit(2)
        .frame(maxWidth: .infinity, alignment: .leading)  // claim remaining width
}
```

**Dynamic Type at AX sizes**: Test at AX5 (the largest accessibility size) in every Preview. Use `@ScaledMetric` for any spacing tied to text, and prefer `ViewThatFits` over hand-rolled size-class branches when layouts must reflow.

```swift
struct OrderRow: View {
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 24
    @ScaledMetric(relativeTo: .body) private var rowSpacing: CGFloat = 12

    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Wide layout
            HStack(spacing: rowSpacing) {
                icon
                Text(label)
                Spacer()
                Text(price)
            }
            // Narrow / AX5 fallback: stack vertically
            VStack(alignment: .leading, spacing: rowSpacing) {
                HStack(spacing: rowSpacing) {
                    icon
                    Text(label)
                }
                Text(price)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var icon: some View {
        Image(systemName: "bag.fill").frame(width: iconSize, height: iconSize)
    }
}

// Preview gallery for Dynamic Type
#Preview("AX5") {
    OrderRow().environment(\.dynamicTypeSize, .accessibility5)
}
```

See [reference/accessibility.md](accessibility.md) for the full Dynamic Type and Reduce Transparency rules behind this.

### Internationalization (i18n)

**Text expansion**:

- Add 30–40% space budget for translations.
- Use stacks and `.frame(maxWidth: .infinity, ...)` over fixed-width buttons.
- Test with the longest target language (usually German, often Russian).
- Avoid fixed widths on text containers.

```swift
// BAD: assumes short English text
Button("Submit") { }
    .frame(width: 96)

// GOOD: adapts to content + Dynamic Type
Button("Submit") { }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
```

**LocalizedStringKey, not String**:

```swift
// GOOD: Text(_:) takes LocalizedStringKey by default, looks up String Catalog
Text("welcome.title")  // resolves via Localizable.xcstrings

// String interpolation that needs localization
let formatted = String(localized: "Hello, \(name)", comment: "Greeting on home screen")

// AttributedString with localized markdown
Text(try! AttributedString(localized: "Read the **terms** to continue"))
```

Never hand-build user-facing strings with `+` or `String(format:)`. Use `String(localized:)`, `LocalizedStringResource`, and the String Catalog so translators can reorder, pluralize, and gender as the language requires.

**RTL (Right-to-Left) support**:

```swift
// Use leading / trailing, never .left / .right
HStack {
    Image(systemName: "chevron.backward")  // auto-mirrors in RTL
    Text("Back")
}
.padding(.leading, 16)        // becomes trailing in RTL automatically

// Custom drawn shapes that should mirror need .flipsForRightToLeftLayoutDirection
CustomArrow()
    .flipsForRightToLeftLayoutDirection(true)

// SF Symbols with directional meaning use the .backward / .forward variants
// (chevron.backward, arrow.forward) which auto-mirror. Avoid .left / .right.
```

Test RTL by adding a Preview override:

```swift
#Preview("RTL") {
    SettingsView()
        .environment(\.layoutDirection, .rightToLeft)
}
```

**Character set support**:

- UTF-8 everywhere (Swift's `String` is UTF-8 internally).
- Test with CJK strings (no spaces between words, breaks naive width assumptions).
- Test with emoji (grapheme clusters, skin tones, ZWJ sequences).
- Test with combining marks and bidi-mixed text.

**Date / time / number formatting**:

```swift
// GOOD: Foundation FormatStyle, locale-aware
let date = Date.now
date.formatted(date: .abbreviated, time: .shortened)
//   en-US: "Apr 24, 2026 at 3:42 PM"
//   de-DE: "24.04.2026, 15:42"
//   ja-JP: "2026/04/24 15:42"

// Currency formatting
1234.56.formatted(.currency(code: "USD"))    // "$1,234.56"
1234.56.formatted(.currency(code: "EUR").locale(Locale(identifier: "de-DE")))
//                                                "1.234,56 €"

// Number with grouping
1_000_000.formatted(.number.grouping(.automatic))
```

Never hand-roll `"$\(amount)"` or `"\(month)/\(day)/\(year)"`. The system formatters handle calendars, locales, and accessibility (VoiceOver reads `.formatted(...)` numbers correctly).

**Pluralization**:

```swift
// BAD: assumes English pluralization
Text("\(count) item\(count != 1 ? "s" : "")")

// GOOD: String Catalog with plural variants
Text("\(count) items")  // String Catalog handles zero/one/two/few/many/other
```

In `Localizable.xcstrings`, mark the key as plural and let the catalog editor encode the plural rules per language. Russian alone needs three forms.

### Error Handling

**Network errors**:

```swift
enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}

struct ProjectsView: View {
    @State private var state: LoadState<[Project]> = .idle

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView("Loading projects")
            case .loaded(let projects) where projects.isEmpty:
                ContentUnavailableView(
                    "No projects yet",
                    systemImage: "folder",
                    description: Text("Create your first project to get started.")
                )
            case .loaded(let projects):
                List(projects) { ProjectRow(project: $0) }
            case .failed(let error):
                ContentUnavailableView {
                    Label("Couldn't load projects", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(friendlyMessage(for: error))
                } actions: {
                    Button("Try Again") { Task { await load() } }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .task { await load() }
    }

    private func friendlyMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return "You're offline. Check your connection and try again."
            case .timedOut:               return "The request took too long. The server might be busy."
            case .cancelled:              return "The request was cancelled."
            default:                      return "Network error. Try again in a moment."
            }
        }
        return "Something went wrong. Try again, or contact support if it keeps happening."
    }
}
```

**Form validation errors**:

- Inline `Text` errors directly under the field, never a generic banner at the top.
- Plain language ("Email is missing @", not "Invalid input").
- Don't disable submit until the user attempts it: that hides the requirement.
- Preserve user input on error: never wipe a half-filled form.

**HTTP status codes**:

| Status | Treatment                                                                    |
| ------ | ---------------------------------------------------------------------------- |
| 400    | Show field-specific validation errors near the offending input.              |
| 401    | Trigger re-auth flow (sheet or push to sign-in), preserve in-progress work.  |
| 403    | Explain the permission needed and who to ask. Don't show "Unauthorized."     |
| 404    | Show a `ContentUnavailableView` with a way back to safety.                   |
| 429    | Show a rate-limit message with the wait time, retry on tap.                  |
| 500    | Generic friendly message with retry; offer "Contact support" if it persists. |

**`Result` and `throws`**:

Prefer `throws` for synchronous and async functions; use `Result` when you need to defer or pass an error across an async boundary that doesn't propagate.

```swift
// GOOD: throws + try await
func fetchProjects() async throws -> [Project] {
    let (data, response) = try await URLSession.shared.data(from: endpoint)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
        throw APIError.badStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
    }
    return try JSONDecoder.api.decode([Project].self, from: data)
}

// View: catch and route to LoadState.failed
private func load() async {
    state = .loading
    do {
        state = .loaded(try await fetchProjects())
    } catch {
        state = .failed(error)
    }
}
```

### Optionals: Nil Handling and Force-Unwrap Bans

**No force-unwraps in shipping code.** Force-unwrap (`!`) is acceptable only for:

- Test fixtures.
- Compile-time-known cases (`URL(string: "https://example.com")!` for a hardcoded literal you've eyeballed).
- Outlets in legacy UIKit (irrelevant here).

Everywhere else, force-unwrap is a crash waiting for a real user to find it.

```swift
// BAD: force-unwrap on user data
let user = users.first(where: { $0.id == id })!

// GOOD: optional binding with explicit fallback
guard let user = users.first(where: { $0.id == id }) else {
    state = .failed(LookupError.userNotFound(id))
    return
}

// GOOD: optional chaining + nil-coalescing for display
Text(user?.displayName ?? "Unknown")
```

**Optional chaining patterns**:

```swift
// Chain through optionals safely
let initial = user?.profile?.displayName?.first.map(String.init) ?? "?"

// Conditional rendering on optionals
if let avatar = user.avatarURL {
    AsyncImage(url: avatar) { image in
        image.resizable().scaledToFill()
    } placeholder: {
        Color.gray.opacity(0.1)
    }
} else {
    Image(systemName: "person.crop.circle.fill")
        .foregroundStyle(.tertiary)
}
```

**Implicitly unwrapped optionals (`!` on properties)** are a force-unwrap in disguise. Avoid them.

### Task Cancellation

Async work in SwiftUI is cancelled when the owning view disappears or its `task` modifier rebinds. Code that ignores cancellation leaks work, double-submits, and shows stale data.

```swift
struct SearchResults: View {
    @State private var query = ""
    @State private var results: [Match] = []

    var body: some View {
        List(results) { MatchRow(match: $0) }
            .searchable(text: $query)
            .task(id: query) {           // task cancels + restarts on query change
                await search(query)
            }
    }

    private func search(_ q: String) async {
        guard !q.isEmpty else { results = []; return }
        do {
            // Debounce, then check cancellation before continuing
            try await Task.sleep(for: .milliseconds(300))
            try Task.checkCancellation()

            let matches = try await api.search(q)
            try Task.checkCancellation()    // bail before mutating state if cancelled

            results = matches
        } catch is CancellationError {
            return                          // expected, swallow silently
        } catch {
            // surface real errors via your LoadState pattern
        }
    }
}
```

**`withTaskCancellationHandler` for non-Swift cancellation paths** (URLSession data tasks, Combine subscriptions, third-party callbacks):

```swift
func download(_ url: URL) async throws -> Data {
    let task = URLSession.shared.dataTask(with: url) { _, _, _ in /* ... */ }
    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            // ...wire continuation to the dataTask completion
            task.resume()
        }
    } onCancel: {
        task.cancel()
    }
}
```

**`@MainActor` boundaries**: state mutations that drive the UI must hop back to the main actor. SwiftUI `@State` is main-actor-isolated by default in modern Swift, but if you build helpers, mark them explicitly:

```swift
@MainActor
final class SearchModel: ObservableObject {
    @Published var results: [Match] = []

    func update(with matches: [Match]) {
        results = matches  // safe: @MainActor guarantees main thread
    }
}
```

Hardening failure mode: a long async task completes after the user navigates away, mutates state on a background actor, and SwiftUI logs a purple warning or crashes in debug. Always check `Task.isCancelled` (or `try Task.checkCancellation()`) before the final state write.

### Edge Cases & Boundary Conditions

**Empty states**: Use `ContentUnavailableView` (iOS 17+) for every empty collection, search-no-results, and load failure. Never leave a blank screen.

```swift
// Built-in convenience for empty search
ContentUnavailableView.search(text: query)

// Custom empty state
ContentUnavailableView {
    Label("No tasks", systemImage: "checklist")
} description: {
    Text("Add a task to get started.")
} actions: {
    Button("New Task", action: createTask)
        .buttonStyle(.borderedProminent)
}
```

**Loading states**: Initial load, pagination load, refresh. Show what's loading with copy ("Loading projects…", not just a spinner). For long operations, give a time estimate or progress.

**Large datasets**:

```swift
// Use List or LazyVStack: they recycle rows
List(items) { ItemRow(item: $0) }

// Pagination on scroll-to-bottom
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
            .onAppear {
                if item == items.last { Task { await loadMore() } }
            }
    }
    if isLoadingMore { ProgressView().frame(maxWidth: .infinity) }
}
```

Never load 10,000 items into a `VStack`. Never decode a giant array on the main actor.

**Concurrent operations**:

```swift
// Prevent double-submit
@State private var isSubmitting = false

Button("Submit") {
    Task {
        isSubmitting = true
        defer { isSubmitting = false }
        await submit()
    }
}
.disabled(isSubmitting)
```

For optimistic updates, snapshot the prior state, mutate immediately, and roll back on failure. Always include a way for the user to know the rollback happened (toast, inline error, restored state).

**Permission states**:

- No permission to view: explain why, link to Settings.app.
- Permission denied: don't keep asking, surface the deep-link to `UIApplication.openSettingsURLString`.
- Read-only mode: visually distinguish (disabled controls, banner, lock symbol), and don't pretend the user can edit.

```swift
// Open Settings.app for permission re-grant
Button("Open Settings") {
    if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }
}
```

**Platform compatibility**:

- Use `#available` checks for APIs newer than your deployment target.
- Provide fallbacks for `iOS 26` features when targeting `iOS 18+`.
- Feature-detect, don't device-detect.

```swift
if #available(iOS 17, *) {
    ContentUnavailableView("No tasks", systemImage: "checklist")
} else {
    VStack {
        Image(systemName: "checklist").font(.largeTitle).foregroundStyle(.tertiary)
        Text("No tasks").foregroundStyle(.secondary)
    }
}
```

### Input Validation & Sanitization

**Client-side validation**:

- Required fields (mark, validate on blur, surface inline).
- Format validation (email, phone, URL) using `Foundation` regex or `URL(string:)`.
- Length limits via `.onChange(of:)` truncation, not silent dropping.
- Custom validation rules surfaced as `Text` errors below the field.

**Server-side validation** (always):

- Never trust client validation alone. Re-validate on every API write.
- Escape user input before it lands in `WKWebView`, `AttributedString` markdown, or shell commands.
- Rate-limit at the API layer.

**Constraint handling**:

```swift
TextField("Username", text: $username)
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled(true)
    .keyboardType(.asciiCapable)
    .onChange(of: username) { _, new in
        if new.count > 24 { username = String(new.prefix(24)) }
    }

if let error = usernameError {
    Text(error)
        .font(.caption)
        .foregroundStyle(.red)
        .accessibilityIdentifier("username.error")
}
```

### Accessibility Resilience

This section overlaps with [reference/accessibility.md](accessibility.md): hardening failures here are P0/P1 in [reference/heuristics-scoring.md](heuristics-scoring.md).

**Keyboard navigation** (iPad and Mac Catalyst, macOS):

- All actions reachable via tab + return.
- `.keyboardShortcut(...)` on primary actions.
- Logical focus order in custom layouts (`.accessibilitySortPriority(_:)`).
- Escape (`.keyboardShortcut(.cancelAction)`) and command-period dismiss modals.

**VoiceOver**:

- `.accessibilityLabel` on every icon-only control.
- Combine related views with `.accessibilityElement(children: .combine)`.
- Announce dynamic changes with `AccessibilityNotification.Announcement(...).post()`.

**Reduce Motion**:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

content
    .transition(reduceMotion ? .opacity : .move(edge: .leading).combined(with: .opacity))
```

**Reduce Transparency**:

```swift
@Environment(\.accessibilityReduceTransparency) private var reduceTransparency

RoundedRectangle(cornerRadius: 16)
    .fill(reduceTransparency
        ? AnyShapeStyle(Color(.systemBackground))
        : AnyShapeStyle(Material.regularMaterial))
```

**Increase Contrast**: test with Settings → Accessibility → Display & Text Size → Increase Contrast. System colors adapt; hand-mixed colors often don't.

### Performance Resilience

**Slow connections**:

- `AsyncImage` placeholder while downloading, error state on failure.
- Skeleton screens (`Color.gray.opacity(0.1)` rectangles) instead of empty space during initial load.
- Cache aggressively (`URLCache`, on-disk Codable cache).
- Offline-first where the data model allows: write locally, sync when online.

**Retry with backoff**:

```swift
func fetchWithRetry<T>(
    maxAttempts: Int = 3,
    operation: () async throws -> T
) async throws -> T {
    var attempt = 0
    while true {
        do {
            return try await operation()
        } catch {
            attempt += 1
            if attempt >= maxAttempts { throw error }
            try Task.checkCancellation()
            try await Task.sleep(for: .milliseconds(250 * Int(pow(2.0, Double(attempt)))))
        }
    }
}
```

**Memory leaks**:

- Use `[weak self]` in long-lived closures (Combine sinks, NotificationCenter observers).
- Cancel `AnyCancellable` sets on view disappearance.
- Cancel `Task`s in `.task { }` (SwiftUI does this automatically when the view disappears).

**Throttling & debouncing**:

```swift
// Built-in via .task(id:): see Task Cancellation above for the search debounce pattern.

// For non-search debounce, use Combine
.onReceive(
    publisher.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
) { value in
    handle(value)
}
```

## Testing Strategies

**Manual testing**:

- Long text: paste a 200-character string into every text field and label.
- Emoji: use 🇮🇸 (flag), 👨‍👩‍👧‍👦 (ZWJ family), 🏳️‍🌈 (multi-codepoint) in every string field.
- RTL: switch the simulator to Arabic or Hebrew.
- CJK: switch to Japanese; verify breaks and line wrapping.
- Network: enable Network Link Conditioner, simulate "Very Bad Network" or full offline.
- Large datasets: load a Preview with 1000+ rows.
- Concurrent actions: tap submit ten times fast.
- Errors: force `URLError.notConnectedToInternet` in a debug toggle.
- Empty: clear the data store, navigate to every list view.

**Automated testing**:

- Unit tests for `friendlyMessage(for:)`, decoders, validators, and any pure function with edge cases.
- Snapshot tests via [SnapshotPreviews](https://github.com/EmergeTools/SnapshotPreviews) for empty, loading, error, and AX5 variants of every view.
- UI tests for critical flows (sign-in, checkout, content creation).
- Accessibility audit via Xcode's Accessibility Inspector before each release.

**IMPORTANT**: Hardening is about expecting the unexpected. Real users will do things you never imagined.

**NEVER**:

- Assume perfect input. Validate everything, server-side too.
- Ignore internationalization. Design for global from day one.
- Leave error messages generic ("An error occurred", "Something went wrong").
- Forget offline scenarios on a mobile platform.
- Trust client-side validation alone.
- Use fixed widths for text containers.
- Assume English-length text.
- Block the entire interface when one component errors.
- Force-unwrap optionals on user data.
- Mutate UI state from a background actor.
- Skip cancellation checks in long-running async tasks.

## Verify Hardening

Test thoroughly with edge cases:

- **Long text**: 100+ character names, descriptions, push titles.
- **Emoji**: emoji in every text field, including ZWJ sequences.
- **RTL**: full app pass with `.environment(\.layoutDirection, .rightToLeft)`.
- **CJK**: full app pass in Japanese or Chinese.
- **AX5**: every view rendered at `.dynamicTypeSize(.accessibility5)`.
- **Network issues**: airplane mode mid-flow, slow connection via Network Link Conditioner.
- **Large datasets**: 1000+ items in every list.
- **Concurrent actions**: rapid-fire submit, double-tap on every primary action.
- **Errors**: force every `URLError` and HTTP status code path.
- **Empty**: blank data store, no permissions, no items.
- **Cancellation**: navigate away mid-load, mid-search, mid-upload.

Remember: you're hardening for production reality, not Preview perfection. Expect users to input weird data, lose connection mid-flow, run AX5, switch to Arabic, and use your product in ways you never imagined. Build resilience into every view, every async function, every state machine.

## Cross-references

- [reference/accessibility.md](accessibility.md): Dynamic Type rules behind text overflow, Reduce Motion / Reduce Transparency fallbacks, VoiceOver requirements that hardening must satisfy.
- [reference/heuristics-scoring.md](heuristics-scoring.md): hardening failures map directly to severity. Crash on no network, force-unwrap on user data, AX5 layout collapse, missing RTL support: all P0. Generic error messages, missing `ContentUnavailableView`, no retry path: P1.
- [reference/ux-writing.md](ux-writing.md): the language pattern for error messages, empty states, and recovery copy.
- [reference/interaction-design.md](interaction-design.md): empty-state and loading-state interaction rules.
