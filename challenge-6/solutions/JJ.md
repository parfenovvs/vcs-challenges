# Challenge 6 Solution — jj

## The Tool: `jj workspace add`

jj has first-class workspace support. Each workspace has its own working copy but shares the same repo — commits, bookmarks, and config are all shared. This maps directly onto `git worktree`.

---

## Step 1 — Initialize jj in the primary workspace

```bash
cd ~/git-workshop-challenges/challenge-6/workspace
jj git init --colocate
```

`--colocate` keeps the existing `.git` directory intact so the repo remains usable with plain git too.

## Step 2 — Check current state

```bash
jj log
# Should show feat/a, feat/b (current), feat/c all branching off main
```

## Step 3 — Add workspaces for feat/a and feat/c

```bash
jj workspace add ../workspace-a --revision feat/a
jj workspace add ../workspace-c --revision feat/c
```

Verify:

```bash
jj workspace list
# default  <hash>  (feat/b)
# workspace-a  <hash>  (feat/a)
# workspace-c  <hash>  (feat/c)
```

## Step 4 — Simulate work completing on each branch

### feat/a

```bash
echo "feature_a_complete()" >> ../workspace-a/feature_a.txt
jj -R ../workspace-a describe -m "feat: complete feature_a"
```

### feat/b (primary workspace)

```bash
echo "feature_b_complete()" >> feature_b.txt
jj describe -m "feat: complete feature_b"
```

### feat/c

```bash
echo "feature_c_complete()" >> ../workspace-c/feature_c.txt
jj -R ../workspace-c describe -m "feat: complete feature_c"
```

## Step 5 — Advance the bookmarks, then merge into main

The bookmarks `feat/a`, `feat/b`, `feat/c` still point at the initial commits; you need to move them to the workspace working-copy commits before merging.

```bash
# Advance each bookmark to the completed commit
# (use the change IDs shown by `jj workspace list`)
jj bookmark set feat/a -r workspace-a@
jj bookmark set feat/b -r default@
jj bookmark set feat/c -r workspace-c@
```

Now create the merge commit:

```bash
# Create a merge commit with all three features as parents
jj new main feat/a feat/b feat/c -m "merge: combine all features"

# Point the main bookmark at the new merge commit
jj bookmark set main -r @

# Push
jj git push --bookmark main
```

## Step 6 — Clean up workspaces

```bash
jj workspace forget workspace-a
jj workspace forget workspace-c
rm -rf ../workspace-a ../workspace-c
```

## Verify

```bash
jj log -r main
ls
# README.md  feature_a.txt  feature_b.txt  feature_c.txt
```

---

## Key Concepts

| Concept | Detail |
|---------|--------|
| `jj workspace add` | Creates a new working copy at a given revision; shares the repo's commit graph |
| Auto-snapshot | jj snapshots working copy changes automatically — no explicit `git add` needed |
| `jj new` with multiple parents | Creates a merge commit; the equivalent of `git merge feat/a feat/b feat/c` |
| `jj bookmark set` | Moves a bookmark (branch) to point at the current commit |
| Workspace forget | `jj workspace forget` unregisters the workspace; manually `rm -rf` the directory |

## Difference from git worktree

- jj workspaces are a first-class concept — no "branch is locked to a worktree" restriction; jj tracks working copies, not branch checkouts
- `jj workspace add` accepts any revision expression, not just branch names
- Workspace state is stored in the repo's op log, so workspace metadata survives across machines if you push the op log
