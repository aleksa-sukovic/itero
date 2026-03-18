if is_linux; then
    if ! command_exists ya; then
        log_info "Installing yazi..."
        dnf_enable_copr_repo "lihaohong/yazi"
        dnf_install yazi
    fi

    install_desktop "$ITERO_CONFIG/yazi/yazi.desktop"
elif is_macos; then
    brew_install yazi
fi

link_mirror "$ITERO_CONFIG/yazi" "$HOME/.config/yazi"

if file_has_changed "$ITERO_CONFIG/yazi/package.toml" true; then
    if ! ya pkg install; then
        log_warn "Failed to install yazi packages"
        return 1
    fi
fi
