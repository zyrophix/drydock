# 04 — Root files

Every basket-A repo carries the same root. What is shared lives in the shared `.github` defaults repo ([05](05-github-defaults.md)); what is per-repo is listed here. No exceptions without a reason written in the repo.

## Per-repo (mandatory)

| File | Rule |
| --- | --- |
| `README.md` | By template ([03](03-readme.md)). |
| `LICENSE` | From the matrix below. **Never inherited from defaults** — the file must ship with clones and packages. |
| `CHANGELOG.md` | Keep a Changelog format. Updated on every release; `Unreleased` section at top. |
| `.gitignore` | Language-appropriate (Rust `target/`, Python `.venv/` + `__pycache__/`, Go binaries, Java `build/`). |
| `.editorconfig` | Root `[*]` block: charset, LF, trailing-whitespace trim, final newline. |

## Per-repo (conditional)

| File | When |
| --- | --- |
| `ARCHITECTURE.md` | Non-obvious internals (eBPF fallback chains, P2P signaling). Link from README §8. |
| `PRIVACY.md` | Handles user data (traffic, telemetry). Required wherever user data is stored or transmitted. |
| `CITATION.cff` | Someone might cite it. Cheap to add, impossible to reconstruct later. |

## License matrix

| Project kind | License | Why |
| --- | --- | --- |
| Rust | Dual MIT **+** Apache-2.0 (`LICENSE-MIT`, `LICENSE-APACHE`) | Ecosystem convention. |
| Python / Go / C++ / Java | MIT | Single permissive license, least friction. |
| Handbook content (prose) | CC BY-SA 4.0 | Code samples inside stay MIT where marked. |
| `drydock` itself | CC BY-SA 4.0 (docs/templates) + MIT (`scripts/`) | Content + tooling split. |

## Shared (inherited, override only with reason)

`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `SUPPORT.md`, issue/PR templates — from the shared `.github` defaults repo. A repo keeps its own copy only when it has project-specific rules. Override reason goes in the file's top comment.

Inheritance is real: `audit.sh --inherits-github-defaults` treats links to these files as satisfied without local copies, and marks them `(inherited)` in the report. Without the flag, a missing local file fails the link check — so CI for repos that inherit must pass the flag.

## Templates

- [CONTRIBUTING (default)](../templates/contributing.md)
- [SECURITY (default)](../templates/security.md)
- [CODE_OF_CONDUCT (link-first)](../templates/code-of-conduct.md)
- [SUPPORT (default)](../templates/support.md)
- [PULL_REQUEST_TEMPLATE](../templates/pull-request-template.md)
- [FUNDING.yml (dormant)](../templates/funding.yml)
- [ISSUE_TEMPLATE/](../templates/issue-template/bug.yml) (`bug.yml`, `feature.yml`, `config.yml`)
- [workflow-templates/](../templates/workflow-templates/rust.yml) (`rust.yml`, `python.yml`, `go.yml`, `gradle.yml`)
