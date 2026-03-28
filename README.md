# Git Workshop

Hands-on challenges for practising Git history rewriting. Each challenge drops you into a realistic scenario and asks you to clean it up.

## Prerequisites

- Git installed
- A terminal
- No network access required — all remotes are local

## How to Start a Challenge

```bash
bash challenge-N/setup.sh
cd ~/git-workshop-challenges/challenge-N/workspace
```

Re-running `setup.sh` resets the challenge to its original state.

Read `CHALLENGE.md` in this repo for the scenario, goal, and expected end state before you start.

## Challenges

| # | Name | Scenario |
|---|------|----------|
| 0 | The Split Commit | Split a bundled commit into two focused ones |
| 1 | The Simple Fixup | Move a misplaced change into the correct earlier commit |
| 2 | The Hotfix Cherry-Pick | Backport a bug fix to a release branch |
| 3 | The Wrong Cherry-Pick | Undo a bad cherry-pick and apply the correct one |
| 4 | The Stack Collapse | Rebase a stacked branch after a squash-merge at the base |
| 5 | The Stack Insertion | Insert a new branch mid-stack and rebase everything above it |

## Solutions

Each challenge has step-by-step solutions in its `solutions/` directory — both Git (`GIT.md`) and jj (`JJ.md`) variants. Try the challenge before peeking.
