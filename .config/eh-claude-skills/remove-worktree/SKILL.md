---
name: remove-worktree
description: Remove a git worktree, delete its checkout directory, and release it from herdr. Use when the user asks to remove, delete, or clean up a git worktree, a branch's worktree, or a herdr worktree workspace.
allowed-tools: Bash, AskUserQuestion
---

# remove-worktree

Wraps `$HOME/.config/bash/scripts/git-worktree-remove`, which removes one
worktree and first closes the herdr workspace holding it open.

Always invoke it by absolute path. `~/.config/bash/scripts` is only added to
`PATH` by interactive shell config, so a bare `git-worktree-remove` will not
resolve in tool-run shells. The path argument may be anywhere; the script
anchors itself to the right repo.

For cleaning up many branches whose remote is gone, `git-cleanup` already does
this in a loop with an fzf picker. Point the user at it instead of looping here.

## Workflow

1. Find the worktree. `git worktree list` in the repo. Match the user's words
   against the paths and branches; if more than one fits, ask which.
2. Show what will go. Run both and show the output as-is:
   ```sh
   "$HOME/.config/bash/scripts/git-worktree-remove" --dry-run <path>
   git -C <path> status --short
   ```
3. Ask for confirmation with AskUserQuestion. Always ask, every time — when the
   user already named the worktree, when they said "just do it", when they
   asked for several at once. List one line per thing that goes: the directory,
   the herdr workspace, and the branch if they asked for that too.
4. On yes:
   ```sh
   "$HOME/.config/bash/scripts/git-worktree-remove" <path>
   ```
5. Report what happened.

## Rules

- Uncommitted changes: `git worktree remove` refuses and the script leaves the
  worktree alone. Report the refusal and let the user decide what to do about
  the changes. Removing it anyway is the user's call: they ask, you run
  `git worktree remove --force` yourself.
- The branch survives unless the user asks for it. Then `git branch -d <branch>`
  after the worktree is gone; `-D` only if they say so.
- Closing a herdr workspace kills every pane in it, including any Claude
  session running there. If the dry-run's workspace id equals
  `$HERDR_WORKSPACE_ID`, this session dies mid-run and can't report back.
  Say so in the confirmation; on yes, run it last, after anything else you
  owe the user, or hand them the command to run from another workspace. If
  it's a different workspace, still name it in the confirmation: other
  agents in it go too.
- Several worktrees: dry-run them all, confirm once with the full list, then
  remove them one at a time.
