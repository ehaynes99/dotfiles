#!/usr/bin/env bash

# Inspects the lines an edit just added and, when they're comment-heavy or
# contain a comment that narrates the change or cites a ticket, hands the model
# back a concrete count and the offending lines. A number it can check beats a
# restatement of the rule, which it has already learned to skim past.

density_threshold=25
min_comments=3

here=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
input=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$input")
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")
[[ -n "$file" ]] || exit 0

name=${file##*/}
ext=${name##*.}
[[ "$ext" == "$name" ]] && ext=$name
ext=${ext,,}

density=true
case "$ext" in
c | h | cc | cpp | cxx | hpp | java | js | jsx | ts | tsx | mjs | cjs | go | rs | kt | kts | swift | scala | cs | php | dart | groovy | proto | kdl | gradle | scss | sass | less | zig)
	lc='//' bopen='/*' bclose='*/' ;;
css)
	lc='' bopen='/*' bclose='*/' ;;
sh | bash | zsh | fish | py | pyi | rb | pl | pm | tf | tfvars | nix | r | jl | ex | exs | nu | makefile | dockerfile | containerfile | justfile)
	lc='#' bopen='' bclose='' ;;
yaml | yml | toml | ini | cfg | conf)
	# Config files legitimately run comment-heavy; only the content rules apply.
	lc='#' bopen='' bclose='' density=false ;;
sql | lua | hs | elm)
	lc='--' bopen='' bclose='' ;;
html | htm | xhtml | xml | vue | svelte)
	lc='' bopen='<!--' bclose='-->' ;;
el | lisp | clj | cljs | cljc | scm | rkt)
	lc=';' bopen='' bclose='' ;;
vim)
	lc='"' bopen='' bclose='' ;;
*)
	exit 0 ;;
esac

tmp=$(mktemp -d) || exit 0
trap 'rm -rf "$tmp"' EXIT

added_lines() {
	jq -r "$1" <<<"$input" >"$tmp/old"
	jq -r "$2" <<<"$input" >"$tmp/new"
	diff --unchanged-line-format='' --old-line-format='' --new-line-format='%L' \
		"$tmp/old" "$tmp/new"
}

mode=edit
case "$tool" in
Write)
	mode=write
	jq -r '.tool_input.content // ""' <<<"$input" >"$tmp/added"
	;;
Edit)
	added_lines '.tool_input.old_string // ""' '.tool_input.new_string // ""' >"$tmp/added"
	;;
MultiEdit)
	: >"$tmp/added"
	count=$(jq '(.tool_input.edits // []) | length' <<<"$input")
	for ((i = 0; i < count; i++)); do
		added_lines ".tool_input.edits[$i].old_string // \"\"" \
			".tool_input.edits[$i].new_string // \"\"" >>"$tmp/added"
	done
	;;
*)
	exit 0 ;;
esac

report=$(awk -v LC="$lc" -v BOPEN="$bopen" -v BCLOSE="$bclose" -v MODE="$mode" \
	-f "$here/hooks/classify.awk" "$tmp/added")

read -r comments code <<<"${report%%$'\n'*}"
hits=$(tail -n +2 <<<"$report")
total=$((comments + code))

problems=()
if [[ -n "$hits" ]]; then
	while IFS= read -r hit; do
		case "$hit" in
		NARR:*) problems+=("narrates the change (git history's job): ${hit#NARR:}") ;;
		TICKET:*) problems+=("cites a ticket/issue (commit message's job): ${hit#TICKET:}") ;;
		esac
	done <<<"$hits"
fi

dense=false
if $density && ((comments >= min_comments && total > 0)) &&
	((comments * 100 / total > density_threshold)); then
	dense=true
fi

$dense || ((${#problems[@]})) || exit 0

{
	echo "Comment discipline — you just wrote $file:"
	$dense && echo "- $comments of $total added non-blank lines are comments ($((comments * 100 / total))%)."
	for p in "${problems[@]}"; do echo "- $p"; done
	echo
	echo "Go back over the comments in that edit and delete the ones that don't earn their place. Then hold to the rule for the rest of this session:"
	echo
	cat "$here/hooks/rule.txt"
} >"$tmp/message"

# Make the next PreToolUse reminder fire immediately rather than waiting out
# the interval, since the model has demonstrably drifted.
session=$(jq -r '.session_id // "unknown"' <<<"$input")
session=${session//[^A-Za-z0-9_-]/_}
state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/eh-claude-plugins/comment-diet"
mkdir -p "$state_dir" && echo 999 >"$state_dir/$session"

jq -n --rawfile message "$tmp/message" '{
	hookSpecificOutput: {
		hookEventName: "PostToolUse",
		additionalContext: $message
	}
}'
