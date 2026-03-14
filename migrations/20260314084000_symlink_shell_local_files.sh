#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

migrate_shell_local_file() {
    local repo_path="$1"
    local home_path="$2"

    if [ -L "$repo_path" ] && [ "$(readlink "$repo_path")" = "$home_path" ]; then
        return 0
    fi

    if [ ! -e "$home_path" ] && [ -f "$repo_path" ] && [ ! -L "$repo_path" ]; then
        mkdir -p "$(dirname "$home_path")"
        mv "$repo_path" "$home_path"
        log_ok "Moved: $home_path"
    elif [ -L "$repo_path" ] || [ -e "$repo_path" ]; then
        rm -f "$repo_path"
    fi

    if [ -e "$home_path" ]; then
        mkdir -p "$(dirname "$repo_path")"
        ln -s "$home_path" "$repo_path"
        log_ok "Linked: $repo_path"
    fi
}

migrate_shell_local_file \
    "$ITERO_PATH/config/shell/zshrc.local" \
    "$HOME/.zshrc.local"

migrate_shell_local_file \
    "$ITERO_PATH/config/shell/functions.local" \
    "$HOME/.functions.local"
