# Benchmark — Chat Conversation (4 Conditions)

**Date:** 2026-04-15
**Brief:** `evals/brief-04-chat-conversation.md`
**Skill under test:** `impeccable-swift` (`~/Code/impeccable-swift/impeccable/SKILL.md`)
**Orchestrator target:** Sonnet

---

## 1. Goal

Measure what `impeccable-swift` adds over stock SwiftUI output by building the same chat conversation view four times under different design-guidance conditions — no skill (Build 1), the web-only `impeccable` skill (Build 2), the `impeccable-swift` skill in full (Build 3), and the full Sean setup with project `DESIGN.md` plus global design preferences (Build 4). All four builds share the same data model and sample conversation so the only variable is the guidance given to the generating sub-agent. A final judge sub-agent runs `/impeccable-swift:critique` on each view and emits a cross-build comparison table.

---

## 2. Project structure

Single Xcode project at `~/Code/impeccable-swift/evals/ChatBenchmark/`. iOS 26+ only, SwiftUI lifecycle, no tests target, no macOS target (keep the scope tight — this is a benchmark, not a shipping app).

```
evals/ChatBenchmark/
├── ChatBenchmark.xcodeproj/
├── ChatBenchmark/
│   ├── ChatBenchmarkApp.swift          # @main, launches ContentView
│   ├── ContentView.swift               # TabView switching Build1–Build4
│   ├── Models/                         # Shared. Built once. All builds consume.
│   │   ├── Message.swift
│   │   ├── Sender.swift
│   │   ├── MessageContent.swift        # enum covering all 6 types
│   │   ├── LinkPreview.swift
│   │   ├── Attachment.swift
│   │   ├── ReplyThread.swift
│   │   └── SampleData.swift            # `SampleData.conversation: [Message]`
│   ├── Build1_Stock/
│   │   └── ChatConversationView.swift  # entry: `Build1ChatConversationView`
│   ├── Build2_WebImpeccable/
│   │   └── ChatConversationView.swift  # entry: `Build2ChatConversationView`
│   ├── Build3_ImpeccableSwift/
│   │   └── ChatConversationView.swift  # entry: `Build3ChatConversationView`
│   ├── Build4_FullSetup/
│   │   └── ChatConversationView.swift  # entry: `Build4ChatConversationView`
│   ├── DESIGN.md                        # Only Build 4 reads this — lives here so
│   │                                    # the judge can cite it.
│   └── Assets.xcassets/                 # App icon + accent color asset (Build 4 only
│                                        # uses the accent; Builds 1–3 ignore it).
└── README.md                            # How to run, how to judge, what each tab is.
```

**Naming note.** Each build's view file is literally `ChatConversationView.swift` but declares a uniquely-named struct (`Build1ChatConversationView`, etc.) so `ContentView`'s `TabView` can reference all four without collision. The judge still scores a file called `ChatConversationView.swift` per build folder.

**Decision flagged for Sean.** I'm putting `DESIGN.md` inside the app target directory (not at `evals/ChatBenchmark/` root) so the Xcode project structure stays conventional. The teach flow normally writes to repo root — but this benchmark lives inside a larger repo, so targeting the app directory is the right call. If you'd rather have it at `evals/ChatBenchmark/DESIGN.md`, that's a one-line change for the Foundation sub-agent.

---

## 3. Shared types

Swift type shape only — the Foundation sub-agent writes the actual declarations. All types `Identifiable`, `Hashable`, `Equatable` where sensible.

