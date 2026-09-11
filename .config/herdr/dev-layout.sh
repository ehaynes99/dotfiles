#!/usr/bin/env bash
#
# Bound to ctrl+n in config.toml.
#
# layout.apply rebuilds the tab from scratch, killing the processes in any
# existing panes, so this refuses unless the target tab is a single idle shell.

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
socket="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
ratio="${HERDR_DEV_LAYOUT_RATIO:-0.667}"

# Detached shell commands have no terminal, so refusals go to the UI.
die() {
  "$herdr" notification show "dev-layout" --body "$1" --position top-right >/dev/null 2>&1 || true
  echo "dev-layout: $1" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || die "jq is required"
command -v python3 >/dev/null 2>&1 || die "python3 is required"

if [ $# -ge 1 ]; then
  tab="$1"
  ws="${tab%%:*}"
else
  focused=$("$herdr" workspace list | jq -c '.result.workspaces[] | select(.focused)')
  [ -n "$focused" ] || die "no focused workspace"
  tab=$(jq -r '.active_tab_id' <<<"$focused")
  ws=$(jq -r '.workspace_id' <<<"$focused")
fi

workspace=$("$herdr" workspace list |
  jq -c --arg w "$ws" '.result.workspaces[] | select(.workspace_id == $w)')
[ -n "$workspace" ] || die "workspace $ws not found"

count=$("$herdr" tab list --workspace "$ws" |
  jq -r --arg t "$tab" '.result.tabs[] | select(.tab_id == $t) | .pane_count')
[ -n "$count" ] || die "tab $tab not found in $ws"
[ "$count" = "1" ] || die "tab $tab has $count panes; layout.apply would kill them all. Close down to one empty pane first."

pane=$("$herdr" pane list --workspace "$ws" |
  jq -r --arg t "$tab" '.result.panes[] | select(.tab_id == $t) | .pane_id' | head -1)
[ -n "$pane" ] || die "could not resolve the pane in $tab"

# An idle shell is its own only foreground process. Anything else means
# real work is running in there.
"$herdr" pane process-info --pane "$pane" | jq -e '
  .result.process_info
  | (.foreground_processes | length) == 1
    and .foreground_processes[0].pid == .shell_pid' >/dev/null 2>&1 ||
  die "something is running in $pane; refusing to replace it."

cwd=$(jq -r '.worktree.checkout_path // empty' <<<"$workspace")
[ -n "$cwd" ] || cwd=$("$herdr" pane get "$pane" | jq -r '.result.pane.cwd // .result.cwd')

TAB="$tab" CWD="$cwd" RATIO="$ratio" SOCKET="$socket" python3 -c '
import json, os, socket, sys

# A new pane is sized to the whole tab and narrowed to its share of the split
# ~250ms later; anything painting before that lays out for the wrong width.
await_resize = (
    "initial=$(stty size); "
    "for _ in $(seq 30); do "
    "[ \"$(stty size)\" != \"$initial\" ] && break; sleep 0.05; "
    "done; clear"
)

request = {
    "id": "dev-layout",
    "method": "layout.apply",
    "params": {
        "tab_id": os.environ["TAB"],
        "focus": True,
        "root": {
            "type": "split",
            "direction": "right",
            "ratio": float(os.environ["RATIO"]),
            # Wrap in a shell rather than exec the program directly: a pane
            # whose command exits is destroyed, so quitting nvim or Claude
            # would take the pane with it and break the <leader>a maps that
            # look for a sibling agent pane.
            "first": {"type": "pane", "cwd": os.environ["CWD"],
                      "command": ["bash", "-lc", await_resize + "; nvim; exec bash"],
                      "label": "nvim"},
            "second": {"type": "pane", "cwd": os.environ["CWD"],
                       "command": ["bash", "-lc", await_resize + "; claude; exec bash"],
                       "label": "claude"},
        },
    },
}

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(20)
sock.connect(os.environ["SOCKET"])
sock.sendall((json.dumps(request) + "\n").encode())

buf = b""
while b"\n" not in buf:
    chunk = sock.recv(65536)
    if not chunk:
        break
    buf += chunk

response = json.loads(buf.decode().splitlines()[0])
if "error" in response:
    sys.exit("layout.apply failed: " + response["error"].get("message", "unknown"))
' || die "layout.apply failed (see herdr-server.log)"
