#!/bin/bash
# The DMS bar reserves an exclusive zone at the top of the output. flameshot's
# capture window is sized to the full monitor resolution, so niri clamps it
# below the bar without shrinking the image it displays, pushing the bottom
# of the screenshot (and flameshot's own toolbar) off the visible window.
# Hiding the bar removes the reserved zone so flameshot gets the full height.
dms ipc call bar hide index 0
flameshot gui
dms ipc call bar reveal index 0
