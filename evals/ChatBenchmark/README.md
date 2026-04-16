# ChatBenchmark

A 4-condition benchmark that measures what `impeccable-swift` adds over stock SwiftUI by building the same chat conversation view under different design-guidance conditions.

## What this is

The same chat UI is built four times, each under a different level of design guidance:

| Tab | Build                      | Condition                                                                          |
| --- | -------------------------- | ---------------------------------------------------------------------------------- |
| 1   | Build 1 — Stock            | No skill, no guidance. A competent iOS developer's default output.                 |
| 2   | Build 2 — Web impeccable   | The web-focused `impeccable` skill applied as best as possible to SwiftUI.         |
| 3   | Build 3 — impeccable-swift | The `impeccable-swift` skill in full, universal-only mode (no project DESIGN.md).  |
| 4   | Build 4 — Full setup       | `impeccable-swift` skill + project `DESIGN.md` + Sean's global design preferences. |

All four builds share the same data models (`Models/`) and sample conversation (`SampleData.swift`). The only variable is the guidance given to the generating sub-agent.

## How to open in Xcode

```
open ~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark.xcodeproj
```

Or open Xcode and use File > Open to navigate to `evals/ChatBenchmark/`.

## How to switch between builds

The app uses a `TabView` with 4 tabs. Tap the tab bar items to switch between Build 1, 2, 3, and 4.

## How to run the judge

The judge sub-agent reads each build's `ChatConversationView.swift` and applies the `impeccable-swift:critique` protocol to produce a scored comparison report.

Results are written to: `evals/ChatBenchmark/BENCHMARK_RESULTS.md`

To reproduce the judge run, launch a sub-agent with the judge prompt from §6 of:
`docs/plans/2026-04-15-benchmark-chat-plan.md`

## Project structure

```
ChatBenchmark/
├── ChatBenchmark.xcodeproj/
├── ChatBenchmark/
│   ├── ChatBenchmarkApp.swift        # @main app entry
│   ├── ContentView.swift             # TabView routing to all 4 builds
│   ├── DESIGN.md                     # Design tokens (Build 4 only reads this)
│   ├── Models/                       # Shared models — do not modify
│   │   ├── Message.swift
│   │   ├── Sender.swift
│   │   ├── MessageContent.swift
│   │   ├── LinkPreview.swift
│   │   ├── Attachment.swift
│   │   ├── ReplyThread.swift
│   │   └── SampleData.swift          # 14-item deterministic sample conversation
│   ├── Build1_Stock/
│   │   └── ChatConversationView.swift
│   ├── Build2_WebImpeccable/
│   │   └── ChatConversationView.swift
│   ├── Build3_ImpeccableSwift/
│   │   └── ChatConversationView.swift
│   └── Build4_FullSetup/
│       └── ChatConversationView.swift
└── README.md
```

## Benchmark plan

Full plan at: `docs/plans/2026-04-15-benchmark-chat-plan.md`
