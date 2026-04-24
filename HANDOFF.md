# Impeccable 3.0 Upgrade — Session Handoff

Written: 2026-04-24. Branch: `claude/impeccable-3-0-upgrade-4MsLs`. Target release: `impeccable-swift v0.2.0`.

Delete this file before the v0.2.0 PR merges.

## Where we are right now

Paul Bakaus merged Impeccable 3.0 upstream earlier today (PR #109, merge commit `6816558`, HEAD `f5e82162`). It's a major re-architecture: 18 standalone skills collapse into one `/impeccable` skill with 23 sub-commands, new brand/product register system, mandatory context loader, browser-based Live Mode. The Swift port is catching up to it on this branch.

### Commits on this branch (past main)

- `3cbb973` — `chore(upstream): record Imp 3.0 review — port in progress` (Phase 0)
- *(this commit)* — `chore(2a): ...` (Phase 2a WIP — plumbing in place, `SKILL.md` rewrite still pending)

### Plan in one page

| Phase | Status | What |
|---|---|---|
| 0 — record review | ✅ done | UPSTREAM.md row + `docs/3.0-upgrade-plan.md` scoping doc |
| 1 — command inventory | ✅ done | `docs/3.0-command-inventory.md` (23 commands, per-row classification) |
| 2a — skill tree restructure | 🟡 WIP | Scripts ported, old dirs deleted, legacy saved. **`SKILL.md` rewrite still pending.** |
| 2b — 23 sub-command ref ports | ⏳ next | Parallel sub-agents, one per command |
| 2c — typography + craft merges | ⏳ | Mechanical + judgment merges from upstream |
| 2d — non-sub-command ref ports | ⏳ | `brand.md`, `product.md`, `personas.md`, `cognitive-load.md`, `heuristics-scoring.md` |
| 2e — detector wiring | ⏳ | Wire SwiftLint / impeccable-lint / asset-catalog-checker into `audit.md` |
| 3 — evals | ⏳ | Re-run ChatBenchmarkV2; baseline is 28 → 4 P0+P1 findings, port must hold or improve |
| 4 — ship v0.2.0 | ⏳ | CHANGELOG, README, pin to `f5e82162`, single PR |

## Locked decisions (do not relitigate without user)

All five answered in session, captured here for future resumers.

1. **Live Mode** — stub only. `reference/live.md` points at Xcode Previews + SnapshotPreviews. No port of the 7 browser `.mjs` scripts. No element picker.
2. **Register** — full parity with upstream. Port both `brand.md` and `product.md`. Brand register is valid for SwiftUI (marketing shells, portfolios).
3. **Shortcuts** — clean break. No `pin.mjs` shims pre-applied for `critique` / `polish`. The `pin.mjs` script still ships so end-users can pin what they want.
4. **Scope** — full 23 sub-commands in v0.2.0. No subset.
5. **Timing** — everything on this branch. No intermediate merge to `main`.

## What Phase 2a did (this commit)

**Deleted:**
- `critique/SKILL.md`, `critique/.gitkeep`
- `polish/SKILL.md`, `polish/.gitkeep`

Their contents are preserved at `docs/legacy/legacy-critique-skill-v0.1.0.md` and `docs/legacy/legacy-polish-skill-v0.1.0.md` (gitignored path) as reference material for the Phase 2b agents who'll blend them with upstream's `critique.md` / `polish.md`.

**Added:**
- `impeccable/scripts/load-context.mjs` — byte-identical to upstream `f5e82162`. Reads `PRODUCT.md` + `DESIGN.md` from project root.
- `impeccable/scripts/pin.mjs` — Swift-adapted. `PARENT_SKILL = 'impeccable-swift'`, harness detection updated, marker renamed to `<!-- impeccable-swift-pinned-skill -->`, messaging references `impeccable-swift`.
- `impeccable/scripts/command-metadata.json` — 23 sub-command entries, descriptions rewritten to signal Swift/SwiftUI scope.

**Not yet done (this is where 2a stopped):**
- `impeccable/SKILL.md` rewrite. Current file is still the v0.1.0 POC version. Needs full rewrite as the 3.0 dispatcher.

## What's next — exact steps to resume

### Step 1: finish Phase 2a

Rewrite `impeccable/SKILL.md` as the 3.0 dispatcher. Template: `/tmp/impeccable-upstream/.claude/skills/impeccable/SKILL.md` (or re-clone — see below).

Must include:

- **Frontmatter:**
  - `name: impeccable-swift`
  - `description:` — Swift-adapted trigger surface. Signal iOS 26+ / macOS 26+, mention SwiftUI, Liquid Glass, SF Symbols, HIG. Keep upstream's trigger richness (the long list of design tasks).
  - `version: 0.2.0`
  - `user-invocable: true`
  - `argument-hint:` — match upstream's category-grouped shape with all 23 commands.
  - `license: Apache 2.0. Based on Paul Bakaus's impeccable (Apache 2.0). See NOTICE.md.`
  - `allowed-tools: [Bash(node *)]`
- **Setup (non-optional)** — port upstream's two-step context gathering + register selection. Use `node .claude/skills/impeccable-swift/scripts/load-context.mjs` (not upstream's path).
- **Shared design laws** — port upstream's verbatim. Swift-substitute where web-specific:
  - Motion: "Don't animate CSS layout properties" → "Don't animate layout properties (padding, frame, spacing); animate opacity, scale, offset, color instead."
  - Absolute bans: side-stripe borders, gradient text, glassmorphism-as-default, hero-metric template, identical card grids, modal-as-first-thought — re-cast for SwiftUI (e.g., gradient text via `.foregroundStyle(LinearGradient(...))`; modal abuse via `.sheet`).
  - Keep "no em dashes" rule (and no `--` substitute).
