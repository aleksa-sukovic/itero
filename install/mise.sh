if is_linux; then
    if ! command_exists mise; then
        dnf_enable_copr_repo "jdxcode/mise"
        dnf_install mise
    fi
elif is_macos; then
    brew_install mise
fi

link_file "$ITERO_CONFIG/mise/config.toml" "$HOME/.config/mise/config.toml"
mise install -yq
