#!/usr/bin/env bash

# The rule lands at session start, alongside the harness instruction it
# overrides, so the commit message is composed right the first time. The Bash
# deny is the backstop.

here=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
cat >/dev/null

jq -n --rawfile rule "$here/hooks/rule.txt" '{
	hookSpecificOutput: {
		hookEventName: "SessionStart",
		additionalContext: $rule
	}
}'