```swift
// Sender.swift
enum Sender: String, Hashable {
    case me
    case alex     // primary correspondent
    case jordan   // secondary correspondent (for reply thread variety)
}

struct SenderInfo {
    let sender: Sender
    let displayName: String
    let avatarSymbolName: String   // SF Symbol fallback; no image assets required
}

// LinkPreview.swift
struct LinkPreview: Hashable {
    let title: String
    let description: String
    let thumbnailSystemName: String   // SF Symbol stand-in for thumbnail
    let sourceURL: URL
    let sourceLabel: String            // e.g. "nytimes.com"
}

// Attachment.swift
struct Attachment: Hashable {
    enum Kind: Hashable {
        case pdf
        case photo
    }
    let kind: Kind
    let filename: String
    let fileSizeBytes: Int
    let systemSymbolName: String       // "doc.fill" for pdf, "photo" for photo
    // For .photo: displayImageSystemName renders as SF Symbol stand-in for image asset.
    let displayImageSystemName: String?
}

// ReplyThread.swift
struct ReplyThread: Hashable {
    let replies: [Reply]

    struct Reply: Hashable, Identifiable {
        let id: UUID
        let sender: Sender
        let body: String
        let sentAt: Date
    }
}

// MessageContent.swift  — covers all 6 content types from the brief
enum MessageContent: Hashable {
    case text(String)
    case linkPreview(body: String?, preview: LinkPreview)
    case photo(Attachment)               // inline image
    case pdfAttachment(Attachment)
    case replyThreadRoot(body: String, thread: ReplyThread)
    case dateHeader(Date)                // rendered as a separator row
}

// Message.swift
struct Message: Identifiable, Hashable {
    let id: UUID
    let sender: Sender
    let sentAt: Date
    let content: MessageContent
}

// SampleData.swift
enum SampleData {
    static let senders: [Sender: SenderInfo] = [...]
    static let conversation: [Message] = [...]   // 12–15 items, see §4
}
```

**Why `MessageContent` as one enum with a `dateHeader` case.** Keeps the feed a single `[Message]` array — no parallel arrays, no special-casing in each build. Builds are free to render `dateHeader` however they want (sticky overlay, inline row, etc.) since that's a design decision the brief explicitly puts on the table.

**Why SF Symbols for images.** No photo assets need to ship. Link previews and inline photos use symbols like `photo.stack`, `newspaper.fill`, `doc.richtext` as visual stand-ins. This keeps all four builds visually comparable without introducing a "who picked better stock photos?" variable. Builds can style the symbol (color, size, background) however they want.

---

## 4. SampleData spec

A single contiguous conversation between `me`, `alex`, and `jordan`, sent over two days. Total **14 items** (includes 2 date headers, so 12 message rows). Ordered oldest → newest:

1. **Date header** — "Yesterday"
2. **Received text from alex** — short: "hey, you around?"
3. **Sent text from me** — multiline: "yeah, just finishing up. that thing we were talking about last week — I finally read the piece. it's good." (3 lines at default width)
4. **Received link preview from alex** — body "this one?", link preview card with title "The Case for a Slower Internet", description "Why we should stop optimizing for engagement and start optimizing for attention.", source `theatlantic.com`, thumbnail symbol `newspaper.fill`
5. **Sent text from me** — "exactly that one."
6. **Received photo from alex** — inline image (symbol `photo.stack` as stand-in), no body text, captioned by sender name + timestamp only
7. **Sent text from me** — "ha, perfect."
8. **Date header** — "Today"
9. **Received text from alex** — "one more thing — sending over the brief"
10. **Received PDF attachment from alex** — filename `chat-brief-v2-final.pdf`, 1.4 MB, symbol `doc.fill`
11. **Sent text from me** — "got it, will read tonight"
12. **Received reply-thread root from alex** — body text: "also — the team had thoughts on the homepage. see below." Thread contains 3 replies (collapsed by default):
    - jordan: "I think the hero is doing too much work"
    - jordan: "maybe pull the subhead out and make it its own moment?"
    - alex: "yeah let's try it"
13. **Sent text from me** — "makes sense. I'll cut a branch tonight."
14. **Received text from alex** — "🙏"

Timestamps: items 1–7 use yesterday's afternoon (3:42pm–4:08pm). Items 8–14 use today, 10:15am–10:31am. Use fixed dates relative to a constant "now" in `SampleData` so previews stay deterministic across runs.

