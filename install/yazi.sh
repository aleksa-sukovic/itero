if is_linux; then
    if ! command_exists ya; then
        log_info "Installing yazi..."
        dnf_enable_copr_repo "lihaohong/yazi"
        dnf_install yazi
    fi

    install_desktop "$ITERO_CONFIG/yazi/yazi.desktop"
fi

link_mirror "$ITERO_CONFIG/yazi" "$HOME/.config/yazi"

if file_has_changed "$ITERO_CONFIG/yazi/package.toml" true; then
    ya pkg install 2>/dev/null || true
fi
