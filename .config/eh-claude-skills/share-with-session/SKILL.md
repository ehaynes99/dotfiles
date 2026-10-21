---
name: share-with-session
description: Send something to, or pull something from, another Claude Code session identified by its session UUID. Use when the user invokes /share-with-session, or asks to send/share/hand off something to a session, or to read/get/pick up something from a session, and gives a session id (a UUID).
---

# share-with-session

```
/share-with-session <session-uuid> [what to send, or what to read from it]
```

Decide the direction from the request: sending this session's work to the
target (Send), or getting the target's work into this session (Pull).

The UUID is the target's `sessionId`. It is **not** the `[ref]` hex shown by
ListAgents, and a session's name has no relation to its UUID. Never pick a
peer by similarity, recency, or cwd — resolve the name from the UUID exactly.

## Resolve

Every live session registers itself in `~/.claude/sessions/<pid>.json` with
both `sessionId` and `name`:

```sh
jq -r --arg id "<session-uuid>" \
  'select(.sessionId==$id) | "\(.name)\t\(.status)\t\(.cwd)"' \
  ~/.claude/sessions/*.json
```

- Exactly one row: that `name` is the SendMessage address.
- No row: the session is not running (or the UUID is wrong). Stop and tell
  the user; do not fall back to any other session. Don't trim, fix up or
  prefix-match the UUID either — ask for it again.
- The id equals your own session id: tell the user they gave you this session.

## Send

`SendMessage({to: "<name>", message: "..."})` with the name copied verbatim.
If the name is ambiguous in ListAgents, append the `[ref]` from the ListAgents
row whose name matches.

The message must stand alone — the target has none of this conversation.
When sending a change, include the exact diff or file contents, the absolute
paths, and the repo/branch it applies to, not a summary of it. If the user
didn't say what to send, ask. If the target should read from this session
itself, give it this session's full UUID so it can Pull: ListAgents names
this session in its first line; look that name up in
`~/.claude/sessions/*.json` (`select(.name=="<name>") | .sessionId`).

Report back to the user the resolved name, and that the message was sent.

## Pull

Read the target's transcript directly; it doesn't need to be running:

```sh
ls ~/.claude/projects/*/<session-uuid>.jsonl
```

Same rules as Resolve: exactly one file, exact UUID, otherwise stop and ask.
It's JSONL, one event per line, and can be large — search it with `jq`/`grep`
for what the user asked about (the latest diffs, Edit/Write tool inputs, the
final assistant messages) rather than reading it whole. Prefer the files the
transcript points to on disk over transcript snippets when they still exist.

If the transcript doesn't hold what's needed and the session is live, ask it
via Send instead, and say so to the user — its reply arrives later as a
message to this session.
