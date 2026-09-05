#!/usr/bin/env bash

# Re-states the comment rule before an edit, but only every Nth edit. Injecting
# it on every single write turns it into wallpaper the model stops reading —
# the same way the memory entry it replaces stopped working.

interval=20

here=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
input=$(cat)
session=$(jq -r '.session_id // "unknown"' <<<"$input")
session=${session//[^A-Za-z0-9_-]/_}

state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/eh-claude-plugins/comment-diet"
mkdir -p "$state_dir" || exit 0
find "$state_dir" -maxdepth 1 -type f -mtime +7 -delete 2>/dev/null

counter="$state_dir/$session"
n=$(cat "$counter" 2>/dev/null)
[[ "$n" =~ ^[0-9]+$ ]] || n=$interval

if ((n < interval)); then
	echo $((n + 1)) >"$counter"
	exit 0
fi
echo 0 >"$counter"

jq -n --rawfile rule "$here/hooks/rule.txt" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		additionalContext: $rule
	}
}'
