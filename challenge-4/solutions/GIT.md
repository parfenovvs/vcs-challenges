# Solution — Challenge 4: The Stack Collapse

## Approach

Use `git rebase --onto` to replay each branch's *own* commits on top of a new base, explicitly telling git which commits to *exclude*. This drops the already-merged `feat/a` work without touching anything else.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-4/workspace
```

### 2. Understand the commit graph

```bash
git log --oneline --all --graph
# * a15be87 feat: add feature_c       <-- feat/c
# * 91c5426 feat: add feature_b       <-- feat/b
# * e3c7ae7 feat: add feature_a       <-- old feat/a (orphaned)
# | * a1ae8d5 feat: add feature_a (#1) <-- main (squash commit)
# |/
# * cdf87b1 chore: initial project setup
```

`feat/b` and `feat/c` are stacked on the **old** `feat/a` commit (`e3c7ae7`), which is no longer in `main`'s history. The new `main` has the squash commit `a1ae8d5` instead. We must rebase both branches onto the new `main`, dropping `e3c7ae7`.

### 3. Rebase `feat/b` onto `main`

```bash
git rebase --onto main feat/a feat/b
```

**Anatomy of `git rebase --onto <newbase> <upstream> <branch>`:**
- `<newbase>` (`main`) — where the rebased commits will land
- `<upstream>` (`feat/a`) — the *exclusive* start of the range to replay (commits *after* this are taken)
- `<branch>` (`feat/b`) — the *inclusive* end of the range

So this replays only the commits that are in `feat/b` but **not** in `feat/a` — i.e., just `feat: add feature_b` — on top of `main`.

Verify:

```bash
git log --oneline main..feat/b
# dd85ac5 feat: add feature_b
```

### 4. Rebase `feat/c` onto the updated `feat/b`

```bash
git rebase --onto feat/b feat/a feat/c
```

This replays commits in `feat/c` that are not in `feat/a` — originally that would include both `feat/b` and `feat/c`. However, git is smart enough to **automatically drop** `feat: add feature_b` because its patch is already present in the new `feat/b` tip. Only `feat: add feature_c` lands.

You'll see this in the output:

```
dropping 91c5426 feat: add feature_b -- patch contents already upstream
```

Verify:

```bash
git log --oneline main..feat/c
# c545547 feat: add feature_c
# dd85ac5 feat: add feature_b
```

### 5. Force-push both branches

```bash
git push --force-with-lease origin feat/b
git push --force-with-lease origin feat/c
```

### 6. Final verification

```bash
git log --oneline main..feat/b
# <hash> feat: add feature_b

git log --oneline main..feat/c
# <hash> feat: add feature_c
# <hash> feat: add feature_b

cat features.txt   # on feat/b tip
# # Features
# feature_a()
# feature_b()
```

## Key Insights

- **`git rebase --onto <newbase> <upstream> <branch>`** is the precise tool for "move a range of commits somewhere else". Plain `git rebase <newbase>` can't drop commits from the middle of a stack; `--onto` can.

- **Why plain `git rebase main` would fail here**: Without `--onto`, git would try to replay all of `feat/b`'s history since its fork from `main` — but because `main` has been rewritten (squash merge), git doesn't know which commits are "already there". You'd get a conflict or duplicate commits.

- **Automatic patch-drop during rebase**: When git detects that a commit being replayed produces a diff that's already in the target branch (identical patch content), it silently skips it. This is how step 4 works: `feat/b`'s commit is already in the new `feat/b`, so git drops it automatically when rebasing `feat/c`.

- **`--force-with-lease` vs `--force`**: Both rewrite the remote branch. `--force-with-lease` adds a safety check — it refuses to push if someone else has pushed to the branch since you last fetched. Always prefer it over bare `--force` when collaborating.

- **The stacked PR cost of squash-merge**: Squash-merge creates a new commit with a different hash than any original commit in the branch, breaking the parent chain. Every branch stacked on top must be rebased with `--onto` after each squash-merge at the base. This is the fundamental maintenance cost of squash-merge workflows with stacked PRs.

- **Naming the `<upstream>` argument**: The second argument to `--onto` is the branch (or commit) whose commits you want to *exclude*, not include. Think of it as "replay everything after this point".