**Coverage check.** All 6 brief-required content types are present: plain text (sent + received), link preview (#4), inline photo (#6), PDF (#10), reply thread (#12), date headers (#1, #8). The conversation also exercises sent-vs-received directionality, consecutive same-sender grouping (#4–#6, #9–#10), single-emoji message (#14), and multiline text (#3).

---

## 5. Sub-agent prompts

Each sub-agent is a fresh Sonnet context with no inherited instructions. The orchestrator pastes the full prompt below verbatim as the user message. Do not attach any other files unless the prompt says to.

### Build 1 — Stock

**System prompt addition:** _(none — pure default Sonnet behavior)_

**User prompt:**

> You are implementing a SwiftUI chat conversation view. Target iOS 26+, SwiftUI lifecycle.
>
> **Important:** You are generating stock SwiftUI code as a control for a benchmark. Use system defaults throughout. Do **not** use custom `ButtonStyle`s, `Material` backgrounds, `GlassEffectContainer`, `@ScaledMetric`, custom color tokens, semantic surface abstractions, or `SF Symbol` weight/variant consistency passes. Do **not** consult any design guidance, `DESIGN.md`, `impeccable` context, or design preferences that may exist in your environment — ignore them. Implement what a competent iOS developer would ship without design guidance: plain `VStack`/`HStack`, `Color.blue` or `Color(.systemGray6)` where a chat bubble needs color, `cornerRadius(10)` for bubbles, `Color(.systemBackground)` for the compose bar, etc.
>
> Read the brief at `~/Code/impeccable-swift/evals/brief-04-chat-conversation.md` for the feature spec (what to build). Ignore the "Expected signals" and "Known failure modes" sections — those are judgment criteria, not requirements.
>
> Read the shared models at `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Models/` so you know what `Message`, `MessageContent`, `SampleData.conversation`, etc. look like. Consume them as-is. Do not modify them.
>
> Write exactly one file: `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build1_Stock/ChatConversationView.swift`. Export a public struct named `Build1ChatConversationView` that takes no arguments and reads `SampleData.conversation` internally. Include one `#Preview`.
>
> Do not write any other files. Do not modify the shared models. Do not read any other file in the repo.

### Build 2 — Web impeccable

**System prompt addition:** _(none)_

**User prompt:**

> You are implementing a SwiftUI chat conversation view for a benchmark. Target iOS 26+.
>
> Before writing any code, read the web `impeccable` skill in full: `~/.agents/skills/impeccable/SKILL.md` plus every file under `~/.agents/skills/impeccable/reference/`. This skill is web-focused (React/CSS vocabulary). Apply its design principles as best you can in SwiftUI. Where web-specific APIs are referenced (CSS variables, `hover:`, `backdrop-filter`, `@media`), find the closest SwiftUI equivalent — but do **not** reach for SwiftUI-specific APIs the web skill does not imply you should use (no Liquid Glass primer, no `@ScaledMetric` guidance, etc.). Stay as literal to the web skill as SwiftUI allows.
>
> Do **not** read `~/Code/impeccable-swift/impeccable/` or any file under it. Do **not** read `DESIGN.md` even if you find one. This build measures whether a web-focused skill carries any benefit to Swift on its own.
>
> Read the brief at `~/Code/impeccable-swift/evals/brief-04-chat-conversation.md` for what to build (skip the "Expected signals" and "Known failure modes" sections).
>
> Read the shared models at `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Models/`. Consume them as-is.
>
> Write exactly one file: `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build2_WebImpeccable/ChatConversationView.swift`. Export a public struct named `Build2ChatConversationView` that takes no arguments. Include one `#Preview`.
>
> Do not modify the shared models.

### Build 3 — impeccable-swift

**System prompt addition:** _(none)_

**User prompt:**

> You are implementing a SwiftUI chat conversation view for a benchmark. Target iOS 26+.
>
> Follow the `impeccable-swift` skill end-to-end. Start by reading `~/Code/impeccable-swift/impeccable/SKILL.md`. Then follow its Context Gathering Protocol: read all 13 reference docs under `~/Code/impeccable-swift/impeccable/reference/`. Run the SwiftUI Reflex Check in the skill before writing any view code. Cite the reference docs by name in comments when a non-obvious decision is made (e.g. `// spatial-design.md: 16pt gutter`).
>
> There is no `DESIGN.md` for this build. Proceed in universal-only mode as the skill prescribes — no warning needed, no defaults guessed from the project.
>
> Read the brief at `~/Code/impeccable-swift/evals/brief-04-chat-conversation.md` for what to build (skip "Expected signals" and "Known failure modes").
>
> Read the shared models at `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Models/`. Consume them as-is.
>
> Write exactly one file: `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build3_ImpeccableSwift/ChatConversationView.swift`. Export a public struct named `Build3ChatConversationView`. Include at least two `#Preview` variants (populated conversation; keyboard-open compose state).
>
> Do not modify the shared models. Do not read the web `impeccable` skill at `~/.agents/skills/impeccable/`.

### Build 4 — Full Sean setup

**System prompt addition:** _(none)_

**User prompt:**

> You are implementing a SwiftUI chat conversation view for a benchmark. Target iOS 26+.
>
> Follow the `impeccable-swift` skill end-to-end: read `~/Code/impeccable-swift/impeccable/SKILL.md`, then all 13 reference docs under `~/Code/impeccable-swift/impeccable/reference/`. Run the SwiftUI Reflex Check before writing view code.
>
> **Project `DESIGN.md`:** Read `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/DESIGN.md`. Apply its tokens (accent color, font, radius, spacing rhythm, motion preferences) per the skill's two-layer read precedence: project tokens override universal defaults where explicit; universal rules apply where the project is silent. Cite `DESIGN.md` in comments when it determines a specific value.
>
> Read the brief at `~/Code/impeccable-swift/evals/brief-04-chat-conversation.md` for what to build (skip "Expected signals" and "Known failure modes").
>
> Read the shared models at `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Models/`. Consume them as-is.
>
> Write exactly one file: `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build4_FullSetup/ChatConversationView.swift`. Export a public struct named `Build4ChatConversationView`. Include at least two `#Preview` variants (populated; keyboard-open).
>
> Do not modify the shared models. Do not read the web `impeccable` skill.

---

## 6. DESIGN.md content (Build 4 only)

Written to `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/DESIGN.md` verbatim by the Foundation sub-agent:

```markdown
# DESIGN.md — ChatBenchmark

This is the design context a SwiftUI sub-agent needs to make good decisions on this project. Tokens here override the impeccable-swift reference docs where explicit. Where this file is silent, the reference docs apply; where both are silent, Apple HIG decides.

## Product context

- **Product:** A direct-messaging app for general consumers. One-to-one and small-group conversations, media sharing, light reply threading.
- **Audience:** Everyday messaging users across all ages. Non-technical. High expectation for the app to "feel Apple."
- **Brand personality:** Clean, focused, fast, reliable. Not playful. Not corporate. Closer in spirit to Messages than to Discord. Understated confidence.
- **Emotional target (3 words):** focused, fast, familiar.

## Platform

- iOS 26+ only. No macOS, iPadOS, visionOS, watchOS targets for this benchmark.
- Liquid Glass materials are in-scope and should be used where they earn their place (compose bar, floating overlays).

## Tokens

### Color

- **Accent:** `#c97350` — a warm rust / terracotta. Used sparingly: send-button fill when enabled, active reply thread affordance, link preview source label. Never as a full-bleed background.
- **Sent bubble surface:** Accent color with appropriate contrast text, OR accent-tinted material. Decide based on reference doc guidance — not a raw `Color.blue`.
- **Received bubble surface:** `Material` (`.regularMaterial` or a semantic surface). Not `Color(.systemGray6)`.
- **Background:** System background, but layered via materials on scroll so the compose bar feels distinct.
- **Dark Mode:** Must work. Accent holds across both appearances; materials carry the surface work.

### Typography

- **Family:** SF Pro (system default — do not declare a custom family).
- **Dynamic Type:** All text scales. Use `@ScaledMetric` for any fixed spacing that must scale with text (bubble min-height, reply-count chip).
- **Sender name (group-chat header above a run):** `.footnote.weight(.semibold)`, secondary color.
- **Message body:** `.body` at default weight.
- **Timestamp:** `.caption2` with `.monospacedDigit()` so numerals don't reflow.
- **Link preview title:** `.subheadline.weight(.semibold)`.
- **Link preview description:** `.footnote`, two-line truncation.
- **Link preview source label:** `.caption2` in accent color.
- **Filename (PDF):** `.subheadline`, `.lineLimit(1)`, `.truncationMode(.middle)`.
- **File size:** `.caption`, secondary color.
- **Date header:** `.footnote.weight(.semibold)`, centered, tertiary color.
- **Reply count affordance:** `.footnote.weight(.medium)`.

### Spacing

- **Rhythm:** 4 / 8 / 12 / 16 / 24.
- **Bubble padding (internal):** 12 vertical, 14 horizontal.
- **Gap between bubbles from different senders:** 12.
- **Gap between consecutive bubbles from the same sender:** 4.
- **Gap around date header row:** 16 above, 8 below.
- **Compose bar internal padding:** 12 vertical, 16 horizontal.
- **Safe area:** handled via `.safeAreaInset(edge: .bottom)` for the compose bar. Do not hardcode bottom padding.

### Shape

- **Bubble corner radius:** 18, `.continuous` style. No tail/pointer — this is a flat bubble language, not iMessage.
- **Link preview card corner radius:** 14, `.continuous`.
- **Inline photo corner radius:** 14, `.continuous`.
- **PDF attachment row corner radius:** 14, `.continuous`.
- **Send button:** capsule.

### Material & elevation

- **Compose bar:** `.bar` material, pinned via `.safeAreaInset`.
- **Received bubbles:** `.regularMaterial` (or `.thinMaterial` if tests show insufficient contrast against the background).
- **Sent bubbles:** accent-tinted surface; see Color.
- **Link preview card:** `.ultraThinMaterial` over a subtle stroke.
- **Elevation:** no drop shadows. Material does the separation.

### Motion

- Reply-thread expand/collapse: spring animation with `.spring(duration: 0.35, bounce: 0.15)`. Respect `@Environment(\.accessibilityReduceMotion)` — fade + instant layout when reduced.
- Keyboard: let SwiftUI handle it via `.safeAreaInset` + `ScrollViewReader.scrollTo`. No manual offset math.

### SF Symbols

- One set per surface. PDF uses `doc.fill`. Reply glyph uses `arrowshape.turn.up.left.fill`. Send button uses `arrow.up.circle.fill` (enabled) / `arrow.up.circle` (disabled). Attachment picker uses `paperclip`.
- Weight: `.semibold` for action glyphs, `.regular` for inline content glyphs. Don't mix.

### Interaction

- **Send button:** custom `ButtonStyle` with visible pressed state (scale ~0.96, opacity shift). Disabled when the text field is empty or whitespace-only. Tapping plays `.sensoryFeedback(.success, trigger:)`.
- **Reply thread affordance:** tappable row with a clear pressed state; announces "3 replies — tap to expand" to VoiceOver via `.accessibilityElement(children: .combine)` + `.accessibilityLabel`.
- **Photo message:** tappable (no-op for the benchmark, but wire up the gesture and accessibility label).

### Accessibility

- All media messages carry `.accessibilityLabel("Photo from [sender]")` / `.accessibilityLabel("PDF from [sender], [filename], [size]")`.
- Link preview uses `.accessibilityAddTraits(.isLink)`.
- Reply thread uses `.accessibilityElement(children: .combine)` on the collapsed row.
- All interactive elements are at least 44×44 in hit area.

## Anti-patterns (explicit for this project)

- No `Color.blue` / `Color(.systemGray6)` hardcoded anywhere.
- No `cornerRadius(10)` with a raw number. Use `.continuous` style and a token.
- No `VStack { ... Spacer() ComposeBar() }` for keyboard avoidance — `.safeAreaInset` only.
- No emoji in code comments. No decorative shadows.
- No custom font family. SF Pro via system text styles only.
```

---

## 7. Scoring template

**Judge invocation (per build).** The Judge sub-agent runs this shell command for each build folder and captures the structured output:

```bash
/impeccable-swift:critique ~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build1_Stock/ChatConversationView.swift
/impeccable-swift:critique ~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build2_WebImpeccable/ChatConversationView.swift
/impeccable-swift:critique ~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build3_ImpeccableSwift/ChatConversationView.swift
/impeccable-swift:critique ~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/Build4_FullSetup/ChatConversationView.swift
```

For Build 4 only, the critique run should also see `DESIGN.md`. The critique skill already follows the protocol of looking for it — as long as the Judge sub-agent's working directory is the app root during that invocation, it'll pick it up. The Judge must document the working directory used for each run in the report so results are reproducible.

**Output format for each build.** Critique emits per-finding records with P0/P1/P2/P3 severity and a category (Spatial, Typography, Color, Interaction, Motion, Symbols, Platform, UX Writing, Accessibility). The Judge aggregates into counts.

**Comparison table (written to `~/Code/impeccable-swift/evals/ChatBenchmark/BENCHMARK_RESULTS.md`):**

```markdown
# ChatBenchmark Results — 2026-04-15

## Top-line verdict

| Build                | Verdict (one sentence) | Total findings |  P0 |  P1 |  P2 |  P3 |
| -------------------- | ---------------------- | -------------: | --: | --: | --: | --: |
| 1 — Stock            | …                      |                |     |     |     |     |
| 2 — Web impeccable   | …                      |                |     |     |     |     |
| 3 — impeccable-swift | …                      |                |     |     |     |     |
| 4 — Full setup       | …                      |                |     |     |     |     |

## Findings by category

| Category           | Build 1 (P0/P1/P2/P3) | Build 2 | Build 3 | Build 4 |
| ------------------ | --------------------- | ------- | ------- | ------- |
| Spatial            |                       |         |         |         |
| Typography         |                       |         |         |         |
| Color              |                       |         |         |         |
| Material           |                       |         |         |         |
| Interaction        |                       |         |         |         |
| Motion             |                       |         |         |         |
| SF Symbols         |                       |         |         |         |
| Platform (iOS 26+) |                       |         |         |         |
| UX Writing         |                       |         |         |         |
| Accessibility      |                       |         |         |         |

## Delta summary

- **Build 2 − Build 1:** What did web impeccable catch that stock didn't? What did it miss because it's web-focused?
- **Build 3 − Build 2:** What did swift-native guidance add on top of web-only?
- **Build 4 − Build 3:** What did `DESIGN.md` + Sean's global prefs add on top of universal rules?

## Representative findings per build

For each build, include 2–3 representative findings verbatim from the critique output, including the cited reference doc.
```

---

## 8. Orchestrator sequence

Steps run sequentially, one sub-agent per step. Each sub-agent is a fresh context.

### Step 1 — Foundation sub-agent

- **Context in:** This plan file (§2, §3, §4, §6).
- **Task:** Create the Xcode project at `~/Code/impeccable-swift/evals/ChatBenchmark/` with iOS 26+ deployment, SwiftUI lifecycle, no tests. Add an Assets.xcassets with an "AccentColor" color set using `#c97350`. Create the folder structure in §2. Write all files in `Models/` including `SampleData.swift` with the 14-item conversation in §4. Write `ContentView.swift` as a `TabView` with 4 tabs, each hosting one build's view (stubbed with a placeholder `Text` view per build — the build sub-agents will replace). Write stub files at each `BuildN_*/ChatConversationView.swift` that expose the right struct name returning a placeholder `Text("Build N — not yet generated")`. Write `DESIGN.md` verbatim from §6. Write `README.md` explaining how to build, how to switch tabs, and how to run the judge.
- **Output out:** Compileable Xcode project. All four tabs render a placeholder. Models compile.
- **Verification:** Orchestrator runs `xcodebuild -project ChatBenchmark.xcodeproj -scheme ChatBenchmark -destination 'generic/platform=iOS' build` and confirms the build succeeds before proceeding.

### Step 2 — Build 1 sub-agent (Stock)

- **Context in:** Build 1 prompt from §5.
- **Task:** As stated in the prompt.
- **Output out:** `Build1_Stock/ChatConversationView.swift` with `Build1ChatConversationView` struct replacing the stub.
- **Verification:** Orchestrator re-runs `xcodebuild` after this step and every subsequent build step. Any compile error is returned to the sub-agent for a single fix pass; if still broken, orchestrator flags it to Sean rather than looping.

### Step 3 — Build 2 sub-agent (Web impeccable)

- **Context in:** Build 2 prompt from §5.
- **Task:** As stated.
- **Output out:** `Build2_WebImpeccable/ChatConversationView.swift`.
- **Verification:** Build.

### Step 4 — Build 3 sub-agent (impeccable-swift)

- **Context in:** Build 3 prompt from §5.
- **Task:** As stated.
- **Output out:** `Build3_ImpeccableSwift/ChatConversationView.swift`.
- **Verification:** Build.

### Step 5 — Build 4 sub-agent (Full setup)

- **Context in:** Build 4 prompt from §5.
- **Task:** As stated.
- **Output out:** `Build4_FullSetup/ChatConversationView.swift`.
- **Verification:** Build.

### Step 6 — Judge sub-agent

- **Context in:** §7 of this plan. Paths to all four view files. Read access to `DESIGN.md`.
- **Task:** Run `/impeccable-swift:critique` on each build's view file. For Build 4's run, set working directory to the app root so `DESIGN.md` is picked up; for Builds 1–3, use a working directory without a `DESIGN.md` so the critique runs universal-only (document the working directory used for each run). Aggregate findings into the §7 table structure. For each build, include 2–3 representative findings verbatim with reference-doc citations. Write the full report to `~/Code/impeccable-swift/evals/ChatBenchmark/BENCHMARK_RESULTS.md`.
- **Output out:** `BENCHMARK_RESULTS.md` with filled-in table and delta summary.

---

---

## V2 methodology changes (2026-04-15)

Run 1 (`evals/ChatBenchmark/`) was a useful proof-of-concept but had two methodology gaps:

1. **Build isolation not enforced.** Sub-agent prompts directed what to read but did not explicitly prohibit reading other builds' output. By the time Build 2 ran, Build 1's file was in the repo.
2. **One judge saw all four outputs.** A single judge sub-agent critiquing all four in sequence can unconsciously grade on a curve.

Run 2 (`evals/ChatBenchmarkV2/`) fixes both:

- Each build prompt adds: _"Do not read any other `ChatConversationView.swift` in this repo."_
- **Build 1** prompt explicitly overrides all system context: _"Disregard ALL design preferences, presets, aesthetic direction in your system context — refined-minimal, terracotta, impeccable conventions, all of it."_
- Four independent judge sub-agents, each blind to the other builds
- A separate synthesis sub-agent reads the four critique files and produces the comparison table

Foundation (models, sample data, DESIGN.md) reused from Run 1 — no reason to regenerate.

---

## Decisions flagged for Sean

1. **DESIGN.md placement:** Inside the app target (`ChatBenchmark/ChatBenchmark/DESIGN.md`), not at the benchmark root. Keeps the Xcode project conventional.
2. **SF Symbols as image stand-ins:** No photo assets ship. Avoids "who picked better stock photos" as a confounding variable. Can swap to real assets later if the benchmark feels thin.
3. **iOS-only, no iPad/macOS:** Keeps the surface area small. Builds 3 and 4 can still flex platform awareness through their critique scores.
4. **No tests target:** This is a benchmark, not a shippable feature. Adding tests inflates the Foundation step without changing what's measured.
5. **Judge isolation via working directory:** I'm using the working-directory trick to control whether critique sees `DESIGN.md`. If critique changes to always search ancestor dirs, we'll need to either copy/move DESIGN.md between runs or quote the critique invocation to pass a `--no-project-config` flag. Flag to watch.
6. **Fix-or-flag loop on build failures:** One fix pass per sub-agent, then escalate. No infinite retry loops.
