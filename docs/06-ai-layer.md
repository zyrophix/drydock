# 06 — AI layer

Coding agents are a real audience for every basket-A repo. The AI layer answers one question: what must an agent know before touching this code that it cannot reliably infer? Everything else is noise that burns context and causes confident mistakes.

## Files

| File | Role | Rule |
| --- | --- | --- |
| `AGENTS.md` | Source of truth. Build/test commands, boundaries, traps, pointers to `docs/`. | Every basket-A code repo has one. ~100 lines max. |
| `CLAUDE.md` | Thin shim for Claude Code, which does not read `AGENTS.md` natively. | One import line + Claude-only additions, if any. Never a second copy of the rules. |
| Nested `AGENTS.md` | Subtree-specific facts (monorepo packages, divergent toolchains). | Only where the subtree genuinely differs. Closest file to the edited code wins. |

Reference implementation pattern: an agent-framework repo carrying `AGENTS.md` operating rules + a one-line `CLAUDE.md` shim. Templates: [agents.md](../templates/agents.md) (copy as `AGENTS.md`), [claude.md](../templates/claude.md) (copy as `CLAUDE.md`).

## What goes in

- **Exact commands with working directory and flags.** Distinguish the fast check from the expensive suite (`cargo test --lib` vs full E2E; "takes ~20 min, run once at the end").
- **Boundaries.** Generated code, migrations, lockfiles — what not to edit directly and what to run instead.
- **Known traps.** The non-obvious failure an agent repeats: missing services, required env, platform-only tests.
- **Pointers, not encyclopedias.** Architecture lives in `docs/`; `AGENTS.md` links to it.

## What stays out

Vague ideals ("write clean code"), dependency inventories (the manifest is fresher), duplicated README content, one-off task requirements (those belong in the task prompt), and anything tooling already enforces (formatters, linters, CI). Never secrets or credentials.

## Maintenance

Add a rule when an agent repeats a costly mistake or a review catches something it could not infer. Remove it when the repo or tooling makes it obsolete. Review quarterly; stale instructions mislead worse than none.

## Enforcement honesty

The `audit.sh` AI checks are WARN (advisory), not FAIL — by design, not by omission. A solo fleet cannot afford hard gates on judgment-heavy content (is this `AGENTS.md` *good*?), so the standard enforces *presence and shape* (file exists, CLAUDE is a shim/symlink, no duplicated copies) and leaves *quality* to review. If your fleet grows reviewers, promote these to FAIL.
