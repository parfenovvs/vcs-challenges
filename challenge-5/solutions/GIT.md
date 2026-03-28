# Solution — Challenge 5: The Stack Insertion

## Approach

Create `feat/new` branching off `feat/a`, add the new commit, then use `git rebase` to replay `feat/b` on top of `feat/new`. The rebase will produce a conflict because the insertion point changes the file — resolve it by placing all three features in order.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-5/workspace
```

### 2. Understand the commit graph

```bash
git log --oneline --all --graph
# * e36ed7a feat: add feature_b   <-- feat/b
# * 9c87cbf feat: add feature_a   <-- feat/a  (you are here)
# * 1073b85 chore: initial project setup   <-- main
```

Both `feat/a` and `feat/b` share a linear history. We need to split that chain by injecting a new commit between them.

### 3. Create `feat/new` off `feat/a`

You are already on `feat/a`. Branch from here:

```bash
git checkout -b feat/new
```

Add the new feature:

```bash
printf 'feature_new()\n' >> features.txt
git add features.txt
git commit -m "feat: add feature_new"
git push -u origin feat/new
```

`features.txt` now reads:
```
# Features
feature_a()
feature_new()
```

### 4. Rebase `feat/b` onto `feat/new`

```bash
git checkout feat/b
git rebase feat/new
```

This will produce a **conflict** in `features.txt`. The conflict looks like:

```
# Features
feature_a()
<<<<<<< HEAD
feature_new()
=======
feature_b()
>>>>>>> e36ed7a (feat: add feature_b)
```

**Why the conflict?** `feat/b`'s original commit appended `feature_b()` after `feature_a()`. Now the base (`feat/new`) has `feature_new()` between them. Git cannot decide the order automatically.

Resolve by placing all three features in the correct order:

```
# Features
feature_a()
feature_new()
feature_b()
```

Then continue:

```bash
git add features.txt
git rebase --continue
```

### 5. Force-push `feat/b`

The rebase rewrites `feat/b`'s commit (new parent = `feat/new` tip), so a force-push is required:

```bash
git push --force-with-lease origin feat/b
```

### 6. Verify the end state

```bash
git log --oneline main..feat/new
# <hash> feat: add feature_new
# <hash> feat: add feature_a

git log --oneline main..feat/b
# <hash> feat: add feature_b
# <hash> feat: add feature_new
# <hash> feat: add feature_a

cat features.txt   # on feat/b tip
# # Features
# feature_a()
# feature_new()
# feature_b()
```
## Key Insights

- **Mid-stack insertion = branch + rebase**: The primitive operation is always the same: create the new branch at the insertion point, commit your changes, then `git rebase <new-branch>` on every branch that was above the insertion point.

- **Why conflicts happen on insertion**: When you insert a commit that modifies a file, every downstream commit that also touches that file will conflict during rebase. Git does not know the intended ordering of concurrent edits — you must declare the final desired state manually.

- **`git rebase <branch>` vs `git rebase --onto`**: Plain `git rebase feat/new` works here because `feat/b` diverges from a point that is still in `feat/new`'s history (`feat/a` tip). You only need `--onto` when you want to drop commits from the replayed range (as in challenge 4).

- **`--force-with-lease` is safer than `--force`**: It checks that no one else has pushed to the remote branch since you last fetched. If the remote has moved, the push is rejected instead of silently overwriting someone else's work.

- **Stack maintenance cost**: Every branch stacked above the insertion point must be rebased. With a two-branch stack that's one rebase. With a five-branch stack it's four, each potentially with conflicts. Tools like `git-branchless` or `jj` automate this propagation.

- **`git rerere`**: If you frequently do mid-stack insertions, enable `git config rerere.enabled true`. Git will remember how you resolved a conflict the first time and replay the resolution automatically on subsequent rebases of the same diff.
