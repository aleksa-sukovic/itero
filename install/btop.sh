if is_linux; then
    dnf_install btop
    install_desktop "$ITERO_CONFIG/btop/btop.desktop"
elif is_macos; then
    brew_install btop
fi

link_file "$ITERO_CONFIG/btop/btop.conf" "$HOME/.config/btop/btop.conf"
