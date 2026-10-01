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

start='(^|[|;&(`]|[[:space:]])'
# Global flags, with optional values, between the tool name and its
# subcommand, e.g. `gh -R owner/repo pr ...`.
flags='([[:space:]]+-[^[:space:]]+([[:space:]]+[^-][^[:space:]]*)?)*'

# The trailing \> keeps `--comments` (a read flag on `gh pr view`) from matching.
gh_subcommand="${start}gh${flags}[[:space:]]+(pr|issue)[[:space:]]+(comment|review)\\>"

graphql_mutation='(addComment|addPullRequestReview|addPullRequestReviewComment|addPullRequestReviewThread|addPullRequestReviewThreadReply|submitPullRequestReview|updateIssueComment|updatePullRequestReview|updatePullRequestReviewComment|addDiscussionComment|updateDiscussionComment)'

api_cmd="${start}(gh${flags}[[:space:]]+api\\>|curl\\>.*(api\\.github\\.com|github\\.[^/[:space:]]+/api/v3))"
# Only as a path segment, so field names like `comments(first:1)` in a
# request body don't count.
comment_path="/(comments|reviews|replies)([/?'\"[:space:]]|$)"
# Body/field flags make `gh api` default to POST.
write='(-X|--method|--request)[[:space:]]+.?(POST|PATCH|PUT|post|patch|put)|(^|[[:space:]])(-f|-F|-d|--field|--raw-field|--input|--data|--data-raw|--data-binary|--json)([[:space:]]|=)'

if [[ "$command" =~ $gh_subcommand || "$command" =~ $graphql_mutation ]] ||
	{ [[ "$command" =~ $api_cmd ]] && [[ "$command" =~ $comment_path ]] && [[ "$command" =~ $write ]]; }; then
	reason="Blocked: this would post to GitHub as the user — gh and curl authenticate with their token, so the comment would land on the PR under their name, as if they wrote it. Write the reply out in the conversation instead and let them post it."

	jq -n --arg reason "$reason" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "deny",
			permissionDecisionReason: $reason
		}
	}'
fi
