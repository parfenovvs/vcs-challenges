# Challenge 2 — The Hotfix Cherry-Pick (jj Solution)

## Steps

### 1. Set up jj in the workspace

```bash
cd ~/git-workshop-challenges/challenge-2/workspace
jj git init --colocate
```

`--colocate` places the `.jj/` directory alongside `.git/`, so both tools share the same history.

### 2. Inspect the graph

```bash
jj log -r 'all()'
```

You'll see two diverging lines from the `feat: add authentication` commit:
- `release/1.0` — stops at commit 3
- `main` — has commit 4 (the fix) and commit 5 (export feature)

Identify the fix commit's **change ID** — the short alphanumeric prefix in the left column (e.g. `rsmmsnzs`).

### 3. Duplicate the fix onto release/1.0

```bash
jj duplicate -r <fix-change-id> --destination release/1.0
```

`jj duplicate` creates a copy of the commit with a new change ID, placing it on top of the given destination. This is jj's equivalent of `git cherry-pick`.

The command prints the new change ID (e.g. `rovqrotq`).

### 4. Move the bookmark

```bash
jj bookmark set release/1.0 -r <new-change-id>
```

Bookmarks in jj don't move automatically. After duplicating, the `release/1.0` bookmark still points to commit 3. Move it explicitly to the new fix commit.

### 5. Verify

```bash
jj log -r '::release/1.0'
```

Should show 4 commits, with `fix: correct off-by-one in calculate()` on top.

### 6. Push

```bash
jj git push --bookmark release/1.0
```

---

## Key Insight: `jj duplicate` vs `git cherry-pick`

In git, `cherry-pick` applies a commit's diff to the current branch — if there are conflicts, you resolve them interactively before the commit exists.

In jj, `duplicate --destination` does the same thing but stores the conflict **inside the commit** if one arises. The commit always succeeds; you resolve the conflict afterwards when ready. This makes rebasing and cherry-picking non-blocking operations.

## Key Insight: Bookmarks don't auto-follow

Unlike git branches, jj bookmarks are static pointers. After `jj duplicate`, you must explicitly call `jj bookmark set` to advance the bookmark — this is intentional and avoids accidental branch movement.
