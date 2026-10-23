if is_linux; then
    if ! command_exists mise; then
        log_warn "Mise is required to install Yazi"
        return 1
    fi

    if ! mise which yazi --tool yazi@latest &>/dev/null || should_update; then
        log_info "Installing Yazi with Mise..."
        if ! mise install -yq yazi@latest; then
            log_warn "Failed to install Yazi with Mise"
            return 1
        fi
        log_ok "Installed Yazi with Mise"
    fi

    if ! yazi_bin="$(mise which yazi --tool yazi@latest)" \
        || ! ya_bin="$(mise which ya --tool yazi@latest)"; then
        log_warn "Failed to locate Yazi binaries installed by Mise"
        return 1
    fi

    mkdir -p "$HOME/.local/bin"
    ln -nsf "$yazi_bin" "$HOME/.local/bin/yazi"
    ln -nsf "$ya_bin" "$HOME/.local/bin/ya"

    install_desktop "$ITERO_CONFIG/yazi/yazi.desktop"
elif is_macos; then
    brew_install yazi
fi

rm -f "$HOME/.config/yazi/theme.toml"
link_mirror "$ITERO_CONFIG/yazi" "$HOME/.config/yazi"

if should_update; then
    if ! ya pkg upgrade --discard; then
        log_warn "Failed to upgrade Yazi packages"
        return 1
    fi
fi

if file_has_changed "$ITERO_CONFIG/yazi/package.toml" false; then
    if ! ya pkg install; then
        log_warn "Failed to install yazi packages"
        return 1
    fi

    file_has_changed "$ITERO_CONFIG/yazi/package.toml" true
fi
