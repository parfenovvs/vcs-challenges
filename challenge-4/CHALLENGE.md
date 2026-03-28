# Challenge 4 — The Stack Insertion

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

Mid-stack insertions are common: a reviewer asks for a prerequisite change, or you realise feature_b depends on a helper you forgot. Without tooling, this requires creating a branch, then carefully rebasing everything above it. This is a friction point that `jj` handles elegantly (operations are symmetric in jj — inserting is as easy as appending).

## Hints

<details>
<summary>Hint 1 — Create feat/new from feat/a</summary>

You're already on `feat/a`. Create the new branch:

```bash
git checkout -b feat/new
# Edit features.txt to add feature_new()
git add features.txt
git commit -m "feat: add feature_new"
git push -u origin feat/new
```
</details>

<details>
<summary>Hint 2 — Rebase feat/b onto feat/new</summary>

`feat/b` currently has `feat/a`'s commit as its parent. You want to replay only the `feat/b`-specific commit (`feat: add feature_b`) on top of `feat/new`:

```bash
git rebase --onto feat/new feat/a feat/b
```

This says: "take the commits between `feat/a` and `feat/b` (exclusive), and put them on top of `feat/new`."
</details>

<details>
<summary>Hint 3 — Resolving potential conflicts</summary>

After the rebase, `feat/b` adds `feature_b()` on top of a file that now contains `feature_a()` and `feature_new()`. Git will try to apply the diff cleanly. If there's a conflict (e.g., line ordering), resolve it manually:

```bash
# Edit features.txt to have the correct order, then:
git add features.txt
git rebase --continue
```
</details>

<details>
<summary>Hint 4 — Verifying the result</summary>

```bash
git log --oneline --graph feat/b
```

You should see:
```
* feat: add feature_b       <-- feat/b
* feat: add feature_new     <-- feat/new
* feat: add feature_a       <-- feat/a
* chore: initial project setup
```
</details>

## Key Commands

```bash
git checkout -b <branch>              # create and switch to new branch
git rebase --onto <newbase> <upstream> <branch>
git rebase --continue                 # after resolving conflicts
git log --oneline --graph --all       # visualize branch graph
git push --force-with-lease           # push rewritten branches
```

## Expected End State

```
git log --oneline main..feat/new
# <hash> feat: add feature_new

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
