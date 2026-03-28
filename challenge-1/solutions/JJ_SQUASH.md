# Challenge 1 — The Simple Fixup (jj squash alternative)

## Alternative Approach: `jj squash -i --from … --into …`

Instead of editing each commit individually and resolving a conflict, jj offers a more surgical approach: **interactively move specific hunks from one commit into another**.

## The Command

```bash
jj squash -i --from lpuyoomp --into klluxwrw
```

- `--from lpuyoomp` — the source commit (the `display` commit that has the misplaced `MAX_INPUT`)
- `--into klluxwrw` — the destination commit (the `calculate` commit where `MAX_INPUT` belongs)
- `-i` — interactive: opens a diff editor so you can select *which hunks* to move

In the diff editor, you would **select only the `MAX_INPUT` line** and leave the `display()` hunk unselected. jj then:
1. Moves the selected hunk into `klluxwrw`
2. Removes it from `lpuyoomp`
3. Rebases `lpuyoomp` on top of the updated `klluxwrw` — **no conflict**, because jj accounts for the moved hunk

## Why No Conflict?

With `jj edit` (the approach in `JJ.md`), you manually add `MAX_INPUT` to the `calculate` commit and jj rebases `display` on top. Because the original `display` commit also introduced `MAX_INPUT`, jj sees a conflict: both the new parent and the rebased commit claim to add the same line.

With `jj squash -i --from … --into …`, jj moves the hunk atomically — it knows the hunk came *from* `lpuyoomp`, so when it rebases `lpuyoomp`, the hunk is already gone. No conflict arises.

## Why It Didn't Work Here

`jj squash -i` requires an interactive terminal (a TTY) to display the diff selection UI. Running it in a non-interactive context (e.g. a script, CI, or a tool that captures stdout) fails with:

```
Error: Failed to edit diff
Caused by: failed to set up terminal: No such device or address (os error 6)
```

In a normal terminal session this command works fine.

## When to Use Each Approach

| Situation | Prefer |
|---|---|
| Moving a clean, isolated hunk between commits | `jj squash -i --from … --into …` |
| Restructuring larger portions or multiple files | `jj edit` + manual resolution |
| Non-interactive environment (CI, scripts) | `jj edit` + manual file writes |
| You want to avoid thinking about conflicts | `jj squash -i --from … --into …` |
