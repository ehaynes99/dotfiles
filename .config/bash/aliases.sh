# Builtins
alias grep='grep --color=auto'
alias ls='ls -hN --color=auto'
# alias which='alias | which -i'
alias which='alias | which -i'
alias newv='nvim -u /home/erich/.config/new-nvim/init.lua'
# alias codeburn='npx -y codeburn'

# Cliboard
if [ -n "$WAYLAND_DISPLAY" ]; then
  alias clip='wl-copy'
else
  alias clip='xclip -r -sel clip'
fi

alias v='open_nvim'
alias k='kubectl'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias ga.='git add .'
