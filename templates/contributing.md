<!-- Default CONTRIBUTING.md for the shared .github defaults repo. Repos with project-specific rules keep their own copy. -->
# Contributing

Thanks for helping. This is the shared default for all fleet projects; a repo with extra rules links them at the top of its own file.

## Setup

```sh
git clone https://github.com/<owner>/<repo>
cd <repo>
```

Build / test / lint per ecosystem:

| Ecosystem | Build | Test | Lint |
|---|---|---|---|
| Rust | `cargo build` | `cargo test` | `cargo clippy -- -D warnings`, `cargo fmt --check` |
| Python (uv) | `uv sync` | `uv run pytest` | `uv run ruff check`, `uv run ruff format --check` |
| Go | `go build ./...` | `go test ./... -race` | `go vet ./...`, `gofmt -l .` |
| Gradle (Java) | `./gradlew build` | `./gradlew test` | `./gradlew check` |

## Workflow

1. Fork → branch (`feat/<slug>` or `fix/<slug>`) → PR against `main`.
2. One concern per PR. Green CI before review.
3. Commits follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `ci:`, `chore:`.

## What good PRs include

- The change, the reason, and how it was tested.
- Updated tests for behavior changes; updated README/CHANGELOG when user-visible.
- No unrelated drive-by refactors.

## Conduct and security

Behavior follows the [Code of Conduct](CODE_OF_CONDUCT.md). **Never report vulnerabilities via public issues** — see the [Security Policy](SECURITY.md).
