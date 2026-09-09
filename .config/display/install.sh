#!/usr/bin/env bash
# Usage: sudo ./install.sh [--apply] [--host NAME]
# Without --apply it only prints what it would change.
set -euo pipefail

SRC=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
FIRMWARE_DIR=/usr/lib/firmware/edid
SLEEP_HOOK=/etc/systemd/system-sleep/drm-reprobe
CMDLINE=/etc/kernel/cmdline
MKINITCPIO=/etc/mkinitcpio.conf

apply=
host=$(uname -n); host=${host%%.*}

die() { echo "install.sh: $*" >&2; exit 1; }
run() { if [[ $apply ]]; then "$@"; else echo "  would run: $*"; fi; }

while [[ $# -gt 0 ]]; do
  case $1 in
    --apply) apply=1; shift ;;
    --host)  host=${2:?--host needs a value}; shift 2 ;;
    *)       die "unknown option: $1" ;;
  esac
done

conf=$SRC/hosts/$host.conf
[[ -f $conf ]] || die "no host config at $conf"

CONNECTOR= EDID_BLOB= FORCE_ENABLE=no
# shellcheck source=/dev/null
. "$conf"
[[ $CONNECTOR && $EDID_BLOB ]] || die "$conf must set CONNECTOR and EDID_BLOB"

blob=$SRC/edid/$EDID_BLOB
[[ -f $blob ]] || die "missing EDID blob: $blob"
[[ $apply && $EUID -ne 0 ]] && die "--apply needs root"

echo "host=$host connector=$CONNECTOR edid=$EDID_BLOB force_enable=$FORCE_ENABLE"
[[ $apply ]] || echo "(dry run -- pass --apply to make changes)"

echo "[1/5] EDID blob"
run install -Dm644 "$blob" "$FIRMWARE_DIR/$EDID_BLOB"

echo "[2/5] resume hook"
run install -Dm755 "$SRC/system-sleep/drm-reprobe" "$SLEEP_HOOK"

echo "[3/5] kernel cmdline"
want="drm.edid_firmware=$CONNECTOR:edid/$EDID_BLOB"
[[ $FORCE_ENABLE == yes ]] && want+=" video=$CONNECTOR:e"
current=$(<"$CMDLINE")
# Drop any prior directives for this connector so re-runs do not accumulate them.
cleaned=$(printf '%s' "$current" \
  | sed -E "s@ ?drm\.edid_firmware=$CONNECTOR:[^ ]*@@g; s@ ?video=$CONNECTOR:[^ ]*@@g")
desired="$cleaned $want"
if [[ "$current" == "$desired" ]]; then
  echo "  already correct"
elif [[ $apply ]]; then
  cp -n "$CMDLINE" "$CMDLINE.bak" 2>/dev/null || true
  printf '%s\n' "$desired" > "$CMDLINE"
  echo "  -> $desired"
else
  echo "  would set: $desired"
fi

echo "[4/5] mkinitcpio FILES"
fw_path=$FIRMWARE_DIR/$EDID_BLOB
if grep -qF "$fw_path" "$MKINITCPIO"; then
  echo "  already present"
elif ! grep -qE '^FILES=\([^)]*\)$' "$MKINITCPIO"; then
  die "FILES= in $MKINITCPIO is not a single-line array; add $fw_path by hand"
elif [[ $apply ]]; then
  cp -n "$MKINITCPIO" "$MKINITCPIO.bak" 2>/dev/null || true
  sed -i -E "s@^FILES=\((.*)\)\$@FILES=(\1 $fw_path)@; s@FILES=\( @FILES=(@" "$MKINITCPIO"
  echo "  added $fw_path"
else
  echo "  would add $fw_path to FILES="
fi

echo "[5/5] regenerate initramfs/UKI"
findmnt -no TARGET /boot >/dev/null 2>&1 || die "/boot is not mounted; the UKI would not reach the ESP"
run mkinitcpio -P

echo
echo "done. reboot for cmdline changes to take effect."
echo "verify after reboot:"
echo "  cat /sys/module/drm/parameters/edid_firmware"
echo "  cat /sys/class/drm/card*-$CONNECTOR/status"
