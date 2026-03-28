# Challenge 0 — The Split Commit

## Scenario

You committed a bunch of changes, pushed the branch, and opened a PR. A reviewer points out that the commit bundles two unrelated things — a constant and a function — making the diff harder to reason about. You need to split it into two focused commits before the review continues.

## Starting State

- Branch: `feat/split`
- 1 commit ahead of `main`
- File: `utils.txt`

The branch has one commit:
```
feat: add foo function and MAX_SIZE constant
```

That commit added two unrelated things to `utils.txt`:
- A constant: `MAX_SIZE = 100`
- A function: `def foo(): ...`

## Goal

Split the single commit into two commits:
1. `feat: add MAX_SIZE constant`
2. `feat: add foo function`

Each commit should contain only its own change. The final history on `feat/split` should show two commits above `main`.

## Why This Matters

Small, focused commits make code review easier and history more useful. When commits bundle unrelated changes, reviewers can't approve parts independently, and `git bisect` or `git revert` becomes harder.

## Expected End State

```
git log --oneline main..feat/split
# <hash> feat: add foo function
# <hash> feat: add MAX_SIZE constant
```

Clean working tree, branch pushed to remote.
