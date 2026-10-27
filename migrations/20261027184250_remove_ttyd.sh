#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if is_linux && package_exists ttyd; then
    log_info "Removing ttyd..."
    sudo dnf remove -y -q ttyd
    log_ok "Removed ttyd"
fi
