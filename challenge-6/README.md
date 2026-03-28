# Challenge 6 — The Parallel Workspaces

## Scenario

Three features are in flight simultaneously:

- **`feat/a`** — a long-running background process (think: a build or test suite) is running on this branch. Checking it out would kill the process.
- **`feat/b`** — your active development branch. This is where you are now.
- **`feat/c`** — an AI agent is making commits here autonomously. Switching to it would disrupt its working directory.

All three need to land on `main` independently.

## Starting State

```
main ── feat/a  (one commit: "feat: add initial feature_a")
     └─ feat/b  (one commit: "feat: add initial feature_b")  ← you are here
     └─ feat/c  (one commit: "feat: add initial feature_c")
```

## Your Goal

1. Add a second commit to `feat/b` (your active work) in the primary workspace.
2. Add a second commit to `feat/a` (simulating the background process completing) **without** disrupting your `feat/b` workspace.
3. Add a second commit to `feat/c` (simulating the AI agent completing) **without** disrupting either `feat/b` or `feat/a`.
4. Merge all three branches into `main` and push.

## Constraint

You cannot use `git checkout` to switch between branches — doing so would stomp on in-progress work.

## Expected End State

```
main (contains README.md, feature_a.txt, feature_b.txt, feature_c.txt)
```

Each feature file should contain two lines (initial + complete).

## Hint

Look into `git worktree`. It lets you check out multiple branches into separate directories, all sharing the same `.git` object store — no second clone needed.

## Verify

```bash
git log --oneline --graph main
ls   # README.md  feature_a.txt  feature_b.txt  feature_c.txt
```
