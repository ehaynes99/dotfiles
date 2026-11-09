---
name: reload-all-sessions
description: Run /reload-plugins and /reload-skills in every other Claude Code session running in herdr. Use when the user asks to reload skills or plugins across all sessions, or after editing a skill/plugin that other sessions should pick up.
allowed-tools: Bash
---

# reload-all-sessions

Run `$HOME/.config/bash/scripts/claude-reload-all` by absolute path and relay
its output. Sessions that were working or blocked are listed as `skip`; tell
the user they need a manual reload (or rerun this once they are idle).

This session cannot reload itself — if it needs the change too, tell the user
to run `/reload-plugins` / `/reload-skills` here.
