#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if is_linux && package_exists kitty; then
    log_info "Removing Kitty..."
    sudo dnf remove -y -q kitty
    log_ok "Kitty removed"
elif is_macos && command_exists brew && brew list --cask kitty &>/dev/null; then
    log_info "Removing Kitty..."
    brew uninstall --cask kitty
    log_ok "Kitty removed"
fi

copilot_path="$HOME/.local/bin/copilot"
if [ -f "$copilot_path" ]; then
    log_info "Removing Copilot..."
    rm "$copilot_path"
    log_ok "Copilot removed"
fi

kitty_config="$HOME/.config/kitty"
if [ -d "$kitty_config" ]; then
    while IFS= read -r -d '' link; do
        if [[ "$(readlink "$link")" == "$ITERO_PATH"/* ]]; then
            rm "$link"
        fi
    done < <(find "$kitty_config" -type l -print0)

    rmdir "$kitty_config" 2>/dev/null || true
fi
