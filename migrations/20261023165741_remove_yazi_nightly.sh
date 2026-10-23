#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if ! is_linux; then
    exit 0
fi

yazi_dir="$HOME/.local/share/yazi-nightly"
removed=false

for binary in yazi ya; do
    binary_path="$HOME/.local/bin/$binary"
    if [ -L "$binary_path" ] && [[ "$(readlink "$binary_path")" == "$yazi_dir/"* ]]; then
        rm -f "$binary_path"
        removed=true
    fi
done

if [ -d "$yazi_dir" ]; then
    rm -rf "$yazi_dir"
    removed=true
fi

if [ "$removed" = true ]; then
    log_ok "Removed Yazi nightly installation"
fi
