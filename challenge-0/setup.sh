#!/usr/bin/env bash
set -e

CHALLENGE_DIR="$HOME/git-workshop-challenges/challenge-0"
WORKSPACE="$CHALLENGE_DIR/workspace"
REMOTE="$CHALLENGE_DIR/remote.git"

# Idempotent: remove and recreate
rm -rf "$CHALLENGE_DIR"
mkdir -p "$WORKSPACE" "$REMOTE"

# Initialize bare remote
git init --bare -b main "$REMOTE"

# Initialize workspace
git -C "$WORKSPACE" init -b main
git -C "$WORKSPACE" remote add origin "$REMOTE"

# Base commit on main
cat > "$WORKSPACE/utils.txt" << 'EOF'
EOF
git -C "$WORKSPACE" add utils.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "chore: initial project setup"
git -C "$WORKSPACE" push -u origin main

# Create feat/split branch
git -C "$WORKSPACE" checkout -b feat/split

# Single commit with both MAX_SIZE and foo()
cat > "$WORKSPACE/utils.txt" << 'EOF'
MAX_SIZE = 100

def foo():
    return "hello"
EOF
git -C "$WORKSPACE" add utils.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add foo function and MAX_SIZE constant"
git -C "$WORKSPACE" push -u origin feat/split

# Stay on feat/split
echo ""
echo "============================================================"
echo "  CHALLENGE 0 — The Split Commit"
echo "============================================================"
echo ""
echo "  You are on branch: feat/split"
echo "  1 commit ahead of main."
echo ""
echo "  The commit 'feat: add foo function and MAX_SIZE"
echo "  constant' bundles two unrelated changes. Your task"
echo "  is to split it into two separate commits."
echo ""
echo "  See CHALLENGE.md for full instructions and hints."
echo "============================================================"
echo ""
echo "  Workspace: $WORKSPACE"
echo ""
