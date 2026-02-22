if is_linux; then
    if ! command_exists wezterm; then
        log_info "Installing wezterm..."
        dnf_enable_copr_repo "wezfurlong/wezterm-nightly"
        dnf_install wezterm
    fi
fi

link_mirror "$ITERO_CONFIG/wezterm" "$HOME/.config/wezterm"
