#!/usr/bin/env bash
set -e

CHALLENGE_DIR="$HOME/git-workshop-challenges/challenge-3"
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
printf '# Features\n' > "$WORKSPACE/features.txt"
git -C "$WORKSPACE" add features.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "chore: initial project setup"
git -C "$WORKSPACE" push -u origin main

# feat/a: stacked on main
git -C "$WORKSPACE" checkout -b feat/a
printf 'feature_a()\n' >> "$WORKSPACE/features.txt"
git -C "$WORKSPACE" add features.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add feature_a"
git -C "$WORKSPACE" push -u origin feat/a

# feat/b: stacked on feat/a
git -C "$WORKSPACE" checkout -b feat/b
printf 'feature_b()\n' >> "$WORKSPACE/features.txt"
git -C "$WORKSPACE" add features.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add feature_b"
git -C "$WORKSPACE" push -u origin feat/b

# feat/c: stacked on feat/b
git -C "$WORKSPACE" checkout -b feat/c
printf 'feature_c()\n' >> "$WORKSPACE/features.txt"
git -C "$WORKSPACE" add features.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add feature_c"
git -C "$WORKSPACE" push -u origin feat/c

# Simulate squash-merge of feat/a into main
git -C "$WORKSPACE" checkout main
git -C "$WORKSPACE" merge --squash feat/a
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add feature_a (#1)"
git -C "$WORKSPACE" push origin main

# End on feat/b
git -C "$WORKSPACE" checkout feat/b

echo ""
echo "============================================================"
echo "  CHALLENGE 3 — The Stack Collapse"
echo "============================================================"
echo ""
echo "  You are on branch: feat/b"
echo "  Stack: main <- feat/a <- feat/b <- feat/c"
echo ""
echo "  feat/a was squash-merged into main as:"
echo "  'feat: add feature_a (#1)'"
echo ""
echo "  Now feat/b and feat/c are based on the OLD feat/a"
echo "  commit, not the new squash commit on main."
echo "  They need to be rebased onto the updated main."
echo ""
echo "  See CHALLENGE.md for full instructions and hints."
echo "============================================================"
echo ""
echo "  Workspace: $WORKSPACE"
echo ""
