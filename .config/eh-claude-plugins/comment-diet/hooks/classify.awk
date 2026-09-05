# Reads the lines added by an edit and reports how many are comments, plus any
# that look like change narration or a ticket reference.
#
# Inputs: LC (line-comment prefix), BOPEN/BCLOSE (block delimiters), MODE
# ("write" exempts a file's leading header block from the density count).
# Output: "<comments> <code>" then one "NARR:"/"TICKET:" line per hit.

function starts(s, p) { return p != "" && substr(s, 1, length(p)) == p }

function suspicious(l,   low, pre) {
	low = tolower(l)
	if (low ~ /(^|[^a-z-])(previously|formerly|used to |prior to this|before this change|we now |now (uses|returns|takes|handles|calls|does|only|instead)|(was|were|has been|have been) (renamed|replaced|removed|moved|changed|extracted|split|merged)|(renamed|replaced|removed|moved|switched|migrated) (from|to|by|with)|in favor of|old (behavior|behaviour|implementation|version|code|logic|way|name)|this (change|commit|pr|refactor|patch)|no longer (used|needed|necessary|exists))/) {
		if (nnarr < 3) narr[++nnarr] = l
		return
	}
	if (match(l, /[A-Z][A-Z0-9]{1,9}-[0-9]+/)) {
		pre = substr(l, RSTART, RLENGTH)
		sub(/-[0-9]+$/, "", pre)
		if (!(pre in deny) && ntick < 3) { tick[++ntick] = l; return }
	}
	if (low ~ /(ticket|jira|issue|story)[ :#]*[0-9]+/ && ntick < 3) tick[++ntick] = l
}

BEGIN {
	split("UTF ISO SHA RFC CVE HTTP HTTPS IPV AES MD PEP ES TLS SSL EC GL WCAG UTC BASE ASCII ANSI IEEE CRC ECMA ID X Y Z W N A B C", d, " ")
	for (i in d) deny[d[i]] = 1
	header = (MODE == "write")
}

{
	line = $0
	if (line ~ /^[[:space:]]*$/) next
	if (MODE == "write" && NR == 1 && line ~ /^#!/) { code++; next }

	s = line
	sub(/^[[:space:]]+/, "", s)
	is_comment = 0

	if (in_block) {
		is_comment = 1
		if (BCLOSE != "" && index(s, BCLOSE)) in_block = 0
	} else if (starts(s, BOPEN)) {
		is_comment = 1
		if (index(substr(s, length(BOPEN) + 1), BCLOSE) == 0) in_block = 1
	} else if (starts(s, LC)) {
		is_comment = 1
	}

	if (!is_comment) { header = 0; code++; next }
	suspicious(line)
	if (!header) comment++
}

END {
	printf "%d %d\n", comment, code
	for (i = 1; i <= nnarr; i++) printf "NARR:%s\n", narr[i]
	for (i = 1; i <= ntick; i++) printf "TICKET:%s\n", tick[i]
}
