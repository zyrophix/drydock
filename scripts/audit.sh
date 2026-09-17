#!/usr/bin/env bash
# audit.sh — check a repo against the drydock standard.
# Usage: audit.sh [--type t1|t2|b] [--inherits-github-defaults] [--json] <path>
#   --inherits-github-defaults: CONTRIBUTING/SECURITY/SUPPORT/CoC links count as
#     satisfied via the shared .github defaults instead of requiring local files.
#   --json: emit a verification receipt (edithatogo-style) on stdout instead of
#     human lines. Requires python3. Consumed by audit-fleet.sh --out.
# FAIL = standard violation (exit 1). WARN = recommended, non-blocking.
set -u
HERE_AUDIT="$(cd "$(dirname "$0")" && pwd)"
. "$HERE_AUDIT/lib.sh"
PASS=0; FAIL=0; WARN=0; JSON=0; CHECKS_FILE=""
say()  { if [ "$JSON" -eq 0 ]; then printf '%s: %s\n' "$1" "$2"; else printf '%s\t%s\n' "$1" "$2" >> "$CHECKS_FILE"; fi; }
pass() { PASS=$((PASS+1)); say PASS "$1"; }
fail() { FAIL=$((FAIL+1)); say FAIL "$1"; }
warn() { WARN=$((WARN+1)); say WARN "$1"; }
usage() { echo "usage: audit.sh [--type t1|t2|b] [--inherits-github-defaults] [--json] <path>"; exit "${1:-0}"; }

TYPE=""; TARGET=""; INHERITS=0
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage 0 ;;
    --json) JSON=1 ;;
    --inherits-github-defaults) INHERITS=1 ;;
    --type) shift_needed=1; continue ;;
    --type=*) TYPE="${arg#--type=}"; shift_needed=0 ;;
    t1|t2|b) [ -n "${shift_needed:-}" ] && [ "$shift_needed" -eq 1 ] && { TYPE="$arg"; shift_needed=0; continue; }; [ -z "$TARGET" ] && TARGET="$arg" ;;
    *) if [ -n "${shift_needed:-}" ] && [ "$shift_needed" -eq 1 ]; then TYPE="$arg"; shift_needed=0;
       elif [ -z "$TARGET" ]; then TARGET="$arg"; else echo "unexpected arg: $arg"; usage 1; fi ;; 
  esac
done
# handle separated "--type t1" form
if [ -n "${shift_needed:-}" ] && [ "$shift_needed" -eq 1 ]; then echo "missing value for --type"; usage 1; fi
case "$TYPE" in t1|t2|b) ;; *) echo "unknown or missing --type (want t1|t2|b)"; usage 1 ;; esac
if [ "$JSON" -eq 1 ]; then
  command -v python3 >/dev/null || { echo "--json requires python3"; exit 1; }
  CHECKS_FILE="$(mktemp)"
fi
[ -n "$TARGET" ] || usage 1
[ -d "$TARGET" ] || { echo "FAIL: $TARGET is not a directory"; exit 1; }
cd "$TARGET" || exit 1
NAME="$(basename "$(pwd)")"
STRICT=1; [ "$TYPE" = b ] && STRICT=0   # basket B: local minimum, most root files optional
need() { if [ "$STRICT" -eq 1 ]; then fail "$1"; else warn "$1 (basket B: advisory)"; fi; }

# text of README with fenced code blocks stripped lives in lib.sh (nofence).
# (Headings/links inside fences are examples, not structure.)

# --- root files ---
if [ -s README.md ]; then pass "README.md exists and is non-empty"; else fail "README.md missing or empty"; fi
if [ -f LICENSE ] || [ -f LICENSE-MIT ]; then
  pass "license file present"
else
  fail "no LICENSE"
fi
if [ -f CHANGELOG.md ]; then pass "CHANGELOG.md present"; else need "no CHANGELOG.md"; fi
if [ -f .gitignore ]; then pass ".gitignore present"; else need "no .gitignore"; fi
if [ -f .editorconfig ]; then pass ".editorconfig present"; else need "no .editorconfig"; fi

# --- license contents vs matrix (docs/04) ---
if [ -f Cargo.toml ]; then
  if [ -f LICENSE-MIT ] && [ -f LICENSE-APACHE ]; then pass "Rust dual license (MIT+Apache)"; else fail "Rust project needs LICENSE-MIT + LICENSE-APACHE"; fi
