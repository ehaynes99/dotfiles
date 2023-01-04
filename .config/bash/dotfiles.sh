alias dit="git -c core.excludesfile=$HOME/.dotfiles.gitignore --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
# git clone --bare {URL} $HOME/.dotfiles.git
# dit checkout

# TODO - Remove --polling once resolved: https://github.com/extrawurst/gitui/issues/1446
alias ditui="gitui -d $HOME/.dotfiles.git/ -w $HOME --polling"
