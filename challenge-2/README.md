# Challenge 2 — The Hotfix Cherry-Pick

## Scenario

A bug fix just landed on `main`. Your `release/1.0` branch — already submitted to the app store — needs that fix backported, but you can't pull in the other new features that came along with it. You need to surgically apply just the fix commit.

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

## Expected End State

```
git log --oneline release/1.0
# <hash> fix: correct off-by-one in calculate()
# <hash> feat: add authentication
# <hash> feat: add user model
# <hash> chore: initial project setup
```

`main` is unchanged. `release/1.0` has the fix but not the export feature.
