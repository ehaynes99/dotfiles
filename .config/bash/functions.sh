safe_source() {
  [[ -f "$1" ]] && source "$1"
}

pacman_executables_of() {
  pacman -Qlq $* | perl -nle 'use Term::ANSIColor; print colored($&, 'bright_red') if m{(?<=bin/).+}'
}
