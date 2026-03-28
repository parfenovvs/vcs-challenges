# Challenge 4 — The Stack Collapse: jj Solution

## Overview

After a squash-merge, the base of your stack (`feat/a`) has been rewritten as a new
commit on `main`. The remaining stack branches (`feat/b`, `feat/c`) are now dangling
off the old `feat/a` commit. We need to rebase them onto updated `main`, dropping
the redundant `feat/a` from the chain.

## Starting State

```
@  (empty working copy)
│
│ ○  feat/c   — feat: add feature_c
├─╯
○  feat/b   — feat: add feature_b
│
○  feat/a   — feat: add feature_a   ← OLD, orphaned
│
│ ◆  main    — feat: add feature_a (#1)   ← squash commit
├─╯
◆  chore: initial project setup
```

## Step 1 — Initialize jj

```bash
jj git init --colocate
```

This colocates jj alongside the existing `.git` directory. jj imports the git history
and lets you use both tools transparently.

## Step 2 — Rebase `feat/b` onto `main`, dropping `feat/a`

```bash
jj rebase -r <feat/b-change-id> -d main
```

The `-r` flag rebases **only that single revision** (not its ancestors), then
automatically rebases all of its descendants on top of the result. This is the
key difference from `-s` (which would drag the entire `feat/a → feat/b` subtree).

Because `feat/b`'s diff adds only `feature_b()` on top of whatever its parent
provides, and `main` already contains `feature_a()` via the squash commit, the
rebase applies cleanly.

`feat/c` gets auto-rebased as a descendant, but it ends up with a conflict because
it is now parented on the old `feat/a` (which is no longer an ancestor of `main`).

## Step 3 — Rebase `feat/c` onto the new `feat/b`

```bash
jj rebase -r <feat/c-change-id> -d <feat/b-change-id>
```

Again `-r` for a single revision. jj resolves the conflict automatically: the
previously conflicting content disappears because the new parent already contains
both `feature_a()` and `feature_b()`, and `feat/c` only adds `feature_c()`.

## Step 4 — Push both bookmarks

```bash
jj git push --bookmark feat/b
jj git push --bookmark feat/c
```

jj performs a force-push for bookmarks that have moved (equivalent to
`git push --force-with-lease`), but only after verifying the remote tip still
matches what was last fetched.

## Final State

```
○  feat/c   — feat: add feature_c
│
○  feat/b   — feat: add feature_b
│
◆  main     — feat: add feature_a (#1)
│
◆  chore: initial project setup
```

```bash
git log --oneline main..feat/b
# fd0cb1f feat: add feature_b

git log --oneline main..feat/c
# 2209159 feat: add feature_c
# fd0cb1f feat: add feature_b
```

## Key jj Insights

### `-r` vs `-s` in `jj rebase`

| Flag | Meaning |
|------|---------|
| `-s <rev>` | Rebase the **subtree** rooted at `<rev>` (rev + all descendants) |
| `-r <rev>` | Rebase **only that revision**; descendants are automatically rebased on top of the result |

Using `-r` is what lets you "slice" a single commit out of a stack and land it
directly on a new base — exactly what `git rebase --onto` does but with a simpler
syntax.

### Automatic descendant rebasing

Whenever jj moves a commit (via `rebase -r`, `abandon`, `squash`, etc.) it
always rebases all descendants automatically. You never need to manually chase
down child branches.

### Conflicts are stored, not blocking

When `feat/c` ended up with a conflict after step 2, jj did **not** abort or ask
for immediate resolution. The conflict was stored inside the commit itself (marked
with `×` in `jj log`). This lets you continue working and resolve later — or, as
in step 3, let a subsequent rebase resolve it automatically.

### Change IDs survive rewrites

`feat/b`'s change ID (`oylrqmyy...`) stayed the same even after the rebase changed
its commit hash. This means you can always refer to a logical change by its stable
ID regardless of how many times it has been rebased.