- **SwiftUI Reflex Check** — keep this section from the current v0.1.0 SKILL.md. It's a Swift-specific anti-pattern catalog that complements upstream's "AI slop test." Position it after Shared design laws, before Commands.
- **Commands table** — 23 rows, category-grouped (match upstream's order). Each row: command name, category, description, link to `reference/<command>.md`. Note: the reference files don't exist yet — links will dangle until Phase 2b lands. That's fine.
- **Routing rules** — port upstream's three-rule dispatch.
- **Pin / Unpin** — port upstream's section. Use `node .claude/skills/impeccable-swift/scripts/pin.mjs <pin|unpin> <command>`.

Commit Phase 2a as one commit once SKILL.md is done. Suggested message:

```
feat(2a): restructure to 3.0 single-skill dispatcher

Collapse three standalone skills (impeccable, critique, polish)
into one /impeccable-swift skill with 23 sub-commands via router
pattern. Matches upstream 3.0 architecture.

- Delete critique/ and polish/ (content preserved in docs/legacy/)
- Port load-context.mjs (identical to upstream) and pin.mjs
  (Swift-adapted) and command-metadata.json (23 entries, Swift
  descriptions)
- Rewrite impeccable/SKILL.md as 3.0 dispatcher: setup + register
  + shared design laws + SwiftUI Reflex Check + commands table
  + routing rules

Phase 2b will populate reference/<command>.md for all 23.
```

### Step 2: Phase 2b — 23 parallel sub-command ports

Fan out sub-agents. Each reads:
- Its row in `docs/3.0-command-inventory.md` (classification + links + notes)
- The upstream reference file at `/tmp/impeccable-upstream/.claude/skills/impeccable/reference/<cmd>.md`
- Its legacy file (for `critique` and `polish` only) at `docs/legacy/legacy-*-skill-v0.1.0.md`

Each writes `/home/user/impeccable-swift/impeccable/reference/<cmd>.md`.

Batching suggestion from the session: 3 waves of ~8 agents to catch style drift early. Commit per wave, not per agent.

### Step 3–5: Phases 2c, 2d, 2e

- **2c:** Merge upstream `typography.md` (+17 net lines, mechanical) and `craft.md` (+56 net lines, judgment — new Steps 3 and 4 inserted mid-workflow; renumber carefully).
- **2d:** Create `impeccable/reference/brand.md`, `product.md`, `personas.md`, `cognitive-load.md`, `heuristics-scoring.md`. All ported from upstream with Swift examples layered in.
- **2e:** Wire SwiftLint custom rules + `impeccable-lint` + asset-catalog-checker invocations into `audit.md` as the "Swift detector arm." Optionally wire `impeccable-lint` into `extract.md` for pattern detection.

### Step 6: Phase 3 — evals

Re-run ChatBenchmarkV2. Baseline: 28 → 4 P0+P1 findings (stock → impeccable-swift + DESIGN.md). Port must hold or improve. Consider adding a brand-register brief and a delight/overdrive brief to exercise new surfaces.

### Step 7: Phase 4 — ship

- CHANGELOG entry with explicit BREAKING note about the slash-command surface change.
- README update: install, 23-command menu, register explanation, Live Mode disposition.
- UPSTREAM.md: move pin from `00d485659` to `f5e82162`. Add review row closing out the port.
- Bump frontmatter to `version: 0.2.0`.
- Delete this HANDOFF.md.
- Single PR.

## Environment setup for resumers

When picking this up from a fresh machine (or a fresh Claude Code session):

```bash
# Pull the branch
git fetch origin claude/impeccable-3-0-upgrade-4MsLs
git checkout claude/impeccable-3-0-upgrade-4MsLs
git pull

# Re-clone upstream so sub-agents can diff against f5e82162
mkdir -p /tmp/impeccable-upstream
git clone https://github.com/pbakaus/impeccable.git /tmp/impeccable-upstream

# Verify upstream HEAD matches what we're porting against
cd /tmp/impeccable-upstream
git rev-parse HEAD   # should print f5e82162c1c6e6bdc0cd29f287c4446b679b61a5 or newer
```

If upstream has moved past `f5e82162`, check the new commits for anything that affects the in-flight port. If nothing material, proceed against `f5e82162` — we pin at release.

## Key reference paths

- **Scoping doc (locked decisions + phases):** `docs/3.0-upgrade-plan.md` (tracked via gitignore exception for the duration of this upgrade).
- **Command inventory (per-command brief for sub-agents):** `docs/3.0-command-inventory.md` (same exception).
- **Old critique skill (for Phase 2b blend):** `docs/legacy/legacy-critique-skill-v0.1.0.md` (gitignored — regenerate from `git show 3cbb973^:critique/SKILL.md` if missing).
- **Old polish skill (for Phase 2b blend):** `docs/legacy/legacy-polish-skill-v0.1.0.md` (same).
- **Upstream 3.0 SKILL.md (dispatcher template):** `/tmp/impeccable-upstream/.claude/skills/impeccable/SKILL.md`.
- **Upstream sub-command refs:** `/tmp/impeccable-upstream/.claude/skills/impeccable/reference/*.md`.
- **Upstream scripts (already ported):** `/tmp/impeccable-upstream/.claude/skills/impeccable/scripts/`.
- **Our Swift-native refs (keep unchanged):** `impeccable/reference/sf-symbols.md`, `materials.md`, `navigation.md`, `ios-vs-macos.md`, `accessibility.md`.
- **Our detector stack:** `tools/.swiftlint.yml`, `tools/impeccable-lint/`, `tools/asset-catalog-checker/`.
- **Evals (don't touch until Phase 3):** `evals/ChatBenchmarkV2/`.

## Known gotchas

- `docs/legacy/` is gitignored. The two legacy skill files do NOT travel with the branch. Recover with `git show 3cbb973^:critique/SKILL.md > docs/legacy/legacy-critique-skill-v0.1.0.md` (and same for polish) if you need them on a new machine.
- The Phase 2a sub-agent timed out with a stream idle timeout mid-task. Recovery was: verify plumbing (diff the ported scripts against upstream), then finish SKILL.md manually. Future 2b fan-out: if an agent times out, re-launch with the same brief for that single command only — the brief in the inventory is idempotent.
- `.gitignore` now has an explicit exception for `docs/3.0-upgrade-plan.md` and `docs/3.0-command-inventory.md` so they travel. Remove those exceptions when v0.2.0 ships.
- Upstream's SKILL.md has a `<post-update-cleanup>` block at the top — we deliberately do NOT port it. It runs `cleanup-deprecated.mjs` which we don't ship, and its self-delete logic would churn on us. Skip.
