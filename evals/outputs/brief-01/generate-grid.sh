#!/usr/bin/env bash
# generate-grid.sh
#
# Generates the 4-way ablation grid for brief-01.
#
# 1. Renders each condition's Swift source as a labeled "code card" PNG
#    (800x1000 pt at 2x density) using render-harness/render-code-card.swift.
# 2. Composes the four cards into a 2x2 grid (grid-4-way.png) using
#    render-harness/compose-grid.swift.
#
# What this grid represents (important honesty caveat):
# We render the *source code Claude produced per condition*, not the rendered
# UI. Running each view through an iOS simulator would be heavier and brings
# little more signal for this POC — the differentiation is visible in the code.
# Sean can re-run with real screenshots later if he wants a tighter visual.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS="$DIR/render-harness"

cd "$DIR"

echo "[1/5] Rendering C1 card..."
swift "$HARNESS/render-code-card.swift" C1-no-skill.swift screenshot-C1.png "C1  No skill (vanilla baseline)"

echo "[2/5] Rendering C2 card..."
swift "$HARNESS/render-code-card.swift" C2-impeccable-web.swift screenshot-C2.png "C2  impeccable (web, cross-ported)"

echo "[3/5] Rendering C3 card..."
swift "$HARNESS/render-code-card.swift" C3-impeccable-swift.swift screenshot-C3.png "C3  impeccable-swift (the fork)"

echo "[4/5] Rendering C4 card..."
swift "$HARNESS/render-code-card.swift" C4-sean-claude-setup.swift screenshot-C4.png "C4  Sean's Claude setup (no impeccable)"

echo "[5/5] Composing 2x2 grid..."
swift "$HARNESS/compose-grid.swift" \
  screenshot-C1.png screenshot-C2.png screenshot-C3.png screenshot-C4.png \
  grid-4-way.png

echo "Done. Artifacts:"
ls -la screenshot-C*.png grid-4-way.png
