if is_linux; then
    if ! command_exists lazydocker || should_update; then
        log_info "Installing lazydocker..."
        curl -sSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi
fi

link_file "$ITERO_CONFIG/lazydocker/config.yml" "$HOME/.config/lazydocker/config.yml"
