#!/usr/bin/env bash

case `hostname 2> /dev/null || uname -n | sed -e 's/\..*//'g` in
  eh-home)
    export PS1_USER_COLOR='5;5'
    export PS1_MACHINE_NAME_COLOR='5;6'
    ;;
  eh-main)
    export PS1_USER_COLOR='5;11'
    export PS1_MACHINE_NAME_COLOR='5;172'
    ;;
  eh-thinkpad)
    export PS1_USER_COLOR='5;30'
    export PS1_MACHINE_NAME_COLOR='5;93'
    ;;
  eh-win)
    export PS1_USER_COLOR='5;2'
    export PS1_MACHINE_NAME_COLOR='5;2'
    ;;
  *)
    export PS1_USER_COLOR='5;7'
    export PS1_MACHINE_NAME_COLOR='5;7'
    ;;
esac

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\n\[\033[38;${PS1_USER_COLOR}m\]\u\[\033[38;5;7m\]@\[\033[38;${PS1_MACHINE_NAME_COLOR}m\]\h:\[\033[38;5;7m\]\w\[\033[33m\]\$(parse_git_branch) \[\033[38;5;8m\](\D{%T})\n\[\033[38;5;7m\]\$ \[$(tput sgr0)\]"

