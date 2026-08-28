#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if is_linux; then
    rm -f "$HOME/.local/bin/buzz"
    rm -f "$HOME/.local/share/applications/buzz.desktop"
    rm -rf "$HOME/.local/share/buzz"
    log_ok "Removed Buzz"
elif is_macos && command_exists brew && brew list --cask block-buzz &>/dev/null; then
    brew uninstall --cask block-buzz
    log_ok "Removed Buzz"
fi
