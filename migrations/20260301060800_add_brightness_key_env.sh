#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

env_file="$ITERO_PATH/.env"

if ! grep -q "BRIGHTNESS_KEY_UP" "$env_file"; then
    printf '\n# External monitor brightness shortcuts\n' >> "$env_file"
    printf 'BRIGHTNESS_KEY_UP=<Super>MonBrightnessUp\n' >> "$env_file"
    printf 'BRIGHTNESS_KEY_DOWN=<Super>MonBrightnessDown\n' >> "$env_file"
    log_ok "Added brightness key defaults to .env"
fi
