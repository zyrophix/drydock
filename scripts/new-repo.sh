#!/usr/bin/env bash
# new-repo.sh — scaffold a repo from drydock templates.
# Usage: new-repo.sh <name> --type t1|t2|b [--dir DIR] [--license mit|cc-by-sa]
# A fresh scaffold is INCOMPLETE by design: fill placeholders, then run audit.sh for the gap list.
set -euo pipefail
usage() { echo "usage: new-repo.sh <name> --type t1|t2|b [--dir DIR] [--license mit|cc-by-sa]"; exit "${1:-0}"; }
[ $# -ge 1 ] || usage 1
NAME="$1"; shift
case "$NAME" in
  *[^a-z0-9-]*|"") echo "FAIL: name must match ^[a-z0-9-]+\$ (got '$NAME')"; exit 1 ;;
  my-*|test-*) echo "FAIL: no my-/test- prefixes in permanent repos (docs/02)"; exit 1 ;;
esac
TYPE=""; DIR="$HOME/Projects"; LICENSE_KIND=""
while [ $# -gt 0 ]; do
  case "$1" in
    --type) TYPE="${2:?missing value}"; shift 2 ;;
    --type=*) TYPE="${1#--type=}"; shift ;;
    --dir) DIR="${2:?missing value}"; shift 2 ;;
    --dir=*) DIR="${1#--dir=}"; shift ;;
    --license) LICENSE_KIND="${2:?missing value}"; shift 2 ;;
    --license=*) LICENSE_KIND="${1#--license=}"; shift ;;
    -h|--help) usage 0 ;;
    *) echo "unknown arg $1"; usage 1 ;;
  esac
done
case "$TYPE" in t1|t2|b) ;; *) echo "missing or bad --type (want t1|t2|b)"; usage 1 ;; esac
if [ "$TYPE" = t2 ]; then
  case "$NAME" in *-handbook) ;; *) echo "WARN: handbook repos conventionally end in -handbook (docs/02)" ;; esac
fi
HERE="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$DIR/$NAME"
[ -e "$DEST" ] && { echo "FAIL: $DEST already exists"; exit 1; }

mkdir -p "$DEST/docs" "$DEST/assets"
case "$TYPE" in t1) PREFIX="readme-t1" ;; t2) PREFIX="readme-t2" ;; b) PREFIX="readme-tb" ;; esac
cp "$HERE"/templates/"$PREFIX"-* "$DEST/README.md"
sed -i "s|<name>|$NAME|g; s|<repo>|$NAME|g" "$DEST/README.md"
if [ "$TYPE" = t1 ]; then
  cp "$HERE/templates/agents.md" "$DEST/AGENTS.md"
  sed -i "s|<repo>|$NAME|g" "$DEST/AGENTS.md"
  cp "$HERE/templates/claude.md" "$DEST/CLAUDE.md"
  touch "$DEST/assets/.gitkeep"   # demo.gif lands here with the first screenshot
fi
cp "$HERE/.editorconfig" "$DEST/.editorconfig"
if [ "$TYPE" = t1 ]; then
  cat > "$DEST/.gitignore" <<'EOF'
target/
*.egg-info/
__pycache__/
.venv/
dist/
build/
*.test
*.out
EOF
else
  printf 'build/\n.venv/\n' > "$DEST/.gitignore"
fi
if [ "$TYPE" != b ]; then
  cat > "$DEST/CHANGELOG.md" <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]
EOF
fi
case "$LICENSE_KIND" in
  "") echo "FAIL: pass --license mit|cc-by-sa (dual MIT+Apache: copy from an existing Rust repo, see docs/04)"; exit 1 ;;
  mit) cp "$HERE/scripts/LICENSE-MIT" "$DEST/LICENSE" ;;
  cc-by-sa) cp "$HERE/LICENSE" "$DEST/LICENSE" ;;
  *) echo "unknown --license '$LICENSE_KIND' (want mit|cc-by-sa)"; exit 1 ;;
esac
(cd "$DEST" && git init -b main -q && git add -A \
  && git -c user.name=drydock -c user.email=drydock@localhost commit -qm "Scaffold $NAME from drydock ($TYPE)" \
  && echo "scaffolded $DEST")
bash "$HERE/scripts/assemble-github.sh" --stamp "$DEST" >/dev/null && git -C "$DEST" add .drydock.json && git -C "$DEST" -c user.name=drydock -c user.email=drydock@localhost commit -qm "Stamp drydock standards"
echo "next: set origin, fill README placeholders (<user>, demo, commands),"
echo "then run: $HERE/scripts/audit.sh --type $TYPE $DEST  # gap list until green"
