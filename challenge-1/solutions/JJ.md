# Challenge 1 — The Simple Fixup (jj solution)

## The Problem

The `feat: add display function` commit accidentally includes `MAX_INPUT = 1000`, which logically belongs in the `feat: add calculate function` commit. We need to move it without changing the final file content.

## Setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-1/workspace
jj git init --colocate
```

The `--colocate` flag puts the jj repo inside the existing `.git` directory, letting jj and git share the same repo.

## Inspect the History

```bash
jj log
```

```
@  oyuuuskl  (empty) (no description set)
○  lpuyoomp  feat/fixup  feat: add display function
○  klluxwrw  feat: add calculate function
◆  lzwyyklt  main        chore: initial project setup
```

```bash
jj show lpuyoomp   # the display commit — diff includes MAX_INPUT
jj show klluxwrw   # the calculate commit — diff does NOT include MAX_INPUT
```

## The Fix

### Step 1: Edit the `calculate` commit to add `MAX_INPUT`

`jj edit` moves your working copy to an existing commit, letting you amend it in place:

```bash
jj edit klluxwrw
```

Now edit `calculator.txt` so it includes `MAX_INPUT` at the end:

```
# Calculator module

def calculate(x, y):
    return x + y

MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

jj auto-snapshots the change. You'll see the message:
```
Rebased 1 descendant commits onto updated working copy
```

jj automatically rebased the `display` commit on top — but this creates a **conflict**, because the original `display` commit also tried to add `MAX_INPUT`.

### Step 2: Resolve the conflict in the `display` commit

```bash
jj edit lpuyoomp
```

The file now contains jj's conflict markers. Resolve it to the desired final state — `display()` inserted between `calculate()` and `MAX_INPUT`:

```
# Calculator module

def calculate(x, y):
    return x + y

def display(result):
    print(result)

MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

jj detects the resolution automatically when you save the file — no `git add` or `git rebase --continue` needed.

### Step 3: Verify

```bash
jj log
jj show klluxwrw   # diff: adds calculate() + MAX_INPUT
jj show lpuyoomp   # diff: inserts only display() between calculate() and MAX_INPUT
```

Final diffs:

**`feat: add calculate function`**
```diff
+def calculate(x, y):
+    return x + y
+
+MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

**`feat: add display function`**
```diff
 def calculate(x, y):
     return x + y

+def display(result):
+    print(result)
+
 MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

## Key jj Insights

### `jj edit` — amend any commit, not just the latest

Unlike git where amending the past requires `rebase -i`, `jj edit <rev>` lets you directly check out any commit in the stack and modify it. jj automatically rebases all descendants.

### Auto-rebase triggers conflicts

When you amend a parent commit, jj rebases descendants automatically. If a descendant modifies the same content you added to the parent, a conflict is created in that descendant commit. This is expected — jj stores conflicts inside commits rather than stopping the rebase.

### Conflicts live in commits

jj never aborts mid-rebase. Conflicts are recorded in the commit itself (visible in `jj show` and `jj log` with a `×` marker). You resolve them by simply editing the file to the desired state — no special commands needed.

### No staging area

There's no `git add`. The moment you save a file, jj's next command auto-snapshots it. This makes the edit→describe→new loop feel seamless.

### `jj undo` is a safety net

Every operation is recorded in `jj op log`. If anything goes wrong, `jj undo` (or `jj op undo <id>`) restores the exact prior state. This makes exploratory history rewriting much lower risk than git.
