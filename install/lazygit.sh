if is_linux; then
    if ! command_exists lazygit; then
        log_info "Installing lazygit..."
        dnf_enable_copr_repo "dejan/lazygit"
        dnf_install lazygit
    fi

    if ! command_exists delta; then
        log_info "Installing delta..."
        dnf_install git-delta
    fi
elif is_macos; then
    brew_install lazygit git-delta
fi

link_file "$ITERO_CONFIG/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
