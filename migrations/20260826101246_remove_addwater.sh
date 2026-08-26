#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if ! is_linux || ! command_exists flatpak; then
    exit 0
fi

app_id="dev.qwery.AddWater"

if flatpak list --app --columns=application | grep -Fxq "$app_id"; then
    log_info "Removing AddWater..."
    flatpak uninstall -y "$app_id"
    log_ok "AddWater removed"
fi
