# 00 — Why

The problem drydock solves is documentation drift across a fleet of repositories. This chapter grounds it in field data so the standard never floats free of evidence.

## Field data

A 21-directory fleet at the time of writing: three main languages plus systems and docs-only handbooks, roughly half hosted remotely, the rest local-only. Representative symptoms observed:

1. **README spread 0–660 lines with no shared section order.** One project opens with install steps, another with philosophy, a third has an empty `README.md`, several have none at all. A reader cannot transfer knowledge from one repo to the next.
2. **Missing licenses.** Unlicensed code is "all rights reserved" by default — unusable for companies and contributors.
3. **Governance at random.** `CONTRIBUTING.md` here, `SECURITY.md` there, `CHANGELOG.md` somewhere else, issue templates in one place. Each invented independently.
4. **Broken git hygiene.** Local projects pointing `origin` at unrelated repos, folder names disagreeing with repo names (e.g. folder `tool` vs repo `toolkit`), projects with no remote at all.
5. **Copy-paste inheritance.** Each new repo bootstraps from whichever old repo was open in the editor — inheriting whatever drift that repo had accumulated.

## Why "write better docs" is not the fix

Every symptom above was once fixed by hand, in one repo. Fixes do not propagate and do not persist. The durable fixes are structural:

- **Tiers** ([01](01-tiers.md)) — decide once which strictness each project owes, instead of re-deciding per repo.
- **Templates** — new repos start from a template, not from a random sibling.
- **Defaults** — shared files live in one place (a `.github` defaults repo) instead of being copied N times.
- **Checks** — `audit.sh` re-detects drift mechanically, on demand and in CI.

That is what the rest of this book builds, in roadmap order.
