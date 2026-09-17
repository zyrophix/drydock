<!-- AGENTS.md template for basket-A code repos. Keep ~100 lines max. Facts only: commands, boundaries, traps, pointers. -->
# Agent instructions for <repo>

<2–3 sentences: what the project is, stack, repo layout. No marketing.>

## Fast path

- Install: `<command, e.g. uv sync / cargo build / go build ./...>`
- Focused check: `<command for the changed area>`
- Full suite: `<command>` (takes about <N> min — run once after focused checks pass)
- Lint/format: `<commands>`

## Boundaries

- Do not edit `<generated/…>` directly; run `<command>` from `<schema/source>` instead.
- Ask before adding production dependencies or changing migrations.
- <repo-specific rule, e.g. risk-gating invariants>

## Known traps

- <trap 1: e.g. integration tests need `<service>` started with `<command>`>
- Package-specific rules live in that package's nested `AGENTS.md`.

## Pointers

- Architecture: `docs/<file>.md`
- Conventions: `<file>`
