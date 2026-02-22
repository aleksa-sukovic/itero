#!/bin/bash
SYNCTHING_VERSION="2.0.13"

if is_linux; then
    if ! command_exists syncthing || should_update; then
        # Download binary
        arch=$(uname -m)
        case "$arch" in
            x86_64)  arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac

        tarball="syncthing-linux-${arch}-v${SYNCTHING_VERSION}"
        url="https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/${tarball}.tar.gz"
        tmp=$(mktemp -d)

        log_info "Installing Syncthing v${SYNCTHING_VERSION}..."
        curl -fsSL "$url" | tar -xz -C "$tmp"

        mkdir -p "$HOME/.local/bin"
        cp "$tmp/${tarball}/syncthing" "$HOME/.local/bin/syncthing"
        chmod +x "$HOME/.local/bin/syncthing"

        rm -rf "$tmp"
        log_ok "Installed Syncthing v${SYNCTHING_VERSION}"
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
