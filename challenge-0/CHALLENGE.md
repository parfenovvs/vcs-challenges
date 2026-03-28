# Challenge 0 — The Split Commit

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

## Hints

<details>
<summary>Hint 1 — How to re-open a commit for editing</summary>

`git rebase -i` lets you reword, reorder, squash, or **edit** commits interactively. Use `edit` (or `e`) next to the commit you want to split.

```bash
git rebase -i main
# In the editor: change "pick" to "edit" for the target commit
```
</details>

<details>
<summary>Hint 2 — How to unstage and re-commit piece by piece</summary>

When rebase pauses at an `edit` commit, the commit is already applied to your working tree. Undo the commit (keeping the changes staged) then unstage everything:

```bash
git reset HEAD~1        # undo commit, keep changes in working tree
git restore --staged .  # unstage everything (or git reset HEAD)
```

Now stage and commit each change separately:
```bash
git add -p utils.txt    # interactively stage hunks
git commit -m "feat: add MAX_SIZE constant"
# stage the rest
git add utils.txt
git commit -m "feat: add foo function"
git rebase --continue
```
</details>

<details>
<summary>Hint 3 — Pushing the rewritten branch</summary>

After rewriting history, a normal `git push` will be rejected. Use:
```bash
git push --force-with-lease origin feat/split
```
`--force-with-lease` is safer than `--force`: it fails if someone else pushed to the branch since you last fetched.
</details>

## Key Commands

```bash
git rebase -i <base>          # interactive rebase
git reset HEAD~1              # undo last commit, keep changes
git add -p                    # stage changes hunk by hunk
git rebase --continue         # proceed after editing a stop
git push --force-with-lease   # force push safely
```

## Expected End State

```
git log --oneline main..feat/split
# <hash> feat: add foo function
# <hash> feat: add MAX_SIZE constant
```

Clean working tree, branch pushed to remote.
