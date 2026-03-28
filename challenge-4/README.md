# Challenge 4 — The Stack Collapse

## Scenario

You had a stack of three PRs in review. The first one (`feat/a`) just got merged — but the repo uses squash-merge, so the merge commit looks nothing like your original. Now `feat/b` and `feat/c` are dangling off an orphaned commit, and CI is failing. You need to rebase the rest of the stack onto the updated `main` without duplicating the already-merged work.

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

This is the everyday cost of stacked PRs with squash-merge. Every time a PR at the base of your stack merges, you must rebase the rest of the stack using careful `--onto` rebasing.

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
