fcd() {
	[[ -n "$1" ]] && path="$1" || path="."

	result=$(fd -td ".*" "$path" | fzf)
	[[ -n "$result" ]] && cd "$result" || return
}

fzp() {
	fd | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
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

vp() {
	local dirs=(
		'/home/erich/workspace/openphone/projects'
		'/home/erich/workspace/tmp'
		'/home/erich/workspace/monorepo'
    '/home/erich/all-workspaces/external'
		'/home/erich/workspace/backend/backend'
	)

	project=$(fd -d1 -td . "${dirs[@]}" | fzf --preview='bat {}package.json' --query "$*")
  project="${project/#~/$HOME}"

	if [ "$project" != "" ]; then
		cd "$(dirname "$project")" || return
		open_nvim "$(basename "$project")"
	fi
}
