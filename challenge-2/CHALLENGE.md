# Challenge 2 — The Hotfix Cherry-Pick

## Starting State

- Branch: `release/1.0`
- Branched from `main` at commit 3 (`feat: add authentication`)

`main` history:
```
feat: add export functionality       <-- HEAD of main
fix: correct off-by-one in calculate()
feat: add authentication             <-- where release/1.0 branched
feat: add user model
chore: initial project setup
```

`release/1.0` history:
```
feat: add authentication             <-- HEAD of release/1.0
feat: add user model
chore: initial project setup
```

## Goal

Apply the commit `fix: correct off-by-one in calculate()` from `main` onto `release/1.0` — without also pulling in `feat: add export functionality`.

After the challenge, `release/1.0` should have 4 commits, with the fix as its tip.

## Why This Matters

Release branches are a common pattern in mobile development (tied to app store submissions). When a bug is fixed on the main development line, you often need to backport *only* that fix to an already-shipped version. `git cherry-pick` is the standard tool for this.

## Hints

<details>
<summary>Hint 1 — Finding the commit hash</summary>

You need the SHA of the fix commit on `main`. A few ways to find it:

```bash
git log --oneline main
# or
git log --oneline main ^release/1.0   # commits on main not in release/1.0
```

Copy the short hash of `fix: correct off-by-one in calculate()`.
</details>

<details>
<summary>Hint 2 — Applying the commit</summary>

```bash
git cherry-pick <hash>
```

This creates a new commit on your current branch (`release/1.0`) with the same diff and message as the original. The SHA will be different — it's a copy, not a move.
</details>

<details>
<summary>Hint 3 — If there's a conflict</summary>

Cherry-pick can conflict if the context around the changed lines differs between branches. If that happens:

```bash
# Resolve conflicts in the file, then:
git add app.txt
git cherry-pick --continue
```

Or to abort and start over:
```bash
git cherry-pick --abort
```
</details>

<details>
<summary>Hint 4 — Pushing the result</summary>

```bash
git push origin release/1.0
```

This is a fast-forward push (no history rewrite), so no `--force` needed.
</details>

## Key Commands

```bash
git log --oneline <branch>            # inspect branch history
git log --oneline main ^release/1.0  # commits in main not in release/1.0
git cherry-pick <hash>                # copy a commit to current branch
git cherry-pick --continue            # resume after resolving conflict
git cherry-pick --abort               # cancel cherry-pick
```

## Expected End State

```
git log --oneline release/1.0
# <hash> fix: correct off-by-one in calculate()
# <hash> feat: add authentication
# <hash> feat: add user model
# <hash> chore: initial project setup
```

`main` is unchanged. `release/1.0` has the fix but not the export feature.
