#!/usr/bin/env bash
# assemble-github.sh — build and maintain the shared .github defaults tree from drydock templates.
# File ownership (see docs/05):
#   managed (byte-exact, overwritten on every assemble): CODE_OF_CONDUCT.md,
#     PULL_REQUEST_TEMPLATE.md, FUNDING.yml, ISSUE_TEMPLATE/*, workflow-templates/*
#   seeded (copy-once, never touched after): CONTRIBUTING.md, SECURITY.md, SUPPORT.md
# Usage:
#   assemble-github.sh <dest-dir>            fresh assembly (managed + seeded)
#   assemble-github.sh --check <dest-dir>    report drift of managed files (exit 1 if any)
#   assemble-github.sh --stamp <repo-dir>    write .drydock.json stamp (DRYDOCK_STANDARDS)
set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"
MODE="assemble"
[ "${1:-}" = "--check" ] && { MODE="check"; shift; }
[ "${1:-}" = "--stamp" ] && { MODE="stamp"; shift; }
DEST="${1:?usage: assemble-github.sh [--check|--stamp] <dir>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$MODE" = "stamp" ]; then
  printf '{\n  "_comment": "drydock standards generation (see drydock docs/05).",\n  "standards": %s,\n  "updated": "%s"\n}\n' \
    "$DRYDOCK_STANDARDS" "$(date +%F)" > "$DEST/.drydock.json"
  echo "stamped $DEST/.drydock.json (standards $DRYDOCK_STANDARDS)"
  exit 0
fi

build_tree() {
  local d="$1"
  mkdir -p "$d"/ISSUE_TEMPLATE "$d"/workflow-templates
  cp "$HERE/templates/code-of-conduct.md" "$d/CODE_OF_CONDUCT.md"
  cp "$HERE/templates/pull-request-template.md" "$d/PULL_REQUEST_TEMPLATE.md"
  cp "$HERE/templates/funding.yml" "$d/FUNDING.yml"
  cp "$HERE/templates/issue-template/"*.yml "$d/ISSUE_TEMPLATE/"
  cp "$HERE/templates/workflow-templates/"*.yml "$d/workflow-templates/"
}
seed_once() {
  local d="$1"
  for pair in "contributing.md:CONTRIBUTING.md" "security.md:SECURITY.md" "support.md:SUPPORT.md"; do
    src="${pair%%:*}"; dst="${pair##*:}"
    [ -e "$d/$dst" ] || cp "$HERE/templates/$src" "$d/$dst"
  done
}

if [ "$MODE" = "check" ]; then
  TMP="$(mktemp -d)"
  build_tree "$TMP"
  DRIFT=0
  while IFS= read -r rel; do
    if [ ! -e "$DEST/$rel" ]; then echo "MISSING: $rel"; DRIFT=$((DRIFT+1));
    elif ! cmp -s "$TMP/$rel" "$DEST/$rel"; then echo "DRIFTED: $rel"; DRIFT=$((DRIFT+1)); fi
  done < <(cd "$TMP" && find . -type f | sed 's|^\./||' | sort)
  rm -rf "$TMP"
  [ "$DRIFT" -eq 0 ] && echo "managed files in sync ($DEST)" || { echo "$DRIFT managed file(s) drifted — re-run assemble"; exit 1; }
  exit 0
fi

build_tree "$DEST"
seed_once "$DEST"
ls -R "$DEST"
echo "---"
echo "review, then publish as public <owner>/.github (defaults apply only to public repos)"
