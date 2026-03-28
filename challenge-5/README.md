# Challenge 5 — The Stack Insertion

## Scenario

You have two stacked PRs in review: `feat/a` and `feat/b` (which depends on `feat/a`). A reviewer asks you to extract a prerequisite helper into its own PR so it can be reviewed and approved independently. You need to insert a new branch in the middle of your stack — without losing `feat/b` or rewriting it from scratch.

## Starting State

- Branch: `feat/a`
- Current stack:

```
main:   [initial]
feat/a: [initial] <- feat: add feature_a       <-- you are here
feat/b: [initial] <- feat: add feature_a <- feat: add feature_b
```

`features.txt` at `feat/a` tip:
```
# Features
feature_a()
```

`features.txt` at `feat/b` tip:
```
# Features
feature_a()
feature_b()
```

## Goal

Insert a new branch `feat/new` between `feat/a` and `feat/b`, adding a new line `feature_new()` to `features.txt`.

Target stack:
```
main <- feat/a <- feat/new <- feat/b
```

After insertion:
- `feat/new` is 1 commit ahead of `feat/a`, adds `feature_new()`
- `feat/b` is rebased so it sits on top of `feat/new` (1 commit ahead, adds `feature_b()`)

## Why This Matters

Mid-stack insertions are common: a reviewer asks for a prerequisite change, or you realise feature_b depends on a helper you forgot. Without tooling, this requires creating a branch, then carefully rebasing everything above it.

## Expected End State

```
git log --oneline main..feat/new
# <hash> feat: add feature_new
# <hash> feat: add feature_a

git log --oneline main..feat/b
# <hash> feat: add feature_b
# <hash> feat: add feature_new
# <hash> feat: add feature_a
```

```
# features.txt at feat/b tip:
# Features
feature_a()
feature_new()
feature_b()
```

All three branches (`feat/a`, `feat/new`, `feat/b`) pushed to remote.
