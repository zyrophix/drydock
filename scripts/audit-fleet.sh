#!/usr/bin/env bash
# audit-fleet.sh — run audit.sh over every repo in the registry, print the drift number.
# Registry: ./registry.json if present, else ./registry.example.json.
# Usage: audit-fleet.sh [--root DIR] [--out DIR]
#   --root DIR: fleet location (default: $HOME/fleet).
#   --out DIR:  write per-repo JSON receipts (<name>.json) + append TREND.md row.
#               Run locally on a schedule, e.g. cron: 0 6 * * * <drydock>/scripts/audit-fleet.sh --root <fleet-dir> --out <drydock>/audits/latest >/dev/null
# Exit 1 if any repo FAILs. Skips entries whose local dir is absent.
set -u
ROOT="$HOME/fleet"; OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:?missing DIR}"; shift 2 ;;
    --out) OUT="${2:?missing DIR}"; shift 2 ;;
    -h|--help) echo "usage: audit-fleet.sh [--root DIR] [--out DIR]"; exit 0 ;;
    *) echo "unknown arg $1"; exit 1 ;;
  esac
done
HERE="$(cd "$(dirname "$0")/.." && pwd)"
AUDIT="$HERE/scripts/audit.sh"
REG="$HERE/registry.json"
[ -f "$REG" ] || REG="$HERE/registry.example.json"
[ -n "$OUT" ] && mkdir -p "$OUT"
TOTAL_FAIL=0; TOTAL_WARN=0; N=0; FAILED=""; SKIPPED=""
while IFS='|' read -r name type local; do
  dir="$ROOT/$local"
  if [ ! -d "$dir" ]; then echo "SKIP: $name (no $dir)"; SKIPPED="$SKIPPED $name"; continue; fi
  N=$((N+1))
  if [ -n "$OUT" ]; then
    if bash "$AUDIT" --type "$type" --json "$dir" > "$OUT/$name.json" 2>/dev/null; then rc=0; else rc=1; fi
    f="$(python3 -c "import json; print(json.load(open('$OUT/$name.json'))['summary']['fail'])")"
    w="$(python3 -c "import json; print(json.load(open('$OUT/$name.json'))['summary']['warn'])")"
    summary="PASS=? FAIL=$f WARN=$w ($name, type $type)"
  else
    out="$(bash "$AUDIT" --type "$type" "$dir" 2>&1 || true)"
    summary="$(printf '%s' "$out" | tail -n 1)"
    f="$(printf '%s' "$summary" | sed -E 's/.*FAIL=([0-9]+).*/\1/')"
    w="$(printf '%s' "$summary" | sed -E 's/.*WARN=([0-9]+).*/\1/')"
  fi
  TOTAL_FAIL=$((TOTAL_FAIL+f)); TOTAL_WARN=$((TOTAL_WARN+w))
  [ "$f" -gt 0 ] && FAILED="$FAILED $name($f)" || true
  printf '%-28s %s\n' "$name" "FAIL=$f WARN=$w"
done < <(python3 -c "
import json
reg = json.load(open('$REG'))
for r in reg['repos']:
    print(r['name'] + '|' + r['type'] + '|' + r['local'])
")
echo "---"
echo "fleet: repos=$N drift FAIL=$TOTAL_FAIL WARN=$TOTAL_WARN${FAILED:+ | failing:$FAILED}${SKIPPED:+ | missing:$SKIPPED}"
if [ -n "$OUT" ]; then
  TREND="$(dirname "$OUT")/TREND.md"
  [ -f "$TREND" ] || printf '# Fleet drift trend\n\n| Date | Repos | FAIL | WARN |\n| --- | --- | --- | --- |\n' > "$TREND"
  TODAY="$(date +%F)"
  grep -v "^| $TODAY |" "$TREND" > "$TREND.tmp" && mv "$TREND.tmp" "$TREND"
  printf '| %s | %s | %s | %s |\n' "$TODAY" "$N" "$TOTAL_FAIL" "$TOTAL_WARN" >> "$TREND"
  echo "receipts in $OUT, trend in $TREND"
fi
[ "$TOTAL_FAIL" -eq 0 ]