elif [ -f pyproject.toml ] || [ -f go.mod ] || [ -f build.gradle ] || [ -f CMakeLists.txt ] || [ -f package.json ]; then
  if [ -s LICENSE ] && grep -qi "mit license" LICENSE; then pass "LICENSE is MIT"; else fail "LICENSE missing or not MIT"; fi
else
  if [ -s LICENSE ] && grep -qiE "mit license|apache|creative commons" LICENSE; then pass "LICENSE has recognizable terms"; else fail "LICENSE missing or unrecognizable"; fi
fi

# --- naming: folder vs remote (exact basename match, not substring) ---
if git rev-parse --git-dir >/dev/null 2>&1; then
  pass "git repo initialized"
  ORIGIN="$(git remote get-url origin 2>/dev/null || true)"
  if [ -z "$ORIGIN" ]; then
    warn "no origin remote"
  else
    REPO_PART="${ORIGIN##*[/:]}"; REPO_PART="${REPO_PART%.git}"
    if [ "$REPO_PART" = "$NAME" ]; then
      pass "origin repo name matches folder ($REPO_PART)"
    else
      fail "origin repo '$REPO_PART' != folder '$NAME' ($ORIGIN)"
    fi
  fi
  BRANCH="$(git branch --show-current 2>/dev/null || true)"
  if [ "$BRANCH" = main ]; then pass "default branch is main"; else need "branch is '$BRANCH', expected main"; fi
else
  fail "not a git repo"
fi

# --- README sections: required set + canonical order ---
if [ -s README.md ]; then
  BODY="$(nofence README.md)"
  NBODY="$(printf '%s' "$BODY" | tr -d ' ')"   # spaceless: "How to read" matches Howtoread
  case "$TYPE" in
    t1) REQ="Install Quickstart Usage Contributing License"
        REC="Why Repooverview"
        ORDER="Why Install Quickstart Usage Repooverview Contributing License" ;;
    t2) REQ="Contents Contributing License"
        REC="Why Howtoread"
        ORDER="Why Contents Howtoread Quickstart Repooverview Roadmap Principles Contributing License" ;;
    b)  REQ="Commands"
        REC=""
        ORDER="Commands" ;;
  esac
  for s in $REQ; do
    if printf '%s' "$NBODY" | grep -qiE "^#{1,3}.*$s"; then pass "README has '$s'"; else fail "README missing '$s'"; fi
  done
  for s in $REC; do
    if printf '%s' "$NBODY" | grep -qiE "^#{1,3}.*$s"; then pass "README has '$s'"; else warn "README missing recommended '$s'"; fi
  done
  # order: indices of matched canonical headings must ascend (extra headings ignored)
  IDX=""; OK_ORDER=1
  for s in $ORDER; do
    n="$(printf '%s' "$NBODY" | grep -inE "^#{1,3}.*$s" | head -n 1 | cut -d: -f1)"
    [ -n "$n" ] && IDX="$IDX $n"
  done
  prev=0
  for n in $IDX; do
    if [ "$n" -lt "$prev" ]; then OK_ORDER=0; break; fi
    prev="$n"
  done
  if [ "$OK_ORDER" -eq 1 ]; then pass "section order follows canonical ($ORDER)"; else fail "sections out of canonical order (want: $ORDER)"; fi
  LAST="$(printf '%s' "$BODY" | grep -E '^## ' | tail -n 1 || true)"
  if [ "$TYPE" = b ]; then
    pass "basket B: no License-section requirement"
  else
    case "$LAST" in *[Ll]icense*) pass "License is the last ## section" ;; *) fail "last ## section is not License ($LAST)" ;; esac
  fi
  if printf '%s' "$BODY" | awk '/^#+ /{ n=length($1); if (n>prev+1 && prev>0) bad=1; prev=n } END{ exit bad }'; then
    pass "no skipped heading levels"
  else
    fail "skipped heading level in README"
  fi
  N_BADGES="$(printf '%s' "$BODY" | grep -o 'img.shields.io' | wc -l)"
  if [ "$N_BADGES" -lt "$BADGE_MIN" ]; then
    need "no badges — add CI + license at minimum"
  elif [ "$N_BADGES" -gt "$BADGE_MAX" ]; then
    fail "$N_BADGES badges — max $BADGE_MAX, keep signal only"
  else
    pass "badge count sane ($N_BADGES)"
  fi
fi

