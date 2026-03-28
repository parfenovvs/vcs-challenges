# Challenge 3 — The Wrong Cherry-Pick

## Scenario

A colleague tried to backport the hotfix to `release/1.0` but cherry-picked the wrong commit — they grabbed the new export feature instead of the bug fix. You've inherited this branch and need to clean it up: remove the unwanted commit and apply the correct one.

## Starting State

- Branch: `release/1.0`
- The wrong commit `feat: add export functionality` was already cherry-picked onto it

`main` history:
```
feat: add export functionality       <-- HEAD of main
fix: correct off-by-one in calculate()
feat: add authentication             <-- where release/1.0 branched
feat: add user model
chore: initial project setup
```

`release/1.0` history (current — broken):
```
feat: add export functionality       <-- wrong commit, must be removed
feat: add authentication
feat: add user model
chore: initial project setup
```

## Goal

End up with `release/1.0` containing exactly the hotfix and nothing else from after the branch point:

```
fix: correct off-by-one in calculate()   <-- correct commit
feat: add authentication
feat: add user model
chore: initial project setup
```

## Why This Matters

Mistakes happen — especially when commit messages look similar or hashes are copy-pasted in a hurry. Knowing how to undo a cherry-pick with `git reset` and redo it correctly is a practical skill for release branch management on any mobile team.

## Expected End State

```
git log --oneline release/1.0
# <hash> fix: correct off-by-one in calculate()
# <hash> feat: add authentication
# <hash> feat: add user model
# <hash> chore: initial project setup
```

`main` is unchanged. `release/1.0` has the fix but not the export feature.
