if ! is_linux; then
    return 0
fi

log_info "Setting up GNOME..."

GNOME_EXTENSIONS=(
    "custom-hot-corners-extended@G-dH.github.com"
    "gsconnect@andyholmes.github.io"
    "lockkeys@vaina.lt"
    "night-light-slider-updated@vilsbeg.codeberg.org"
    "vicinae@dagimg-dot"
)

# Install Extension Manager for managing extensions via GUI
flatpak_install "com.mattjakeman.ExtensionManager"

# Setup tiling window management
local pop_shell_repo="https://aleksa-sukovic:$GITHUB_TOKEN@github.com/aleksa-sukovic/itero-wm.git"
local pop_shell_dir="$HOME/.local/share/itero-sources/itero-wm"
local pop_shell_dest="$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com"

if [[ ! -d "$pop_shell_dir" ]]; then
    git clone -b master "$pop_shell_repo" "$pop_shell_dir"
fi

if [[ ! -d "$pop_shell_dest" ]] || should_update; then
    cd "$pop_shell_dir"
    git pull --ff-only
    make
    make install
    cd "$ITERO_PATH"
    log_ok "Installed Pop Shell from fork"
fi

# Install system-wide schemas for dconf settings to work
sudo cp "$pop_shell_dir/schemas/org.gnome.shell.extensions.pop-shell.gschema.xml" \
    /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

rm -f "$HOME/.config/pop-shell/config.json"
link_file "$ITERO_CONFIG/gnome/pop-shell.json" "$HOME/.config/pop-shell/config.json"

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