# --- standards stamp (lever 2: rot-after-adoption detector) ---
if [ -f .drydock.json ]; then
  STAMP="$(python3 -c "import json; print(json.load(open('.drydock.json')).get('standards','?'))" 2>/dev/null || echo "?")"
  if [ "$STAMP" = "$DRYDOCK_STANDARDS" ]; then
    pass "standards stamp current ($STAMP)"
  elif [ "$STAMP" = "?" ]; then
    warn ".drydock.json unreadable — restamp via assemble/new-repo"
  else
    warn "standards $STAMP < $DRYDOCK_STANDARDS — sync templates (see docs/05)"
  fi
elif [ "$TYPE" != b ]; then
  warn "no .drydock.json stamp — add via new-repo/assemble (see docs/05)"
fi

# --- AI layer (basket A code repos) ---
if [ "$TYPE" = t1 ]; then
  if [ -f AGENTS.md ]; then pass "AGENTS.md present"; else warn "no AGENTS.md"; fi
  if [ -L CLAUDE.md ]; then
    [ "$(readlink CLAUDE.md)" = AGENTS.md ] && pass "CLAUDE.md symlinks to AGENTS.md" || warn "CLAUDE.md symlink points elsewhere"
  elif [ -f CLAUDE.md ]; then
    grep -q "@AGENTS.md" CLAUDE.md && pass "CLAUDE.md shims @AGENTS.md" || warn "CLAUDE.md duplicates AGENTS.md — keep a shim, not a copy"
  else
    warn "no CLAUDE.md"
  fi
  for f in .github/copilot-instructions.md GEMINI.md .cursorrules; do
    if [ -e "$f" ] && [ ! -L "$f" ]; then warn "$f is a copy — symlink to AGENTS.md instead"; fi
  done
fi

# --- internal links (templates/ exempt: placeholders resolve at copy time) ---
BROKEN=0
while IFS= read -r md; do
  dir="$(dirname "$md")"
  while IFS= read -r link; do
    case "$link" in http*|mailto:*|"#"*|"") continue ;; esac
    base="$(basename "$link")"
    case "$base" in CONTRIBUTING.md|SECURITY.md|SUPPORT.md|CODE_OF_CONDUCT.md|PULL_REQUEST_TEMPLATE.md)
      if [ ! -e "$dir/$link" ] && [ "$INHERITS" -eq 1 ]; then
        pass "$base inherited from shared .github defaults"; continue
      fi ;;
    esac
    if [ ! -e "$dir/$link" ]; then say FAIL "broken link in $md -> $link"; BROKEN=$((BROKEN+1)); fi
  done < <(nofence "$md" | grep -oE '\]\(([^)#]+)(#[^)]*)?\)' | sed -E 's/^\]\(//; s/(#[^)]*)?\)$//')
done < <(find . -name '*.md' "${MD_FIND_EXCL[@]}")
if [ "$BROKEN" -eq 0 ]; then pass "no broken internal links"; else FAIL=$((FAIL+BROKEN)); fi

if [ "$JSON" -eq 1 ]; then
  REV="$(git rev-parse --short HEAD 2>/dev/null || echo "uncommitted")"
  [ "$FAIL" -eq 0 ] && RESULT="pass" || RESULT="fail"
  python3 - "$CHECKS_FILE" "$NAME" "$TYPE" "$REV" "$RESULT" "$PASS" "$FAIL" "$WARN" "$DRYDOCK_STANDARDS" <<'EOF'
import json, sys
path, name, type_, rev, result, p, f, w, std = (sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4],
    sys.argv[5], int(sys.argv[6]), int(sys.argv[7]), int(sys.argv[8]), int(sys.argv[9]))
checks = []
for line in open(path, encoding="utf-8"):
    line = line.rstrip("\n")
    if not line or "\t" not in line:
        continue
    level, evidence = line.split("\t", 1)
    checks.append({"name": evidence, "result": level.lower(), "evidence": evidence})
print(json.dumps({"repository": name, "type": type_, "revision": rev, "standards": std,
                  "result": result, "checks": checks,
                  "summary": {"pass": p, "fail": f, "warn": w}}, indent=2))
EOF
  rm -f "$CHECKS_FILE"
else
  echo "---"
  echo "PASS=$PASS FAIL=$FAIL WARN=$WARN ($NAME, type $TYPE)"
fi
[ "$FAIL" -eq 0 ]
