#!/usr/bin/env bash

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

pattern='\<git\>.*\<worktree\>[[:space:]]+\<add\>'
if [[ "$command" =~ $pattern ]]; then
	plugin_root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
	reason="Use $plugin_root/worktree-create instead of raw 'git worktree add' — it also links Claude Code project memory into the new worktree. Usage: worktree-create [-b] <path> <branch> [<start-point>]"
	jq -n --arg reason "$reason" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: $reason
		}
	}'
fi
