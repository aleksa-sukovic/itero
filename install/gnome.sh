if ! is_linux; then
    return 0
fi

log_info "Setting up GNOME..."

GNOME_EXTENSIONS=(
    "custom-hot-corners-extended@G-dH.github.com"
    "gsconnect@andyholmes.github.io"
    "lockkeys@vaina.lt"
    "night-light-slider-updated@vilsbeg.codeberg.org"
    "rounded-window-corners@fxgn"
    "vicinae@dagimg-dot"
)

# Install Extension Manager for managing extensions via GUI
flatpak_install "com.mattjakeman.ExtensionManager"

# Set up tiling window management via IteroWM
local itero_wm_repo="https://aleksa-sukovic:$GITHUB_TOKEN@github.com/aleksa-sukovic/itero-wm.git"
local itero_wm_dir="$HOME/.local/share/itero-sources/itero-wm"
# IteroWM still uses the upstream extension ID for GNOME integration
local itero_wm_config_dir="$HOME/.config/pop-shell"
local itero_wm_schema="org.gnome.shell.extensions.pop-shell.gschema.xml"

if [[ ! -d "$itero_wm_dir" ]]; then
    git clone -b master "$itero_wm_repo" "$itero_wm_dir"
fi

cd "$itero_wm_dir"
git pull --ff-only
make
make install
cd "$ITERO_PATH"
log_ok "Installed IteroWM from fork"

# Install system-wide schemas for dconf settings to work
sudo cp "$itero_wm_dir/schemas/$itero_wm_schema" \
    /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

rm -f "$itero_wm_config_dir/config.json"
link_file "$ITERO_CONFIG/gnome/pop-shell.json" "$itero_wm_config_dir/config.json"

# Install extensions that are not yet installed
for ext in "${GNOME_EXTENSIONS[@]}"; do
    if ! gnome-extensions info "$ext" &>/dev/null; then
        log_info "Installing extension: $ext"
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions \
            org.gnome.Shell.Extensions InstallRemoteExtension s "$ext" 2>/dev/null || \
            log_warn "Failed to install $ext (install manually via Extension Manager)"
    fi
done

# Setup autostart
mkdir -p "$HOME/.config/autostart"
link_file "/usr/share/applications/vicinae.desktop" "$HOME/.config/autostart/vicinae.desktop"

# Load dconf settings
local dconf_file="$ITERO_CONFIG/gnome/dconf.ini"
if [[ -f "$dconf_file" ]]; then
    if file_has_changed "$dconf_file" || should_update; then
        dconf load / < "$dconf_file"
        log_ok "Loaded GNOME dconf settings"
    fi
fi

log_ok "GNOME setup complete"
