if ! is_linux; then
    return 0
fi

log_info "Installing screenshot tools..."

dnf_install flameshot

link_file "$ITERO_CONFIG/flameshot/flameshot.ini" "$HOME/.config/flameshot/flameshot.ini"
