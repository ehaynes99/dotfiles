#!/usr/bin/env bash

# Re-states the comment rule immediately before every edit. Flagging the
# slather afterward never worked — by then the comments are written and the
# model rationalizes them — so the rule lands while the decision is still open.

here=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
cat >/dev/null

jq -n --rawfile rule "$here/hooks/rule.txt" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		additionalContext: $rule
	}
}'
