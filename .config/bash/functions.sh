safe_source() {
  [[ -f "$1" ]] && source "$1"
}

pacman_executables_of() {
  pacman -Qlq $* | perl -nle 'use Term::ANSIColor; print colored($&, 'bright_red') if m{(?<=bin/).+}'
}

fcd() {
  [[ -n "$1" ]] && path="$1" || path="."
  result=$(fd -td ".*" "$path" | fzf)
  [[ -n "$result" ]] && cd $result
}
