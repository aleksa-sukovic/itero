if is_linux; then
    if ! command_exists vicinae; then
        dnf_enable_copr_repo "quadratech188/vicinae"
        dnf_install vicinae
    fi
fi

link_file "$ITERO_CONFIG/vicinae/settings.user.jsonc" "$HOME/.config/vicinae/settings.user.jsonc"
init_local "$ITERO_CONFIG/vicinae/settings.default.json" "$HOME/.config/vicinae/settings.json"

