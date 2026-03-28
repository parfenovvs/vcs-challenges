# Solution — Challenge 1: The Simple Fixup (Interactive Rebase + Amend)

## Approach

Use `git rebase -i` to pause on the first commit (`feat: add calculate function`) and amend it to include `MAX_INPUT`. The rebase then replays the second commit on top, which causes a conflict — because the original second commit assumed `MAX_INPUT` didn't exist yet. Resolving that conflict produces the correct final history.

## Step-by-Step

### 1. Run the setup

```bash
bash setup.sh
cd ~/git-workshop-challenges/challenge-1/workspace
```

### 2. Inspect the current state

```bash
git log --oneline main..feat/fixup
# 0eebd15 feat: add display function
# 2ba8b4c feat: add calculate function
```

`MAX_INPUT` is currently introduced in the second commit. Verify:

```bash
git show HEAD   # includes MAX_INPUT — wrong
git show HEAD~  # does not include MAX_INPUT — wrong
```

### 3. Start an interactive rebase targeting the first commit

```bash
git rebase -i main
```

Your editor opens with:

```
pick 2ba8b4c feat: add calculate function
pick 0eebd15 feat: add display function
```

Change `pick` to `edit` on the first line and save:

```
edit 2ba8b4c feat: add calculate function
pick 0eebd15 feat: add display function
```

Git pauses with HEAD at `feat: add calculate function`.

### 4. Amend the first commit to include MAX_INPUT

Append `MAX_INPUT` to the file:

```bash
cat >> calculator.txt << 'EOF'

MAX_INPUT = 1000  # <-- belongs in calculate(), not here
EOF
```

Stage and amend the commit (keep the same message):

```bash
git add calculator.txt
git commit --amend --no-edit
```

### 5. Continue the rebase

```bash
git rebase --continue
```

Git will try to replay `feat: add display function` on top of the amended commit. Because the original second commit introduced `MAX_INPUT` (and now the first commit already has it), Git reports a **conflict**:

```
CONFLICT (content): Merge conflict in calculator.txt
```

This is expected — it is Git telling you that the two versions of `MAX_INPUT` need to be reconciled.

### 6. Resolve the conflict

Open `calculator.txt`. The conflict looks like:

```
<<<<<<< HEAD
=======
def display(result):
    print(result)

>>>>>>> 0eebd15 (feat: add display function)
MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

The `HEAD` side already has `MAX_INPUT` (from the amended commit). The incoming side adds `display()` above it. The correct resolution keeps both `display()` and the existing `MAX_INPUT`:

```
# Calculator module

def calculate(x, y):
    return x + y

def display(result):
    print(result)

MAX_INPUT = 1000  # <-- belongs in calculate(), not here
```

Stage the resolved file and finish:

```bash
git add calculator.txt
git rebase --continue
```

### 7. Force-push the rewritten branch

```bash
git push --force-with-lease origin feat/fixup
```

### 8. Verify

```bash
git log --oneline main..feat/fixup
# <hash> feat: add display function
# <hash> feat: add calculate function

git show HEAD~   # diff shows calculate() AND MAX_INPUT
git show HEAD    # diff shows only display()
```

The final file content is unchanged; only attribution moved.

## Key Insights

- **`edit` in the rebase todo** pauses the rebase at that commit so you can amend it. Unlike `git commit --amend` alone (which only works on `HEAD`), rebase lets you target any commit in history.
- **Amending a commit mid-rebase** is done with `git commit --amend`. Use `--no-edit` to keep the message; omit it to open the editor.
- **Why the conflict happens**: The original second commit's diff expected `MAX_INPUT` not to exist yet. Once the first commit includes it, Git cannot apply the second commit's diff cleanly and stops for you to resolve.
- **The conflict is not a mistake** — it is Git correctly detecting that the same line is now introduced in two places. Resolving it is part of the solution.
- **`--force-with-lease`** is safer than `--force`: it refuses to push if the remote has commits you haven't seen locally, protecting you from accidentally overwriting a teammate's push.
- For the case where the misplaced change is in the *most recent* commit and you want to move it to `HEAD~1`, this `rebase -i` + `edit` approach is the canonical solution. If you only needed to remove something from `HEAD`, a plain `git commit --amend` would suffice.
