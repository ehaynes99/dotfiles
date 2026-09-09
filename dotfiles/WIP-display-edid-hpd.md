# WIP: KVM display EDID / HPD handling

**Temporary handoff doc.** Delete when `.config/display` is proven working and
the branch merges. Branch: `display-edid-hpd`.

## Why this exists

One Acer CZ340CK ultrawide is shared across 3–4 machines through an HDMI KVM.
All the machines run this same Arch + dotfiles setup. **DisplayPort is not an
option** — half the machines have no DP output. That rules out Level1Techs and
ConnectPRO, the only KVM brands with decent reputations, since both are
DP-only.

The plan is therefore to buy a plain HDMI KVM and solve EDID/HPD in the kernel
rather than paying for hardware EDID emulation.

Two problems to solve, and only the first is confirmed real on the hardware:

1. **Wake-from-sleep.** With the previously-owned KVM (returned 2026-09-08, but
   otherwise fine and the likely re-purchase), pressing a key woke the machine
   but the monitor stayed undetected until the input was toggled away and back.
   That is HPD not being re-asserted.
2. **Window reshuffle on switch.** When the KVM switches to another machine,
   the connector drops, the compositor tears the output down, and windows get
   rearranged. This is the thing hardware EDID emulation normally buys you.

## What is in the repo now

```
~/.config/display/
  edid/acer-cz340ck.bin      256-byte EDID dumped from the live monitor
  system-sleep/drm-reprobe   resume hook, fixes problem 1
  hosts/eh-work.conf         per-host: connector, blob, force-enable flag
  install.sh                 dry-run by default, --apply to write
```

Nothing has been installed to the system yet. `install.sh` has only been
dry-run. **It has never been run with `--apply`.**

## The two mechanisms

**Problem 1 — resume hook.** `/sys/class/drm/card*-*/status` is root-writable;
writing `detect` forces a re-probe, which is what toggling the input was doing
by hand. The hook does that for every connector after resume. Safe on laptops
and safe with nothing plugged in.

**Problem 2 — EDID pinning.** Needs all of:

- the blob at `/usr/lib/firmware/edid/acer-cz340ck.bin`
- `drm.edid_firmware=HDMI-A-1:edid/acer-cz340ck.bin video=HDMI-A-1:e` in
  `/etc/kernel/cmdline`
- that same path in `FILES=` in `/etc/mkinitcpio.conf`, because `HOOKS`
  contains `kms`, so the blob is needed before the encrypted root unlocks
- `mkinitcpio -P` to rebuild the UKI

`install.sh` does all four, idempotently.

## Facts worth not rediscovering

- The kernel parameter is `drm.edid_firmware`, **not** the older
  `drm_kms_helper.edid_firmware`. Confirmed via
  `/sys/module/drm/parameters/edid_firmware`.
- Connector is `HDMI-A-1` on amdgpu (Granite Ridge iGPU, `card1`). Monitor
  reports 3440x1440@75 over HDMI. The Acer's DP is only 1.2.
- `/boot` **is** mounted (`/dev/nvme0n1p1`, ~940M free) and the mkinitcpio
  preset writes UKIs to `/boot/EFI/Linux/`. It reads as empty to a non-root
  `ls` because the ESP is mounted root-only — don't conclude it's unmounted.
- `hostname` is not installed on this system; `install.sh` uses `uname -n`.
- The monitor does **not** answer DDC/CI through a KVM: EDID reads fine at I²C
  0x50 but 0x37 is dead (`EIO`). Whether the panel supports DDC/CI at all is
  still unknown — it was never tested with a direct connection. If it does,
  `ddcutil setvcp 60` input switching plus a USB switch is a viable alternative
  to a KVM entirely, using the monitor's 4 inputs.
- `i2c-dev` must be loaded for any `ddcutil` work.

## Open questions

- **Does writing `detect` actually emit the uevent niri needs?** Untested — the
  KVM was already returned. Verify before relying on it. Manual check:
  `echo detect | sudo tee /sys/class/drm/card1-HDMI-A-1/status`.
- **Does `video=HDMI-A-1:e` alone fix problem 1**, making the resume hook
  redundant? Plausible, unverified.
- `drm.edid_firmware` without `:e` is believed not to force connected state,
  only to override EDID on an already-detected connector. Unverified.

## Next steps

1. Order the HDMI KVM.
2. `~/.config/display/install.sh` (dry run), then `sudo … --apply`, reboot.
3. Test: switch away and back, then sleep/wake. Confirm windows stay put and
   the monitor comes back without toggling the input.
4. For any laptop, add `hosts/<name>.conf` with `FORCE_ENABLE=no` — the `:e`
   force fabricates a phantom 3440x1440 display when undocked.
5. Delete this file.

## Unrelated loose ends from the same session

- The KVM being returned was a different, much worse unit: it caused ~150–1500 ms
  mouse stalls, confirmed at the evdev layer (so not niri/amdgpu). Not fixed by
  USB autosuspend pinning or by quieting 2.4 GHz (wpa_supplicant/bluetooth).
  Cause never isolated further; the switch is going back.
- `rfkill block bluetooth` was applied during that debugging and **persists
  across reboots**. Undo with `rfkill unblock bluetooth` if bluetooth is wanted.
- `wpa_supplicant` was stopped. Wifi was disconnected anyway.
