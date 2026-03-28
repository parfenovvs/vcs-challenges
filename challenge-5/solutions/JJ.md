# Challenge 5 — The Stack Insertion (jj solution)

## Overview

We need to insert a new commit between two existing stacked branches:

```
Before: main <- feat/a <- feat/b
After:  main <- feat/a <- feat/new <- feat/b
```

## Step-by-Step

### 1. Set up jj

```bash
jj git init --colocate
jj log
```

You'll see:
```
@  <empty working copy>
│ ○  qkwwsnvq feat/b  feat: add feature_b
├─╯
○  nzuxupvy  feat/a  feat: add feature_a
◆  wkuvrowv  main    chore: initial project setup
```

Take note of the change ID for `feat/a` (here: `nzuxupvy`). You only need the shortest unique prefix.

### 2. Create the new change on top of feat/a

```bash
jj new nzuxupvy -m "feat: add feature_new"
```

This creates a new change with `feat/a` as parent and moves `@` to it.

### 3. Add the new content

```bash
printf 'feature_new()\n' >> features.txt
```

jj auto-snapshots the working copy — no `git add` needed.

### 4. Create the feat/new bookmark

```bash
jj bookmark create feat/new
```

This pins the bookmark to the current `@`.

### 5. Rebase feat/b on top of feat/new

```bash
jj rebase -s qkwwsnvq -d yxqvomty
# -s: the source change to rebase (feat/b's change ID)
# -d: the destination (feat/new's change ID)
```

This will produce a **conflict** in `features.txt`. That's expected — the original `feat/b` appended `feature_b()` after `feature_a()`, but now `feature_new()` is in between.

### 6. Resolve the conflict

jj stores conflicts inside the commit itself and doesn't block you. Create a resolution change on top:

```bash
jj new qkwwsnvq
```

The file will have jj conflict markers. Edit `features.txt` to the correct final state:

```
# Features
feature_a()
feature_new()
feature_b()
```

Then squash the resolution back into `feat/b`:

```bash
jj squash
```

The conflict is cleared and `feat/b` now has clean content.

### 7. Push all branches

```bash
jj git push --bookmark feat/a --bookmark feat/new --bookmark feat/b
```

## Verification

```bash
git log --oneline main..feat/new
# 1a889ff feat: add feature_new
# 1800bb1 feat: add feature_a   <-- feat/a is included since it's an ancestor

git log --oneline main..feat/b
# a0076ce feat: add feature_b
# 1a889ff feat: add feature_new
# 1800bb1 feat: add feature_a

git show feat/b:features.txt
# # Features
# feature_a()
# feature_new()
# feature_b()
```

## Key jj Insights

**Inserting mid-stack is explicit by design.** In git you'd do `git checkout feat/a && git checkout -b feat/new`, make the commit, then `git rebase --onto feat/new feat/a feat/b`. In jj, `jj new <parent>` and `jj rebase -s <source> -d <dest>` make the intent clear.

**Conflicts are first-class citizens.** When you rebase `feat/b`, jj doesn't abort — it records the conflict inside the commit and lets you continue. You resolve by: `jj new <conflicted>` (work on top), fix the file, then `jj squash` (fold the fix back in). This is safer than git's all-or-nothing rebase.

**Bookmarks don't move automatically.** After `jj new nzuxupvy`, the `feat/a` bookmark stays on its commit. You explicitly create `feat/new` with `jj bookmark create`. This predictability prevents accidental branch pointer movement.

**Change IDs are stable across rebases.** `qkwwsnvq` (feat/b's change) keeps its change ID even after being rebased. Only the commit hash changes. This makes it safe to refer to changes by their short ID throughout the workflow.
