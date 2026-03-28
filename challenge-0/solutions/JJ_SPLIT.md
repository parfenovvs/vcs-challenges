# Challenge 0 Solution — jj split

## Overview

`jj split` is the most direct way to split a commit. It opens a diff editor
where you select which hunks go into the *first* commit; the rest stay as a
child commit below it. No manual file editing required.

## Steps

### 1. Initialize jj and move onto the combined commit

```bash
cd ~/git-workshop-challenges/challenge-0/workspace
jj git init --colocate
jj log
```

```
@  lkrspzvy  (empty)
○  rywkqkvu  feat/split  feat: add foo function and MAX_SIZE constant
◆  oqtqxqox  main        chore: initial project setup
```

Move `@` directly onto the combined commit:

```bash
jj edit rywkqkvu   # shortest unique prefix of the change ID
```

### 2. Split it

```bash
jj split -i
```

This opens your configured diff editor (e.g. `vimdiff`, `meld`, `difft`).
The right side of the diff is editable — it represents what will go into the
**first** commit. Remove the hunks you do *not* want in the first commit; they
will automatically become the second commit.

For this challenge: remove the `def foo(): ...` block from the right side,
leaving only `MAX_SIZE = 100`. Save and close.

jj will then prompt for two commit messages (one per resulting commit).

```
Enter commit description for the first part (the part you kept):
feat: add MAX_SIZE constant

Enter commit description for the second part (the remainder):
feat: add foo function
```

### 3. Verify the result

```bash
jj log -r "main..feat/split"
```

```
@  <new-id>  feat/split  feat: add foo function
○  <old-id>              feat: add MAX_SIZE constant
```

### 4. Update the bookmark and push

The `feat/split` bookmark was on the old combined commit. Move it to `@` (the
`feat: add foo function` tip) and push:

```bash
jj bookmark set feat/split
jj git push --bookmark feat/split
```

---

## How `jj split` Works Internally

```
Before:           After:
○  L              ○  L'
│                 │
@  K  (split)  →  @  K"  feat: add foo function   (remainder)
│                 │
◆  J              ○  K'  feat: add MAX_SIZE constant  (selected)
                  │
                  ◆  J
```

- The **selected hunks** (what you kept on the right side of the diff editor)
  become the **first (lower) commit** — `K'`.
- The **remaining hunks** (what you removed from the right) become the **second
  (upper) commit** — `K"`, which is a child of `K'`.
- `@` ends up on the upper commit after the split.

## Configuring a Diff Editor

`jj split -i` requires a diff editor. Set one in `~/.config/jj/config.toml`:

```toml
[ui]
diff-editor = "vimdiff"   # or "meld", "difft", "vscode", etc.
```

Or pass it ad-hoc:

```bash
jj split --tool vimdiff
```

## Comparison with the Manual Approach

| | `jj split -i` | Manual (`jj edit` + `jj new`) |
|---|---|---|
| Hunk-level control | Yes — pick individual lines | No — you rewrite files by hand |
| Requires diff editor | Yes | No |
| Good for many hunks | Yes | Tedious |
| Good for learning | Shows the concept clearly | Makes each step explicit |

For a single file with two clearly separated blocks (like this challenge), both
approaches are equally fast. For commits with many interleaved hunks across
multiple files, `jj split -i` is far more practical.
