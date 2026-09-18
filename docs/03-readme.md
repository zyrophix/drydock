# 03 — README structure

One section order for the whole fleet. Readers transfer knowledge between repos; agents parse predictably. Three variants share the skeleton and differ in emphasis.

## The order (all variants)

1. Title + one-liner
2. Badges (1–5, signal only)
3. Demo or map
4. Features / Why
5. Install (T1) or How to read (T2)
6. Quickstart
7. Usage / Configuration
8. Repo overview
9. Contributing
10. License

Omit a section only with reason; never reorder. Target length 100–300 lines — the rest lives in `docs/`.

## Section requirements

| # | Section | Answers | Rules |
| --- | --- | --- | --- |
| 1 | `# name` + one plain sentence | What is this, who is it for? | No "this project is…". Verb first: "Tracks per-process traffic." Matches the GitHub repo description. |
| 2 | Badges | Alive? Usable? Legal? | 1–5, signal only (tools: 3–5 recommended — CI, release, license + ecosystem). Zero badges fails audit; a wall fails audit. Drop always-green decoration. |
| 3 | Demo (T1) / Map (T2) | What does it do / how is the book organized? | T1: screenshot or GIF under 1 MB, stored in-repo (`assets/`). T2: chapter map with one-line per chapter. No external image hosts. |
| 4 | Features / Why | Why this and not the alternative? | Comparison table when a live rival shapes the reader's decision; otherwise a properties list + honest limits. Name the concrete alternative only if the comparison stays true without maintenance. |
| 5 | Install / How to read | How do I get it running / where do I start? | Exact copy-paste commands, tested on a clean machine. Prerequisites stated *above* the command, with versions. T2: reading paths per level instead. |
| 6 | Quickstart | Can I succeed in 30 seconds? | ≤3 steps from install to visible result. If it takes more, simplify onboarding, not the docs. |
| 7 | Usage / Config | How do I use it for real? | Most common case first, self-contained snippets with expected output. Full option tables collapsible or in `docs/`. |
| 8 | Repo overview | Where is what? | Directory map with one line per entry. Mandatory when the tree is non-obvious. |
| 9 | Contributing | How do I help? | One line minimum + link to `CONTRIBUTING.md` (inherited from the shared `.github` defaults counts). |
| 10 | License | Can I legally use it? | Name + SPDX identifier + link. Always last. |

## Anti-patterns (instant fail in audit)

- Badge wall pushing the one-liner below the fold.
- Table of contents before the reader knows what the project is.
- Install command that fails on a clean machine.
- Features described, never shown.
- Stale flags, renamed commands, dead links.
- Screenshots replacing text (images complement, never substitute).
- Skipped heading levels (`#` → `####`).

## Templates

Copy, fill, delete nothing without reason:

- [T1 — CLI / tool / library](../templates/readme-t1-cli.md)
- [T2 — handbook / docs](../templates/readme-t2-handbook.md)
- [B — local minimum](../templates/readme-tb-local.md)

Placeholder links inside templates (`<slug>`, `LICENSE`, `CONTRIBUTING.md`, `assets/demo.gif`) resolve when copied into a real repo — `templates/` is exempt from link checks, in this repo and in `audit.sh`.
