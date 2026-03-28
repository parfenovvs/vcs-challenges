# Challenge 6 Solution — Git

## The Problem

You need to work on three branches at the same time. `git checkout` is off the table because it would overwrite the working directory, stomping on in-progress work.

## The Tool: `git worktree`

`git worktree add` checks out a branch into a new directory that shares the same `.git` object store. You can have as many worktrees as you like — each has its own working directory and HEAD, but commits, refs, and config are shared.

---

## Step 1 — Start in the primary workspace

```bash
cd ~/git-workshop-challenges/challenge-6/workspace
# You should already be on feat/b
git branch
# * feat/b
```

## Step 2 — Add worktrees for feat/a and feat/c

```bash
git worktree add ../worktree-a feat/a
git worktree add ../worktree-c feat/c
```

Verify:

```bash
git worktree list
# ~/git-workshop-challenges/challenge-6/workspace   <hash> [feat/b]
# ~/git-workshop-challenges/challenge-6/worktree-a  <hash> [feat/a]
# ~/git-workshop-challenges/challenge-6/worktree-c  <hash> [feat/c]
```

## Step 3 — Simulate work completing on each branch

### feat/a (background process completing)

```bash
echo "feature_a_complete()" >> ../worktree-a/feature_a.txt
git -C ../worktree-a add feature_a.txt
git -C ../worktree-a -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "feat: complete feature_a"
```

### feat/b (your active work — in the primary workspace)

```bash
echo "feature_b_complete()" >> feature_b.txt
git add feature_b.txt
git -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "feat: complete feature_b"
```

### feat/c (AI agent completing)

```bash
echo "feature_c_complete()" >> ../worktree-c/feature_c.txt
git -C ../worktree-c add feature_c.txt
git -C ../worktree-c -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "feat: complete feature_c"
```

## Step 4 — Merge all three into main

```bash
git checkout main
git merge feat/a feat/b feat/c
```

Git performs an octopus merge (all three parents at once). Since the files are disjoint there are no conflicts.

Push to origin:

```bash
git push origin main
```

## Step 5 — Clean up worktrees

```bash
git worktree remove ../worktree-a
git worktree remove ../worktree-c
```

## Verify

```bash
git log --oneline --graph main
ls
# README.md  feature_a.txt  feature_b.txt  feature_c.txt

cat feature_a.txt
# feature_a_init()
# feature_a_complete()
```

---

## Key Concepts

| Concept | Detail |
|---------|--------|
| Shared object store | All worktrees share `.git` — commits made in any worktree are instantly visible in the others |
| Branch lock | A branch checked out in one worktree cannot be checked out in another — Git enforces this |
| Path convention | Worktree paths can be anywhere; sibling directories (`../worktree-a`) keep things tidy |
| Cleanup | `git worktree remove` removes the directory and the worktree registration; `git worktree prune` cleans up stale entries |
