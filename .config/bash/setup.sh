[[ $- != *i* ]] && return

BASH_CONFIG_DIR="$HOME/.config/bash"

HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
export VISUAL=nvim
export EDITOR="$VISUAL"
export BROWSER="brave"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# eval "$(dircolors ${HOME}/.dircolors/dircolors.256dark-erich)"

# Fix observed windows size if console is resized
shopt -s checkwinsize

# Enable '**' in glob
shopt -s globstar

source "$BASH_CONFIG_DIR/functions/safe_source.sh"

for f in "$BASH_CONFIG_DIR"/functions/*; do
	safe_source "$f"
done

for f in "$BASH_CONFIG_DIR"/lang/*; do
	safe_source "$f"
done

safe_source addons/git-completion.bash
safe_source ps1.sh
safe_source aliases.sh
safe_source dotfiles.sh

pre_path "$HOME/scripts"
pre_path "$BASH_CONFIG_DIR/scripts"

safe_source local-overrides.sh
safe_source secrets.sh
