if ! is_linux; then
    return
fi

if ! command_exists vicinae; then
    dnf_enable_copr_repo "quadratech188/vicinae"
    dnf_install vicinae
fi

link_file "$ITERO_CONFIG/vicinae/settings.user.jsonc" "$HOME/.config/vicinae/settings.user.jsonc"
init_local "$ITERO_CONFIG/vicinae/settings.default.json" "$HOME/.config/vicinae/settings.json"

# Build and install a Vicinae extension without modifying its source directory.
install_vicinae_extension() {
    local extension_name="$1"
    local source_dir="$2"
    local destination_dir="$3"
    local build_dir

    build_dir="$(mktemp -d)"
    mkdir -p "$(dirname "$destination_dir")"
    rm -rf "$destination_dir"

    if ! cp -R "$source_dir"/. "$build_dir" || ! (
        cd "$build_dir"
        npm ci --quiet --no-fund --no-audit
        npm run build --silent -- --out "$destination_dir"
    ); then
        rm -rf "$build_dir"
        log_warn "Failed to install Vicinae extension: $extension_name"
        return 1
    fi

    rm -rf "$build_dir"
    log_ok "Installed Vicinae extension: $extension_name"
}

# Return successfully when any store extension is missing or an update was requested.
vicinae_store_extensions_need_install() {
    should_update && return 0

    for extension_name in "${vicinae_store_extensions[@]}"; do
        [ -f "$HOME/.local/share/vicinae/extensions/store.vicinae.$extension_name/package.json" ] || return 0
    done

    return 1
}

install_vicinae_extension \
    "theme-switcher" \
    "$ITERO_CONFIG/vicinae/extensions/theme-switcher" \
    "$HOME/.local/share/vicinae/extensions/theme-switcher" || return 1

vicinae_store_extensions=(
    "bluetooth"
    "gnome-dnd"
    "gnome-settings"
    "pulseaudio"
    "vscode-recents"
    "wifi-commander"
)

if vicinae_store_extensions_need_install; then
    vicinae_store_dir="$(mktemp -d)"
    vicinae_repo_url="https://github.com/vicinaehq/extensions.git"

    if ! git clone --depth 1 --quiet "$vicinae_repo_url" "$vicinae_store_dir"; then
        rm -rf "$vicinae_store_dir"
        log_warn "Failed to download Vicinae store extensions"
        return 1
    fi

    for extension_name in "${vicinae_store_extensions[@]}"; do
        if ! install_vicinae_extension \
            "$extension_name" \
            "$vicinae_store_dir/extensions/$extension_name" \
            "$HOME/.local/share/vicinae/extensions/store.vicinae.$extension_name"; then
            rm -rf "$vicinae_store_dir"
            return 1
        fi
    done

    rm -rf "$vicinae_store_dir"
fi
