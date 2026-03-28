# Solution — Challenge 0: The Split Commit

## Approach

The goal is to rewrite the last commit into two focused commits. The key tool is `git reset` (mixed mode), which undoes a commit and unstages the changes while leaving the file contents intact.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-0/workspace
```

### 2. Reset the combined commit

```bash
git reset HEAD~1
```

**What this does:** `--mixed` is the default mode. It rewinds `HEAD` one commit, clears the index, and leaves the working tree untouched. The commit is gone from history but nothing is lost — the file changes sit in your working tree, unstaged and ready to recommit in pieces.

Compare with other reset modes:
- `--soft` → history rewound, index and working tree unchanged (still staged)
- `--mixed` (default) → history rewound, index cleared, working tree unchanged (unstaged)
- `--hard` → history rewound, index and working tree both reset (changes lost)

### 3. Create the first commit (constant only)

Write only the constant to the file, stage it, and commit:

```bash
cat > utils.txt << 'EOF'
MAX_SIZE = 100
EOF

git add utils.txt
git commit -m "feat: add MAX_SIZE constant"
```

### 4. Create the second commit (function only)

Add the function on top and commit:

```bash
cat > utils.txt << 'EOF'
MAX_SIZE = 100

def foo():
    return "hello"
EOF

git add utils.txt
git commit -m "feat: add foo function"
```

### 5. Force-push the rewritten branch

```bash
git push --force-with-lease origin feat/split
```

**Why `--force-with-lease` instead of `--force`?**
The original commit is already pushed. Since we rewrote history, a normal push is rejected. `--force-with-lease` does the force push but adds a safety check: it refuses if the remote has new commits you haven't seen locally. This prevents accidentally overwriting a teammate's work.

### 6. Verify

```bash
git log --oneline main..feat/split
# 89747ce feat: add foo function
# 3abbbf5 feat: add MAX_SIZE constant
```

## Alternative: Interactive Rebase

Another common approach is `git rebase -i HEAD~1`, marking the commit as `edit`. Git pauses mid-rebase, letting you amend or split the commit before continuing. The result is the same; the soft-reset approach is slightly more direct for splitting a single commit.

## Key Insights

- **`git reset HEAD~1`** (`--mixed` by default) is the go-to command for "undo the last commit but keep the changes." It's non-destructive and reversible (until you make new commits).
- Splitting a commit is really just: undo it, then recommit the pieces one at a time.
- History rewriting requires a force-push. Always use `--force-with-lease` on shared branches to avoid clobbering teammates.
- Small, focused commits make `git bisect`, `git revert`, and code review dramatically easier.
