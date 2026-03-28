#!/usr/bin/env bash
set -e

CHALLENGE_DIR="$HOME/git-workshop-challenges/challenge-1"
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
cat > "$WORKSPACE/calculator.txt" << 'EOF'
# Calculator module
EOF
git -C "$WORKSPACE" add calculator.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "chore: initial project setup"
git -C "$WORKSPACE" push -u origin main

# feat/fixup branch
git -C "$WORKSPACE" checkout -b feat/fixup

# Commit A: add calculate()
cat > "$WORKSPACE/calculator.txt" << 'EOF'
# Calculator module

def calculate(x, y):
    return x + y
EOF
git -C "$WORKSPACE" add calculator.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add calculate function"

# Commit B: add display() AND misplaced MAX_INPUT
cat > "$WORKSPACE/calculator.txt" << 'EOF'
# Calculator module

def calculate(x, y):
    return x + y

def display(result):
    print(result)

MAX_INPUT = 1000  # <-- belongs in calculate(), not here
EOF
git -C "$WORKSPACE" add calculator.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add display function"

git -C "$WORKSPACE" push -u origin feat/fixup

# Stay on feat/fixup
echo ""
echo "============================================================"
echo "  CHALLENGE 1 — The Simple Fixup"
echo "============================================================"
echo ""
echo "  You are on branch: feat/fixup"
echo "  2 commits ahead of main."
echo ""
echo "  The second commit 'feat: add display function'"
echo "  accidentally includes MAX_INPUT = 1000, which"
echo "  belongs in the first commit alongside calculate()."
echo ""
echo "  Your task: move MAX_INPUT into the first commit"
echo "  without changing the final file content."
echo ""
echo "  See CHALLENGE.md for full instructions and hints."
echo "============================================================"
echo ""
echo "  Workspace: $WORKSPACE"
echo ""
