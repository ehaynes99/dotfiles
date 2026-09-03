#!/usr/bin/env bash

# Denies any Bash command that would post a comment or review to GitHub.
# `gh` (and any curl carrying the user's token) authenticates as the user, so
# anything posted this way shows up on the PR under their name, as if they
# wrote it.
#
# Note: every pattern below has to live in a variable. A backslash escape
# inside an inline [[ =~ ]] pattern is quote-removed by bash, which would turn
# the \< \> word boundaries into literal angle brackets.

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

[[ -n "$command" ]] || exit 0

# Start of a command: line start, or after a separator/pipe/subshell open.
start='(^|[|;&(`]|[[:space:]])'
# Global flags, with optional values, between the tool name and its
# subcommand, e.g. `gh -R owner/repo pr ...`.
flags='([[:space:]]+-[^[:space:]]+([[:space:]]+[^-][^[:space:]]*)?)*'

# `gh pr comment`, `gh issue comment`, `gh pr review`. The trailing \> keeps
# `--comments` (a read flag on `gh pr view`) from matching.
gh_subcommand="${start}gh${flags}[[:space:]]+(pr|issue)[[:space:]]+(comment|review)\\>"

# `gh api` / `curl` against a comment or review endpoint...
gh_api="${start}gh${flags}[[:space:]]+api\\>"
curl_cmd="${start}curl\\>"
github_host='(api\.github\.com|github\.[^/[:space:]]+/api/v3)'
comment_path='(comments|reviews|replies)'

# ...counts only when it's a write: an explicit non-GET method, or body/field
# flags, which make `gh api` default to POST anyway.
write_method='(-X|--method|--request)[[:space:]]+.?(POST|PATCH|PUT|post|patch|put)'
body_flag='(^|[[:space:]])(-f|-F|-d|--field|--raw-field|--input|--data|--data-raw|--data-binary|--json)([[:space:]]|=)'

# GraphQL mutations that post a comment or review.
graphql_mutation='(addComment|addPullRequestReview|addPullRequestReviewComment|addPullRequestReviewThread|addDiscussionComment)'

blocked=false

if [[ "$command" =~ $gh_subcommand ]]; then
	blocked=true
elif [[ "$command" =~ $graphql_mutation ]]; then
	blocked=true
elif [[ "$command" =~ $comment_path ]] &&
	{ [[ "$command" =~ $write_method ]] || [[ "$command" =~ $body_flag ]]; } &&
	{ [[ "$command" =~ $gh_api ]] ||
		{ [[ "$command" =~ $curl_cmd ]] && [[ "$command" =~ $github_host ]]; }; }; then
	blocked=true
fi

$blocked || exit 0

reason="Blocked: this would post to GitHub as the user — gh and curl authenticate with their token, so the comment would land on the PR under their name, as if they wrote it. Write the reply out in the conversation instead and let them post it."

jq -n --arg reason "$reason" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		permissionDecision: "deny",
		permissionDecisionReason: $reason
	}
}'
