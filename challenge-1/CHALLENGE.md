# Challenge 1 — The Simple Fixup

## Scenario

You're mid-review and a teammate points out that `MAX_INPUT = 1000` landed in the wrong commit — it's a constraint for `calculate()`, but it got bundled into the `display` commit. The PR isn't merged yet, so you can still rewrite history to put each change in the right place.

## Starting State

- Branch: `feat/fixup`
- 2 commits ahead of `main`
- File: `calculator.txt`

Commit history (newest first):
```
feat: add display function      <-- HEAD
feat: add calculate function
chore: initial project setup    <-- main
```

The second commit (`feat: add display function`) accidentally includes `MAX_INPUT = 1000`, which logically belongs with `calculate()` in the first commit.

## Goal

Rewrite history so that:
1. `feat: add calculate function` includes `MAX_INPUT = 1000`
2. `feat: add display function` contains only the `display()` function

The final file content must remain identical. Only the attribution of the `MAX_INPUT` line changes.

## Why This Matters

In code review, a reviewer approving the `display` function shouldn't have to reason about an unrelated constant. Clean commits mean each diff tells a focused story. This is also a common scenario when you're mid-stack and realize a change landed in the wrong commit.

## Expected End State

```
git log --oneline main..feat/fixup
# <hash> feat: add display function
# <hash> feat: add calculate function
```

```
# calculator.txt (final, unchanged):
# Calculator module

def calculate(x, y):
    return x + y

def display(result):
    print(result)

MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

`MAX_INPUT` is introduced in commit 1 (`calculate`), removed and reintroduced only in the final file via commit 1. Commit 2 (`display`) diff shows only the `display()` function being added.
