# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A hands-on Git workshop with 6 challenges (0–5) designed for engineering teams. Each challenge teaches a practical history-rewriting technique. There is no build system, no tests, and no application code — the repo contains only challenge materials.

## Structure

Each `challenge-N/` directory contains:
- `CHALLENGE.md` — scenario description, starting state, goal, and expected end state
- `setup.sh` — idempotent script that creates a fresh workspace + bare remote under `~/git-workshop-challenges/challenge-N/`
- `solutions/` — step-by-step solution guides (Git and jj variants)

## Running a Challenge

```bash
bash challenge-N/setup.sh
cd ~/git-workshop-challenges/challenge-N/workspace
```

The setup script is **idempotent** — re-running it wipes and recreates the challenge directory. Each challenge workspace has its own bare `remote.git` acting as the origin.

## Challenges at a Glance

| # | Name | Core Git Skill |
|---|------|----------------|
| 0 | The Split Commit | `git rebase -i` with `edit`, then `git reset HEAD~1` to split |
| 1 | The Simple Fixup | `git rebase -i` with `fixup`/`reword` to move a misplaced change |
| 2 | The Hotfix Cherry-Pick | `git cherry-pick <hash>` to backport a single commit |
| 3 | The Wrong Cherry-Pick | `git reset --hard HEAD~1` to undo, then correct cherry-pick |
| 4 | The Stack Collapse | `git rebase --onto <newbase> <upstream> <branch>` after a squash-merge |
| 5 | The Stack Insertion | Create a branch mid-stack, then `git rebase --onto` to restack dependents |

## Adding or Modifying Challenges

- `setup.sh` scripts use `git -C "$WORKSPACE" -c user.name="Workshop" -c user.email="workshop@example.com"` for all commits — keep this pattern so participants don't need git config set up.
- Solutions live in `solutions/GIT.md` (and `solutions/JJ.md` for jj equivalents). Keep them step-by-step with inline verification commands.
- The workspace remote is a local bare repo (`remote.git`), not GitHub — no network access required.
