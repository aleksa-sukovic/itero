#!/bin/bash

if is_linux; then
    if ! command_exists syncthing || should_update; then
        # Download binary
        arch=$(uname -m)
        case "$arch" in
            x86_64)  arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac

        tarball="syncthing-linux-${arch}-v${ITERO_APP_VERSION_SYNCTHING}"
        url="https://github.com/syncthing/syncthing/releases/download/v${ITERO_APP_VERSION_SYNCTHING}/${tarball}.tar.gz"
        tmp=$(mktemp -d)

        log_info "Installing Syncthing v${ITERO_APP_VERSION_SYNCTHING}..."
        curl -fsSL "$url" | tar -xz -C "$tmp"

        mkdir -p "$HOME/.local/bin"

        # Stop the service before replacing the binary
        systemctl --user stop syncthing.service 2>/dev/null || true

        cp "$tmp/${tarball}/syncthing" "$HOME/.local/bin/syncthing"
        chmod +x "$HOME/.local/bin/syncthing"

        rm -rf "$tmp"
        log_ok "Installed Syncthing v${ITERO_APP_VERSION_SYNCTHING}"
    fi

    # Link service and enable
    mkdir -p "$HOME/.config/systemd/user"
    link_file "$ITERO_CONFIG/syncthing/syncthing.service" "$HOME/.config/systemd/user/syncthing.service"

    systemctl --user daemon-reload
    systemctl --user enable --now syncthing.service 2>/dev/null

    # Install desktop file and launcher script
    chmod +x "$ITERO_PATH/bin/itero-syncthing"
    install_desktop "$ITERO_CONFIG/syncthing/syncthing.desktop"
fi
