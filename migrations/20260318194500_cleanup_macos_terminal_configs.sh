#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if ! is_macos; then
    exit 0
fi

cleanup_path() {
    local path="$1"

    if [ -L "$path" ] || [ -e "$path" ]; then
        rm -rf "$path"
        log_ok "Removed: $path"
    fi
}

log_info "Cleaning up existing macOS terminal config targets"

cleanup_path "$HOME/.config/wezterm"
cleanup_path "$HOME/.config/starship.toml"
cleanup_path "$HOME/.config/mise"
cleanup_path "$HOME/.config/nvim"
cleanup_path "$HOME/.tmux.conf"
cleanup_path "$HOME/.config/yazi"
cleanup_path "$HOME/.config/lazygit"
cleanup_path "$HOME/.config/lazydocker"
cleanup_path "$HOME/.config/fastfetch"
cleanup_path "$HOME/.config/btop"
cleanup_path "$HOME/.zshrc"
cleanup_path "$HOME/.functions"
