#!/usr/bin/env bash
set -e

CHALLENGE_DIR="$HOME/git-workshop-challenges/challenge-4"
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

# End on feat/a
git -C "$WORKSPACE" checkout feat/a

echo ""
echo "============================================================"
echo "  CHALLENGE 4 — The Stack Insertion"
echo "============================================================"
echo ""
echo "  You are on branch: feat/a"
echo "  Stack: main <- feat/a <- feat/b"
echo ""
echo "  You need to insert a NEW branch 'feat/new' between"
echo "  feat/a and feat/b, adding 'feature_new()' to"
echo "  features.txt."
echo ""
echo "  After insertion:"
echo "  main <- feat/a <- feat/new <- feat/b"
echo ""
echo "  feat/b must be rebased so its commit applies cleanly"
echo "  on top of feat/new."
echo ""
echo "  See CHALLENGE.md for full instructions and hints."
echo "============================================================"
echo ""
echo "  Workspace: $WORKSPACE"
echo ""
