# Audit checklist (manual companion to `scripts/audit.sh`)

Run `audit.sh <path> --type t1|t2|b` first — it covers files, naming, sections, and links mechanically. What it cannot check, verify by hand below.

## Reader test (all types)

- [ ] First screen answers what / who-for / why in under 30 seconds.
- [ ] Install works on a clean machine (container or fresh user, not your laptop).
- [ ] Quickstart produces the promised visible result.
- [ ] Demo GIF/screenshot matches the current version.
- [ ] Every badge resolves and reflects reality (no permanently-green decoration).

## Freshness (basket A)

- [ ] No stale flags, renamed commands, or dead anchors (`#section` links).
- [ ] CHANGELOG `Unreleased` matches actual unreleased changes.
- [ ] Version table in SECURITY matches supported releases.

## Tier honesty

- [ ] Basket assignment still correct (opening criteria in `docs/01-tiers.md`).
- [ ] Scaffold-stage repos state stage + graduation requirements.
- [ ] Archived repos carry the banner and the GitHub archive flag.
