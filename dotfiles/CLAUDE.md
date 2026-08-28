# dotfiles

## What this directory is

`~/dotfiles` is mostly **symlinks** — each one points at the real file or
directory elsewhere under `$HOME` (mostly `~/.config/*`). It serves as a
convenience entry point for browsing/editing the tracked config files in one
place; edits made through these paths land on the real files. A few genuine
files live here too — this `CLAUDE.md`, and any other "dotfiles meta" file
that belongs to the dotfiles setup itself rather than to a config elsewhere.

## Never commit or push here

Claude must never run `dit commit`, `dit push`, or plain `git commit`/`push`
against this repo — stage/edit freely, but leave committing and pushing to
the user, always.

## Version control: use `dit`, not `git`

This directory is **not** a git repo. The files it links to are tracked in a
bare-repo dotfiles setup: git dir `~/.dotfiles.git`, work tree `$HOME`
(remote: `git@github.com:ehaynes99/dotfiles.git`).

`dit` and `ditui` (defined in `~/.config/bash/dotfiles.sh`) wrap `git`/`gitui`
with that git-dir/work-tree/excludesfile. Use `dit` in place of `git` for any
version-control operation on these files — `dit status`, `dit diff`,
`dit log`, etc. Plain `git` here either fails or, worse, walks up to some
unrelated repo.

Shell aliases are not available in non-interactive shells, so when running
commands via tooling, spell it out:

```sh
git -c core.excludesfile=$HOME/.dotfiles.gitignore \
    --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME <subcommand>
```

Paths passed to `dit` are relative to the work tree (`$HOME`), not to this
directory: use `dit add .config/niri/config.kdl`, not `dit add niri/config.kdl`.

`~/.dotfiles.gitignore` is an allowlist — everything under `$HOME` is ignored
by default and tracked paths are un-ignored explicitly. A new config
directory won't show up in `dit status` until it's added there.

## Restoring on a new machine

```sh
git clone --bare git@github.com:ehaynes99/dotfiles.git $HOME/.dotfiles.git
dit checkout
```
