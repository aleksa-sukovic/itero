#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

extension="rounded-window-corners@fxgn"

if command_exists gnome-extensions; then
    gnome-extensions disable "$extension" &>/dev/null || true
    gnome-extensions uninstall "$extension" &>/dev/null || true
fi

dconf reset -f "/org/gnome/shell/extensions/rounded-window-corners-reborn/" &>/dev/null || true
rm -rf "$HOME/.local/share/gnome-shell/extensions/$extension"
