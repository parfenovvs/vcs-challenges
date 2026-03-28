# Challenge 1 — The Simple Fixup

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

## Hints

<details>
<summary>Hint 1 — Which tool to reach for</summary>

`git rebase -i` with the `edit` action lets you pause at any commit and amend it. You can also use `fixup` or `squash` to fold a later fix-up commit into an earlier one — but here you need to *move* content from a later commit to an earlier one, so `edit` is cleaner.
</details>

<details>
<summary>Hint 2 — Strategy: edit the first commit</summary>

1. Start an interactive rebase back to `main`:
   ```bash
   git rebase -i main
   ```
2. Mark the first commit (`feat: add calculate function`) as `edit`.
3. When rebase pauses, amend the commit to add `MAX_INPUT`:
   ```bash
   # Edit calculator.txt to add MAX_INPUT = 1000 after calculate()
   git add calculator.txt
   git commit --amend --no-edit
   git rebase --continue
   ```
4. The second commit will then only add `display()` — but it currently also writes `MAX_INPUT`. You'll need to handle the conflict or edit the second commit too.
</details>

<details>
<summary>Hint 3 — Handling the second commit</summary>

After amending the first commit to include `MAX_INPUT`, rebase will apply the second commit on top. Since `MAX_INPUT` is now already present, the second commit's version of the file will try to add it again — either causing a conflict or a duplicate.

Mark the second commit as `edit` too (or resolve the conflict), then remove the `MAX_INPUT` line from that commit's diff before continuing.
</details>

<details>
<summary>Hint 4 — Alternative: squash + re-split</summary>

A simpler mental model: squash both commits into one, then split that one commit into two (like Challenge 0). This avoids reasoning about conflict resolution entirely.

```bash
git rebase -i main
# mark both as "edit" or squash into one, then re-split
```
</details>

## Key Commands

```bash
git rebase -i <base>          # interactive rebase
git commit --amend --no-edit  # amend without changing message
git add -p                    # stage changes hunk by hunk
git rebase --continue         # proceed after an edit stop
git push --force-with-lease   # force push safely
```

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
