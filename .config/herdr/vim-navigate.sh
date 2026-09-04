#!/usr/bin/env bash
#
# Ctrl+h/j/k/l navigation across herdr panes and Neovim splits.
#
# Requires `jq`. Without it, detection is skipped and every chord simply moves
# the herdr pane focus (no Vim awareness).

set -euo pipefail

dir="${1:?usage: vim-navigate.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"

case "$dir" in
  left)  key='ctrl+h' ;;
  down)  key='ctrl+j' ;;
  up)    key='ctrl+k' ;;
  right) key='ctrl+l' ;;
  *) echo "vim-navigate.sh: unknown direction: $dir" >&2; exit 2 ;;
esac

# Foreground process names meaning "Vim is in control of this pane".
# Same matcher vim-tmux-navigator uses: vi, vim, nvim, view, gvim, *diff, ...
vim_re='^g?(view|l?n?vim?x?)(diff)?$'

if command -v jq >/dev/null 2>&1; then
  pane=$("$herdr" pane current 2>/dev/null | jq -r '.result.pane.pane_id // empty')

  if [ -n "$pane" ] && "$herdr" pane process-info --pane "$pane" 2>/dev/null |
    jq -e --arg vim "$vim_re" \
      '.result.process_info.foreground_processes[]?.name
       | ascii_downcase
       | select(test($vim))' >/dev/null 2>&1; then
    exec "$herdr" pane send-keys "$pane" "$key"
  fi
fi

exec "$herdr" pane focus --direction "$dir" --current
