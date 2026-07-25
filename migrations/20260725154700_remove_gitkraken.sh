#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if ! is_linux; then
    exit 0
fi

if package_exists gitkraken; then
    log_info "Removing GitKraken..."
    sudo dnf remove -y -q gitkraken
    log_ok "GitKraken removed"
fi
