if is_linux; then
    if ! command_exists starship; then
        dnf_enable_copr_repo "atim/starship"
        dnf_install starship
    fi
fi

link_file "$ITERO_CONFIG/starship/starship.toml" "$HOME/.config/starship.toml"
