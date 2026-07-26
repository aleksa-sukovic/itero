if is_linux; then
    if ! command_exists vicinae; then
        dnf_enable_copr_repo "quadratech188/vicinae"
        dnf_install vicinae
    fi
fi

link_file "$ITERO_CONFIG/vicinae/settings.user.jsonc" "$HOME/.config/vicinae/settings.user.jsonc"
init_local "$ITERO_CONFIG/vicinae/settings.default.json" "$HOME/.config/vicinae/settings.json"

# Build and install a bundled Vicinae extension
install_vicinae_extension() {
    local extension_name="$1"
    local extensions_dir="$HOME/.local/share/vicinae/extensions"
    local source_dir="$ITERO_CONFIG/vicinae/extensions/$extension_name"
    local destination_dir="$extensions_dir/$extension_name"
    local build_dir

    mkdir -p "$extensions_dir"
    build_dir="$(mktemp -d)"

    rm -rf "$destination_dir"

    (
        cp -R "$source_dir"/. "$build_dir"
        cd "$build_dir"
        npm ci --quiet --no-fund --no-audit
        npm run build --silent
    )

    rm -rf "$build_dir"
    log_ok "Installed Vicinae extension: $extension_name"
}

install_vicinae_extension "theme-switcher"
install_vicinae_extension "monitor-control"
install_vicinae_extension "audio-device-switcher"
