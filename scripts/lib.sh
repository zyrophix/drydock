#!/usr/bin/env bash
# lib.sh — shared helpers for drydock scripts. Source it, don't execute it.
# Usage in a script: HERE="$(cd "$(dirname "$0")" && pwd)"; . "$HERE/lib.sh"
# (Source BEFORE cd-ing into the audit target: nofence takes a path argument.)

# Standards generation adopted repos stamp in .drydock.json.
# Bump on every backward-incompatible template/governance change + CHANGELOG entry.
# Release checklist (docs/07) includes this bump.
DRYDOCK_STANDARDS=1

# Badge bounds, single home (facts.json mirrors these; check-facts.sh verifies).
# Rule: 1-5 signal badges; tools recommended 3-5 (docs/03).
BADGE_MIN=1
BADGE_MAX=5

# Print a markdown file with fenced code blocks removed.
# Headings/links inside fences are examples, not structure — both audit.sh
# and check-links.sh must agree on this (see N-M6: divergence was a bug).
nofence() { awk 'BEGIN{f=0} /^```/{f=!f; next} f==0' "$1"; }

# find(1) exclusions shared by every *.md walk: build outputs, vendored
# deps, VCS metadata, and templates/ (placeholders resolve at copy time).
MD_FIND_EXCL=(
  -not -path '*/templates/*'
  -not -path '*/node_modules/*'
  -not -path '*/target/*'
  -not -path '*/.git/*'
  -not -path '*/.venv/*'
  -not -path '*/build/*'
  -not -path '*/dist/*'
  -not -path '*/__pycache__/*'
)
