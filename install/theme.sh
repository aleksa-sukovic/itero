#!/bin/bash

chmod +x "$ITERO_PATH/bin/itero-theme"
chmod +x "$ITERO_PATH/bin/itero-theme-watch"

if is_linux; then
    # Install and enable the theme watcher service
    service_dir="$HOME/.config/systemd/user"

    mkdir -p "$service_dir"
    ln -nsf "$ITERO_CONFIG/systemd/itero-theme-watch.service" "$service_dir/itero-theme-watch.service"

    systemctl --user daemon-reload
    systemctl --user enable --now itero-theme-watch.service

    log_ok "Theme watcher enabled"
fi
