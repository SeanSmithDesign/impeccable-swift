# Announcement Post — impeccable-swift v0.1.0-poc

**Format:** single long-form post for X + LinkedIn (cross-post identical).
**Length:** ~440 words.
**Image:** `docs/media/grid-4-way.png`, embedded once near the top.

---

I liked the original [impeccable](https://github.com/pbakaus/impeccable) — Paul Bakaus's design-quality skill for the web. I was curious what a Swift version would look like.

So I forked it. [impeccable-swift v0.1.0-poc](https://github.com/SeanSmithDesign/impeccable-swift).

![Same brief, four conditions](docs/media/grid-4-way.png)

The visible difference is there. The screenshots above are the same brief run through four conditions: stock SwiftUI, the original web impeccable applied to Swift, impeccable-swift, and my full personal Claude setup. Layout, hierarchy, and material choices shift across the row. You can see it.

There's also a less visible difference. A separate, more rigorous benchmark — four conditions, four independent judges, isolated runs — dropped P0+P1 design findings from 28 down to 4 across the four builds. A lot of that delta lives in things that don't photograph well: Dynamic Type, accessibility labels, reduce motion, `safeAreaInset`. iOS HIG floor is higher than the web's, so stock SwiftUI looks more passable in a screenshot than stock HTML/CSS. The wins land on both layers — visible AND underneath.

And honestly, we've barely scratched the surface of what impeccable offers. Paul's upstream skill has a lot more depth that hasn't been ported into Swift yet. SwiftUI speaks a different dialect, and impeccable-swift teaches it directly — `@ScaledMetric` so spacing scales with the user's accessibility settings, `Label` + SF Symbol as the default icon channel, `Form` for grouped settings, `#Preview` variants for Light/Dark. Same philosophy as the original, different floor plan.

I also ran it against [Brukas](https://github.com/SeanSmithDesign/Pico-Timer), a SwiftUI focus app I actually ship. Three atomic fixes on a marquee branch — spacing tokens, empty-state typography, control-bar height anchored to the grid instead of a magic 80. Honest read the next morning: I couldn't immediately see what changed at first glance. Same shape as the benchmark. Some of these wins you don't really notice until you live in them.

Maybe interesting, maybe not. Early exploration on something that could at least help me out as I build native Swift apps in addition to web. If anyone wants to try it out on their own, feel free! Definitely more work to make it as good as its originator.

- Repo: [github.com/SeanSmithDesign/impeccable-swift](https://github.com/SeanSmithDesign/impeccable-swift)
- Upstream: [github.com/pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache 2.0)
