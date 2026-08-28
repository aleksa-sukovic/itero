#!/bin/bash
set -e

ITERO_PATH="${ITERO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ITERO_PATH/lib/helpers.sh"

if ! is_linux; then
    exit 0
fi

if package_exists yazi; then
    log_info "Removing DNF Yazi..."
    sudo dnf remove -y -q yazi
    log_ok "Removed DNF Yazi"
fi

if [ -f "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:lihaohong:yazi.repo" ]; then
    sudo dnf copr remove -y lihaohong/yazi
    log_ok "Removed lihaohong/yazi repository"
fi

rm -f "$HOME/.config/yazi/init.lua"
rm -rf "$HOME/.config/yazi/plugins/full-border.yazi"
