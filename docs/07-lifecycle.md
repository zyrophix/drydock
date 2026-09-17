# 07 — Lifecycle

Repos move through stages. The stage is stated honestly in the README — a scaffold pretending to be mature destroys trust faster than a scaffold admitting it.

## Stages

| Stage | Meaning | README shows | Example |
| --- | --- | --- | --- |
| `scaffold` | Proving the idea; APIs churn; may never ship | Status line + what works / what does not / what graduation requires | e.g. a P2P prototype: hole-punch works, relay in phase 2 |
| `active` | Public, usable, maintained; breaking changes possible | Full T1/T2 README, CHANGELOG, issues answered | most of basket A |
| `mature` | Stable API, mostly fixes; breaking changes rare and announced | All of active + supported-versions table in SECURITY | e.g. a stable CLI at v3 with a versions table |
| `archived` | Read-only; no issues, no fixes; GitHub archive flag set | Banner: why archived + suggested successor, if any | e.g. a superseded dotfiles repo |

Basket C is not a stage — it is outside the lifecycle entirely.

## Transitions

- **scaffold → active:** opening criteria from [01-tiers](01-tiers.md) all hold + full-standard audit clean.
- **active → mature:** three consecutive months without breaking changes + SECURITY versions table filled.
- **any → archived:** superseded, unmaintained 12+ months with no intent to resume, or idea proven wrong. Archive, do not delete — links and clones survive.
- **archived → active:** unarchive + fresh audit. Rare; treat as a new opening.

## Release checklist (active+)

1. `CHANGELOG.md` `Unreleased` drained into a version section (Keep a Changelog).
2. README install + quickstart re-verified on a clean machine.
3. Tag `vX.Y.Z` (SemVer); binaries attached where applicable.
4. `audit.sh` clean; the rest is the manual checklist in [appendices/audit-checklist.md](appendices/audit-checklist.md).

## Branch protection (solo-fleet note)

Public drydock carried a ruleset: no deletion, no force-push, no bypass actors. Required status checks were deliberately **not** in the ruleset — they deadlock solo direct-push (a check cannot pass on a commit that cannot be pushed). CI still runs on every push and gates pull requests. Revisit if the repo gains co-maintainers: then PR-required + strict checks become the honest setting.

Caveat: GitHub gates both rulesets and classic branch protection behind Pro for *private* repos. While this repo is private on a Free plan, protection is local discipline only (no force-push habit + tags per release). Re-enable the ruleset if it goes public again or upgrades.

## Drydock's own release checklist (this repo)

1–4 above, plus:

5. Bump `DRYDOCK_STANDARDS` in `scripts/lib.sh` when templates/governance changed incompatibly.
6. Restamp this repo (`assemble-github.sh --stamp .`).
7. Regenerate `audits/TREND.md` row (`audit-fleet.sh --out audits/latest`) so the drift number is current.
