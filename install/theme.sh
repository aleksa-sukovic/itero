#!/bin/bash

if is_linux; then
    chmod +x "$ITERO_PATH/bin/itero-theme"
    chmod +x "$ITERO_PATH/bin/itero-theme-watch"

    # Install and enable the theme watcher service
    local service_dir="$HOME/.config/systemd/user"

    mkdir -p "$service_dir"
    ln -nsf "$ITERO_CONFIG/systemd/itero-theme-watch.service" "$service_dir/itero-theme-watch.service"

    systemctl --user daemon-reload
    systemctl --user enable --now itero-theme-watch.service

    log_ok "Theme watcher enabled"
fi
