# 05 — GitHub defaults (shared `.github` repo)

One public repo holds the shared community-health files. Any basket-A repo without its own copy inherits these automatically — update once, propagate everywhere. Per-repo copies override; the override reason goes in the file's top comment.

## Requirements

- The repo **must be public**, or defaults do not apply.
- `README.md` and `LICENSE` are **never** defaults — always per-repo ([04](04-root-files.md)).

## Contents

```text
<owner>/.github/
├── CONTRIBUTING.md            # from drydock templates/contributing.md
├── CODE_OF_CONDUCT.md         # from drydock templates/code-of-conduct.md
├── SECURITY.md                # from drydock templates/security.md
├── SUPPORT.md                 # from drydock templates/support.md
├── PULL_REQUEST_TEMPLATE.md   # from drydock templates/pull-request-template.md
├── FUNDING.yml                # from drydock templates/funding.yml (dormant until enabled)
├── ISSUE_TEMPLATE/            # from drydock templates/issue-template/
│   ├── config.yml             # no blank issues
│   ├── bug.yml                # version, platform, repro, expected
│   └── feature.yml            # problem, proposal, alternatives
└── workflow-templates/        # from drydock templates/workflow-templates/
    ├── rust.yml               # fmt + clippy + test (rust-toolchain@stable stays rolling by design; pin per-repo on freeze)
    ├── python.yml             # uv sync + ruff + pytest
    ├── go.yml                 # gofmt + vet + test -race
    └── gradle.yml             # ./gradlew check (Java 21)
```

## Assembly

`scripts/assemble-github.sh <dest>` builds this tree from `templates/` — the script is the single assembly path, no hand-copying. Then: review the output, publish as **public** `<owner>/.github`, and adopt fleet-wide by deleting redundant per-repo copies (keeping documented project-specific ones).

## File ownership (rot-after-adoption control)

- **Managed** (byte-exact, overwritten on every assemble): `CODE_OF_CONDUCT.md`, `PULL_REQUEST_TEMPLATE.md`, `FUNDING.yml`, `ISSUE_TEMPLATE/*`, `workflow-templates/*`.
- **Seeded** (copy-once, never touched after): `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md` — repos customize freely.
- `assemble-github.sh --check <dest>` reports drift of managed files (exit 1). Run it before re-assembling.

## Standards stamp

Adopted repos carry `.drydock.json` (`{"standards": N}`) written by `new-repo.sh` or `assemble-github.sh --stamp`. `audit.sh` warns when the stamp trails the current generation (`DRYDOCK_STANDARDS` in `scripts/lib.sh`). Bump the constant on every backward-incompatible template/governance change — the release checklist in [07](07-lifecycle.md) includes it.

## Build order

The shared `.github` repo does not exist yet — templates and assembly are landed, publication + fleet adoption are the next step.
