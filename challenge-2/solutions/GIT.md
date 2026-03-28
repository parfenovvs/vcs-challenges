# Solution — Challenge 2: The Hotfix Cherry-Pick

## Approach

Use `git cherry-pick` to copy exactly one commit — the hotfix — from `main` onto `release/1.0`. Cherry-pick replays the diff of a specific commit onto your current branch as a new commit, leaving all other commits on `main` untouched.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-2/workspace
```

### 2. Inspect the current state

You are on `release/1.0`. Confirm what it looks like:

```bash
git log --oneline release/1.0
# 144aba5 feat: add authentication
# cfeac85 feat: add user model
# 350501c chore: initial project setup
```

And what `main` has that `release/1.0` doesn't:

```bash
git log --oneline main
# b3eb72a feat: add export functionality
# d9d57f9 fix: correct off-by-one in calculate()
# 144aba5 feat: add authentication
# ...
```

The two commits added after the branch cut are visible. You only want the fix, not the export feature.

### 3. Identify the fix commit hash

```bash
git log --oneline main
```

Note the hash next to `fix: correct off-by-one in calculate()` — in the example above it is `d9d57f9`. Your hash will differ.

Alternatively, find it without scanning manually:

```bash
git log --oneline main ^release/1.0 --grep "fix:"
# d9d57f9 fix: correct off-by-one in calculate()
```

### 4. Cherry-pick that commit onto release/1.0

Make sure you are on `release/1.0` (the setup script leaves you there):

```bash
git cherry-pick d9d57f9   # use your actual hash
```

Git applies the diff from that commit and creates a **new** commit on `release/1.0` with the same message and authorship.

### 5. Verify

```bash
git log --oneline release/1.0
# 6a23af4 fix: correct off-by-one in calculate()
# 144aba5 feat: add authentication
# cfeac85 feat: add user model
# 350501c chore: initial project setup
```

`release/1.0` now has 4 commits. `main` is unchanged:

```bash
git log --oneline main
# b3eb72a feat: add export functionality
# d9d57f9 fix: correct off-by-one in calculate()
# ...
```

## Key Insights

- **`git cherry-pick <hash>`** copies the *diff* of a single commit and applies it as a new commit on your current branch. The resulting commit has a different hash but the same message, author, and diff content.
- **Cherry-pick vs. merge**: A merge would bring in *all* commits reachable from `main` that aren't on `release/1.0` — including the unwanted export feature. Cherry-pick gives you surgical precision.
- **Cherry-pick vs. rebase**: Rebase replays a *range* of commits; cherry-pick targets one (or a few explicit) commits. Use cherry-pick when you want isolated backports.
- **The new commit is independent**: The cherry-picked commit on `release/1.0` is a copy, not a reference to the original. Future changes to the original on `main` won't affect `release/1.0` and vice versa.
- **Conflicts are possible**: If the file being patched diverged significantly between `main` and `release/1.0`, Git will pause with a conflict — resolve it the same way as a merge conflict, then `git cherry-pick --continue`.
- **Backporting pattern**: In mobile/app-store workflows, release branches are often frozen after submission. Cherry-pick is the standard way to apply critical patches to an already-shipped version without pulling in unreleased features.
