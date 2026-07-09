#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if ! is_linux; then
    exit 0
fi

log_info "Cleaning up previous Pop Shell extension installation"

if command_exists gnome-extensions; then
    gnome-extensions disable "pop-shell@system76.com" &>/dev/null || true
fi

cleanup_path() {
    local path="$1"

    if [ -L "$path" ] || [ -e "$path" ]; then
        rm -rf "$path"
        log_ok "Removed: $path"
    fi
}

cleanup_path "$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com"
cleanup_path "$HOME/.config/pop-shell"
