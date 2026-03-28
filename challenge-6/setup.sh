#!/usr/bin/env bash
set -euo pipefail

CHALLENGE_DIR="$HOME/git-workshop-challenges/challenge-6"
WORKSPACE="$CHALLENGE_DIR/workspace"
REMOTE="$CHALLENGE_DIR/remote.git"

echo "Setting up Challenge 6 — The Parallel Workspaces..."

# Wipe and recreate
rm -rf "$CHALLENGE_DIR"
mkdir -p "$WORKSPACE" "$REMOTE"

# Init bare remote
git init --bare -b main "$REMOTE"

# Init workspace
git -C "$WORKSPACE" init -b main
git -C "$WORKSPACE" remote add origin "$REMOTE"

# Commit README on main
echo "# Parallel Workspaces" > "$WORKSPACE/README.md"
git -C "$WORKSPACE" add README.md
git -C "$WORKSPACE" -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "chore: initial commit"
git -C "$WORKSPACE" push -u origin main

# Create feat/a
git -C "$WORKSPACE" checkout -b feat/a
echo "feature_a_init()" > "$WORKSPACE/feature_a.txt"
git -C "$WORKSPACE" add feature_a.txt
git -C "$WORKSPACE" -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "feat: add initial feature_a"
git -C "$WORKSPACE" push -u origin feat/a

# Create feat/b
git -C "$WORKSPACE" checkout main
git -C "$WORKSPACE" checkout -b feat/b
echo "feature_b_init()" > "$WORKSPACE/feature_b.txt"
git -C "$WORKSPACE" add feature_b.txt
git -C "$WORKSPACE" -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "feat: add initial feature_b"
git -C "$WORKSPACE" push -u origin feat/b

# Create feat/c
git -C "$WORKSPACE" checkout main
git -C "$WORKSPACE" checkout -b feat/c
echo "feature_c_init()" > "$WORKSPACE/feature_c.txt"
git -C "$WORKSPACE" add feature_c.txt
git -C "$WORKSPACE" -c user.name="Workshop" -c user.email="workshop@example.com" \
    commit -m "feat: add initial feature_c"
git -C "$WORKSPACE" push -u origin feat/c

# Leave workspace on feat/b
git -C "$WORKSPACE" checkout feat/b

echo ""
echo "=========================================="
echo " Challenge 6 — The Parallel Workspaces"
echo "=========================================="
echo ""
echo "Three feature branches are in flight simultaneously."
echo "A background process is running on feat/a."
echo "An AI agent is committing to feat/c."
echo "You are working on feat/b."
echo ""
echo "Your mission:"
echo "  1. Add a second commit to feat/b (you are here)"
echo "  2. Add a second commit to feat/a — without disrupting feat/b"
echo "  3. Add a second commit to feat/c — without disrupting feat/a or feat/b"
echo "  4. Merge all three into main and push"
echo ""
echo "Constraint: no 'git checkout' to switch branches."
echo "Hint: git worktree"
echo ""
echo "Workspace: $WORKSPACE"
echo ""
