fcd() {
	[[ -n "$1" ]] && path="$1" || path="."

	result=$(fd -td ".*" "$path" | fzf)
	[[ -n "$result" ]] && cd "$result" || return
}

fzp() {
	fd | fzf \
		--preview '[[ -d {} ]] && ls -1 {} || bat --color=always --style=numbers --line-range=:500 {}' \
		--bind='tab:up' \
		--bind='shift-tab:down'
}

function pr-checkout() {
	local pr_number

	pr_number=$(
		gh api 'repos/:owner/:repo/pulls' |
			jq --raw-output '.[] | "#\(.number) \(.title)"' |
			fzf |
			sed 's/^#\([0-9]\+\).*/\1/'
	)

	if [ "$pr_number" != "" ]; then
		gh pr checkout "$pr_number"
	fi
}
