#!/bin/bash

if is_linux; then
    log_info "Installing GUI/desktop applications..."

    # GUI applications
    dnf_install \
        libreoffice \
        firefox \
        chromium \
        texlive-scheme-full

    # Set Firefox as default browser
    xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
    xdg-mime default firefox.desktop x-scheme-handler/http 2>/dev/null || true
    xdg-mime default firefox.desktop x-scheme-handler/https 2>/dev/null || true

    # Ensure Firefox window class maps correctly for window switchers
    firefox_desktop_file="$HOME/.local/share/applications/org.mozilla.firefox.desktop"
    if [ -f "$firefox_desktop_file" ]; then
        if grep -q "^StartupWMClass=" "$firefox_desktop_file"; then
            set_config_value "$firefox_desktop_file" "StartupWMClass" "org.mozilla.firefox"
        else
            sed -i "/^\[Desktop Entry\]$/a StartupWMClass=org.mozilla.firefox" "$firefox_desktop_file"
        fi
    fi

    # Ensure flatpak is installed before installing flatpak applications
    dnf_install flatpak

    # Add flathub repo if flatpak was just installed
    if ! flatpak remotes | grep -q flathub; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        log_ok "Added flathub remote"
    fi

    # Flatpak applications
    flatpak_install org.videolan.VLC
    flatpak_install org.zotero.Zotero
    flatpak_install md.obsidian.Obsidian
    flatpak_install com.calibre_ebook.calibre
    flatpak_install ca.desrt.dconf-editor
    flatpak_install dev.qwery.AddWater
fi
