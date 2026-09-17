#!/usr/bin/env bash
# check-facts.sh — verify facts.json is the single home for restated facts.
# Checks: standards == lib.sh, chapters == docs/0*.md, template lists == templates/
# dirs, fleet counts == registry.json, .last-updated review markers fresh.
# Usage: check-facts.sh (run from drydock root; also a CI step).
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE" || exit 1
FAIL=0
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
ok()  { echo "PASS: $1"; }
. ./scripts/lib.sh

F=./facts.json
# Fleet counts validate against the TRACKED example registry (the contract).
# A maintainer-local registry.json (untracked) may hold any fleet.
REG_F=./registry.example.json
[ "$(python3 -c "import json; print(json.load(open('$F'))['standards'])")" = "$DRYDOCK_STANDARDS" ] \
  && ok "facts.standards == lib.sh ($DRYDOCK_STANDARDS)" || bad "facts.standards != lib.sh ($DRYDOCK_STANDARDS)"

check_list() { # $1=facts key $2=glob $3=strip-suffix-mode(dot-md|raw)
  expected="$(python3 -c "import json; print(' '.join(sorted(json.load(open('$F'))['$1'])))")"
  actual=""
  for f in $2; do
    b="$(basename "$f")"
    [ "$3" = "dot-md" ] && b="${b%.md}"
    actual="$actual $b"
  done
  actual="$(printf '%s' "$actual" | tr ' ' '\n' | grep -v '^$' | sort | tr '\n' ' ' | sed 's/^ //;s/ $//')"
  [ "$expected" = "$actual" ] && ok "facts.$1 matches disk" || bad "facts.$1 mismatch: want [$expected] got [$actual]"
}
check_list chapters "./docs/0*.md" dot-md
check_list templates_root "./templates/*.md ./templates/*.yml" raw
check_list templates_issue "./templates/issue-template/*.yml" raw
check_list templates_workflows "./templates/workflow-templates/*.yml" raw

N_REG="$(python3 -c "import json; print(len(json.load(open('$REG_F'))['repos']))")"
N_FACT="$(python3 -c "import json; print(json.load(open('$F'))['fleet']['repos'])")"
[ "$N_REG" = "$N_FACT" ] && ok "fleet count $N_FACT == registry" || bad "fleet count facts=$N_FACT registry=$N_REG"

B_MIN="$(python3 -c "import json; print(json.load(open('$F'))['badges']['min'])")"
B_MAX="$(python3 -c "import json; print(json.load(open('$F'))['badges']['max'])")"
[ "$B_MIN" = "$BADGE_MIN" ] && [ "$B_MAX" = "$BADGE_MAX" ] \
  && ok "facts.badges bounds == lib.sh ($BADGE_MIN-$BADGE_MAX)" \
  || bad "facts.badges {$B_MIN,$B_MAX} != lib.sh ($BADGE_MIN-$BADGE_MAX)"

for d in docs templates scripts; do
  marker="$d/.last-updated"
  [ -f "$marker" ] || { bad "$marker missing"; continue; }
  reviewed="$(cat "$marker")"
  last_change="$(git log -1 --format=%cs -- "$d" 2>/dev/null || echo "$reviewed")"
  if [[ "$reviewed" < "$last_change" ]]; then
    bad "$d changed ($last_change) after review marker ($reviewed) — review and bump $marker"
  else
    ok "$d review marker fresh ($reviewed)"
  fi
done

# receipts, if present (audits/latest/ is gitignored; CI skips this when absent)
if [ -d ./audits/latest ] && ls ./audits/latest/*.json >/dev/null 2>&1; then
  if python3 - ./receipt.schema.json ./audits/latest <<'EOF'; then
import glob, json, sys
schema = json.load(open(sys.argv[1]))
req = schema["required"]
checks_req = schema["properties"]["checks"]["items"]["required"]
sum_req = schema["properties"]["summary"]["required"]
types = set(schema["properties"]["type"]["enum"])
results = set(schema["properties"]["result"]["enum"])
cresults = set(schema["properties"]["checks"]["items"]["properties"]["result"]["enum"])
n = 0
for f in sorted(glob.glob(sys.argv[2] + "/*.json")):
    r = json.load(open(f))
    assert all(k in r for k in req), f
    assert r["type"] in types and r["result"] in results, f
    assert all(all(k in c for k in checks_req) and c["result"] in cresults for c in r["checks"]), f
    assert all(k in r["summary"] for k in sum_req), f
    n += 1
print(str(n) + " receipts conform")
EOF
    ok "receipts conform to receipt.schema.json"
  else
    bad "receipt(s) violate receipt.schema.json"
  fi
else
  echo "SKIP: no local receipts (run audit-fleet.sh --out first)"
fi

[ "$FAIL" -eq 0 ] && echo "facts OK" || { echo "$FAIL fact(s) drifted"; exit 1; }
