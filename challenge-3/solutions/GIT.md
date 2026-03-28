# Solution — Challenge 3: The Wrong Cherry-Pick

## Approach

The wrong commit is already on `release/1.0`. Remove it with `git reset --hard HEAD~1` (which discards the top commit entirely), then cherry-pick the correct hotfix from `main`.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-3/workspace
```

### 2. Inspect the current state

You land on `release/1.0`. Confirm the problem:

```bash
git log --oneline release/1.0
# 7fa21cc feat: add export functionality   <-- wrong, must go
# 02017f1 feat: add authentication
# 251709d feat: add user model
# 53f3f39 chore: initial project setup
```

And confirm what the correct commit looks like on `main`:

```bash
git log --oneline main
# 8d74165 feat: add export functionality
# de87789 fix: correct off-by-one in calculate()   <-- this is what we want
# 02017f1 feat: add authentication
# ...
```

### 3. Undo the wrong cherry-pick

The wrong commit is the tip of `release/1.0`. Reset hard to its parent:

```bash
git reset --hard HEAD~1
```

`HEAD~1` means "one commit before HEAD". The `--hard` flag discards the commit *and* its working-tree changes (the exported file is gone). Now the branch is back to its correct base:

```bash
git log --oneline release/1.0
# 02017f1 feat: add authentication
# 251709d feat: add user model
# 53f3f39 chore: initial project setup
```

### 4. Find the correct commit hash

```bash
git log --oneline main --grep "fix:"
# de87789 fix: correct off-by-one in calculate()
```

Note the hash — yours will differ.

### 5. Cherry-pick the hotfix

```bash
git cherry-pick de87789   # use your actual hash
```

### 6. Verify

```bash
git log --oneline release/1.0
# 0b18fd3 fix: correct off-by-one in calculate()
# 02017f1 feat: add authentication
# 251709d feat: add user model
# 53f3f39 chore: initial project setup
```

`main` is unchanged:

```bash
git log --oneline main
# 8d74165 feat: add export functionality
# de87789 fix: correct off-by-one in calculate()
# ...
```

## Key Insights

- **`git reset --hard HEAD~1`** moves the branch pointer back one commit and throws away the working-tree changes introduced by that commit. It is the standard way to completely undo a cherry-pick (or any other commit) that hasn't been pushed yet.
- **`HEAD~N` syntax**: `HEAD~1` is one commit back, `HEAD~2` is two commits back, and so on. You can also spell it `HEAD^` — both mean the same thing for a linear history.
- **`--hard` vs `--soft` vs `--mixed`**:
  - `--hard` — discards both the commit and its working-tree changes. Use when you want the commit gone entirely.
  - `--soft` — removes the commit but leaves its changes staged. Use when you want to re-commit with different content or a different message.
  - `--mixed` (default) — removes the commit and un-stages the changes, but leaves them in the working tree. Use when you want to re-examine changes before re-staging.
- **Only reset local, unpushed commits**: `git reset --hard` rewrites history. If the wrong cherry-pick was already pushed to a shared remote, use `git revert <hash>` instead — that creates a new commit that undoes the change without altering history.
- **Why separate files matter for cherry-pick**: Cherry-pick applies the *diff* of a single commit. If two sequential commits both modify the same file, the second commit's diff depends on the first being present — cherry-picking only the second onto a branch that lacks the first causes a conflict. Design commits to be self-contained when backporting is expected.
- **Backporting pattern**: The reset-then-cherry-pick workflow is common in release branch management: undo the mistaken change, then precisely apply the intended one. The result is a clean, minimal release branch containing only what belongs there.
