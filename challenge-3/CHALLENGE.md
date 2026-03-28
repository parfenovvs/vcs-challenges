# Challenge 3 — The Stack Collapse

## Starting State

- Branch: `feat/b`
- Stack before the squash-merge:

```
main:   [initial]
feat/a: [initial] <- feat: add feature_a
feat/b: [initial] <- feat: add feature_a <- feat: add feature_b
feat/c: [initial] <- feat: add feature_a <- feat: add feature_b <- feat: add feature_c
```

- `feat/a` was squash-merged into `main` as a single commit:
  ```
  feat: add feature_a (#1)
  ```

- Current state of `main`:
  ```
  feat: add feature_a (#1)    <-- HEAD of main (squash commit)
  chore: initial project setup
  ```

- `feat/b` and `feat/c` still point to the **old** `feat/a` commit, which no longer exists in `main`'s ancestry.

## Goal

Rebase `feat/b` onto the updated `main`, dropping the now-redundant `feat/a` commit that was already merged. Then do the same for `feat/c` (rebased onto the updated `feat/b`).

After the challenge:
- `feat/b` should be 1 commit ahead of `main` (only `feat: add feature_b`)
- `feat/c` should be 1 commit ahead of `feat/b` (only `feat: add feature_c`)

## Why This Matters

This is the everyday cost of stacked PRs with squash-merge. Every time a PR at the base of your stack merges, you must rebase the rest of the stack. Without tooling, this requires careful `--onto` rebasing. This friction is exactly what tools like Graphite and `jj` are designed to eliminate.

## Hints

<details>
<summary>Hint 1 — Why a plain rebase won't work</summary>

```bash
git rebase main   # on feat/b — this will likely conflict or duplicate commits
```

A plain `git rebase main` replays *all* commits in `feat/b` not in `main` — including the `feat: add feature_a` commit, which conflicts with the squash commit already in `main`. You need to tell git to only replay the commits you actually want.
</details>

<details>
<summary>Hint 2 — The --onto flag</summary>

`git rebase --onto <newbase> <upstream> <branch>` replays commits from `<upstream>..HEAD` onto `<newbase>`:

```bash
# Rebase feat/b: take commits from feat/a..feat/b, replay onto main
git rebase --onto main feat/a feat/b
```

This says: "everything that was on top of the old `feat/a`, put it on top of `main` instead."
</details>

<details>
<summary>Hint 3 — Then update feat/c</summary>

After `feat/b` is rebased, you need to rebase `feat/c` onto the new `feat/b`:

```bash
# Save the old feat/b position before rebasing feat/b
# (or use the old feat/b SHA recorded from git log)
git rebase --onto feat/b <old-feat/b-sha> feat/c
```

Or simply: after rebasing `feat/b`, check out `feat/c` and rebase it interactively.
</details>

<details>
<summary>Hint 4 — Resolving conflicts</summary>

After the squash-merge, `main` contains `feature_a()`. When replaying `feat/b`'s commit on top, git should apply cleanly since `feat/b` only adds `feature_b()`. If you see conflicts, check which version of the file you want and use `git add` + `git rebase --continue`.
</details>

## Key Commands

```bash
git log --oneline --graph --all       # visualize the full branch graph
git rebase --onto <newbase> <upstream> <branch>
git rebase --continue                 # after resolving conflicts
git rebase --abort                    # start over
git push --force-with-lease           # push rewritten branches
```

## Expected End State

```
git log --oneline main..feat/b
# <hash> feat: add feature_b

git log --oneline main..feat/c
# <hash> feat: add feature_c
# <hash> feat: add feature_b
```

```
# features.txt at feat/b tip:
# Features
feature_a()
feature_b()
```

Both `feat/b` and `feat/c` pushed with `--force-with-lease`.
