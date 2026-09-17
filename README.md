# Drydock

> A dry dock for repositories: operating standards plus checks that enforce them. Bring a repo in, bring it up to standard.

[![CI](https://img.shields.io/github/actions/workflow/status/zyrophix/drydock/ci.yml)](https://github.com/zyrophix/drydock/actions)
[![License](https://img.shields.io/badge/License-CC_BY--SA_4.0-green.svg)](LICENSE)
[![Standards](https://img.shields.io/badge/standards-1-green.svg)](facts.json)

## Why this handbook exists

Repository fleets drift. Each new repo starts as a copy of an older one that has already drifted — READMEs with no shared section order, missing licenses, remotes pointing at siblings, governance files scattered at random. The problem is not writing documentation once. The problem is drift.

Drydock addresses drift with two properties:

- **Executable standards.** Every rule ships with a check — a script or a checklist. A standard without a check is a wish.
- **Self-application.** This repo passes its own `audit.sh` in CI. A standard that cannot survive its own carrier is a broken standard.

Intended for maintainers of a repository fleet — from solo to small-team — who prefer enforced structure over per-repo improvisation. Background and field data: [00 — Why](docs/00-why.md).

## Contents

- [00 — Why](docs/00-why.md) — the drift problem and the evidence behind it
- [01 — Tiers](docs/01-tiers.md) — baskets A/B/C: what gets opened, what stays local, what is out of scope
- [02 — Naming](docs/02-naming.md) — repo, folder, branch, and file names
- [03 — README structure](docs/03-readme.md) — section order, per-section rules, anti-patterns
- [04 — Root files](docs/04-root-files.md) — license matrix, CHANGELOG, per-repo vs shared
- [05 — GitHub defaults](docs/05-github-defaults.md) — the shared `.github` defaults repo
- [06 — AI layer](docs/06-ai-layer.md) — `AGENTS.md` standard + `CLAUDE.md` shim
- [07 — Lifecycle](docs/07-lifecycle.md) — scaffold → active → mature → archive
- [Appendix — Audit checklist](docs/appendices/audit-checklist.md) — manual companion to `audit.sh`

## How to read

New to the system: read [00](docs/00-why.md) then [01](docs/01-tiers.md), sort the fleet into A / B / C, and start with the worst README in tier A. Standardizing one repo: [03](docs/03-readme.md) + the matching template in `templates/`. Enforcing fleet-wide: `scripts/audit.sh` + [07](docs/07-lifecycle.md).

## Quickstart

Requires: `bash` 4+ and `git`. No installs, no network. (`python3` only for `audit.sh --json` and `check-facts.sh`; the core audit is pure bash.)

Audit this repo against its own standard:

```sh
./scripts/audit.sh . --type t2
```

Audit any repo (pick the matching type):

```sh
./scripts/audit.sh <path-to-repo> --type t1|t2|b
./scripts/check-links.sh <path-to-repo>
```

Scaffold a new standard repo:

```sh
./scripts/new-repo.sh newtool --type t1 --dir <fleet-dir>
```

Fleet drift number (all basket-A/B repos in `registry.json`; copy `registry.example.json` to start):

```sh
./scripts/audit-fleet.sh            # human table, exit 1 on drift
./scripts/audit-fleet.sh --out audits/latest   # + JSON receipts and audits/TREND.md row
```

## Repo overview

- `docs/` — handbook chapters, numbered in reading order
- `docs/appendices/` — checklists and reference material
- `templates/` — copy-paste standards (READMEs, governance, agent files, CI workflows). Placeholder links inside resolve at copy time and are exempt from link checks
- `scripts/` — executable checks (`audit.sh`, `check-links.sh`, `check-facts.sh`), fleet tools (`audit-fleet.sh`), scaffolding (`new-repo.sh`, `assemble-github.sh`), MIT-licensed
- `.github/workflows/` — CI (audit, scaffold-smoke, markdownlint, links-external, scorecard) on every push
- `facts.json` — single home for restated facts (verified by `scripts/check-facts.sh`); `.last-updated` per area marks the last review
- `registry.example.json` — fleet registry shape with illustrative entries (real registries stay local, untracked)
- `receipt.schema.json` — contract for `audit.sh --json` receipts; `.drydock.json` — standards stamp of this repo
- `audits/TREND.md` — fleet drift trend (rows appended by local runs, not synced)
- `CITATION.cff`, `CHANGELOG.md`, `LICENSE` — citation, history, terms

## Roadmap

Shipped in 0.1: chapters 00–07, README templates T1/T2/B, governance templates, `audit.sh` / `new-repo.sh` / `check-links.sh` / `audit-fleet.sh` / `assemble-github.sh` / `check-facts.sh`, self-audit CI, standards stamps, facts single-home.

Planned: shared `.github` defaults publication, fleet pilot adoptions, drift work queue (`--create-issues`), agent-file validators as CI complements.

## Principles

- A standard without a check is a wish.
- Two clicks max: any maintainer question is answered within two clicks from a README.
- Honest stages: scaffold status is stated in the README, not hidden.
- Tiers, not uniformity: public, local, and out-of-scope get different strictness.
- Self-application: drydock passes its own audit.

## Contributing

Issues and PRs welcome: branch off `main`, keep CI green (`check-links.sh` + self-`audit.sh` run on every push). Prose contributions are licensed CC BY-SA 4.0, script contributions MIT, per the License section below.

## License

Docs and templates: [CC BY-SA 4.0](LICENSE). Scripts (`scripts/`): MIT — see [scripts/LICENSE-MIT](scripts/LICENSE-MIT).
