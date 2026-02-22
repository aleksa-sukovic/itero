if is_linux; then
    dnf_install fastfetch
fi

link_file "$ITERO_CONFIG/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
link_file "$ITERO_CONFIG/fastfetch/logo.txt" "$HOME/.config/fastfetch/logo.txt"
