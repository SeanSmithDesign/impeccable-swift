# Announcement Post — impeccable-swift v0.1.0-poc

**Format:** single long-form post for X + LinkedIn (cross-post identical).
**Length:** ~480 words.

**Media (3 attachments, all motion):**

1. `~/Library/Mobile Documents/com~apple~CloudDocs/impeccable-swift-launch/matrix/chatbench-all-v2s-4x1-labeled.mp4` (1.5 MB, 2920×1420, 6.5s) — ChatBenchmark across 4 conditions: stock SwiftUI / web impeccable cross-ported / impeccable-swift / Sean's full Claude setup. Labels: `stock`, `impeccable`, `impeccable-swift`, `personal`.
2. `~/Library/Mobile Documents/com~apple~CloudDocs/impeccable-swift-launch/matrix/chatbench-b4-compare-labeled.mp4` (806 KB, 1480×1420, 6.5s) — two different chat apps at final build, impeccable-swift applied. Labels: `v1`, `v2`.
3. `~/Library/Mobile Documents/com~apple~CloudDocs/impeccable-swift-launch/matrix/brukas-dogfood-framed.mp4` (962 KB, 700×1420, 28s) — Brukas timer flow: chat resolves → timer starts → Live Activity on lock screen → session complete celebration. Control-bar polish visible throughout.

**Reply fuel (not in main post):**

- `chatbench-all-v1s-4x1-labeled.mp4` — the _other_ app's build progression
- 16 framed standalones: `chatbench-v{1,2}-b{1,2,3,4}-framed.{mp4,gif}`
- `chatbench-b2-compare-labeled.mp4`, `chatbench-b3-compare-labeled.mp4` — intermediate-build pair comparisons, labeled v1/v2 (natural bonus-tweet material)

**Cross-post note:** X allows up to 4 media per post, so 3 attachments ships fine. LinkedIn generally allows one video per post — for LinkedIn either pick the single strongest (v2 progression), or split across two posts.

**Killed from earlier draft:** `docs/media/grid-4-way.png` (raw Swift code quadrants; reads as engineering post, not design post).

---

Like many, I'm a fan of @impeccable_ai's front-end skill by @pbakaus. As I was doing some native iOS/macOS work, I was curious what a Swift version would look like.

Being open source, it was a great opportunity to fork it. Previewing [impeccable-swift v0.1.0-poc](https://github.com/SeanSmithDesign/impeccable-swift).

![Same app, four conditions: stock, web impeccable, impeccable-swift, my full Claude setup](matrix/chatbench-all-v2s-4x1-labeled.mp4)

The visible difference is there. Above is the same simple app run through four conditions: stock SwiftUI, the original web impeccable applied to Swift, impeccable-swift, and my full personal Claude setup. Layout, hierarchy, and material choices shift across the row. You can see it.

There's also a less visible difference. A separate, more rigorous benchmark: four conditions, four independent judges, isolated runs. P0+P1 design findings dropped from 28 down to 4 across the four builds. A lot of that delta lives in things that don't photograph well: Dynamic Type, accessibility labels, reduce motion, `safeAreaInset`. iOS HIG floor in some ways is higher than the web's, so stock SwiftUI looks more passable in a screenshot than stock HTML/CSS. The wins land on both layers, visible AND underneath.

![Two different chat apps, both at final build, impeccable-swift applied](matrix/chatbench-b4-compare-labeled.mp4)

And honestly, barely scratching the surface of what impeccable offers. Paul's upstream skill has a lot more depth that hasn't been ported or tested in impeccable-swift yet. SwiftUI speaks a different dialect, and impeccable-swift teaches it directly: `@ScaledMetric` so spacing scales with the user's accessibility settings, `Label` + SF Symbol as the default icon channel, `Form` for grouped settings, `#Preview` variants for Light/Dark. Same philosophy as the original, different floor plan.

I also ran it against [Brukas](https://www.brukas.app), a SwiftUI focus app I have in alpha right now. An app that I thought was set up fairly well. Three atomic fixes on a marquee branch: spacing tokens, empty-state typography, control-bar height anchored to the grid instead of a magic 80. Honest read the next morning: I couldn't immediately see what changed at first glance. Same shape as the benchmark. Some of these wins you don't really notice until you live in them.

![Brukas: chat conversation resolves into a running focus timer](matrix/brukas-dogfood-framed.mp4)

Maybe interesting, maybe not. Early exploration on something that could at least help me out as I build native Swift apps in addition to web. If anyone wants to try it out on their own, feel free! Definitely more work to make it as good as its originator.

- Repo: [github.com/SeanSmithDesign/impeccable-swift](https://github.com/SeanSmithDesign/impeccable-swift)
- Upstream: [github.com/pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache 2.0)
- Brukas: [brukas.app](https://www.brukas.app) (shameless plug)
