fcd() {
	[[ -n "$1" ]] && path="$1" || path="."

	result=$(fd -td ".*" "$path" | fzf)
	[[ -n "$result" ]] && cd "$result" || return
}

fuzzy_preview() {
	fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
}
