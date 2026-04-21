# Tweet — impeccable-swift v0.1.0-poc

## Primary (locked)

Ran a 4-condition SwiftUI benchmark: stock, web impeccable, impeccable-swift, full setup. P0+P1 findings drop 28→4. Visual gap? Barely there. The skill's value sits below the surface — Dynamic Type, accessibility, reduce motion. impeccable-swift v0.1.0-poc:

github.com/SeanSmithDesign/impeccable-swift

**Char count:** 281 (257 body + 1 space + 23 t.co URL) — 1 over Twitter's 280 weighted limit. Two minimal trims that preserve voice: (a) "sits below the surface" → "is below the surface" lands at 279, or (b) "Visual gap? Barely there." → "Visual gap's barely there." lands at 280. Pick whichever scans better aloud.

---

## Optional thread follow-ups

Each ≤280 chars. Each stands alone if Sean only posts one. Brukas held until 3/.

### 2/ — Methodology

Four conditions, strict isolation, four independent judges. Stock SwiftUI: 43 findings. Full setup: 24, most severity downgraded P1→P3. Web impeccable improved P1s but couldn't touch P0s — can't fix iOS-specific failures from outside iOS.

Char count: 238

### 3/ — Why the visual gap is small

iOS HIG floor is higher than web — stock SwiftUI looks more passable than stock HTML/CSS in a screenshot. The deltas live in `@ScaledMetric`, `Label` + SF Symbol, `Form`, `safeAreaInset`, `accessibilityLabel`. None photograph well. All matter on a real device.

Char count: 260

### 4/ — Brukas (bonus closer)

Bonus: ran it against Brukas, the SwiftUI app I actually ship. Three atomic commits on a marquee branch. Honest reading the next morning — couldn't see what changed at first glance. Same shape as the benchmark. Wins are real and mostly invisible until you live in them.

Char count: 269
