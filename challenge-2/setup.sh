#!/usr/bin/env bash
set -e

CHALLENGE_DIR="$HOME/git-workshop-challenges/challenge-2"
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

# Commit 1
printf '# App module\n' > "$WORKSPACE/app.txt"
git -C "$WORKSPACE" add app.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "chore: initial project setup"

# Commit 2
printf 'user = User()\n' >> "$WORKSPACE/app.txt"
git -C "$WORKSPACE" add app.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add user model"

# Commit 3
printf 'auth = Auth(user)\n' >> "$WORKSPACE/app.txt"
git -C "$WORKSPACE" add app.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add authentication"

# Push main (commits 1-3)
git -C "$WORKSPACE" push -u origin main

# Branch release/1.0 from commit 3
git -C "$WORKSPACE" checkout -b release/1.0
git -C "$WORKSPACE" push -u origin release/1.0

# Back to main for commits 4 and 5
git -C "$WORKSPACE" checkout main

# Commit 4: the hotfix
printf 'calculate(n - 1)  # fix off-by-one\n' >> "$WORKSPACE/app.txt"
git -C "$WORKSPACE" add app.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "fix: correct off-by-one in calculate()"

# Commit 5
printf 'export(data)\n' >> "$WORKSPACE/app.txt"
git -C "$WORKSPACE" add app.txt
git -C "$WORKSPACE" \
  -c user.name="Workshop" -c user.email="workshop@example.com" \
  commit -m "feat: add export functionality"

git -C "$WORKSPACE" push origin main

# End on release/1.0
git -C "$WORKSPACE" checkout release/1.0

echo ""
echo "============================================================"
echo "  CHALLENGE 2 — The Hotfix Cherry-Pick"
echo "============================================================"
echo ""
echo "  You are on branch: release/1.0"
echo "  This branch was cut from main at commit 3."
echo ""
echo "  A bug fix landed on main after the branch cut:"
echo "  'fix: correct off-by-one in calculate()'"
echo ""
echo "  Your task: bring that fix into release/1.0"
echo "  without pulling in the unrelated export commit."
echo ""
echo "  See CHALLENGE.md for full instructions and hints."
echo "============================================================"
echo ""
echo "  Workspace: $WORKSPACE"
echo ""
