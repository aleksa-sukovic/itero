if is_linux; then
    if ! command_exists vicinae; then
        dnf_enable_copr_repo "quadratech188/vicinae"
        dnf_install vicinae
    fi
fi

link_file "$ITERO_CONFIG/vicinae/settings.user.jsonc" "$HOME/.config/vicinae/settings.user.jsonc"
init_local "$ITERO_CONFIG/vicinae/settings.default.json" "$HOME/.config/vicinae/settings.json"

# Setup Vicinae theme switcher extension
local vicinae_extensions_dir="$HOME/.local/share/vicinae/extensions"
local vicinae_extension_name="theme-switcher"

local vicinae_extension_source_dir="$ITERO_CONFIG/vicinae/extensions/$vicinae_extension_name"
local vicinae_extension_dest_dir="$vicinae_extensions_dir/$vicinae_extension_name"

mkdir -p "$vicinae_extensions_dir"

local vicinae_extension_build_dir
vicinae_extension_build_dir="$(mktemp -d)"

rm -rf "$vicinae_extension_dest_dir"

(
    cp -R "$vicinae_extension_source_dir"/. "$vicinae_extension_build_dir"
    cd "$vicinae_extension_build_dir"
    npm ci --quiet --no-fund --no-audit
    npm run build --silent
)

rm -rf "$vicinae_extension_build_dir"
log_ok "Installed Vicinae extension: $vicinae_extension_name"
