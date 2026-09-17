# 02 — Naming

Names are addresses. A wrong address costs every future visitor a redirect in their head. Rules below are grounded in real breakage from the fleet.

## Repository names

1. **Lowercase, hyphens, no underscores, no camelCase.** `night-shift`, not `night_shift`.
2. **The repo name matches the thing it ships.** Binary, package, or book title — one name everywhere: repo, folder, package manager, README title. If the folder is `tool` but the repo is `toolkit`, every clone starts with confusion. Rename the folder.
3. **No username prefixes, no `my-`, no `test-` in permanent repos.** Scaffolds either graduate or get archived (see lifecycle).
4. **Handbooks end in `-handbook`.** The suffix signals "book, not tool" (e.g. `guide-handbook`).

## Local folders

5. **Folder name == repo name, always.** Clone target, local path, and remote agree. Verify: `basename $(pwd)` == repo name == `gh repo view --json name -q .name`.
6. **One project per repo.** An ideas folder or a dotfiles grab-bag is not a repo — it is basket C. Do not force standards onto it; do not let it inherit a foreign remote.

## Remotes

7. **`origin` points at the repo's own remote, never a sibling's.** Real breakage: three local projects once pointed at `dotfiles`. Check after every clone and every remote change:

   ```sh
   git remote get-url origin
   ```

8. **Default branch is `main`.** Short-lived branches: `feat/<slug>`, `fix/<slug>`. No `master`, no `dev` as a permanent second head.

## Files

9. **UPPERCASE for root-level standard files:** `README.md`, `LICENSE`, `SECURITY.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md`.
10. **Lowercase with hyphens for docs:** `docs/threat-model.md`, never `docs/ThreatModel.md` or `docs/threat_model.md`.
11. **Handbook chapters are numbered:** `docs/00-quickstart.md`, `docs/01-*.md`. Numbers fix reading order; names fix content. Never renumber published chapters — append new ones.
12. **Language variants suffix the BCP 47 tag:** `README.ru.md` next to `README.md`, which stays English. Exceptional, not default — allowed only where bilingualism is the project's feature.

## Enforcement

Naming is checked by `scripts/audit.sh`: folder-vs-remote match, branch name, filename case. Items 5 and 7 double as the manual pre-push check.
