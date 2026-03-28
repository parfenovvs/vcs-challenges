# Solution — Challenge 0: The Split Commit (Interactive Rebase)

## Approach

Use `git rebase -i` to pause on the target commit and split it into two. This approach works for any commit in history, not just the most recent one.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-0/workspace
```

### 2. Start an interactive rebase

```bash
git rebase -i HEAD~1
```

Your editor opens with:

```
pick 930ca50 feat: add foo function and MAX_SIZE constant
```

Change `pick` to `edit` and save:

```
edit 930ca50 feat: add foo function and MAX_SIZE constant
```

Git pauses mid-rebase with HEAD pointing at that commit.

### 3. Unstage the commit's changes

```bash
git reset HEAD~1
```

The commit is undone and its changes are left unstaged in the working tree — same position as the direct reset approach.

### 4. Create the first commit (constant only)

```bash
cat > utils.txt << 'EOF'
MAX_SIZE = 100
EOF

git add utils.txt
git commit -m "feat: add MAX_SIZE constant"
```

### 5. Create the second commit (function only)

```bash
cat > utils.txt << 'EOF'
MAX_SIZE = 100

def foo():
    return "hello"
EOF

git add utils.txt
git commit -m "feat: add foo function"
```

### 6. Finish the rebase

```bash
git rebase --continue
```

Git sees no remaining commits to process and completes cleanly.

### 7. Force-push the rewritten branch

```bash
git push --force-with-lease origin feat/split
```

### 8. Verify

```bash
git log --oneline main..feat/split
# <hash> feat: add foo function
# <hash> feat: add MAX_SIZE constant
```

## Key Insights

- `edit` in the rebase todo list means "stop here so I can amend or split this commit."
- After pausing, `git reset HEAD~1` is still the tool that actually unstages the changes — rebase just lets you target commits deeper in history.
- `git rebase --continue` tells Git you're done with the paused commit and to proceed with the rest of the todo list.
- For the most recent commit, `git reset HEAD~1` alone (see GIT_RESET.md) is simpler. Rebase shines when the target commit is not at the tip of the branch.
