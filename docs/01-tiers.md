# 01 — Tiers

Not every project owes the same strictness. Three baskets; assignment is by criteria, not by mood. Re-evaluate a project's basket when its status changes (e.g. scaffold becomes public).

## Basket A — public standard

Full standard: README by template, LICENSE, CHANGELOG, `.github` defaults (inherited or overridden), AI layer, self-audit clean. Applies to repos that are public **or committed to become public**.

Two README variants inside A: **T1** for CLI/tools/libraries, **T2** for handbooks/docs. An agent-framework repo is the natural special case — its README and `AGENTS.md` serve as the reference implementation, audited rather than rewritten.

Scaffold-stage projects stay in A but state their stage honestly in the README: what works, what does not, what graduation requires.

Illustration: a fleet might hold `atlas-cli` (T1, active), `guide-handbook` (T2, active), and `pilot` (T1, scaffold) in this basket.

## Basket B — local minimum

A short README for the maintainer's own future self (~40–60 lines): what it is, status, commands, layout. No governance files, no publication polish, no audit obligation.

Illustration: a personal-only utility such as `scratch-tool`.

## Basket C — out of scope

Personal, archival, or idea-stage material the system does not touch. No requirements at all.

Illustration: dotfiles, idea folders, frozen experiments.

## Criteria for opening (B/C → A)

Open a project when **all** of these hold:

1. It does something a stranger can use or learn from within 30 minutes.
2. Its README can honestly promise install + quickstart that work on a clean machine.
3. The maintenance contract is accepted: issues answered, security reports receivable, releases tagged.
4. No secrets, credentials, or personal data in history (rewrite or stay closed).

If any item fails, the project stays where it is. "Will open someday" without a date is basket C.

## Drift note

Membership lists rot. The machine-readable list is `registry.json` next to this book — `scripts/audit-fleet.sh` walks it and prints the fleet drift number (`FAIL=`/`WARN=` totals). That file is maintainer-local data (untracked; start from `registry.example.json`). The baskets above stay the human-readable rationale.
