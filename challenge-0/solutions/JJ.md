# Challenge 0 Solution — jj

## Overview

In jj, splitting a commit means: edit the commit in-place, trim it to one change,
then stack a new child change with the remainder. No interactive rebase menu needed.

## Steps

### 1. Initialize jj in the workspace

```bash
cd ~/git-workshop-challenges/challenge-0/workspace
jj git init --colocate
```

`--colocate` keeps `.git/` and `.jj/` side-by-side so the repo works with both
tools. jj imports the existing git history immediately.

### 2. Inspect the graph

```bash
jj log
```

You'll see something like:

```
@  <empty change>        ← working copy (auto-created by jj)
○  psyvznpp  feat/split  feat: add foo function and MAX_SIZE constant
◆  mzqnutpy  main        chore: initial project setup
```

jj always places an empty working-copy change on top when you initialize.

### 3. Edit the combined commit directly

```bash
jj edit psyvznpp   # use the shortest unique prefix of the change ID
```

`jj edit` moves `@` (the working copy) onto that change. You are now editing
`psyvznpp` itself — not a child of it. Any file edits will amend it in-place.

### 4. Trim the commit to only the first change

Edit `utils.txt` so it contains only the constant:

```
MAX_SIZE = 100
```

Then describe the commit:

```bash
jj describe -m "feat: add MAX_SIZE constant"
```

jj auto-snapshots the file edit the moment you ran `describe`, so there is no
explicit `git add` step.

### 5. Stack a new child change with the second part

```bash
jj new
```

`jj new` creates an empty change on top of `@` and moves `@` there. Now edit
`utils.txt` to its final state (both lines):

```
MAX_SIZE = 100

def foo():
    return "hello"
```

The diff of this new change is only the function — exactly what we want.

```bash
jj describe -m "feat: add foo function"
```

### 6. Verify the stack

```bash
jj log -r "main..feat/split"
```

Expected output (two commits above main, correct order):

```
@  qqrxnmnn  feat/split  feat: add foo function
○  psyvznpp              feat: add MAX_SIZE constant
```

### 7. Update the bookmark and push

The `feat/split` bookmark still points to the old combined commit. Move it to `@`:

```bash
jj bookmark set feat/split
jj git push --bookmark feat/split
```

jj will force-move the remote bookmark (the history was rewritten).

---

## Key jj Insights

| Concept | What it means here |
|---|---|
| `jj edit <rev>` | Moves `@` onto an existing commit so you edit it in-place, not on a child |
| Auto-snapshot | jj records file changes automatically; no staging area or `git add` |
| `jj new` | Seals the current change and opens a fresh empty one on top |
| `jj describe` | Sets/amends the commit message of `@` without touching history |
| `jj undo` | Every operation is logged; any mistake can be fully reversed |
| Bookmark ≠ auto-move | Bookmarks stay put when you rewrite history — you must `jj bookmark set` explicitly |
