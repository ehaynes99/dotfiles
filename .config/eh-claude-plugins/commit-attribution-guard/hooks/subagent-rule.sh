#!/usr/bin/env bash

# Subagents start with a fresh context and don't reliably inherit the user's
# memory, so they get the rule unconditionally.

here=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
cat >/dev/null

jq -n --rawfile rule "$here/hooks/rule.txt" '{
	hookSpecificOutput: {
		hookEventName: "SubagentStart",
		additionalContext: $rule
	}
}'
