# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
for scripts and templates (docs prose is versioned by date, not numbers).

## [Unreleased]

## [0.1.0] — 2026-09-17

### Added

- Handbook chapters 00–07: drift evidence, tiers A/B/C, naming, README
  structure (T1/T2/B), root files and license matrix, shared `.github`
  defaults design, AI layer (`AGENTS.md` standard), lifecycle to archive.
- Templates: README T1/T2/B, governance defaults (CONTRIBUTING, SECURITY,
  CODE_OF_CONDUCT, SUPPORT, issue/PR forms, funding), CI workflows
  (rust/python/go/gradle), agent files.
- Scripts (MIT): `audit.sh` (section order, license matrix, origin match,
  badge bounds, `--json` receipts), `new-repo.sh` (validated scaffolding),
  `check-links.sh`, `audit-fleet.sh` (registry drift number + trend),
  `assemble-github.sh` (shared `.github` assembly + drift check),
  `check-facts.sh` (single-home facts + review markers).
- Machine-readable contracts: `registry.example.json`, `facts.json`,
  `receipt.schema.json`, `.drydock.json` standards stamps,
  managed/seeded file ownership.
- CI: self-audit, scaffold smoke tests, markdownlint, lychee, Scorecard;
  SHA-pinned Actions; protected main branch.

### Sources

- Verification receipts: `edithatogo/repository-standards`.
- Stamped updates, managed/seeded split: `sebastian-software/standards`.
- `facts.json` single-home: `repository-standards/core` (R4).
- `.last-updated` markers: `niclaslindstedt/oss-spec`.
- Link-only CoC, symlink discipline: `oss-spec`.
- `.github` fallback mechanics: tenthirtyam.org `.github` dispatches.
