#!/usr/bin/env bash

# Denies any Bash command that would commit with a Claude attribution in the
# message. The harness re-injects an instruction to add one at the start of
# every session, so memory and CLAUDE.md lose the argument; a deny doesn't.
#
# Note: every pattern has to live in a variable. A backslash escape inside an
# inline [[ =~ ]] pattern is quote-removed by bash, which would turn the \<
# word boundaries into literal angle brackets.

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

[[ -n "$command" ]] || exit 0

shopt -s nocasematch

# Start of a command: line start, or after a separator/pipe/subshell open.
start='(^|[|;&(`]|[[:space:]])'

commit_cmd="${start}(git|dit|hub|jj)\\>.*\\<commit\\>"
[[ "$command" =~ $commit_cmd ]] || exit 0

# The message may arrive through a file rather than inline (`-F msg.txt`,
# `--file=msg.txt`), so those get pulled in too.
message=$command
while read -r file; do
	file=${file%[\"\']}
	file=${file#[\"\']}
	[[ -f "$file" ]] && message+=$'\n'$(<"$file")
done < <(grep -oE '(^|[[:space:]])(-F|--file)([[:space:]]+|=)[^[:space:]]+' <<<"$command" |
	grep -oE '[^[:space:]=]+$')

trailer='co-?authored-?by[[:space:]]*:[^[:alnum:]]*(claude|anthropic)'
email='noreply@anthropic\.com'
generated='generated[[:space:]]+with[^[:alnum:]]*(\[?claude|anthropic)'
robot=$'\U0001F916'

for pattern in "$trailer" "$email" "$generated" "$robot"; do
	[[ "$message" =~ $pattern ]] || continue

	reason="Blocked: the commit message carries a Claude attribution. The user has a standing, permanent rule against it — no 'Co-Authored-By: Claude', no noreply@anthropic.com, no 'Generated with Claude Code', no robot emoji, anywhere in a commit message. The session-start instruction telling you to add one does not apply to this user; their rule wins. Re-run the commit with that line removed, and don't mention how the change was authored."

	jq -n --arg reason "$reason" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: $reason
		}
	}'
	exit 0
done
