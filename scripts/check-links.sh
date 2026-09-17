#!/usr/bin/env bash
# check-links.sh — fail on broken internal markdown links.
# Fenced code blocks are stripped (same rule as audit.sh, shared lib.sh):
# example links inside fences are not structure.
# --inherits-github-defaults: same exemption as audit.sh — CONTRIBUTING.md,
#   SECURITY.md, SUPPORT.md, CODE_OF_CONDUCT.md, PULL_REQUEST_TEMPLATE.md
#   count as satisfied via the shared .github defaults. Inheriting repos run BOTH tools
#   with the flag; without it both fail honestly.
# Usage: check-links.sh [--inherits-github-defaults] <path>
set -u
HERE_CL="$(cd "$(dirname "$0")" && pwd)"
. "$HERE_CL/lib.sh"
INHERITS=0
[ "${1:-}" = "--inherits-github-defaults" ] && { INHERITS=1; shift; }
TARGET="${1:-.}"
BROKEN=0
while IFS= read -r md; do
  dir="$(dirname "$md")"
  while IFS= read -r link; do
    case "$link" in http*|mailto:*|"#"*|"") continue ;; esac
    base="$(basename "$link")"
    case "$base" in CONTRIBUTING.md|SECURITY.md|SUPPORT.md|CODE_OF_CONDUCT.md|PULL_REQUEST_TEMPLATE.md)
      if [ ! -e "$dir/$link" ] && [ "$INHERITS" -eq 1 ]; then continue; fi ;;
    esac
    if [ ! -e "$dir/$link" ]; then
      echo "BROKEN: $md -> $link"; BROKEN=$((BROKEN+1))
    fi
  done < <(nofence "$md" 2>/dev/null | grep -oE '\]\(([^)#]+)(#[^)]*)?\)' | sed -E 's/^\]\(//; s/(#[^)]*)?\)$//')
done < <(find "$TARGET" -name '*.md' "${MD_FIND_EXCL[@]}")
if [ "$BROKEN" -eq 0 ]; then echo "links OK ($TARGET)"; else echo "$BROKEN broken link(s)"; exit 1; fi
