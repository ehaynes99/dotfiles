# dotfiles

## What this directory is

`~/dotfiles` is mostly **symlinks** — each one points at the real file or directory
elsewhere under `$HOME` (mostly `~/.config/*`):

```
alacritty          -> ~/.config/alacritty/
bash               -> ~/.config/bash/
bat                -> ~/.config/bat/
DankMaterialShell  -> ~/.config/DankMaterialShell/
gitui              -> ~/.config/gitui/
niri               -> ~/.config/niri/
ripgrep            -> ~/.config/ripgrep/
.gitconfig         -> ~/.gitconfig
.dotfiles.gitconfig -> ~/.dotfiles.gitconfig
.dotfiles.gitignore -> ~/.dotfiles.gitignore
```

It serves as a convenience entry point for browsing/editing the tracked config
files in one place; edits made through these paths land on the real files. A few
genuine files live here too — this `CLAUDE.md`, and any other "dotfiles meta"
file that belongs to the dotfiles setup itself rather than to a config elsewhere.

## Version control: use `dit`, not `git`

This directory is **not** a git repo. The files it links to are tracked in a
bare-repo dotfiles setup: git dir `~/.dotfiles.git`, work tree `$HOME`
(remote: `git@github.com:ehaynes99/dotfiles.git`).

`~/.config/bash/dotfiles.sh` defines:

```sh
alias dit='git -c core.excludesfile=$HOME/.dotfiles.gitignore --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'
alias ditui='gitui -d $HOME/.dotfiles.git/ -w $HOME'
```

Use `dit` in place of `git` for any version-control operation on these files —
`dit status`, `dit diff`, `dit add <path>`, `dit commit`, `dit log`, etc. Plain
`git` here either fails or, worse, walks up to some unrelated repo.

Shell aliases are not available in non-interactive shells, so when running
commands via tooling, spell the alias out:

```sh
git -c core.excludesfile=$HOME/.dotfiles.gitignore \
    --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME <subcommand>
```

Paths passed to `dit` are relative to the work tree (`$HOME`), not to this
directory: use `dit add .config/niri/config.kdl`, not `dit add niri/config.kdl`.

`~/.dotfiles.gitignore` is an allowlist — everything under `$HOME` is ignored by
default and tracked paths are un-ignored explicitly. A new config directory won't
show up in `dit status` until it's added there.

## Restoring on a new machine

```sh
git clone --bare git@github.com:ehaynes99/dotfiles.git $HOME/.dotfiles.git
dit checkout
```
