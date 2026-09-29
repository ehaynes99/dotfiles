#!/usr/bin/env bash

# Lands the rule before a response is composed; a PreToolUse reminder arrives
# only after the edit is already written.

here=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
cat >/dev/null
[[ -z $COMMENT_DIET_JUDGE ]] || exit 0

jq -n --rawfile rule "$here/hooks/rule.txt" '{
	hookSpecificOutput: {
		hookEventName: "UserPromptSubmit",
		additionalContext: $rule
	}
}'
