#!/usr/bin/env bash
export XDG_DATA_DIRS=${XDG_DATA_DIRS-/usr/local/share:/usr/share}
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/$USER/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"

