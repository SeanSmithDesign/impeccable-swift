# Tweet drafts — impeccable-swift v0.1.0-poc

Three variants, each ≤280 chars. Sean picks one. All link to the repo.

Char counts assume Twitter's t.co URL wrapping (23 chars for the shortened form).

---

## Variant A — Lead with the C4 honesty angle (RECOMMENDED per Workstream C observation)

ported a design-quality skill to Swift and ran a 4-way ablation. finding i didn't expect: a carefully configured personal setup gets tasteful Swift, but still leaves platform-specific SwiftUI affordances on the table. v0.1.0-poc, research framing.

github.com/SeanSmithDesign/impeccable-swift

Char count: 271 (247 body + 1 space + 23 URL)
Hook: the value prop is narrower and more honest than "the skill wins"

---

## Variant B — Lead with the Form differentiator

fun finding from a 4-way SwiftUI ablation on a Settings screen: only 1 of 4 configurations reached for `Form`. the other three hand-rolled a VStack of rows. guess which one used the skill. v0.1.0-poc, receipts in the repo.

github.com/SeanSmithDesign/impeccable-swift

Char count: 246 (222 body + 1 space + 23 URL)
Hook: sharp single-word differentiator, reader solves the puzzle themselves

---

## Variant C — Lead with the Brukas before/after

forked impeccable into Swift and ran it against an app i actually ship. three atomic commits later, the codebase feels a little more cared-for. no wow-moment bug, just cumulative wins. v0.1.0-poc, not a product — sharing the research.

github.com/SeanSmithDesign/impeccable-swift

Char count: 258 (234 body + 1 space + 23 URL)
Hook: the production-adjacent receipt — real app, real commits, honest characterization

---

## Thread follow-up (optional, if Sean wants to post a thread)

**2/** the 4 conditions: C1 no skill, C2 web impeccable ported to Swift, C3 impeccable-swift, C4 my personal Claude setup with a DESIGN-SWIFT template but no skill. all four parse and typecheck. differences are taste and idiom, not correctness.

Char count: 237

**3/** C3 is the only condition that reached for `Form`, `Label` + SF Symbol, `Button(role: .destructive)`, `@ScaledMetric`, and multi-variant `#Preview`. C4 was visibly tasteful — semantic colors, 4pt grid, 44pt tap targets — but didn't reach for Apple-specific idioms.

Char count: 263

**4/** big caveats: i wrote the skill AND the eval, one brief, single-session role-play not four isolated environments. directional evidence, not a benchmark. blind designer review and more briefs are on the backlog. full write-up + methodology receipts linked from the repo.

Char count: 268
