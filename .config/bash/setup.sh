[[ $- != *i* ]] && return

BASH_CONFIG_DIR="$HOME/.config/bash"

HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
export VISUAL=nvim
export EDITOR="$VISUAL"
export LESS='-R'
export BROWSER="brave"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git"'
# fixes httpie ssl
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export EARLYOOM_ARGS="-m 5,2 -s 10,5 --prefer '(^|/)(java|node)'"

export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
export DISABLE_TELEMETRY=1
# investigate
# export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
# investigate more, but likely no
# export CLAUDE_CODE_USE_BEDROCK=1
# export CLAUDE_CODE_USE_VERTEX=1

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
ssh-add -l &>/dev/null || ssh-add ~/.ssh/id_ed25519

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
pre_path "$HOME/bin"
pre_path "$HOME/.local/bin"
pre_path "$HOME/.local/share/pnpm"
pre_path "$BASH_CONFIG_DIR/scripts"
while IFS= read -r -d '' DIR; do
	pre_path "$DIR"
done < <(find -L "$BASH_CONFIG_DIR/scripts" -mindepth 1 -type d -print0)

safe_source local-overrides.sh
safe_source secrets.sh
