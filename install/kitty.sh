if is_linux; then
    if ! command_exists kitty; then
        log_info "Installing kitty..."
        dnf_install kitty
    fi
elif is_macos; then
    brew_install --cask kitty
fi

link_mirror "$ITERO_CONFIG/kitty" "$HOME/.config/kitty"
