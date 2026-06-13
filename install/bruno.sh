#!/bin/bash

log_info "Installing Bruno..."

if is_linux; then
    flatpak_install com.usebruno.Bruno
    init_local \
        "$ITERO_CONFIG/bruno/preferences.json" \
        "$HOME/.var/app/com.usebruno.Bruno/config/bruno/preferences.json"
elif is_macos; then
    brew_install --cask bruno
    init_local \
        "$ITERO_CONFIG/bruno/preferences.json" \
        "$HOME/Library/Application Support/Bruno/preferences.json"
fi
