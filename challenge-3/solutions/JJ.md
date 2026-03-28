# Challenge 3 — The Wrong Cherry-Pick (jj solution)

## Overview

In jj, there's no cherry-pick command. Instead you **duplicate** a change (creating
an independent copy with a new change ID) and rebase it where you want it. Undoing
an unwanted commit is just `jj abandon` — descendants are rebased automatically.

## Step-by-step

### 1. Initialize jj in the workspace

```bash
jj git init --colocate
```

### 2. Inspect the repository

```bash
jj log
```

You'll see:

```
@  yquvzkuv  (empty) working copy
○  snnmnlko  feat: add export functionality   <-- release/1.0 (WRONG)
◆  xvzkxlrz  feat: add authentication        <-- release/1.0@origin (branch point)
```

And in the full graph (`jj log -r 'all()' --no-graph`):

```
ywvqzkqn  fix: correct off-by-one in calculate()   <-- the commit we want
```

### 3. Abandon the wrong commit

```bash
jj abandon snnmnlko
```

jj removes the commit and automatically rebases `@` (the working copy) onto its
parent (`xvzkxlrz`, the branch point). The `release/1.0` bookmark is deleted
because it pointed solely to the abandoned commit.

### 4. Duplicate the correct fix commit

```bash
jj duplicate -r ywvqzkqn
```

`jj duplicate` creates an independent copy of the change, preserving its original
parent. Because the fix commit on `main` already has `feat: add authentication` as
its parent — the same commit that `release/1.0` branched from — the duplicate lands
in exactly the right place, on top of the branch point.

The output shows the new change ID, e.g. `pkvluspr`.

### 5. Recreate the release/1.0 bookmark

Because jj deleted the bookmark when we abandoned its target, we use `jj bookmark set`
(not `create`) to restore it — `set` handles the case where a remote-tracked bookmark
was deleted locally:

```bash
jj bookmark set "release/1.0" -r pkvluspr
```

### 6. Verify

```bash
git log --oneline release/1.0
# 6b3e8c5 fix: correct off-by-one in calculate()
# e3fab94 feat: add authentication
# 92b55e6 feat: add user model
# 011df48 chore: initial project setup
```

## Key jj insights

| Concept | Detail |
|---------|--------|
| **`jj abandon`** | Removes a change and automatically rebases any descendants onto its parent. No manual rebase needed. |
| **`jj duplicate`** | Creates an independent copy of a change (new change ID, same content/message). This is jj's equivalent of `git cherry-pick`. |
| **`jj bookmark set` vs `bookmark create`** | Use `set` when a local bookmark was deleted but its remote-tracking ref (`release/1.0@origin`) still exists — `create` will error in that case. |
| **Change IDs are stable** | Even after rebasing, a change keeps its change ID. You can always refer to it by the shortest unique prefix. |
| **`jj undo`** | If you make a mistake at any step, `jj undo` rolls back the last operation completely safely. |

## Why this is cleaner than git

In git you need `git reset --hard HEAD~1` to undo the cherry-pick (destructive,
requires knowing the right ref), then `git cherry-pick <correct-hash>`. In jj:
- `abandon` is non-destructive (recoverable via `jj op undo`)
- `duplicate` + `bookmark set` is explicit and operates on stable change IDs
- No staging, no HEAD gymnastics
