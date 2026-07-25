---
description: Commit the pending diff as one commit per intent, pre-grouped from the .claude/edit-groups hints the claude-track-edits hook recorded. Live git diff is authoritative; edit-groups are hints only, so edits made outside Claude are handled too.
---

# /commit-slices

Turn the current pending changes into **one commit per intent**, using
`.claude/edit-groups/*.json` (written by the `claude-track-edits` PostToolUse
hook) as *grouping hints*. The live `git diff` is authoritative for what gets
staged — edit-groups only suggest how to group it. Because of that, changes made
**outside** Claude are handled fine: they just land in an `uncategorized` slice
instead of being lost.

This builds on the `slice-commits` skill's `hunk_slice.py`, which does the actual
hunk/line staging against `HEAD` (never touching the working tree, fully
reversible). Read that skill if you need the ID scheme / plan schema details.

## Steps

1. **Read the intent hints.** For each `.claude/edit-groups/*.json` (skip the
   `.snapshots/` dir and any `*.lock`), collect:
   - the category slug (filename without `.json`),
   - its `description`,
   - the set of `file`s across `edits[]`, and each edit's rough line ranges from
     `edits[].hunks[].start_line` / `line_count`.

   This is the intent map: *file (+ approximate line ranges) → category*. Treat
   it as a hint only — line numbers drift and a file may have changed since.

2. **Get the authoritative diff.** Locate the slice-commits script (usually
   `~/.claude/skills/slice-commits/scripts/hunk_slice.py`) and run:
   ```
   nix-shell -p python3 --run "python3 <script> show"
   ```
   Use `nix-shell -p python3` on this machine: bare `python3` resolves to a
   broken macOS stub (`/usr/bin/python3`) that errors with `tool 'python3' not
   found`, so a plain-`python3` check passes but execution fails. Read the whole
   `F/H/L` inventory — IDs are positional to *this* invocation, so build the plan
   against this exact output.

3. **Assign every change ID to a category:**
   - A file claimed by **exactly one** category → assign the whole file (`F<n>`)
     to it.
   - A file claimed by **multiple** categories → split at hunk/line level, using
     each category's recorded line ranges + `description` to decide which
     hunk/line goes where.
   - A file/hunk/line claimed by **no** category → put it in a slice named
     `uncategorized` (edits made outside Claude, or whose hint was already
     pruned). **Never drop anything silently** — surface what landed here.
   - Seed each slice's commit subject from the category `description`, but match
     the repo's real convention (`git log --oneline -20`).

4. **Write the plan JSON to scratch** — *outside* the repo (a plan file inside
   the repo shows up as its own untracked change and contaminates the next
   `show`). One slice per non-empty category. Schema: see the slice-commits
   skill (`{"slices":[{"subject":...,"body":...,"changes":[...]}]}`). If this
   session's commits carry a `Co-Authored-By:` trailer, add it to each `body`.

5. **Dry-run** and iterate until coverage is what you intend:
   ```
   nix-shell -p python3 --run "python3 <script> apply-plan <plan.json> --dry-run"
   ```

6. **Show the user** the slice list, which category maps to which commit, and
   exactly what fell into `uncategorized`. Get a quick go-ahead — the grouping is
   a judgment call even though the operation is reversible.

7. **Execute**, only after go-ahead:
   ```
   nix-shell -p python3 --run "python3 <script> apply-plan <plan.json> --execute"
   ```
   It prints the original HEAD sha; undo the whole run with
   `git reset --mixed <that-sha>` (working tree is never touched).

8. **Prune consumed hints.** For every category committed **in full**, delete its
   `.claude/edit-groups/<slug>.json` and `<slug>.json.lock`. Leave hints for
   anything left pending (partially committed or intentionally excluded). Do
   **not** touch `.claude/edit-groups/.snapshots/` — those baselines self-correct
   against the new HEAD, and deleting a snapshot for a partially-committed file
   would cause the hook to re-capture the still-pending changes on its next edit.
   Report what was pruned and what was kept.

## Notes

- Trust the live `show`, not the stored hunk patches — edit-groups patches are
  point-in-time and go stale the moment anything else touches a file.
- If nothing consumes a category (e.g. it only ever tracked files now deleted or
  reverted), it'll simply produce no changes to assign; drop it from the plan and
  prune it.
